-- Localizable MaNGOS strings used by the AQ war effort controller.
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
    SET @cOldContent = '013';

    SET @cNewVersion = '22';
    SET @cNewStructure = '06';
    SET @cNewContent = '014';
    SET @cNewDescription = 'AQ_War_Effort_Repeatables';
    SET @cNewComment = 'Allow repeatable AQ donations';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        START TRANSACTION;

        -- All 30 follow-up quests must remain repeatable after their first turn-in.
        IF (SELECT COUNT(*) FROM `quest_template` WHERE `entry` IN (8493,8495,8500,8504,8506,8510,8512,8514,8516,8518,8521,8523,8525,8527,8529,8533,8543,8546,8550,8581,8583,8589,8591,8601,8605,8608,8610,8612,8614,8616) AND `Method`=0 AND `PrevQuestId`>0) <> 30 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ repeatable quest templates differ';
        END IF;
        IF (SELECT COUNT(*) FROM `quest_template` WHERE `entry` IN (8492,8493,8494,8495,8499,8500,8503,8504,8505,8506,8509,8510,8511,8512,8513,8514,8515,8516,8517,8518,8520,8521,8522,8523,8524,8525,8526,8527,8528,8529,8532,8533,8542,8543,8545,8546,8549,8550,8580,8581,8582,8583,8588,8589,8590,8591,8600,8601,8604,8605,8607,8608,8609,8610,8611,8612,8613,8614,8615,8616)) <> 60 OR
           EXISTS (SELECT 1 FROM `game_event_quest` WHERE `quest` IN (8492,8493,8494,8495,8499,8500,8503,8504,8505,8506,8509,8510,8511,8512,8513,8514,8515,8516,8517,8518,8520,8521,8522,8523,8524,8525,8526,8527,8528,8529,8532,8533,8542,8543,8545,8546,8549,8550,8580,8581,8582,8583,8588,8589,8590,8591,8600,8601,8604,8605,8607,8608,8609,8610,8611,8612,8613,8614,8615,8616) AND `event`<>120) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ donation quest event conflict';
        END IF;
        UPDATE `quest_template` SET `SpecialFlags`=`SpecialFlags` | 1 WHERE `entry` IN (8493,8495,8500,8504,8506,8510,8512,8514,8516,8518,8521,8523,8525,8527,8529,8533,8543,8546,8550,8581,8583,8589,8591,8601,8605,8608,8610,8612,8614,8616);

        INSERT IGNORE INTO `game_event_quest` (`quest`,`event`)
          SELECT `entry`,120 FROM `quest_template` WHERE `entry` IN (8492,8493,8494,8495,8499,8500,8503,8504,8505,8506,8509,8510,8511,8512,8513,8514,8515,8516,8517,8518,8520,8521,8522,8523,8524,8525,8526,8527,8528,8529,8532,8533,8542,8543,8545,8546,8549,8550,8580,8581,8582,8583,8588,8589,8590,8591,8600,8601,8604,8605,8607,8608,8609,8610,8611,8612,8613,8614,8615,8616);

        INSERT INTO `db_version` VALUES (@cNewVersion, @cNewStructure,
            @cNewContent, @cNewDescription, @cNewComment);
        COMMIT;
        SELECT '* UPDATE COMPLETE *' AS `===== Status =====`,
               @cNewDescription AS `===== DB is now on Version =====`;
    ELSE
        IF (@cCurResult = @cNewResult) THEN
            SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,
                   @cCurResult AS `===== DB is already on Version =====`;
        ELSE
            IF (@cCurResult IS NULL) THEN
                SELECT '* UPDATE FAILED *' AS `===== Status =====`,
                       'Unable to locate DB Version Information' AS `============= Error Message =============`;
            ELSE
                SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,
                       @cCurResult AS `===== Found Version =====`;
            END IF;
        END IF;
    END IF;
END $$

DELIMITER ;

CALL update_mangos();

DROP PROCEDURE IF EXISTS `update_mangos`;
