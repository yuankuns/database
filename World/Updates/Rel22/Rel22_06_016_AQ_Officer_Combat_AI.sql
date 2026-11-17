-- CMaNGOS Classic DB e4825cf: six dynamically spawned officer groups.
-- 0x10000 maps CMaNGOS combat retry; player-only charge uses target 8.
-- These templates have no spawns until the dynamic group port is completed.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;
    SET @v := (SELECT `version` FROM db_version ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM db_version ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM db_version ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='015' THEN
        DROP TEMPORARY TABLE IF EXISTS expected_aq_officer_ai;
        DROP TEMPORARY TABLE IF EXISTS expected_aq_officer_text;
        CREATE TEMPORARY TABLE expected_aq_officer_ai LIKE creature_ai_scripts;
        CREATE TEMPORARY TABLE expected_aq_officer_text LIKE creature_ai_texts;
        INSERT INTO expected_aq_officer_text (entry,content_default,content_loc2,content_loc3,content_loc6,content_loc7,content_loc8,type,language,comment) VALUES
          (-900776,'%s lets loose a massive attack.','%s déclenche une attaque massive.',
           '%s lässt eine mächtige Attacke los.','realiza un ataque masivo.',
           '%s realiza un ataque masivo.','%s начинает массированную атаку.',7,0,'Lieutenant General Nokhor: colossal smash');
        INSERT INTO expected_aq_officer_ai (id,creature_id,event_type,event_inverse_phase_mask,event_chance,event_flags,event_param1,event_param2,event_param3,event_param4,action1_type,action1_param1,action1_param2,action1_param3,action2_type,action2_param1,action2_param2,action2_param3,action3_type,action3_param1,action3_param2,action3_param3,comment) VALUES
          (1574701,15747,0,0,100,65537,0,16000,10000,40000,11,13730,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1574702,15747,0,0,100,65537,0,20000,5000,25000,11,24023,8,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1574703,15747,0,0,100,65537,0,16000,8000,24000,11,19643,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1575001,15750,0,0,100,65537,0,16000,10000,40000,11,13730,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1575002,15750,0,0,100,65537,0,20000,5000,25000,11,24023,8,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1575003,15750,0,0,100,65537,0,16000,8000,24000,11,19643,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1575301,15753,0,0,100,65537,0,16000,10000,40000,11,13730,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1575302,15753,0,0,100,65537,0,20000,5000,25000,11,24023,8,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1575303,15753,0,0,100,65537,0,16000,8000,24000,11,19643,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1575701,15757,0,0,100,65537,0,16000,10000,40000,11,13730,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1575702,15757,0,0,100,65537,0,20000,5000,25000,11,24023,8,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1575703,15757,0,0,100,65537,0,16000,8000,24000,11,19643,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1580601,15806,0,0,100,65537,0,16000,10000,40000,11,13730,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1580602,15806,0,0,100,65537,0,20000,5000,25000,11,24023,8,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1580603,15806,0,0,100,65537,0,16000,8000,24000,11,19643,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581201,15812,0,0,100,65537,0,16000,10000,40000,11,13730,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581202,15812,0,0,100,65537,0,20000,5000,25000,11,24023,8,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581203,15812,0,0,100,65537,0,16000,8000,24000,11,19643,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581301,15813,0,0,100,65537,0,16000,10000,40000,11,13730,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581302,15813,0,0,100,65537,0,20000,5000,25000,11,24023,8,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581303,15813,0,0,100,65537,0,16000,8000,24000,11,19643,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581401,15814,0,0,100,65537,0,16000,10000,40000,11,13730,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581402,15814,0,0,100,65537,0,20000,5000,25000,11,24023,8,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581403,15814,0,0,100,65537,0,16000,8000,24000,11,19643,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581501,15815,0,0,100,65537,0,16000,10000,40000,11,13730,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581502,15815,0,0,100,65537,0,20000,5000,25000,11,24023,8,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581503,15815,0,0,100,65537,0,16000,8000,24000,11,19643,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581601,15816,0,0,100,65537,0,16000,10000,40000,11,13730,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581602,15816,0,0,100,65537,0,20000,5000,25000,11,24023,8,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581603,15816,0,0,100,65537,0,16000,8000,24000,11,19643,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581701,15817,0,0,100,65537,0,16000,10000,40000,11,13730,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581702,15817,0,0,100,65537,0,20000,5000,25000,11,24023,8,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581703,15817,0,0,100,65537,0,16000,8000,24000,11,19643,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581801,15818,0,0,100,65537,60000,90000,60000,90000,11,25599,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581802,15818,0,0,100,65537,20000,30000,20000,30000,11,26167,17,2,1,-900776,0,0,0,0,0,0,'AQ war officer combat'),
          (1581803,15818,0,0,100,65537,0,16000,10000,40000,11,23511,17,0,0,0,0,0,0,0,0,0,'AQ war officer combat'),
          (1581804,15818,0,0,100,65537,0,16000,8000,24000,11,24573,1,0,0,0,0,0,0,0,0,0,'AQ war officer combat');
        -- All world tables are MyISAM. Check every conflicting row before writes.
        IF (SELECT COUNT(*) FROM creature_template WHERE entry IN (15747,15750,15753,15757,15806,15812,15813,15814,15815,15816,15817,15818)) <> 12 OR
           EXISTS (SELECT 1 FROM script_binding WHERE type=0 AND bind IN (15747,15750,15753,15757,15806,15812,15813,15814,15815,15816,15817,15818)) OR
           EXISTS (SELECT 1 FROM creature_template t WHERE t.entry IN (15747,15750,15753,15757,15806,15812,15813,15814,15815,15816,15817,15818) AND
              NOT (t.AIName='' OR (t.AIName='EventAI' AND EXISTS
                (SELECT 1 FROM creature_ai_scripts a WHERE a.creature_id=t.entry AND a.id DIV 100=t.entry AND a.id MOD 100 BETWEEN 1 AND IF(t.entry=15818,4,3))))) OR
           EXISTS (SELECT 1 FROM creature_ai_texts a LEFT JOIN expected_aq_officer_text e ON a.entry=e.entry
              WHERE a.entry=-900776 AND (e.entry IS NULL OR NOT (a.`entry` <=> e.`entry` AND BINARY a.`content_default` <=> BINARY e.`content_default` AND BINARY a.`content_loc1` <=> BINARY e.`content_loc1` AND BINARY a.`content_loc2` <=> BINARY e.`content_loc2` AND BINARY a.`content_loc3` <=> BINARY e.`content_loc3` AND BINARY a.`content_loc4` <=> BINARY e.`content_loc4` AND BINARY a.`content_loc5` <=> BINARY e.`content_loc5` AND BINARY a.`content_loc6` <=> BINARY e.`content_loc6` AND BINARY a.`content_loc7` <=> BINARY e.`content_loc7` AND BINARY a.`content_loc8` <=> BINARY e.`content_loc8` AND a.`sound` <=> e.`sound` AND a.`type` <=> e.`type` AND a.`language` <=> e.`language` AND a.`emote` <=> e.`emote` AND BINARY a.`comment` <=> BINARY e.`comment`))) OR
           EXISTS (SELECT 1 FROM creature_ai_scripts a LEFT JOIN expected_aq_officer_ai e ON a.id=e.id
              WHERE (a.creature_id IN (15747,15750,15753,15757,15806,15812,15813,15814,15815,15816,15817,15818) OR a.id IN (1574701,1574702,1574703,1575001,1575002,1575003,1575301,1575302,1575303,1575701,1575702,1575703,1580601,1580602,1580603,1581201,1581202,1581203,1581301,1581302,1581303,1581401,1581402,1581403,1581501,1581502,1581503,1581601,1581602,1581603,1581701,1581702,1581703,1581801,1581802,1581803,1581804))
                AND (e.id IS NULL OR NOT (a.`id` <=> e.`id` AND a.`creature_id` <=> e.`creature_id` AND a.`event_type` <=> e.`event_type` AND a.`event_inverse_phase_mask` <=> e.`event_inverse_phase_mask` AND a.`event_chance` <=> e.`event_chance` AND a.`event_flags` <=> e.`event_flags` AND a.`event_param1` <=> e.`event_param1` AND a.`event_param2` <=> e.`event_param2` AND a.`event_param3` <=> e.`event_param3` AND a.`event_param4` <=> e.`event_param4` AND a.`action1_type` <=> e.`action1_type` AND a.`action1_param1` <=> e.`action1_param1` AND a.`action1_param2` <=> e.`action1_param2` AND a.`action1_param3` <=> e.`action1_param3` AND a.`action2_type` <=> e.`action2_type` AND a.`action2_param1` <=> e.`action2_param1` AND a.`action2_param2` <=> e.`action2_param2` AND a.`action2_param3` <=> e.`action2_param3` AND a.`action3_type` <=> e.`action3_type` AND a.`action3_param1` <=> e.`action3_param1` AND a.`action3_param2` <=> e.`action3_param2` AND a.`action3_param3` <=> e.`action3_param3` AND BINARY a.`comment` <=> BINARY e.`comment`))) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ officer combat AI conflict';
        END IF;
        INSERT INTO creature_ai_texts SELECT e.* FROM expected_aq_officer_text e LEFT JOIN creature_ai_texts a ON a.entry=e.entry WHERE a.entry IS NULL;
        INSERT INTO creature_ai_scripts SELECT e.* FROM expected_aq_officer_ai e LEFT JOIN creature_ai_scripts a ON a.id=e.id WHERE a.id IS NULL;
        UPDATE creature_template SET AIName='EventAI' WHERE entry IN (15747,15750,15753,15757,15806,15812,15813,15814,15815,15816,15817,15818);
        INSERT INTO db_version VALUES ('22','06','016','AQ_Officer_Combat_AI','Add AQ officer combat AI');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='016' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ officer AI migration requires 22/06/015';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
