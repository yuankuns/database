-- Align Officer Maloof's existing phase-4 spawn with the pinned Classic DB.
-- Migration 018 corrected its respawn settings but retained a nearby legacy
-- position because its validation allowed a two-yard radius.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='045' THEN
        IF NOT EXISTS (SELECT 1 FROM `creature` c
            WHERE c.guid=86424 AND c.id=15708 AND c.map=0 AND c.spawntimesecs=120 AND c.spawndist=0
              AND ABS(c.position_x-(-8813.4))<0.01 AND ABS(c.position_y-654.195)<0.01
              AND ABS(c.position_z-96.0776)<0.01 AND ABS(c.orientation-4.5185)<0.001)
           AND NOT EXISTS (SELECT 1 FROM `creature` c
            WHERE c.guid=86424 AND c.id=15708 AND c.map=0 AND c.spawntimesecs=120 AND c.spawndist=0
              AND ABS(c.position_x-(-8813.75))<0.01 AND ABS(c.position_y-654.07)<0.01
              AND ABS(c.position_z-96.16)<0.01 AND ABS(c.orientation-4.83456)<0.001) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Officer Maloof spawn differs from expected source or legacy row';
        END IF;
        IF (SELECT COUNT(*) FROM `game_event_creature` WHERE guid=86424 AND event=129)<>1 OR
           (SELECT COUNT(*) FROM `game_event_creature` WHERE guid=86424)<>1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Officer Maloof phase binding mismatch';
        END IF;

        UPDATE `creature` SET position_x=-8813.75,position_y=654.07,position_z=96.16,orientation=4.83456
          WHERE guid=86424 AND id=15708 AND map=0;
        INSERT INTO `db_version` VALUES ('22','06','046','AQ_Officer_Spawn_Position',
          'Align Officer Maloof spawn with Classic');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='046' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ officer spawn position correction requires 22/06/045';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
