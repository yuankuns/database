-- Phase scaffold for the AQ controller. Apply with its matching core.
DROP PROCEDURE IF EXISTS `update_mangos`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SHOW ERRORS;
        SELECT '* UPDATE FAILED *' AS `===== Status =====`,
               @cCurResult AS `===== DB is on Version: =====`;
        RESIGNAL;
    END;

    SET @cCurVersion := (SELECT `version` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cCurStructure := (SELECT `structure` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cCurContent := (SELECT `content` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);

    SET @cOldVersion = '22';
    SET @cOldStructure = '06';
    SET @cOldContent = '004';

    SET @cNewVersion = '22';
    SET @cNewStructure = '06';
    SET @cNewContent = '005';
    SET @cNewDescription = 'AQ_War_Effort_Phases';
    SET @cNewComment = 'Add manually controlled AQ war effort phases';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        START TRANSACTION;

        -- The source has multiple phase links per spawn, while this core has
        -- one event per GUID. 128 spans all five phases and 129 spans the
        -- first four. Existing event-22 spawns are retained and reassigned.
        IF EXISTS (SELECT 1 FROM `game_event` WHERE `entry` BETWEEN 120 AND 129
                   AND (NOT (`description` <=> CASE `entry`
                     WHEN 120 THEN 'AQ War Effort Phase 1 Item collection'
                     WHEN 121 THEN 'AQ War Effort Phase 2 Transportation'
                     WHEN 122 THEN 'AQ War Effort Phase 3 Gong'
                     WHEN 123 THEN 'AQ War Effort Phase 4 10 Hour War'
                     WHEN 124 THEN 'AQ War Effort Phase 5 Done'
                     WHEN 125 THEN 'AQ War Effort Ashi dead'
                     WHEN 126 THEN 'AQ War Effort Regal dead'
                     WHEN 127 THEN 'AQ War Effort Zora dead'
                     WHEN 128 THEN 'AQ War Effort Shared All Phases'
                     WHEN 129 THEN 'AQ War Effort Shared Pre-Completion'
                   END) OR `occurence`<>525600 OR `length`<>1 OR `holiday`<>0 OR
                   `start_time`<>'2000-01-01 00:00:00' OR `end_time`<>'2000-01-01 00:00:01')) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ event ID conflict';
        END IF;
        IF (SELECT COUNT(*) FROM `quest_template` WHERE `entry` IN
            (8743,8795,8857,8858,8859)) <> 5 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ required quest templates missing';
        END IF;

        IF (SELECT COUNT(*) FROM `creature` WHERE (`guid`,`id`) IN
            ((38,15763),(2032,15764),(6519,15765),(6520,15761),
             (25997,15767),(32076,15768),(46803,15762),(79695,15766),
             (86424,15708))) <> 9 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ existing NPC GUIDs differ';
        END IF;
        IF (SELECT COUNT(*) FROM `gameobject` WHERE (`guid`,`id`) IN
            ((29294,180598),(29299,180681),(29300,180680),(29301,180679),
             (632441,180826),(632442,180832),(632443,180838),
             (632444,180818),(632445,180812))) <> 9 OR
           NOT EXISTS (SELECT 1 FROM `gameobject` WHERE `guid`=49451 AND `id` IN (180717,180718)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ existing gameobject GUIDs differ';
        END IF;
        IF (SELECT COUNT(*) FROM `game_event_creature` WHERE `guid` IN
            (38,2032,6519,6520,25997,32076,46803,79695,86424)
            AND `event` IN (22,128,129)) <> 9 OR
           EXISTS (SELECT 1 FROM `game_event_creature`
             WHERE (`guid` IN (38,2032,6519,6520,25997,32076,46803,79695) AND `event` NOT IN (22,128)) OR
                   (`guid`=86424 AND `event` NOT IN (22,129))) OR
           (SELECT COUNT(*) FROM `game_event_gameobject` WHERE `guid` IN
            (29294,29299,29300,29301,632441,632442,632443,632444,632445)
            AND `event` IN (22,120)) <> 9 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ existing event bindings differ';
        END IF;

        -- Reject dormant or custom links that would become active under the
        -- new IDs. Only partial writes of this migration are accepted here.
        IF EXISTS (SELECT 1 FROM `game_event_creature` WHERE ABS(`event`) BETWEEN 120 AND 129 AND NOT
                     ((`event`=128 AND `guid` IN (38,2032,6519,6520,25997,32076,46803,79695)) OR
                      (`event`=129 AND `guid`=86424))) OR
           EXISTS (SELECT 1 FROM `game_event_gameobject` WHERE ABS(`event`) BETWEEN 120 AND 129 AND NOT
                     (`event`=120 AND `guid` IN (29294,29299,29300,29301,632441,632442,632443,632444,632445))) OR
           EXISTS (SELECT 1 FROM `game_event_quest` WHERE `event` BETWEEN 120 AND 129 AND NOT
                     ((`quest`=8795 AND `event`=129) OR (`quest`=8743 AND `event` IN (122,123)) OR
                      (`quest`=8857 AND `event`=125) OR (`quest`=8858 AND `event`=126) OR
                      (`quest`=8859 AND `event`=127))) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ new event IDs already have unrelated bindings';
        END IF;

        IF EXISTS (SELECT 1 FROM `script_binding` WHERE `type`=0
                   AND `bind` IN (15740,15741,15742)
                   AND `ScriptName` <> 'npc_aq_war_colossus') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ colossus script binding conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `script_binding` WHERE `ScriptName`='npc_aq_war_colossus'
                   AND `bind` IN (15740,15741,15742) AND (`type`<>0 OR `data`<>0)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ colossus script binding metadata conflict';
        END IF;

        -- Finished windows prevent automatic calendar scheduling; the AQ
        -- controller explicitly owns these events.
        INSERT IGNORE INTO `game_event`
            (`entry`,`start_time`,`end_time`,`occurence`,`length`,`holiday`,`description`)
        VALUES
            (120,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Phase 1 Item collection'),
            (121,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Phase 2 Transportation'),
            (122,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Phase 3 Gong'),
            (123,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Phase 4 10 Hour War'),
            (124,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Phase 5 Done'),
            (125,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Ashi dead'),
            (126,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Regal dead'),
            (127,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Zora dead'),
            (128,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Shared All Phases'),
            (129,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Shared Pre-Completion');

        UPDATE `game_event_creature` SET `event`=128
          WHERE `guid` IN (38,2032,6519,6520,25997,32076,46803,79695);
        UPDATE `game_event_creature` SET `event`=129 WHERE `guid`=86424;
        UPDATE `game_event_gameobject` SET `event`=120
          WHERE `guid` IN (29294,29299,29300,29301,632441,632442,632443,632444,632445);
        -- 180718 is the decorative object; 180717 is the quest giver with the
        -- same display and position. The quest is enabled only during 122/123.
        UPDATE `gameobject` SET `id`=180717 WHERE `guid`=49451 AND `id`=180718;
        INSERT IGNORE INTO `script_binding` (`type`,`ScriptName`,`bind`,`data`) VALUES
          (0,'npc_aq_war_colossus',15740,0),
          (0,'npc_aq_war_colossus',15741,0),
          (0,'npc_aq_war_colossus',15742,0);
        DELETE FROM `game_event_quest` WHERE `quest`=8795 AND `event`=22;
        INSERT IGNORE INTO `game_event_quest` (`quest`,`event`) VALUES
          (8795,129),(8743,122),(8743,123),(8857,125),(8858,126),(8859,127);

        INSERT INTO `db_version` VALUES (@cNewVersion, @cNewStructure,
            @cNewContent, @cNewDescription, @cNewComment);
        SET @cNewResult := (SELECT `description` FROM `db_version`
            WHERE `version` = @cNewVersion AND `structure` = @cNewStructure
              AND `content` = @cNewContent);
        COMMIT;
        SELECT '* UPDATE COMPLETE *' AS `===== Status =====`,
               @cNewResult AS `===== DB is now on Version =====`;
    ELSE
        IF (@cCurResult = @cNewResult) THEN
            SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,
                   @cCurResult AS `===== DB is already on Version =====`;
        ELSE
            IF (@cCurResult IS NULL) THEN
                SELECT '* UPDATE FAILED *' AS `===== Status =====`,
                       'Unable to locate DB Version Information' AS `============= Error Message =============`;
            ELSE
                SET @cCurOutput = CONCAT(@cCurVersion, '_', @cCurStructure,
                    '_', @cCurContent, ' - ', @cCurResult);
                SET @cOldOutput = CONCAT(@cOldVersion, '_', @cOldStructure,
                    '_', @cOldContent, ' - ',
                    COALESCE(@cOldResult, 'IS NOT APPLIED'));
                SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,
                       @cOldOutput AS `=== Expected ===`,
                       @cCurOutput AS `===== Found Version =====`;
            END IF;
        END IF;
    END IF;
END $$

DELIMITER ;

CALL update_mangos();

DROP PROCEDURE IF EXISTS `update_mangos`;
