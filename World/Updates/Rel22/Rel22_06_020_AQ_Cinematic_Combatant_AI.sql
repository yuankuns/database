-- Restore the Classic EventAI cleanup and transformation behavior for AQ gate
-- cinematic combatants. Every event/action used here exists in Zero's
-- CreatureEventAI; unsupported source actions are not translated implicitly.
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
    IF @v='22' AND @s='06' AND @c='019' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_cinematic_ai_stage`;
        CREATE TEMPORARY TABLE `aq_cinematic_ai_stage` (
          `id` INT UNSIGNED NOT NULL PRIMARY KEY,
          `creature_id` INT UNSIGNED NOT NULL,
          `event_type` TINYINT UNSIGNED NOT NULL,
          `event_inverse_phase_mask` TINYINT UNSIGNED NOT NULL,
          `event_chance` TINYINT UNSIGNED NOT NULL,
          `event_flags` INT UNSIGNED NOT NULL,
          `event_param1` INT UNSIGNED NOT NULL,
          `event_param2` INT NOT NULL,
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
        INSERT INTO `aq_cinematic_ai_stage` VALUES
          (1541401,15414,8,0,100,0,25158,-1,0,0,41,40000,0,0,0,0,0,0,0,0,0,0,'Qiraji Wasp - Despawn Self on Spell Hit (q.8519)'),
          (1542101,15421,8,0,100,0,25158,-1,0,0,41,40000,0,0,0,0,0,0,0,0,0,0,'Qiraji Drone - Despawn Self on Spell Hit (q.8519)'),
          (1542201,15422,8,0,100,0,25158,-1,0,0,41,40000,0,0,0,0,0,0,0,0,0,0,'Qiraji Tank - Despawn Self on Spell Hit (q.8519)'),
          (1542301,15423,8,0,100,0,25158,-1,0,0,41,40000,0,0,0,0,0,0,0,0,0,0,'Kaldorei Infantry - Despawn Self on Spell Hit (q.8519)'),
          (1542401,15424,8,0,100,0,25145,-1,0,0,22,1,0,0,0,0,0,0,0,0,0,0,'Anubisath Conqueror - Set Phase 1 on Spell Hit'),
          (1542402,15424,8,0,100,0,25158,-1,0,0,41,20000,0,0,0,0,0,0,0,0,0,0,'Anubisath Conqueror - Despawn on Spell Hit'),
          (1542403,15424,29,1,100,0,3000,10000,0,0,37,0,0,0,0,0,0,0,0,0,0,0,'Anubisath Conqueror - Die on Generic Timer (Phase 1)');

        IF (SELECT COUNT(*) FROM `aq_cinematic_ai_stage`)<>7 OR
           (SELECT COUNT(*) FROM `creature_template` WHERE `entry` IN (15414,15421,15422,15423,15424)
             AND (`AIName`='' OR `AIName`='EventAI'))<>5 OR
           EXISTS (SELECT 1 FROM `script_binding` WHERE `type`=0 AND `bind` IN (15414,15421,15422,15423,15424)) OR
           EXISTS (SELECT 1 FROM `creature_ai_scripts` a
             WHERE a.`creature_id` IN (15414,15421,15422,15423,15424)
             AND a.`id` NOT IN (1541401,1542101,1542201,1542301,1542401,1542402,1542403)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ cinematic combatant AI template or script set mismatch';
        END IF;
        IF EXISTS (
          SELECT 1 FROM `aq_cinematic_ai_stage` s
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
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ cinematic combatant AI ID conflicts with existing script';
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
          FROM `aq_cinematic_ai_stage`;
        UPDATE `creature_template` SET `AIName`='EventAI' WHERE `entry` IN (15414,15421,15422,15423,15424);
        INSERT INTO `db_version` VALUES ('22','06','020','AQ_Cinematic_Combatant_AI',
          'Restore AQ cinematic Qiraji and Anubisath EventAI behavior');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='020' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ cinematic combatant AI migration requires 22/06/019';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
