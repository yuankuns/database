-- Restore the text emote paired with General Rajaxx's ten-minute Frenzy cast.
-- Classic DB update 4712 attaches broadcast text 1191 to the spell relay.
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
    IF @v='22' AND @s='06' AND @c='028' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_rajaxx_frenzy_text_stage`;
        CREATE TEMPORARY TABLE `aq_rajaxx_frenzy_text_stage` LIKE `creature_ai_texts`;
        INSERT INTO `aq_rajaxx_frenzy_text_stage`
          (`entry`,`content_default`,`content_loc2`,`content_loc3`,`content_loc6`,`content_loc7`,`content_loc8`,
           `sound`,`type`,`language`,`emote`,`comment`) VALUES
          (-900784,'%s goes into a frenzy!',
           '%s est pris de frénésie !','%s gerät in Raserei!',
           'se pone frenético.','¡%s entra en frenesí!','%s приходит в ярость!',
           0,2,0,0,'General Rajaxx - Frenzy text emote');

        DROP TEMPORARY TABLE IF EXISTS `aq_rajaxx_frenzy_ai_stage`;
        CREATE TEMPORARY TABLE `aq_rajaxx_frenzy_ai_stage` LIKE `creature_ai_scripts`;
        INSERT INTO `aq_rajaxx_frenzy_ai_stage`
          (`id`,`creature_id`,`event_type`,`event_inverse_phase_mask`,`event_chance`,`event_flags`,
           `event_param1`,`event_param2`,`event_param3`,`event_param4`,
           `action1_type`,`action1_param1`,`action1_param2`,`action1_param3`,
           `action2_type`,`action2_param1`,`action2_param2`,`action2_param3`,
           `action3_type`,`action3_param1`,`action3_param2`,`action3_param3`,`comment`) VALUES
          (1534106,15341,0,0,100,65537,600000,600000,120000,120000,
           11,8269,0,1,1,-900784,0,0,0,0,0,0,
          'General Rajaxx - Cast Frenzy after 10 Minutes');

        IF NOT EXISTS (SELECT 1 FROM `creature_template` WHERE `entry`=15341 AND `AIName`='EventAI') OR
           NOT EXISTS (SELECT 1 FROM `creature_ai_scripts` WHERE `id`=1534106 AND `creature_id`=15341
             AND `event_type`=0 AND `event_inverse_phase_mask`=0 AND `event_chance`=100 AND `event_flags`=1
             AND `event_param1`=600000 AND `event_param2`=600000 AND `event_param3`=120000 AND `event_param4`=120000
             AND `action1_type`=11 AND `action1_param1`=8269 AND `action1_param2`=0 AND `action1_param3`=1
             AND `action2_type`=0 AND `action2_param1`=0 AND `action2_param2`=0 AND `action2_param3`=0
             AND `action3_type`=0 AND `action3_param1`=0 AND `action3_param2`=0 AND `action3_param3`=0
             AND BINARY `comment`=BINARY 'General Rajaxx - Cast Frenzy after 10 Minutes') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Rajaxx Frenzy EventAI source row mismatch';
        END IF;
        IF EXISTS (SELECT 1 FROM `creature_ai_texts` a JOIN `aq_rajaxx_frenzy_text_stage` s ON a.entry=s.entry
          WHERE NOT (BINARY a.content_default <=> BINARY s.content_default AND
            BINARY a.content_loc1 <=> BINARY s.content_loc1 AND BINARY a.content_loc2 <=> BINARY s.content_loc2 AND
            BINARY a.content_loc3 <=> BINARY s.content_loc3 AND BINARY a.content_loc4 <=> BINARY s.content_loc4 AND
            BINARY a.content_loc5 <=> BINARY s.content_loc5 AND BINARY a.content_loc6 <=> BINARY s.content_loc6 AND
            BINARY a.content_loc7 <=> BINARY s.content_loc7 AND BINARY a.content_loc8 <=> BINARY s.content_loc8 AND
            a.sound <=> s.sound AND a.type <=> s.type AND a.language <=> s.language AND
            a.emote <=> s.emote AND BINARY a.comment <=> BINARY s.comment)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Rajaxx Frenzy text ID conflict';
        END IF;

        INSERT IGNORE INTO `creature_ai_texts`
          (`entry`,`content_default`,`content_loc1`,`content_loc2`,`content_loc3`,`content_loc4`,
           `content_loc5`,`content_loc6`,`content_loc7`,`content_loc8`,`sound`,`type`,`language`,`emote`,`comment`)
          SELECT `entry`,`content_default`,`content_loc1`,`content_loc2`,`content_loc3`,`content_loc4`,
            `content_loc5`,`content_loc6`,`content_loc7`,`content_loc8`,`sound`,`type`,`language`,`emote`,`comment`
          FROM `aq_rajaxx_frenzy_text_stage`;
        UPDATE `creature_ai_scripts` SET `event_flags`=65537,`action2_type`=1,`action2_param1`=-900784
          WHERE `id`=1534106 AND `creature_id`=15341;
        INSERT INTO `db_version` VALUES ('22','06','029','AQ_Rajaxx_Frenzy_Text',
          'Restore Rajaxx Frenzy text');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='029' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Rajaxx Frenzy yell migration requires 22/06/028';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
