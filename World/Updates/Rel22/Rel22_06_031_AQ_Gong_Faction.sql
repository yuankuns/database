-- Match the final Classic faction setting for the AQ Scarab Gong.
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
    IF @v='22' AND @s='06' AND @c='030' THEN
        IF (SELECT COUNT(*) FROM `gameobject_template` WHERE `entry`=180717 AND `type`=2
            AND `name`='The Scarab Gong' AND `faction` IN (0,35))<>1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ gong template mismatch';
        END IF;
        UPDATE `gameobject_template` SET `faction`=35
          WHERE `entry`=180717 AND `type`=2 AND `name`='The Scarab Gong' AND `faction`=0;
        INSERT INTO `db_version` VALUES ('22','06','031','AQ_Gong_Faction',
          'Align Scarab Gong faction');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='031' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ gong migration requires 22/06/030';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
