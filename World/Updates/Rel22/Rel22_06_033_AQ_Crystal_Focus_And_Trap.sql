-- Restore the Classic spell-focus / linked-trap behavior of AQ crystals.
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
    IF @v='22' AND @s='06' AND @c='032' THEN
        IF (SELECT COUNT(*) FROM `gameobject_template` WHERE
            (`entry`=180810 AND `type`=0 AND `name`='Resonating Crystal Formation' AND `faction`=114
             AND `size`=1 AND `data0`=0 AND `data1`=10 AND `data2`=180811) OR
            (`entry`=180811 AND `type`=0 AND `name`='Resonating Crystal Formation Glow' AND `faction`=114
             AND `size`=1 AND `data0`=0 AND `data1`=0 AND `data2`=0 AND `data3`=0 AND `data4`=1))<>2 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ crystal focus/trap template mismatch';
        END IF;
        UPDATE `gameobject_template` SET `type`=8,`size`=4
          WHERE `entry`=180810 AND `type`=0 AND `name`='Resonating Crystal Formation'
            AND `faction`=114 AND `size`=1 AND `data0`=0 AND `data1`=10 AND `data2`=180811;
        UPDATE `gameobject_template` SET `type`=6,`size`=10
          WHERE `entry`=180811 AND `type`=0 AND `name`='Resonating Crystal Formation Glow'
            AND `faction`=114 AND `size`=1 AND `data0`=0 AND `data1`=0 AND `data2`=0 AND `data3`=0 AND `data4`=1;
        INSERT INTO `db_version` VALUES ('22','06','033','AQ_Crystal_Focus_Trap',
          'Restore AQ crystal focus/trap');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='033' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ crystal migration requires 22/06/032';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
