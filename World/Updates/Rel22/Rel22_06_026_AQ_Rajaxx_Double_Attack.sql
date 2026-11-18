-- Restore Rajaxx's Double Attack spawn aura from Classic ACID.
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
    IF @v='22' AND @s='06' AND @c='025' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_rajaxx_double_attack_stage`;
        CREATE TEMPORARY TABLE `aq_rajaxx_double_attack_stage` LIKE `creature_ai_scripts`;
        INSERT INTO `aq_rajaxx_double_attack_stage`
          (`id`,`creature_id`,`event_type`,`event_inverse_phase_mask`,`event_chance`,`event_flags`,
           `event_param1`,`event_param2`,`event_param3`,`event_param4`,
           `action1_type`,`action1_param1`,`action1_param2`,`action1_param3`,
           `action2_type`,`action2_param1`,`action2_param2`,`action2_param3`,
           `action3_type`,`action3_param1`,`action3_param2`,`action3_param3`,`comment`) VALUES
          (1534110,15341,11,0,100,0,0,0,0,0,11,18943,0,34,0,0,0,0,0,0,0,0,
           'General Rajaxx - Cast Double Attack on Spawn');

        IF NOT EXISTS (SELECT 1 FROM `creature_template` WHERE `entry`=15341 AND `AIName`='EventAI') OR
           EXISTS (SELECT 1 FROM `creature_ai_scripts` WHERE `creature_id`=15341 AND `id`<>1534110 AND
             `event_type`=11 AND `action1_type`=11 AND `action1_param1`=18943) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Rajaxx Double Attack template or duplicate mismatch';
        END IF;
        IF EXISTS (
          SELECT 1 FROM `aq_rajaxx_double_attack_stage` s JOIN `creature_ai_scripts` a ON a.id=s.id
          WHERE NOT (a.creature_id <=> s.creature_id AND a.event_type <=> s.event_type AND
            a.event_inverse_phase_mask <=> s.event_inverse_phase_mask AND a.event_chance <=> s.event_chance AND
            a.event_flags <=> s.event_flags AND a.event_param1 <=> s.event_param1 AND
            a.event_param2 <=> s.event_param2 AND a.event_param3 <=> s.event_param3 AND
            a.event_param4 <=> s.event_param4 AND a.action1_type <=> s.action1_type AND
            a.action1_param1 <=> s.action1_param1 AND a.action1_param2 <=> s.action1_param2 AND
            a.action1_param3 <=> s.action1_param3 AND a.action2_type <=> s.action2_type AND
            a.action2_param1 <=> s.action2_param1 AND a.action2_param2 <=> s.action2_param2 AND
            a.action2_param3 <=> s.action2_param3 AND a.action3_type <=> s.action3_type AND
            a.action3_param1 <=> s.action3_param1 AND a.action3_param2 <=> s.action3_param2 AND
            a.action3_param3 <=> s.action3_param3 AND BINARY a.comment <=> BINARY s.comment)
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Rajaxx Double Attack EventAI ID conflict';
        END IF;

        INSERT IGNORE INTO `creature_ai_scripts`
          (`id`,`creature_id`,`event_type`,`event_inverse_phase_mask`,`event_chance`,`event_flags`,
           `event_param1`,`event_param2`,`event_param3`,`event_param4`,
           `action1_type`,`action1_param1`,`action1_param2`,`action1_param3`,
           `action2_type`,`action2_param1`,`action2_param2`,`action2_param3`,
           `action3_type`,`action3_param1`,`action3_param2`,`action3_param3`,`comment`)
          SELECT `id`,`creature_id`,`event_type`,`event_inverse_phase_mask`,`event_chance`,`event_flags`,
            `event_param1`,`event_param2`,`event_param3`,`event_param4`,
            `action1_type`,`action1_param1`,`action1_param2`,`action1_param3`,
            `action2_type`,`action2_param1`,`action2_param2`,`action2_param3`,
            `action3_type`,`action3_param1`,`action3_param2`,`action3_param3`,`comment`
          FROM `aq_rajaxx_double_attack_stage`;
        INSERT INTO `db_version` VALUES ('22','06','026','AQ_Rajaxx_Double_Attack',
          'Restore Rajaxx Double Attack aura');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='026' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Rajaxx Double Attack migration requires 22/06/025';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
