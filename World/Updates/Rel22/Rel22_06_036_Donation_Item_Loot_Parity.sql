-- Apply pinned Classic loot corrections for AQ donation item sources.
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
    IF @v='22' AND @s='06' AND @c='035' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_donation_loot_stage`;
        CREATE TEMPORARY TABLE `aq_donation_loot_stage` (
          `entry` MEDIUMINT UNSIGNED NOT NULL,
          `item` MEDIUMINT UNSIGNED NOT NULL,
          `old_chance` FLOAT NOT NULL,
          `new_chance` FLOAT NOT NULL,
          PRIMARY KEY (`entry`,`item`)
        );
        INSERT INTO `aq_donation_loot_stage` VALUES
          (2956,2318,38.4919,40),(2957,2318,38.7258,40),(2958,2318,40.6289,40),
          (2959,2318,39.7046,40),(2960,2318,40.3959,40),(3035,2318,39.6707,40),
          (3058,2318,60.4563,60),(3566,2318,39.5852,40),(5807,2318,41.3534,40),
          (2476,2318,41.3793,32),(1225,2318,60.7477,70),(1224,2318,78.836,75),
          (1189,2318,73.7338,72),(1192,2318,73.708,72),(1693,2318,60.5804,60),
          (1191,2318,59.1459,60),(1188,2318,59.4855,60),(1186,2318,59.326,60),
          (1190,2318,38.5502,40),(2476,2319,55.1724,57),(1225,2319,26.1682,23),
          (1224,2319,17.4603,17),(1189,2319,19.4935,20),(1192,2319,18.9922,20),
          (976,2319,39.4737,47),(976,4234,57.0175,47),(2347,4234,79.4118,77),
          (2347,4304,20.5882,22),(4339,4234,15.625,30),(4339,4304,28.125,65),
          (4425,4234,56.5217,50),(4425,2319,30.4348,40),(534,4234,42.3077,50),
          (534,2319,42.3077,40),(3792,4234,40,55),(3792,2319,60,40),
          (10077,8170,50,0),(10077,4304,45,30);

        SELECT COUNT(*),COALESCE(SUM(l.entry IS NOT NULL),0),
          COALESCE(SUM(l.entry IS NOT NULL AND
            ABS(l.ChanceOrQuestChance-s.old_chance)>0.0001 AND
            ABS(l.ChanceOrQuestChance-s.new_chance)>0.0001),0)
          INTO @aq_loot_stage_count,@aq_loot_rows,@aq_loot_conflicts
          FROM `aq_donation_loot_stage` s
          LEFT JOIN `skinning_loot_template` l ON l.entry=s.entry AND l.item=s.item;
        IF @aq_loot_stage_count<>38 OR @aq_loot_rows<>38 OR @aq_loot_conflicts<>0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Donation skinning-loot rows conflict with Classic updates';
        END IF;

        DROP TEMPORARY TABLE IF EXISTS `aq_herb_loot_stage`;
        CREATE TEMPORARY TABLE `aq_herb_loot_stage` (
          `entry` MEDIUMINT UNSIGNED NOT NULL PRIMARY KEY,
          `old_maxcount` TINYINT UNSIGNED NOT NULL
        );
        INSERT INTO `aq_herb_loot_stage` VALUES (2022,3),(2027,3),(2029,2);
        SELECT COUNT(*),COALESCE(SUM(l.entry IS NOT NULL),0),
          COALESCE(SUM(l.entry IS NOT NULL AND l.maxcount<>s.old_maxcount AND l.maxcount<>1),0)
          INTO @aq_herb_stage_count,@aq_herb_rows,@aq_herb_conflicts
          FROM `aq_herb_loot_stage` s
          LEFT JOIN `creature_loot_template` l ON l.entry=s.entry AND l.item=2447
            AND l.mincountOrRef=1 AND l.groupid=0 AND l.condition_id=0;
        IF @aq_herb_stage_count<>3 OR @aq_herb_rows<>3 OR @aq_herb_conflicts<>0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Peacebloom creature-loot rows conflict with Classic update';
        END IF;

        IF EXISTS (SELECT 1 FROM `creature_loot_template` WHERE entry=4863 AND item=4234
          AND (ABS(ChanceOrQuestChance-0.7)>0.0001 OR groupid<>0 OR mincountOrRef<>1 OR maxcount<>2 OR condition_id<>0)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Jadespine Basilisk leather row conflict';
        END IF;
        IF (SELECT COUNT(*) FROM `skinning_loot_template` WHERE entry=2447)>5 OR
           EXISTS (SELECT 1 FROM `skinning_loot_template` WHERE entry=2447 AND NOT (
             (item=4234 AND ((ChanceOrQuestChance=28 AND groupid=1 AND maxcount=2) OR (ChanceOrQuestChance=40 AND groupid=1 AND maxcount=2)) AND mincountOrRef=1 AND condition_id=0) OR
             (item=4235 AND ChanceOrQuestChance IN (4,5) AND groupid=1 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0) OR
             (item=4304 AND ((ChanceOrQuestChance=48 AND groupid=1 AND maxcount=2) OR (ChanceOrQuestChance=50 AND groupid=1 AND maxcount=2)) AND mincountOrRef=1 AND condition_id=0) OR
             (item=8165 AND ((ChanceOrQuestChance=4 AND groupid=1) OR (ChanceOrQuestChance=10 AND groupid=2)) AND mincountOrRef=1 AND maxcount=1 AND condition_id=0) OR
             (item=8169 AND ChanceOrQuestChance IN (16,5) AND groupid=1 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0))) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Narillasanz skinning rows conflict with Classic update';
        END IF;
        IF EXISTS (SELECT 1 FROM `creature_template` WHERE entry=2447 AND SkinningLootId<>2447) OR
           (SELECT COUNT(*) FROM `creature_template` WHERE entry IN (8302,4660,14280))<>3 OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE entry=8302 AND SkinningLootId NOT IN (0,8302)) OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE entry=4660 AND SkinningLootId NOT IN (0,4660)) OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE entry=14280 AND SkinningLootId NOT IN (100005,14280)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Donation creature skinning binding conflict';
        END IF;

        DROP TEMPORARY TABLE IF EXISTS `aq_new_skinning_stage`;
        CREATE TEMPORARY TABLE `aq_new_skinning_stage` (
          `entry` MEDIUMINT UNSIGNED NOT NULL,
          `item` MEDIUMINT UNSIGNED NOT NULL,
          `chance` FLOAT NOT NULL,
          `maxcount` TINYINT UNSIGNED NOT NULL,
          PRIMARY KEY (`entry`,`item`)
        );
        INSERT INTO `aq_new_skinning_stage` VALUES
          (8302,4304,85,1),(8302,8170,15,1),
          (4660,4234,75,1),(4660,4235,5,1),(4660,4304,20,1),
          (14280,2319,60,1),(14280,4234,35,1),(14280,4235,5,1);
        SELECT COALESCE(SUM(l.entry IS NOT NULL AND
            (ABS(l.ChanceOrQuestChance-s.chance)>0.0001 OR l.groupid<>1 OR
             l.mincountOrRef<>1 OR l.maxcount<>s.maxcount OR l.condition_id<>0)),0),
          COALESCE(SUM(l.entry IS NOT NULL AND s.entry IS NULL),0)
          INTO @aq_new_skinning_conflicts,@aq_new_skinning_unknown
          FROM `skinning_loot_template` l
          LEFT JOIN `aq_new_skinning_stage` s ON l.entry=s.entry AND l.item=s.item
          WHERE l.entry IN (8302,4660,14280);
        IF @aq_new_skinning_conflicts<>0 OR @aq_new_skinning_unknown<>0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='New donation skinning rows conflict with Classic updates';
        END IF;

        UPDATE `skinning_loot_template` l JOIN `aq_donation_loot_stage` s
          ON l.entry=s.entry AND l.item=s.item
          SET l.ChanceOrQuestChance=s.new_chance
          WHERE ABS(l.ChanceOrQuestChance-s.new_chance)>0.0001;
        UPDATE `creature_loot_template` l JOIN `aq_herb_loot_stage` s ON l.entry=s.entry
          SET l.maxcount=1 WHERE l.item=2447 AND l.maxcount<>1;
        DELETE FROM `creature_loot_template` WHERE entry=4863 AND item=4234;
        DELETE FROM `skinning_loot_template` WHERE entry=2447;
        INSERT INTO `skinning_loot_template` (`entry`,`item`,`ChanceOrQuestChance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`)
          VALUES (2447,4234,40,1,1,2,0),(2447,4235,5,1,1,1,0),(2447,4304,50,1,1,2,0),
                 (2447,8169,5,1,1,1,0),(2447,8165,10,2,1,1,0);
        UPDATE `creature_template` SET SkinningLootId=8302 WHERE entry=8302 AND SkinningLootId=0;
        UPDATE `creature_template` SET SkinningLootId=4660 WHERE entry=4660 AND SkinningLootId=0;
        UPDATE `creature_template` SET SkinningLootId=14280 WHERE entry=14280 AND SkinningLootId=100005;
        INSERT INTO `skinning_loot_template` (`entry`,`item`,`ChanceOrQuestChance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`)
          SELECT s.entry,s.item,s.chance,1,1,s.maxcount,0 FROM `aq_new_skinning_stage` s
          LEFT JOIN `skinning_loot_template` l ON l.entry=s.entry AND l.item=s.item WHERE l.entry IS NULL;
        INSERT INTO `db_version` VALUES ('22','06','036','Donation_Item_Loot_Parity',
          'Align pinned Classic donation item loot sources');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='036' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Donation loot parity migration requires 22/06/035';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
