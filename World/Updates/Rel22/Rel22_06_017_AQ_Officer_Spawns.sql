-- CMaNGOS Classic DB e4825cf: AQ 10-hour-war spawn groups 19006-19011.
-- Zero has no spawn_group/world-state condition support. Preserve the six
-- named officers and all 41 occupants as fixed game-event spawns in phase 4.
-- The source randomly selects a slot for each named officer; this port fixes
-- each officer to the first source GUID in its group. Source respawn range
-- 600-900 seconds is represented by Zero's fixed 750-second respawn.
-- The destination creature/event tables are MyISAM and cannot roll back.
-- Check all predictable conflicts before writing; inserts are idempotent and
-- the version row is last so rerunning 016 can finish an interrupted update.
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
    IF @v='22' AND @s='06' AND @c='016' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_officer_spawn_stage`;
        CREATE TEMPORARY TABLE `aq_officer_spawn_stage` (
          `source_guid` INT UNSIGNED NOT NULL,
          `guid` INT UNSIGNED NOT NULL PRIMARY KEY,
          `entry` MEDIUMINT UNSIGNED NOT NULL,
          `map` INT UNSIGNED NOT NULL,
          `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL,
          `orientation` FLOAT NOT NULL,
          `group_id` INT UNSIGNED NOT NULL
        ) ENGINE=InnoDB;
        INSERT INTO `aq_officer_spawn_stage` VALUES
          (155482,802000,15818,1,-8506.98,-2536.04,43.3,0,19006),
          (155612,802001,15757,1,-7828.52,934.79,-0.4,0,19006),
          (155625,802002,15757,1,-7630.52,1323.37,2.62,0,19006),
          (155651,802003,15757,1,-7326.09,1304.46,7.23,0,19006),
          (155664,802004,15757,1,-7302.47,600.01,1.14,0,19006),
          (155690,802005,15757,1,-6784.24,1234.61,6.29,0,19006),
          (155807,802006,15757,1,-6605.68,1801.24,0.28,0,19006),
          (155833,802007,15757,1,-7403.7,821.94,1.45,0,19006),
          (155339,802008,15817,1,-4382.33,243.59,25.58,0,19007),
          (155430,802009,15753,1,-7173.66,-3795.38,8.47,0,19007),
          (155443,802010,15753,1,-7381.78,-4027.6,9.01,0,19007),
          (155456,802011,15753,1,-7570.78,-4490.73,9.01,0,19007),
          (155469,802012,15753,1,-8636.91,-3797.3,21.51,0,19007),
          (155495,802013,15753,1,-7305.97,-3206.02,9.64,0,19007),
          (155508,802014,15753,1,-7402.15,-3640.85,9.44,0,19007),
          (155521,802015,15753,1,-7818.68,-3306.44,62.74,0,19007),
          (155534,802016,15753,1,-6846.83,202.21,3.25,0,19007),
          (155599,802017,15753,1,-7849.5,1764.16,-0.21,0,19007),
          (155638,802018,15753,1,-7426.78,332.49,8.83,0,19007),
          (155677,802019,15753,1,-7131.6,1450.79,2.81,0,19007),
          (155391,802020,15816,1,-5750.83,-3489.55,-57.25,0,19008),
          (155404,802021,15750,1,-6114.33,-3942.42,-58.62,0,19008),
          (155417,802022,15750,1,-6573.5,-3653.97,-58.62,0,19008),
          (155703,802023,15750,1,-6256.02,-3553.3,-58.62,0,19008),
          (155352,802024,15815,1,-5293.12,-1811.42,-55.61,0,19009),
          (155365,802025,15747,1,-5543.27,-2572.61,-57.17,0,19009),
          (155378,802026,15747,1,-5501.18,-3283.62,-36.87,0,19009),
          (155716,802027,15747,1,-5099.89,-1391.94,-51.99,0,19009),
          (155547,802028,15814,1,-4106.91,-1938.93,93.55,0,19010),
          (155560,802029,15806,1,-3804.7,-2218.57,94.22,0,19010),
          (155573,802030,15806,1,-3285.18,-2137.1,91.91,0,19010),
          (155586,802031,15806,1,-857.68,-3224.33,92.83,0,19010),
          (155729,802032,15806,1,-3368.76,-1963.6,93.66,0,19010),
          (155742,802033,15806,1,-2640.28,-1994.15,97.78,0,19010),
          (155313,802034,15813,1,-760.635,-2780.73,93.6667,0,19011),
          (155326,802035,15812,1,-132.5,-2232.31,91.66,0,19011),
          (155755,802036,15812,1,-2196.22,-2012.76,94.28,0,19011),
          (155768,802037,15812,1,-233.33,-2750,93.47,0,19011),
          (155781,802038,15812,1,-1834.06,-2883.61,91.75,0,19011),
          (155794,802039,15812,1,-1333.52,-2049.01,91.79,0,19011),
          (155820,802040,15812,1,-2337.32,-2371.55,93.25,0,19011);

        IF (SELECT COUNT(*) FROM `creature_template` WHERE `entry` IN
            (15747,15750,15753,15757,15806,15812,15813,15814,15815,15816,15817,15818)) <> 12 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ officer templates missing';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM `game_event` WHERE `entry`=123) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ 10-hour-war event missing';
        END IF;
        IF EXISTS (SELECT 1 FROM `aq_officer_spawn_stage` s
             LEFT JOIN `creature` c ON c.guid=s.guid
             LEFT JOIN `creature_template` t ON t.entry=s.entry
             WHERE c.guid IS NOT NULL AND (c.id<>s.entry OR c.map<>s.map OR
               POW(c.position_x-s.x,2)+POW(c.position_y-s.y,2)+POW(c.position_z-s.z,2)>=0.01 OR
               c.orientation<>s.orientation OR c.modelid<>0 OR c.equipment_id<>0 OR
               c.spawntimesecs<>750 OR c.spawndist<>0 OR c.currentwaypoint<>0 OR
               c.curhealth<>GREATEST(t.MinLevelHealth,1) OR c.curmana<>t.MinLevelMana OR
               c.DeathState<>0 OR c.MovementType<>0)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ officer creature GUID conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `aq_officer_spawn_stage` s LEFT JOIN `creature_template` t ON t.entry=s.entry WHERE t.entry IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ officer creature template missing';
        END IF;
        IF EXISTS (SELECT 1 FROM `aq_officer_spawn_stage` s JOIN `game_event_creature` e ON e.guid=s.guid WHERE e.event<>123) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ officer event binding conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `game_event_creature` e LEFT JOIN `aq_officer_spawn_stage` s ON s.guid=e.guid
             WHERE e.event=123 AND e.guid BETWEEN 802000 AND 802040 AND s.guid IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ officer spawn conflict';
        END IF;

        INSERT IGNORE INTO `creature`
          (`guid`,`id`,`map`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,
           `spawntimesecs`,`spawndist`,`currentwaypoint`,`curhealth`,`curmana`,`DeathState`,`MovementType`)
        SELECT s.guid,s.entry,s.map,0,0,s.x,s.y,s.z,s.orientation,750,0,0,
          GREATEST(t.MinLevelHealth,1),t.MinLevelMana,0,0
        FROM `aq_officer_spawn_stage` s JOIN `creature_template` t ON t.entry=s.entry;
        INSERT IGNORE INTO `game_event_creature` (`guid`,`event`)
          SELECT `guid`,123 FROM `aq_officer_spawn_stage`;
        INSERT INTO `db_version` VALUES ('22','06','017','AQ_Officer_Spawns','Add AQ 10-hour-war officers and guards');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='017' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ officer spawn migration requires 22/06/016';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
