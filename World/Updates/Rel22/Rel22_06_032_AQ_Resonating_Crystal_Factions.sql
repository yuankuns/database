-- Match the final Classic faction settings for the AQ phase-3 resource crystals.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='031' THEN
        IF (SELECT COUNT(*) FROM `gameobject_template` WHERE
            (`entry`=180810 AND `type`=0 AND `name`='Resonating Crystal Formation' AND `faction` IN (0,114)) OR
            (`entry`=180811 AND `type`=0 AND `name`='Resonating Crystal Formation Glow' AND `faction` IN (0,114)))<>2 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ crystal template mismatch';
        END IF;
        UPDATE `gameobject_template` SET `faction`=114
          WHERE `entry` IN (180810,180811) AND `type`=0 AND `faction`=0;
        INSERT INTO `db_version` VALUES ('22','06','032','AQ_Crystal_Factions',
          'Align AQ crystal factions');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='032' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ crystal migration requires 22/06/031';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
