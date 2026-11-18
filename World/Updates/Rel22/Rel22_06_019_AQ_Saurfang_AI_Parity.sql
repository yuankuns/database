-- Restore the Classic-supported High Overlord Saurfang actions missing from
-- the Zero EventAI script set. Existing Zero scripts keep their custom kill,
-- shield charge, mortal strike and whirlwind behavior; this adds spawn buffs,
-- Intimidating Roar and an actual Cleave cast (the existing row described as
-- Cleave only changes sheath state). Unsupported Classic action/event types
-- are deliberately not copied.
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
    IF @v='22' AND @s='06' AND @c='018' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_saurfang_ai_stage`;
        CREATE TEMPORARY TABLE `aq_saurfang_ai_stage` (
          `id` INT UNSIGNED NOT NULL PRIMARY KEY,
          `creature_id` INT UNSIGNED NOT NULL,
          `event_type` TINYINT UNSIGNED NOT NULL,
          `event_inverse_phase_mask` TINYINT UNSIGNED NOT NULL,
          `event_chance` TINYINT UNSIGNED NOT NULL,
          `event_flags` INT UNSIGNED NOT NULL,
          `event_param1` INT UNSIGNED NOT NULL,
          `event_param2` INT UNSIGNED NOT NULL,
          `event_param3` INT UNSIGNED NOT NULL,
          `event_param4` INT UNSIGNED NOT NULL,
          `action1_type` TINYINT UNSIGNED NOT NULL,
          `action1_param1` INT UNSIGNED NOT NULL,
          `action1_param2` INT UNSIGNED NOT NULL,
          `action1_param3` INT UNSIGNED NOT NULL,
          `action2_type` TINYINT UNSIGNED NOT NULL,
          `action2_param1` INT UNSIGNED NOT NULL,
          `action2_param2` INT UNSIGNED NOT NULL,
          `action2_param3` INT UNSIGNED NOT NULL,
          `action3_type` TINYINT UNSIGNED NOT NULL,
          `action3_param1` INT UNSIGNED NOT NULL,
          `action3_param2` INT UNSIGNED NOT NULL,
          `action3_param3` INT UNSIGNED NOT NULL,
          `comment` VARCHAR(255) NOT NULL
        ) ENGINE=InnoDB;
        INSERT INTO `aq_saurfang_ai_stage` VALUES
          (1472001,14720,11,0,100,0,0,0,0,0,11,9347,0,34,11,26341,0,34,0,0,0,0,'High Overlord Saurfang - Cast Mortal Strike and Saurfang''s Rage on Spawn'),
          (1472004,14720,0,0,100,1025,3000,9000,15000,15000,11,16508,1,0,0,0,0,0,0,0,0,0,'High Overlord Saurfang - Cast Intimidating Roar'),
          (1472005,14720,0,0,100,1025,5000,8000,7000,7000,11,16044,1,0,0,0,0,0,0,0,0,0,'High Overlord Saurfang - Cast Cleave');

        IF (SELECT COUNT(*) FROM `aq_saurfang_ai_stage`)<>3 OR
           NOT EXISTS (SELECT 1 FROM `creature_template` WHERE `entry`=14720 AND `AIName`='EventAI') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Saurfang EventAI template or manifest mismatch';
        END IF;
        IF EXISTS (
          SELECT 1 FROM `aq_saurfang_ai_stage` s
          JOIN `creature_ai_scripts` a ON a.id=s.id
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
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Saurfang EventAI ID conflicts with existing script';
        END IF;

        INSERT IGNORE INTO `creature_ai_scripts` (
          `id`,`creature_id`,`event_type`,`event_inverse_phase_mask`,`event_chance`,`event_flags`,
          `event_param1`,`event_param2`,`event_param3`,`event_param4`,
          `action1_type`,`action1_param1`,`action1_param2`,`action1_param3`,
          `action2_type`,`action2_param1`,`action2_param2`,`action2_param3`,
          `action3_type`,`action3_param1`,`action3_param2`,`action3_param3`,`comment`
        ) SELECT `id`,`creature_id`,`event_type`,`event_inverse_phase_mask`,`event_chance`,`event_flags`,
          `event_param1`,`event_param2`,`event_param3`,`event_param4`,
          `action1_type`,`action1_param1`,`action1_param2`,`action1_param3`,
          `action2_type`,`action2_param1`,`action2_param2`,`action2_param3`,
          `action3_type`,`action3_param1`,`action3_param2`,`action3_param3`,`comment`
          FROM `aq_saurfang_ai_stage`;
        INSERT INTO `db_version` VALUES ('22','06','019','AQ_Saurfang_AI_Parity',
          'Restore supported Classic Saurfang spawn buffs, roar, and cleave actions');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='019' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Saurfang AI parity migration requires 22/06/018';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
