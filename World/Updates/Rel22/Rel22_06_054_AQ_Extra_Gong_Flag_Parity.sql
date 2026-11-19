-- Align the AQ gong template with the pinned Classic Full_DB row.
-- Classic keeps flags=4 for entry 210334; Zero's baseline has flags=0.
-- Neither database has a static spawn for this template, but preserve the
-- source template value in case it is used by data-driven spawning.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='053' THEN
        IF (SELECT COUNT(*) FROM `gameobject_template` WHERE `entry`=210334
            AND `type`=2 AND `displayId`=4675 AND `name`='Ahn\'Qiraj Gong'
            AND `faction`=84 AND `flags` IN (0,4))<>1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ gong template flags conflict';
        END IF;
        UPDATE `gameobject_template` SET `flags`=4
          WHERE `entry`=210334 AND `type`=2 AND `displayId`=4675
            AND `name`='Ahn\'Qiraj Gong' AND `faction`=84 AND `flags`=0;
        INSERT INTO `db_version` VALUES ('22','06','054','AQ_Extra_Gong_Flag_Parity',
          'Align Classic AQ gong template flags');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='054' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ gong template parity requires 22/06/053';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
