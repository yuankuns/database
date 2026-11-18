-- Align the existing AQ phase officers and two existing event spawns with
-- the source CMaNGOS Classic DB. Migration 006 retained these Zero GUIDs and
-- positions, but also retained their non-parity respawn/radius settings.
-- Preflight accepts either the known pre-migration values or the target values
-- so an interrupted MyISAM update can safely be retried.
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
    IF @v='22' AND @s='06' AND @c='017' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_spawn_parity_stage`;
        CREATE TEMPORARY TABLE `aq_spawn_parity_stage` (
          `guid` INT UNSIGNED NOT NULL PRIMARY KEY,
          `entry` MEDIUMINT UNSIGNED NOT NULL,
          `map` INT UNSIGNED NOT NULL,
          `x` FLOAT NOT NULL,
          `y` FLOAT NOT NULL,
          `z` FLOAT NOT NULL,
          `old_respawn` INT UNSIGNED NOT NULL,
          `old_wander` FLOAT NOT NULL,
          `respawn` INT UNSIGNED NOT NULL,
          `wander` FLOAT NOT NULL,
          `event` SMALLINT NOT NULL
        ) ENGINE=InnoDB;
        INSERT INTO `aq_spawn_parity_stage` VALUES
          (38,15763,0,-4811.98,-1264.85,501.951,300,0,120,0,128),
          (2032,15764,0,-4814.48,-1055.52,502.267,300,0,120,0,128),
          (6519,15765,1,1911.7,-4276.77,31.6557,300,0,120,0,128),
          (6520,15761,1,1945.32,-4330.31,22.1011,300,0,120,0,128),
          (25997,15767,1,-1246.48,74.2627,128.368,250,0,120,0,128),
          (32076,15768,0,1587.89,279.28,-43.0193,300,0,120,0,128),
          (46803,15762,1,9965.52,2533.72,1319,300,0,120,0,128),
          (79695,15766,0,-8859.14,638.287,96.3469,300,0,120,0,128),
          (86424,15708,0,-8813.75,654.07,96.16,3540,0,120,0,129),
          (14446,3456,1,-4077.81,-1971.24,91.8165,275,5,275,0,-123),
          (51412,8147,1,-4403.02,269.403,25.3358,300,15,300,0,-123);

        IF (SELECT COUNT(*) FROM `aq_spawn_parity_stage`)<>11 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ spawn parity manifest count mismatch';
        END IF;
        IF EXISTS (SELECT 1 FROM `aq_spawn_parity_stage` s
                   LEFT JOIN `creature` c ON c.guid=s.guid
                   WHERE c.guid IS NULL OR c.id<>s.entry OR c.map<>s.map OR
                     POW(c.position_x-s.x,2)+POW(c.position_y-s.y,2)+POW(c.position_z-s.z,2)>=4 OR
                     (c.spawntimesecs<>s.old_respawn AND c.spawntimesecs<>s.respawn) OR
                     (c.spawndist<>s.old_wander AND c.spawndist<>s.wander)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ existing spawn differs from expected source values';
        END IF;
        IF EXISTS (SELECT 1 FROM `aq_spawn_parity_stage` s
                   LEFT JOIN `game_event_creature` e ON e.guid=s.guid
                   WHERE e.guid IS NULL OR e.event<>s.event) OR
           (SELECT COUNT(*) FROM `game_event_creature` e
            WHERE e.guid IN (38,2032,6519,6520,25997,32076,46803,79695,86424,14446,51412))<>11 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ existing spawn event binding mismatch';
        END IF;

        UPDATE `creature` c JOIN `aq_spawn_parity_stage` s ON s.guid=c.guid
          SET c.spawntimesecs=s.respawn,c.spawndist=s.wander;
        INSERT INTO `db_version` VALUES ('22','06','018','AQ_Existing_Spawn_Parity',
          'Align existing AQ phase spawn timers and radii with Classic');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='018' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ spawn parity migration requires 22/06/017';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
