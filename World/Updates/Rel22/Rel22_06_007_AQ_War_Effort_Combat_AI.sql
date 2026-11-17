-- Basic AQ war creature combat actions adapted from CMaNGOS Classic DB
-- e4825cf48176edff313d78de66b0beb14371c8eb, GPL-2.0-or-later.
-- CMaNGOS's combat-action retry flag maps to this core's 0x10000 flag.
-- Self-centred battle shout/judgement implicit targets use Zero's self target.
-- CAST_PLAYER_ONLY maps to this core's player-only targets. Crystal root
-- action 61 maps to this core's persistent immobilization action 51. Other scripts
-- are intentionally excluded pending a separate compatibility port.
-- Requires the core's TARGET_T_NEAREST_AOE_TARGET and migration 22/06/006.
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
    SET @cOldContent = '006';

    SET @cNewVersion = '22';
    SET @cNewStructure = '06';
    SET @cNewContent = '007';
    SET @cNewDescription = 'AQ_War_Effort_Combat_AI';
    SET @cNewComment = 'Add AQ war effort basic combat AI';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        START TRANSACTION;

        -- These templates are unique to the AQ war and were unbound in the
        -- target snapshot. Reject custom AI rather than replacing it.
        IF (SELECT COUNT(*) FROM `creature_template` WHERE `entry` IN (15743,15744,15748,15749,15751,15752,15754,15756,15758,15759,15807,15808,15810,15811,15769,15770,15771,15804,15805,15853,15861)
            AND `AIName` IN ('','EventAI')) <> 21 OR
           EXISTS (SELECT 1 FROM `script_binding` WHERE `type`=0 AND `bind` IN (15743,15744,15748,15749,15751,15752,15754,15756,15758,15759,15807,15808,15810,15811,15769,15770,15771,15804,15805,15853,15861)) OR
           EXISTS (SELECT 1 FROM `creature_ai_scripts` WHERE `creature_id` IN (15743,15744,15748,15749,15751,15752,15754,15756,15758,15759,15807,15808,15810,15811,15769,15770,15771,15804,15805,15853,15861)
                   AND `id` NOT IN (1574301,1574302,1574303,1574304,1574401,1574402,1574403,1574404,1574405,1574801,1574802,1574803,1574901,1574902,1575101,1575102,1575103,1575201,1575202,1575401,1575402,1575403,1575601,1575602,1575801,1575802,1575803,1575901,1575902,1576901,1576902,1577001,1577002,1577101,1577102,1580401,1580402,1580501,1580502,1580701,1580702,1580703,1580801,1580802,1581001,1581002,1581003,1581101,1581102,1585301,1585302,1586101,1586102,1586103)) OR
           EXISTS (SELECT 1 FROM `creature_ai_scripts` WHERE `id` IN (1574301,1574302,1574303,1574304,1574401,1574402,1574403,1574404,1574405,1574801,1574802,1574803,1574901,1574902,1575101,1575102,1575103,1575201,1575202,1575401,1575402,1575403,1575601,1575602,1575801,1575802,1575803,1575901,1575902,1576901,1576902,1577001,1577002,1577101,1577102,1580401,1580402,1580501,1580502,1580701,1580702,1580703,1580801,1580802,1581001,1581002,1581003,1581101,1581102,1585301,1585302,1586101,1586102,1586103)
                   AND `creature_id` NOT IN (15743,15744,15748,15749,15751,15752,15754,15756,15758,15759,15807,15808,15810,15811,15769,15770,15771,15804,15805,15853,15861)) THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ combat AI conflict';
        END IF;
        UPDATE `creature_template` SET `AIName`='EventAI' WHERE `entry` IN (15743,15744,15748,15749,15751,15752,15754,15756,15758,15759,15807,15808,15810,15811,15769,15770,15771,15804,15805,15853,15861);
        INSERT IGNORE INTO `creature_ai_scripts` (`id`,`creature_id`,`event_type`,`event_inverse_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`action1_type`,`action1_param1`,`action1_param2`,`action1_param3`,`action2_type`,`action2_param1`,`action2_param2`,`action2_param3`,`action3_type`,`action3_param1`,`action3_param2`,`action3_param3`,`comment`) VALUES
          (1574301,15743,11,0,100,0,0,0,0,0,11,12980,0,0,11,18950,0,34,0,0,0,0,'AQ war effort combat'),
          (1574302,15743,0,0,100,65537,0,20000,30000,40000,11,16727,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574303,15743,0,0,100,65537,0,15000,30000,40000,11,18944,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574304,15743,0,0,100,65537,0,10000,20000,30000,11,19632,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574401,15744,11,0,100,0,0,0,0,0,11,12980,0,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574402,15744,0,0,100,65537,20000,40000,120000,140000,11,23772,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574403,15744,0,0,100,65537,10000,30000,25000,35000,11,19408,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574404,15744,0,0,100,65537,0,20000,8000,18000,11,19196,8,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574405,15744,0,0,100,65537,0,12000,6000,18000,11,17963,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574801,15748,0,0,100,65537,0,15000,12000,24000,11,11876,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574802,15748,0,0,100,65537,0,18000,8000,24000,11,11427,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574803,15748,0,0,100,65537,0,12000,6000,18000,11,17963,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574901,15749,0,0,100,65537,0,20000,12000,24000,11,6605,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1574902,15749,0,0,100,65537,0,12000,15000,18000,11,13445,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575101,15751,0,0,100,65537,0,15000,12000,24000,11,11876,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575102,15751,0,0,100,65537,0,18000,8000,24000,11,11427,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575103,15751,0,0,100,65537,0,12000,6000,18000,11,17963,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575201,15752,0,0,100,65537,0,20000,12000,24000,11,6605,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575202,15752,0,0,100,65537,0,12000,15000,18000,11,13445,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575401,15754,0,0,100,65537,0,15000,12000,24000,11,11876,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575402,15754,0,0,100,65537,0,18000,8000,24000,11,11427,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575403,15754,0,0,100,65537,0,12000,6000,18000,11,17963,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575601,15756,0,0,100,65537,0,20000,12000,24000,11,6605,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575602,15756,0,0,100,65537,0,12000,15000,18000,11,13445,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575801,15758,0,0,100,65537,0,15000,12000,24000,11,11876,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575802,15758,0,0,100,65537,0,18000,8000,24000,11,11427,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575803,15758,0,0,100,65537,0,12000,6000,18000,11,17963,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575901,15759,0,0,100,65537,0,20000,12000,24000,11,6605,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1575902,15759,0,0,100,65537,0,12000,15000,18000,11,13445,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1576901,15769,11,0,100,0,0,0,0,0,51,1,0,0,20,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1576902,15769,0,0,100,65537,0,5000,20000,40000,11,26195,9,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1577001,15770,11,0,100,0,0,0,0,0,51,1,0,0,20,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1577002,15770,0,0,100,65537,0,5000,20000,40000,11,26197,9,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1577101,15771,11,0,100,0,0,0,0,0,51,1,0,0,20,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1577102,15771,0,0,100,65537,0,5000,30000,60000,11,26198,9,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1580401,15804,11,0,100,0,0,0,0,0,51,1,0,0,20,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1580402,15804,0,0,100,65537,0,5000,20000,40000,11,26258,9,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1580501,15805,11,0,100,0,0,0,0,0,51,1,0,0,20,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1580502,15805,0,0,100,65537,0,5000,12000,24000,11,26259,9,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1580701,15807,0,0,100,65537,0,15000,12000,24000,11,11876,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1580702,15807,0,0,100,65537,0,18000,8000,24000,11,11427,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1580703,15807,0,0,100,65537,0,12000,6000,18000,11,17963,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1580801,15808,0,0,100,65537,0,20000,12000,24000,11,6605,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1580802,15808,0,0,100,65537,0,12000,15000,18000,11,13445,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1581001,15810,0,0,100,65537,0,15000,12000,24000,11,11876,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1581002,15810,0,0,100,65537,0,18000,8000,24000,11,11427,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1581003,15810,0,0,100,65537,0,12000,6000,18000,11,17963,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1581101,15811,0,0,100,65537,0,20000,12000,24000,11,6605,17,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1581102,15811,0,0,100,65537,0,12000,15000,18000,11,13445,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1585301,15853,0,0,100,65537,0,10000,30000,60000,11,9128,0,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1585302,15853,0,0,100,65537,0,20000,5000,15000,11,25710,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1586101,15861,0,0,100,65537,0,10000,30000,60000,11,9128,0,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1586102,15861,2,0,100,65537,75,0,5000,15000,11,20343,0,0,0,0,0,0,0,0,0,0,'AQ war effort combat'),
          (1586103,15861,0,0,100,65537,0,20000,5000,15000,11,25710,1,0,0,0,0,0,0,0,0,0,'AQ war effort combat');

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
