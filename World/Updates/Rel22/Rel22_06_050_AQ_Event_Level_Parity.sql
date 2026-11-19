-- Restore Classic level ranges for the five AQ combat templates whose Zero
-- ranges excluded one or more source levels used by the combat stat mapping.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='049' THEN
        IF (SELECT COUNT(*) FROM `creature_template` WHERE Entry IN (15743,15744,15749,15810,15853))<>5 OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE
             (Entry=15743 AND (Name<>'Colossal Anubisath Warbringer' OR (MinLevel,MaxLevel) NOT IN ((63,63),(61,62)))) OR
             (Entry=15744 AND (Name<>'Imperial Qiraji Destroyer' OR (MinLevel,MaxLevel) NOT IN ((62,63),(62,62)))) OR
             (Entry=15749 AND (Name<>'Lesser Silithid Flayer' OR (MinLevel,MaxLevel) NOT IN ((30,31),(29,31)))) OR
             (Entry=15810 AND (Name<>'Eroded Anubisath Warbringer' OR (MinLevel,MaxLevel) NOT IN ((16,17),(16,18)))) OR
             (Entry=15853 AND (Name<>'Orgrimmar Elite Infantryman' OR (MinLevel,MaxLevel) NOT IN ((60,60),(59,60))))) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ event level source/target conflict';
        END IF;
        UPDATE `creature_template` SET MinLevel=61,MaxLevel=62 WHERE Entry=15743 AND MinLevel=63 AND MaxLevel=63;
        UPDATE `creature_template` SET MinLevel=62,MaxLevel=62 WHERE Entry=15744 AND MinLevel=62 AND MaxLevel=63;
        UPDATE `creature_template` SET MinLevel=29,MaxLevel=31 WHERE Entry=15749 AND MinLevel=30 AND MaxLevel=31;
        UPDATE `creature_template` SET MinLevel=16,MaxLevel=18 WHERE Entry=15810 AND MinLevel=16 AND MaxLevel=17;
        UPDATE `creature_template` SET MinLevel=59,MaxLevel=60 WHERE Entry=15853 AND MinLevel=60 AND MaxLevel=60;
        INSERT INTO `db_version` VALUES ('22','06','050','AQ_Event_Level_Parity','Align AQ combat creature levels');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='050' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ event level parity requires 22/06/049';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
