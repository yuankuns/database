-- AQ gate visuals; requires the matching controlled-event core.
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
    SET @cOldContent = '007';

    SET @cNewVersion = '22';
    SET @cNewStructure = '06';
    SET @cNewContent = '008';
    SET @cNewDescription = 'AQ_War_Effort_Gates';
    SET @cNewComment = 'Control AQ gates during the war effort';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        START TRANSACTION;

        -- Event 130 selects temporary closed copies. The original open gates
        -- use its negative binding, so they retain their current state when
        -- the controller is disabled and return at the first gong.
        IF EXISTS (SELECT 1 FROM `game_event` WHERE `entry`=130 AND
            (NOT (`description` <=> 'AQ War Effort Closed Gates') OR
             `occurence`<>525600 OR `length`<>1 OR `holiday`<>0)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ gate event ID conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `game_event_gameobject` WHERE ABS(`event`)=130 AND NOT
            ((`event`=-130 AND `guid` IN (66334,66335,66336)) OR
             (`event`=130 AND `guid` IN (800041,800042,800043)))) OR
           EXISTS (SELECT 1 FROM `game_event_creature` WHERE ABS(`event`)=130) OR
           EXISTS (SELECT 1 FROM `game_event_quest` WHERE `event`=130) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ gate event ID has unrelated bindings';
        END IF;
        IF (SELECT COUNT(*) FROM `gameobject` WHERE (`guid`,`id`,`state`) IN
            ((66334,176146,0),(66335,176147,0),(66336,176148,0))) <> 3 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ original open gates differ';
        END IF;
        IF EXISTS (SELECT 1 FROM `gameobject` g
            JOIN `gameobject` original ON original.guid=CASE g.guid
              WHEN 800041 THEN 66334 WHEN 800042 THEN 66335 ELSE 66336 END
            WHERE g.guid IN (800041,800042,800043) AND
              (g.id<>original.id OR g.map<>original.map OR g.state<>1 OR
               POW(g.position_x-original.position_x,2)+POW(g.position_y-original.position_y,2)+
               POW(g.position_z-original.position_z,2)>0.01)) OR
           EXISTS (SELECT 1 FROM `game_event_gameobject` WHERE
               (guid IN (66334,66335,66336) AND event<>-130) OR
               (guid IN (800041,800042,800043) AND event<>130)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ gate GUID or event conflict';
        END IF;
        INSERT IGNORE INTO `game_event`
          (`entry`,`start_time`,`end_time`,`occurence`,`length`,`holiday`,`description`)
          VALUES (130,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,
                  'AQ War Effort Closed Gates');
        INSERT IGNORE INTO `gameobject`
          (`guid`,`id`,`map`,`position_x`,`position_y`,`position_z`,`orientation`,
           `rotation0`,`rotation1`,`rotation2`,`rotation3`,`spawntimesecs`,`animprogress`,`state`)
          SELECT CASE guid WHEN 66334 THEN 800041 WHEN 66335 THEN 800042 ELSE 800043 END,
            id,map,position_x,position_y,position_z,orientation,rotation0,rotation1,
            rotation2,rotation3,spawntimesecs,animprogress,1
          FROM `gameobject` WHERE `guid` IN (66334,66335,66336);
        INSERT IGNORE INTO `game_event_gameobject` (`guid`,`event`) VALUES
          (66334,-130),(66335,-130),(66336,-130),
          (800041,130),(800042,130),(800043,130);

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
