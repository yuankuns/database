-- Align the dedicated AQ templates using the Classic class-level damage path
-- with the final source values from cmangos-classic-db update 4833.
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
    IF @v='22' AND @s='06' AND @c='029' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_combat_stat_stage`;
        CREATE TEMPORARY TABLE `aq_combat_stat_stage` (
          `entry` MEDIUMINT UNSIGNED NOT NULL PRIMARY KEY,
          `old_multiplier` FLOAT NOT NULL,
          `old_variance` FLOAT NOT NULL,
          `new_multiplier` FLOAT NOT NULL,
          `new_variance` FLOAT NOT NULL
        );
        INSERT INTO `aq_combat_stat_stage` VALUES
          (15702,1,1,1.6519777,0.4),(15703,1,1,1.6519777,0.4),
          (15704,1,1,1.6519777,0.4),(15707,1,1,1.6519777,0.4),
          (15708,1,1,1.6519777,0.4),(15709,1,1,1.6519777,0.4),
          (15740,1,1,95.86218,0.4),(15741,1,1,95.86218,0.4),(15742,1,1,95.86218,0.4),
          (15743,1,1,36.359596,0.4),(15744,1,1,7.798191,0.4),
          (15748,1,1,3.2848964,0.4),(15749,1,1,2.3999999,0.4),
          (15751,1,1,5.9719963,0.4),(15752,1,1,2.242603,0.4),
          (15754,1,1,8.260088,0.4),(15756,1,1,5.104986,0.4),
          (15758,1,1,8.262116,0.4),(15759,1,1,4.955933,0.4),
          (15769,7.5,1,14.491601,0.4),(15770,1,1,1.8096472,0.4),
          (15771,1,1,1.6527961,0.4),
          (15797,1,1,1.6519777,0.4),(15798,1,1,1.6519777,0.4),
          (15799,1,1,1.6519777,0.4),(15804,1,1,2.0000024,0.4),
          (15805,7.5,1,14.999959,0.4),(15807,1,1,3.4000041,0.4),
          (15808,1,1,2.3999898,0.4),(15810,1,1,3.4000041,0.4),
          (15811,1,1,2.1391175,0.4),(15853,1,1,11.567804,0.4),
          (15861,1,1,4.95763,0.4),(15878,1,1,1.7077303,0.4);

        SELECT COUNT(*),SUM(t.entry IS NOT NULL),
          SUM(t.entry IS NOT NULL AND NOT
            ((t.DamageMultiplier=s.old_multiplier AND t.DamageVariance=s.old_variance) OR
             (t.DamageMultiplier=s.new_multiplier AND t.DamageVariance=s.new_variance)))
          INTO @aq_stage_count,@aq_template_count,@aq_stat_conflicts
          FROM `aq_combat_stat_stage` s LEFT JOIN `creature_template` t ON t.entry=s.entry;
        IF @aq_stage_count<>34 OR COALESCE(@aq_template_count,0)<>34 OR
           COALESCE(@aq_stat_conflicts,0)<>0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ combat-stat template mismatch';
        END IF;

        UPDATE `creature_template` t
        JOIN `aq_combat_stat_stage` s ON s.entry=t.entry
        SET t.DamageMultiplier=s.new_multiplier,t.DamageVariance=s.new_variance
        WHERE t.DamageMultiplier<>s.new_multiplier OR t.DamageVariance<>s.new_variance;
        INSERT INTO `db_version` VALUES ('22','06','030','AQ_Combat_Stat_Parity',
          'Align AQ combat damage stats');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='030' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ combat-stat migration requires 22/06/029';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
