-- Match the opening cinematic's allied and hostile forces to Classic data.
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
    SET @cOldContent = '010';
    SET @cNewVersion = '22';
    SET @cNewStructure = '06';
    SET @cNewContent = '011';
    SET @cNewDescription = 'AQ_Opening_Combatants';
    SET @cNewComment = 'Set factions, flags, and equipment for AQ opening forces';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        START TRANSACTION;

        IF (SELECT COUNT(*) FROM `creature_template` WHERE `entry` IN
            (15378,15379,15380,15381,15382,15414,15421,15422,15423,15424)) <> 10 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ opening creature template data missing';
        END IF;
        IF EXISTS (SELECT 1 FROM `creature_equip_template`
                   WHERE `entry`=2541 AND NOT (`equipentry1`=5747 AND `equipentry2`=0 AND `equipentry3`=0)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ Kaldorei equipment template ID conflict';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM `creature_item_template` WHERE `entry`=5747) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ Kaldorei weapon item data missing';
        END IF;

        INSERT IGNORE INTO `creature_equip_template` (`entry`,`equipentry1`,`equipentry2`,`equipentry3`)
          VALUES (2541,5747,0,0);
        INSERT INTO `spell_target_position`
          (`id`,`target_map`,`target_position_x`,`target_position_y`,`target_position_z`,`target_orientation`)
          VALUES (25182,1,-8117.5,1526.19,17.2991,0)
          ON DUPLICATE KEY UPDATE `target_map`=VALUES(`target_map`),
            `target_position_x`=VALUES(`target_position_x`),
            `target_position_y`=VALUES(`target_position_y`),
            `target_position_z`=VALUES(`target_position_z`),
            `target_orientation`=VALUES(`target_orientation`);

        UPDATE `creature_template` SET `FactionAlliance`=35,`FactionHorde`=35,`UnitFlags`=256
          WHERE `entry` IN (15378,15379,15380);
        UPDATE `creature_template` SET `FactionAlliance`=35,`FactionHorde`=35,`UnitFlags`=256
          WHERE `entry`=15381;
        UPDATE `creature_template` SET `FactionAlliance`=35,`FactionHorde`=35,`UnitFlags`=320
          WHERE `entry`=15382;
        UPDATE `creature_template` SET `FactionAlliance`=310,`FactionHorde`=310,
          `UnitFlags`=256,`RegenerateStats`=0,`DamageMultiplier`=3.5
          WHERE `entry` IN (15414,15421,15422,15424);
        UPDATE `creature_template` SET `FactionAlliance`=250,`FactionHorde`=250,
          `UnitFlags`=256,`EquipmentTemplateId`=2541
          WHERE `entry`=15423;

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
