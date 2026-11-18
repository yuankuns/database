-- Restore the zone yell and protected/passive state on the war-effort Rajaxx spawn.
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
    IF @v='22' AND @s='06' AND @c='024' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_ra_spawn_text_stage`;
        CREATE TEMPORARY TABLE `aq_ra_spawn_text_stage` LIKE `creature_ai_texts`;
        INSERT INTO `aq_ra_spawn_text_stage`
          (`entry`,`content_default`,`content_loc2`,`content_loc3`,`content_loc6`,`content_loc7`,`content_loc8`,
           `sound`,`type`,`language`,`emote`,`comment`) VALUES
          (-900783,'Soon you will know the price of your meddling, mortals... The master is nearly whole... And when he rises, your world will cease.',
           'Vous payerez bientôt le prix de votre intrusion, mortels… Le maître est presque entier… Et lorsqu’il se lèvera, le monde finira.',
           'Schon bald werdet ihr den Preis für euer Einmischen bezahlen, Sterbliche... Der Meister ist fast bereit... Und wenn er aufersteht, wird diese Welt aufhören zu existieren.',
           'Pronto conoceréis el precio de vuestra intromisión, mortales... El maestro casi está completo... y cuando se levante, vuestro mundo verá el fin.',
           'Pronto conocerán el precio de su intromisión, mortales... El maestro casi está completo... y cuando se levante, su mundo verá el fin.',
           'Скоро вы познаете цену своему промедлению, смертные. Хозяин почти готов… А когда он восстанет, весь ваш мир падет к его ногам.',
           0,6,0,0,'General Rajaxx - War effort zone yell');

        DROP TEMPORARY TABLE IF EXISTS `aq_ra_spawn_ai_stage`;
        CREATE TEMPORARY TABLE `aq_ra_spawn_ai_stage` LIKE `creature_ai_scripts`;
        INSERT INTO `aq_ra_spawn_ai_stage`
          (`id`,`creature_id`,`event_type`,`event_inverse_phase_mask`,`event_chance`,`event_flags`,
           `event_param1`,`event_param2`,`event_param3`,`event_param4`,
           `action1_type`,`action1_param1`,`action1_param2`,`action1_param3`,
           `action2_type`,`action2_param1`,`action2_param2`,`action2_param3`,
           `action3_type`,`action3_param1`,`action3_param2`,`action3_param3`,`comment`) VALUES
          (1534109,15341,35,800717,100,1,0,0,300000,300000,
           1,-900783,0,0,18,832,0,0,0,0,0,0,'General Rajaxx - War effort spawn yell and unit flags');

        IF NOT EXISTS (SELECT 1 FROM `creature_template` WHERE `entry`=15341 AND `AIName`='EventAI') OR
           NOT EXISTS (SELECT 1 FROM `creature` WHERE `guid`=800717 AND `id`=15341) OR
           NOT EXISTS (SELECT 1 FROM `game_event_creature` WHERE `guid`=800717 AND `event`=123) OR
           EXISTS (SELECT 1 FROM `creature_ai_scripts` WHERE `creature_id`=15341 AND
             `event_type`=35 AND `event_inverse_phase_mask`=800717 AND `id`<>1534109) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Rajaxx war-effort spawn or AI event mismatch';
        END IF;
        IF EXISTS (
          SELECT 1 FROM `aq_ra_spawn_text_stage` s JOIN `creature_ai_texts` a ON a.entry=s.entry
          WHERE NOT (BINARY a.content_default <=> BINARY s.content_default AND
            BINARY a.content_loc1 <=> BINARY s.content_loc1 AND BINARY a.content_loc2 <=> BINARY s.content_loc2 AND
            BINARY a.content_loc3 <=> BINARY s.content_loc3 AND BINARY a.content_loc4 <=> BINARY s.content_loc4 AND
            BINARY a.content_loc5 <=> BINARY s.content_loc5 AND BINARY a.content_loc6 <=> BINARY s.content_loc6 AND
            BINARY a.content_loc7 <=> BINARY s.content_loc7 AND BINARY a.content_loc8 <=> BINARY s.content_loc8 AND
            a.sound <=> s.sound AND a.type <=> s.type AND a.language <=> s.language AND
            a.emote <=> s.emote AND BINARY a.comment <=> BINARY s.comment)
        ) OR EXISTS (
          SELECT 1 FROM `aq_ra_spawn_ai_stage` s JOIN `creature_ai_scripts` a ON a.id=s.id
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
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Rajaxx war-effort spawn text or EventAI ID conflict';
        END IF;

        INSERT IGNORE INTO `creature_ai_texts`
          (`entry`,`content_default`,`content_loc1`,`content_loc2`,`content_loc3`,`content_loc4`,
           `content_loc5`,`content_loc6`,`content_loc7`,`content_loc8`,`sound`,`type`,`language`,`emote`,`comment`)
          SELECT `entry`,`content_default`,`content_loc1`,`content_loc2`,`content_loc3`,`content_loc4`,
            `content_loc5`,`content_loc6`,`content_loc7`,`content_loc8`,`sound`,`type`,`language`,`emote`,`comment`
          FROM `aq_ra_spawn_text_stage`;
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
          FROM `aq_ra_spawn_ai_stage`;
        INSERT INTO `db_version` VALUES ('22','06','025','AQ_Rajaxx_War_Spawn',
          'Restore Rajaxx war spawn event');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='025' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Rajaxx war-effort spawn migration requires 22/06/024';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
