-- Port Classic EventAI event 36 for AQ lasher and Cenarion Hold infantry.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='033' THEN
        START TRANSACTION;
        IF (SELECT COUNT(*) FROM `creature_template` WHERE
            (`entry`=15184 AND `AIName`='EventAI' AND `SpellListId`=151840) OR
            (`entry`=15249 AND `AIName`='' AND `SpellListId`=152490))<>2 OR
           EXISTS (SELECT 1 FROM `creature_ai_scripts` WHERE `creature_id`=15249) OR
           EXISTS (SELECT 1 FROM `creature_ai_scripts` WHERE `id` IN (1518408,1524901)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ unreachable-target AI conflict';
        END IF;
        UPDATE `creature_template` SET `AIName`='EventAI' WHERE `entry`=15249 AND `AIName`='' AND `SpellListId`=152490;
        INSERT INTO `creature_ai_scripts`
          (`id`,`creature_id`,`event_type`,`event_inverse_phase_mask`,`event_chance`,`event_flags`,`event_param1`,`event_param2`,`event_param3`,`event_param4`,`action1_type`,`action1_param1`,`action1_param2`,`action1_param3`,`action2_type`,`action2_param1`,`action2_param2`,`action2_param3`,`action3_type`,`action3_param1`,`action3_param2`,`action3_param3`,`comment`)
        VALUES
          (1518408,15184,36,0,100,65537,0,0,0,0,11,21727,1,0,0,0,0,0,0,0,0,0,'AQ unreachable target summon'),
          (1524901,15249,36,0,100,65537,0,0,0,0,11,21727,1,0,0,0,0,0,0,0,0,0,'AQ unreachable target summon');
        INSERT INTO `db_version` VALUES ('22','06','034','AQ_Target_Unreachable_Summon','Add AQ target-unreachable EventAI');
        COMMIT;
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='034' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ target-unreachable migration requires 22/06/033';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
