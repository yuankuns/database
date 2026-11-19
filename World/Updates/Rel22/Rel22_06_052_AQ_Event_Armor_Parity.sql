-- Restore Silithid Flayer's Classic armor multiplier. The AQ combat stat
-- path now uses pinned Classic level-specific BaseArmor rows for event mobs.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='051' THEN
        IF (SELECT COUNT(*) FROM `creature_template` WHERE Entry=15752 AND Name='Silithid Flayer'
              AND ABS(ArmorMultiplier-1.0)<0.0001)<>1 AND
           (SELECT COUNT(*) FROM `creature_template` WHERE Entry=15752 AND Name='Silithid Flayer'
              AND ABS(ArmorMultiplier-0.884239)<0.0001)<>1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ armor multiplier conflict';
        END IF;
        UPDATE `creature_template` SET ArmorMultiplier=0.884239
          WHERE Entry=15752 AND Name='Silithid Flayer' AND ABS(ArmorMultiplier-1.0)<0.0001;
        INSERT INTO `db_version` VALUES ('22','06','052','AQ_Event_Armor_Parity','Align AQ event armor calculation');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='052' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ armor parity requires 22/06/051';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
