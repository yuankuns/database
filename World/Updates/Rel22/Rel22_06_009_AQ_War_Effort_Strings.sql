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
    SET @cOldContent = '008';

    SET @cNewVersion = '22';
    SET @cNewStructure = '06';
    SET @cNewContent = '009';
    SET @cNewDescription = 'AQ_War_Effort_Strings';
    SET @cNewComment = 'Add localizable strings for AQ war effort';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        START TRANSACTION;

        IF EXISTS (SELECT 1 FROM `mangos_string`
                   WHERE `entry` BETWEEN 1738 AND 1745 AND NOT
                     (`content_default` <=> CASE `entry`
                       WHEN 1738 THEN 'This event is controlled by the Ahn\'Qiraj war effort; use .event aqstart and .event aqstatus.'
                       WHEN 1739 THEN 'The Ahn\'Qiraj war effort controller is disabled in the server configuration.'
                       WHEN 1740 THEN 'Unable to save Ahn\'Qiraj war effort state.'
                       WHEN 1741 THEN 'The Ahn\'Qiraj war effort has already started or finished.'
                       WHEN 1742 THEN 'Ahn\'Qiraj war effort started; the world will update shortly.'
                       WHEN 1743 THEN 'Ahn\'Qiraj phase %u; supply goals met %u/%u; defeated colossi mask %u; phase deadline (Unix time) %llu.'
                       WHEN 1744 THEN 'This stage of the Ahn\'Qiraj war effort is not active.'
                       WHEN 1745 THEN 'The quest was not saved. Please reconnect and try again.' END
                     AND `source_file`='Language.h' AND `source_enum_wrapper`='MangosStrings'
                     AND `source_enum_tag`=CASE `entry`
                       WHEN 1738 THEN 'LANG_AQ_EVENT_CONTROLLED'
                       WHEN 1739 THEN 'LANG_AQ_EVENT_DISABLED'
                       WHEN 1740 THEN 'LANG_AQ_EVENT_STORAGE_ERROR'
                       WHEN 1741 THEN 'LANG_AQ_EVENT_ALREADY_STARTED'
                       WHEN 1742 THEN 'LANG_AQ_EVENT_STARTED'
                       WHEN 1743 THEN 'LANG_AQ_EVENT_STATUS'
                       WHEN 1744 THEN 'LANG_AQ_EVENT_STAGE_INACTIVE'
                       WHEN 1745 THEN 'LANG_AQ_EVENT_QUEST_NOT_SAVED' END)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ war effort string ID conflict';
        END IF;

        INSERT IGNORE INTO `mangos_string`
            (`entry`,`content_default`,`content_loc1`,`content_loc2`,`content_loc3`,`content_loc4`,
             `content_loc5`,`content_loc6`,`content_loc7`,`content_loc8`,
             `source_file`,`source_enum_wrapper`,`source_enum_tag`)
        VALUES
            (1738,'This event is controlled by the Ahn\'Qiraj war effort; use .event aqstart and .event aqstatus.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Language.h','MangosStrings','LANG_AQ_EVENT_CONTROLLED'),
            (1739,'The Ahn\'Qiraj war effort controller is disabled in the server configuration.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Language.h','MangosStrings','LANG_AQ_EVENT_DISABLED'),
            (1740,'Unable to save Ahn\'Qiraj war effort state.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Language.h','MangosStrings','LANG_AQ_EVENT_STORAGE_ERROR'),
            (1741,'The Ahn\'Qiraj war effort has already started or finished.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Language.h','MangosStrings','LANG_AQ_EVENT_ALREADY_STARTED'),
            (1742,'Ahn\'Qiraj war effort started; the world will update shortly.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Language.h','MangosStrings','LANG_AQ_EVENT_STARTED'),
            (1743,'Ahn\'Qiraj phase %u; supply goals met %u/%u; defeated colossi mask %u; phase deadline (Unix time) %llu.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Language.h','MangosStrings','LANG_AQ_EVENT_STATUS'),
            (1744,'This stage of the Ahn\'Qiraj war effort is not active.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Language.h','MangosStrings','LANG_AQ_EVENT_STAGE_INACTIVE'),
            (1745,'The quest was not saved. Please reconnect and try again.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Language.h','MangosStrings','LANG_AQ_EVENT_QUEST_NOT_SAVED');

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
