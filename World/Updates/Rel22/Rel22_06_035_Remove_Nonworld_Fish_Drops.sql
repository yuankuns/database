-- Match Classic update 4638: Spotted Yellowtail is not a creature drop.
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
    IF @v='22' AND @s='06' AND @c='034' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_fish_loot_stage`;
        CREATE TEMPORARY TABLE `aq_fish_loot_stage` (
          `entry` MEDIUMINT UNSIGNED NOT NULL PRIMARY KEY,
          `chance` FLOAT NOT NULL
        );
        INSERT INTO `aq_fish_loot_stage` VALUES
          (379,0.02),(2651,0.02),(2652,0.02),(2655,0.02),(2656,0.02),
          (2691,0.02),(2693,0.02),(2926,0.02),(3662,0.7432),(3692,0.7432),
          (3693,0.7432),(3694,0.7432),(4466,0.02),(4467,0.02);

        SELECT COALESCE(SUM(s.entry IS NULL),0),
          COALESCE(SUM(s.entry IS NOT NULL AND
            (l.ChanceOrQuestChance<>s.chance OR l.groupid<>0 OR
             l.mincountOrRef<>1 OR l.maxcount<>1 OR l.condition_id<>0)),0)
          INTO @aq_unknown_rows,@aq_changed_rows
          FROM `creature_loot_template` l
          LEFT JOIN `aq_fish_loot_stage` s ON s.entry=l.entry
          WHERE l.item=6887;
        IF @aq_unknown_rows<>0 OR @aq_changed_rows<>0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unexpected Spotted Yellowtail creature loot rows';
        END IF;

        DELETE l FROM `creature_loot_template` l
        JOIN `aq_fish_loot_stage` s ON s.entry=l.entry
        WHERE l.item=6887;
        INSERT INTO `db_version` VALUES ('22','06','035','Remove_Nonworld_Fish_Drops',
          'Remove Spotted Yellowtail creature loot');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='035' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Nonworld fish-drop migration requires 22/06/034';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
