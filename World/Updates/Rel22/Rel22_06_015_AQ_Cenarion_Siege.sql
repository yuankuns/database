-- CMaNGOS Classic DB e4825cf: spawn group 19012, condition 2099 (event 123), path 19012.
-- Approximation: Zero follows spawn-position offsets instead of a 10-yard formation;
-- the leader wanders at the destination while the others keep following it.
-- Dynamic officer groups still require a separate compatible implementation.
-- Requires the core EventAI SPAWNED_EVENT_GUID condition.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    SET @cCurVersion := (SELECT `version` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 1);
    SET @cCurStructure := (SELECT `structure` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 1);
    SET @cCurContent := (SELECT `content` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 1);
    IF @cCurVersion='22' AND @cCurStructure='06' AND @cCurContent='014' THEN
        -- Temporary expected rows make interrupted MyISAM writes safely resumable.
        DROP TEMPORARY TABLE IF EXISTS `expected_creature`;
        CREATE TEMPORARY TABLE `expected_creature` LIKE `creature`;
        INSERT INTO expected_creature (guid,id,map,modelid,equipment_id,position_x,position_y,position_z,orientation,spawntimesecs,spawndist,currentwaypoint,curhealth,curmana,DeathState,MovementType) VALUES
          (800775,15744,1,0,0,-7191.45,967.22,1.2,6.068,300,0,0,121222,6441,0,2),
          (800776,15743,1,0,0,-7165.47,924.35,10.85,6.154,300,0,0,327554,0,0,0),
          (800777,15743,1,0,0,-7180.06,1020.13,5.63,6.2,300,0,0,327554,0,0,0),
          (800778,15744,1,0,0,-7183.31,943.32,3.89,6.207,300,0,0,121222,6441,0,0),
          (800779,15744,1,0,0,-7189.12,956.26,1.97,0.268,300,0,0,121222,6441,0,0),
          (800780,15744,1,0,0,-7187.99,976.08,2.08,6.234,300,0,0,121222,6441,0,0),
          (800781,15744,1,0,0,-7184.5,985.64,4.14,6.21,300,0,0,121222,6441,0,0);
        DROP TEMPORARY TABLE IF EXISTS `expected_game_event_creature`;
        CREATE TEMPORARY TABLE `expected_game_event_creature` LIKE `game_event_creature`;
        INSERT INTO expected_game_event_creature (guid,event) VALUES (800775,123),(800776,123),(800777,123),(800778,123),(800779,123),(800780,123),(800781,123);
        DROP TEMPORARY TABLE IF EXISTS `expected_creature_linking`;
        CREATE TEMPORARY TABLE `expected_creature_linking` LIKE `creature_linking`;
        INSERT INTO expected_creature_linking (guid,master_guid,flag) VALUES
          (800776,800775,643),(800777,800775,643),(800778,800775,643),
          (800779,800775,643),(800780,800775,643),(800781,800775,643);
        DROP TEMPORARY TABLE IF EXISTS `expected_creature_movement`;
        CREATE TEMPORARY TABLE `expected_creature_movement` LIKE `creature_movement`;
        INSERT INTO expected_creature_movement (id,point,position_x,position_y,position_z,waittime,script_id,orientation) VALUES
          (800775,1,-6997.58,968.7,6.99,0,0,100),
          (800775,2,-6879.74,866.86,35.18,0,0,100),
          (800775,3,-6833.01,751.95,42.67,1000,800775,100);
        DROP TEMPORARY TABLE IF EXISTS `expected_db_scripts`;
        CREATE TEMPORARY TABLE `expected_db_scripts` LIKE `db_scripts`;
        INSERT INTO expected_db_scripts (script_guid,script_type,id,delay,command,datalong,datalong2,data_flags,comments)
          VALUES (800775,3,800775,0,20,1,5,8,'AQ siege leader: wander around destination');
        DROP TEMPORARY TABLE IF EXISTS `expected_creature_ai_texts`;
        CREATE TEMPORARY TABLE `expected_creature_ai_texts` LIKE `creature_ai_texts`;
        INSERT INTO expected_creature_ai_texts (entry,content_default,content_loc2,content_loc3,content_loc6,content_loc7,content_loc8,type,language,comment)
          VALUES (-900775,'Invaders approaching from the south!','Des envahisseurs arrivent du sud !',
                  'Angreifer nähern sich aus dem Süden!','¡Se aproximan invasores por el sur!',
                  '¡Se aproximan invasores por el sur!','Захватчики приближаются с юга!',1,0,'Warcaller Finster - siege warning');
        DROP TEMPORARY TABLE IF EXISTS `expected_creature_ai_scripts`;
        CREATE TEMPORARY TABLE `expected_creature_ai_scripts` LIKE `creature_ai_scripts`;
        INSERT INTO expected_creature_ai_scripts (id,creature_id,event_type,event_inverse_phase_mask,event_chance,event_flags,event_param1,event_param2,event_param3,event_param4,action1_type,action1_param1,action1_param2,action1_param3,action2_type,action2_param1,action2_param2,action2_param3,action3_type,action3_param1,action3_param2,action3_param3,comment) VALUES
          (1574406,15744,11,0,100,0,3,800775,0,0,45,5,533,0,0,0,0,0,0,0,0,0,'AQ siege leader: send custom A on spawn'),
          (1587801,15878,30,0,100,0,5,15744,0,0,1,-900775,0,0,0,0,0,0,0,0,0,0,'Warcaller Finster: yell when the siege approaches');
        IF
           EXISTS (SELECT 1 FROM `creature` a LEFT JOIN `expected_creature` e ON a.`guid`=e.`guid` WHERE (a.guid BETWEEN 800775 AND 800781) AND (e.`guid` IS NULL OR NOT (a.`guid` <=> e.`guid` AND a.`id` <=> e.`id` AND a.`map` <=> e.`map` AND a.`modelid` <=> e.`modelid` AND a.`equipment_id` <=> e.`equipment_id` AND a.`position_x` <=> e.`position_x` AND a.`position_y` <=> e.`position_y` AND a.`position_z` <=> e.`position_z` AND a.`orientation` <=> e.`orientation` AND a.`spawntimesecs` <=> e.`spawntimesecs` AND a.`spawndist` <=> e.`spawndist` AND a.`currentwaypoint` <=> e.`currentwaypoint` AND a.`curhealth` <=> e.`curhealth` AND a.`curmana` <=> e.`curmana` AND a.`DeathState` <=> e.`DeathState` AND a.`MovementType` <=> e.`MovementType`))) OR
           EXISTS (SELECT 1 FROM `game_event_creature` a LEFT JOIN `expected_game_event_creature` e ON a.`guid`=e.`guid` WHERE (a.guid BETWEEN 800775 AND 800781) AND (e.`guid` IS NULL OR NOT (a.`guid` <=> e.`guid` AND a.`event` <=> e.`event`))) OR
           EXISTS (SELECT 1 FROM `creature_linking` a LEFT JOIN `expected_creature_linking` e ON a.`guid`=e.`guid` WHERE (a.guid BETWEEN 800775 AND 800781 OR a.master_guid BETWEEN 800775 AND 800781) AND (e.`guid` IS NULL OR NOT (a.`guid` <=> e.`guid` AND a.`master_guid` <=> e.`master_guid` AND a.`flag` <=> e.`flag`))) OR
           EXISTS (SELECT 1 FROM `creature_movement` a LEFT JOIN `expected_creature_movement` e ON a.`id`=e.`id` AND a.`point`=e.`point` WHERE (a.id BETWEEN 800775 AND 800781) AND (e.`id` IS NULL OR NOT (a.`id` <=> e.`id` AND a.`point` <=> e.`point` AND a.`position_x` <=> e.`position_x` AND a.`position_y` <=> e.`position_y` AND a.`position_z` <=> e.`position_z` AND a.`waittime` <=> e.`waittime` AND a.`script_id` <=> e.`script_id` AND a.`textid1` <=> e.`textid1` AND a.`textid2` <=> e.`textid2` AND a.`textid3` <=> e.`textid3` AND a.`textid4` <=> e.`textid4` AND a.`textid5` <=> e.`textid5` AND a.`emote` <=> e.`emote` AND a.`spell` <=> e.`spell` AND a.`orientation` <=> e.`orientation` AND a.`model1` <=> e.`model1` AND a.`model2` <=> e.`model2`))) OR
           EXISTS (SELECT 1 FROM `db_scripts` a LEFT JOIN `expected_db_scripts` e ON a.`script_guid`=e.`script_guid` WHERE (a.script_guid=800775 OR (a.script_type=3 AND a.id=800775)) AND (e.`script_guid` IS NULL OR NOT (a.`script_guid` <=> e.`script_guid` AND a.`script_type` <=> e.`script_type` AND a.`id` <=> e.`id` AND a.`delay` <=> e.`delay` AND a.`command` <=> e.`command` AND a.`datalong` <=> e.`datalong` AND a.`datalong2` <=> e.`datalong2` AND a.`buddy_entry` <=> e.`buddy_entry` AND a.`search_radius` <=> e.`search_radius` AND a.`data_flags` <=> e.`data_flags` AND a.`dataint` <=> e.`dataint` AND a.`dataint2` <=> e.`dataint2` AND a.`dataint3` <=> e.`dataint3` AND a.`dataint4` <=> e.`dataint4` AND a.`x` <=> e.`x` AND a.`y` <=> e.`y` AND a.`z` <=> e.`z` AND a.`o` <=> e.`o` AND BINARY a.`comments` <=> BINARY e.`comments`))) OR
           EXISTS (SELECT 1 FROM `creature_ai_texts` a LEFT JOIN `expected_creature_ai_texts` e ON a.`entry`=e.`entry` WHERE (a.entry=-900775) AND (e.`entry` IS NULL OR NOT (a.`entry` <=> e.`entry` AND BINARY a.`content_default` <=> BINARY e.`content_default` AND BINARY a.`content_loc1` <=> BINARY e.`content_loc1` AND BINARY a.`content_loc2` <=> BINARY e.`content_loc2` AND BINARY a.`content_loc3` <=> BINARY e.`content_loc3` AND BINARY a.`content_loc4` <=> BINARY e.`content_loc4` AND BINARY a.`content_loc5` <=> BINARY e.`content_loc5` AND BINARY a.`content_loc6` <=> BINARY e.`content_loc6` AND BINARY a.`content_loc7` <=> BINARY e.`content_loc7` AND BINARY a.`content_loc8` <=> BINARY e.`content_loc8` AND a.`sound` <=> e.`sound` AND a.`type` <=> e.`type` AND a.`language` <=> e.`language` AND a.`emote` <=> e.`emote` AND BINARY a.`comment` <=> BINARY e.`comment`))) OR
           EXISTS (SELECT 1 FROM `creature_ai_scripts` a LEFT JOIN `expected_creature_ai_scripts` e ON a.`id`=e.`id` WHERE (a.id IN (1574406,1587801) OR a.creature_id=15878) AND (e.`id` IS NULL OR NOT (a.`id` <=> e.`id` AND a.`creature_id` <=> e.`creature_id` AND a.`event_type` <=> e.`event_type` AND a.`event_inverse_phase_mask` <=> e.`event_inverse_phase_mask` AND a.`event_chance` <=> e.`event_chance` AND a.`event_flags` <=> e.`event_flags` AND a.`event_param1` <=> e.`event_param1` AND a.`event_param2` <=> e.`event_param2` AND a.`event_param3` <=> e.`event_param3` AND a.`event_param4` <=> e.`event_param4` AND a.`action1_type` <=> e.`action1_type` AND a.`action1_param1` <=> e.`action1_param1` AND a.`action1_param2` <=> e.`action1_param2` AND a.`action1_param3` <=> e.`action1_param3` AND a.`action2_type` <=> e.`action2_type` AND a.`action2_param1` <=> e.`action2_param1` AND a.`action2_param2` <=> e.`action2_param2` AND a.`action2_param3` <=> e.`action2_param3` AND a.`action3_type` <=> e.`action3_type` AND a.`action3_param1` <=> e.`action3_param1` AND a.`action3_param2` <=> e.`action3_param2` AND a.`action3_param3` <=> e.`action3_param3` AND BINARY a.`comment` <=> BINARY e.`comment`))) OR
           -- These tables are not written by this migration. Orphan rows for
           -- the reserved GUIDs would silently change the new spawns.
           EXISTS (SELECT 1 FROM creature_addon WHERE guid BETWEEN 800775 AND 800781) OR
           EXISTS (SELECT 1 FROM pool_creature WHERE guid BETWEEN 800775 AND 800781) OR
           EXISTS (SELECT 1 FROM game_event_creature_data WHERE guid BETWEEN 800775 AND 800781) OR
           EXISTS (SELECT 1 FROM creature_battleground WHERE guid BETWEEN 800775 AND 800781) OR
           EXISTS (SELECT 1 FROM script_binding WHERE type=0 AND bind=15878) OR
           NOT EXISTS (SELECT 1 FROM creature_template WHERE entry=15744 AND AIName='EventAI') OR
           NOT EXISTS (SELECT 1 FROM creature_template WHERE entry=15878 AND
                 (AIName='' OR (AIName='EventAI' AND EXISTS (SELECT 1 FROM creature_ai_texts WHERE entry=-900775)))) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ siege spawn, linking, or script conflict';
        END IF;
        -- All conflicts are checked before writing: these world tables are MyISAM.
        INSERT INTO `creature` SELECT e.* FROM `expected_creature` e LEFT JOIN `creature` a ON a.`guid`=e.`guid` WHERE a.`guid` IS NULL;
        INSERT INTO `game_event_creature` SELECT e.* FROM `expected_game_event_creature` e LEFT JOIN `game_event_creature` a ON a.`guid`=e.`guid` WHERE a.`guid` IS NULL;
        INSERT INTO `creature_linking` SELECT e.* FROM `expected_creature_linking` e LEFT JOIN `creature_linking` a ON a.`guid`=e.`guid` WHERE a.`guid` IS NULL;
        INSERT INTO `creature_movement` SELECT e.* FROM `expected_creature_movement` e LEFT JOIN `creature_movement` a ON a.`id`=e.`id` AND a.`point`=e.`point` WHERE a.`id` IS NULL;
        INSERT INTO `db_scripts` SELECT e.* FROM `expected_db_scripts` e LEFT JOIN `db_scripts` a ON a.`script_guid`=e.`script_guid` WHERE a.`script_guid` IS NULL;
        INSERT INTO `creature_ai_texts` SELECT e.* FROM `expected_creature_ai_texts` e LEFT JOIN `creature_ai_texts` a ON a.`entry`=e.`entry` WHERE a.`entry` IS NULL;
        UPDATE creature_template SET AIName='EventAI' WHERE entry=15878;
        INSERT INTO `creature_ai_scripts` SELECT e.* FROM `expected_creature_ai_scripts` e LEFT JOIN `creature_ai_scripts` a ON a.`id`=e.`id` WHERE a.`id` IS NULL;
        INSERT INTO db_version VALUES ('22','06','015','AQ_Cenarion_Siege','Add Cenarion Hold siege patrol');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @cCurVersion='22' AND @cCurStructure='06' AND @cCurContent='015' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ siege migration requires 22/06/014';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
