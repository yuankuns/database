-- Select a random hostile target in range for Saurfang's shield charge.
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
    IF @v='22' AND @s='06' AND @c='022' THEN
        IF NOT EXISTS (
            SELECT 1 FROM `creature_ai_scripts`
            WHERE `id`=1720910 AND `creature_id`=14720 AND `event_type`=9 AND
              `event_param1`=8 AND `event_param2`=25 AND `event_param3`=2300 AND `event_param4`=3900 AND
              `action1_type`=11 AND `action1_param1`=15749 AND `action1_param2`=1 AND
              `action2_type`=40 AND `action2_param1`=1
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Expected Saurfang shield charge row missing or changed';
        END IF;
        UPDATE `creature_ai_scripts`
        SET `event_type`=34, `action1_param2`=12,
            `comment`='High Overlord Saurfang - Random Shield Charge in Range and set Melee Weapon Model'
        WHERE `id`=1720910;
        INSERT INTO `db_version` VALUES ('22','06','023','AQ_Saurfang_Shield_Target',
          'Saurfang shield charge target');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='023' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Saurfang shield charge migration requires 22/06/022';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
