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
    SET @cOldContent = '012';

    SET @cNewVersion = '22';
    SET @cNewStructure = '06';
    SET @cNewContent = '013';
    SET @cNewDescription = 'AQ_War_Effort_Announcements';
    SET @cNewComment = 'Add localizable strings for AQ war effort';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        START TRANSACTION;

        IF EXISTS (SELECT 1 FROM `mangos_string` WHERE `entry` IN (1746,1747) AND NOT (
            `source_file` <=> 'Language.h' AND `source_enum_wrapper` <=> 'MangosStrings' AND
            `source_enum_tag` <=> CASE `entry` WHEN 1746 THEN 'LANG_AQ_GONG_ANNOUNCEMENT' ELSE 'LANG_AQ_QIRAJI_BREAK' END AND
            `content_default` <=> CASE `entry`
                WHEN 1746 THEN '$n, Champion of the Bronze Dragonflight, has rung the Scarab Gong. The ancient gates of Ahn\'Qiraj open, revealing the horrors of a forgotten war...'
                ELSE 'Massive Qiraji resonating crystals break through the earthen crust of Kalimdor. Colossal creatures made of obsidian stone breach the freshly broken land.' END)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ announcement string ID conflict';
        END IF;
        INSERT IGNORE INTO `mangos_string` (`entry`,`content_default`,`source_file`,`source_enum_wrapper`,`source_enum_tag`) VALUES
          (1746,'$n, Champion of the Bronze Dragonflight, has rung the Scarab Gong. The ancient gates of Ahn\'Qiraj open, revealing the horrors of a forgotten war...','Language.h','MangosStrings','LANG_AQ_GONG_ANNOUNCEMENT'),
          (1747,'Massive Qiraji resonating crystals break through the earthen crust of Kalimdor. Colossal creatures made of obsidian stone breach the freshly broken land.','Language.h','MangosStrings','LANG_AQ_QIRAJI_BREAK');

        IF EXISTS (SELECT 1 FROM `script_texts` WHERE `entry` IN (-1999923,-1999924,-1999925) AND NOT (
            `comment` <=> 'AQ colossus arrival' AND `type`=2 AND `language`=0 AND `sound`=0 AND `emote`=0 AND
            `content_default` <=> CASE `entry`
                WHEN -1999923 THEN '%s casts its massive shadow upon the whole of Silithus.'
                WHEN -1999924 THEN '%s hears the call to battle and rises to serve its master.'
                ELSE '%s breaks free of its cocoon beneath Hive\'Ashi.' END)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ colossus text ID conflict';
        END IF;
        INSERT IGNORE INTO `script_texts` (`entry`,`content_default`,`type`,`language`,`sound`,`emote`,`comment`) VALUES
          (-1999923,'%s casts its massive shadow upon the whole of Silithus.',2,0,0,0,'AQ colossus arrival'),
          (-1999924,'%s hears the call to battle and rises to serve its master.',2,0,0,0,'AQ colossus arrival'),
          (-1999925,'%s breaks free of its cocoon beneath Hive\'Ashi.',2,0,0,0,'AQ colossus arrival');

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
