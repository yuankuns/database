-- Remove Zero-only Silithus Hive skinning tables absent from pinned Classic.
-- Keep direct creature-loot rows, including the shared Broken Silithid Chitin drops.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='044' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_classic_unskinnable_hive_templates`;
        CREATE TEMPORARY TABLE `aq_classic_unskinnable_hive_templates` (
          `entry` MEDIUMINT UNSIGNED NOT NULL PRIMARY KEY,
          `name` VARCHAR(100) NOT NULL
        );
        INSERT INTO `aq_classic_unskinnable_hive_templates` VALUES
          (11698,'Hive\'Ashi Stinger'),
          (11721,'Hive\'Ashi Worker'),(11722,'Hive\'Ashi Defender'),
          (11723,'Hive\'Ashi Sandstalker'),(11724,'Hive\'Ashi Swarmer'),
          (11725,'Hive\'Zora Waywatcher'),(11726,'Hive\'Zora Tunneler'),
          (11727,'Hive\'Zora Wasp'),(11728,'Hive\'Zora Reaver'),
          (11729,'Hive\'Zora Hive Sister'),(11730,'Hive\'Regal Ambusher'),
          (11731,'Hive\'Regal Burrower'),(11732,'Hive\'Regal Spitfire'),
          (11733,'Hive\'Regal Slavemaker'),(11734,'Hive\'Regal Hive Lord');

        DROP TEMPORARY TABLE IF EXISTS `aq_classic_unskinnable_hive_rows`;
        CREATE TEMPORARY TABLE `aq_classic_unskinnable_hive_rows` (
          `entry` MEDIUMINT UNSIGNED NOT NULL,
          `item` MEDIUMINT UNSIGNED NOT NULL,
          `chance` FLOAT NOT NULL,
          `groupid` TINYINT UNSIGNED NOT NULL,
          `mincount` MEDIUMINT NOT NULL,
          `maxcount` TINYINT UNSIGNED NOT NULL,
          `condition_id` MEDIUMINT UNSIGNED NOT NULL,
          PRIMARY KEY (`entry`,`item`)
        );
        INSERT INTO `aq_classic_unskinnable_hive_rows` VALUES
          (11698,20498,31.5467,1,1,2,0),(11698,20499,59.7243,1,1,2,0),(11698,20500,8.7289,1,1,1,0),
          (11721,20498,39.3976,1,1,2,0),(11721,20499,60.4819,1,1,2,0),
          (11722,20498,37.0588,1,1,2,0),(11722,20499,62.9412,1,1,2,0),
          (11723,20498,30.2552,1,1,2,0),(11723,20499,58.5662,1,1,2,0),(11723,20501,10.9356,1,1,1,0),
          (11724,20498,27.4569,1,1,2,0),(11724,20499,60.9929,1,1,2,0),(11724,20500,11.5502,1,1,1,0),
          (11725,20498,39.9635,1,1,2,0),(11725,20499,60.0365,1,1,2,0),
          (11726,20498,40.709,1,1,2,0),(11726,20499,59.291,1,1,2,0),
          (11727,20498,30.6137,1,1,2,0),(11727,20499,60.4332,1,1,2,0),(11727,20500,8.9531,1,1,1,0),
          (11728,20498,30.3196,1,1,2,0),(11728,20499,60.4053,1,1,2,0),(11728,20501,9.2751,1,1,1,0),
          (11729,20498,42.5064,1,1,2,0),(11729,20499,57.4936,1,1,2,0),
          (11730,20498,31.8103,1,1,2,0),(11730,20499,57.1552,1,1,2,0),(11730,20501,11.0345,1,1,1,0),
          (11731,20498,42.6332,1,1,2,0),(11731,20499,57.3668,1,1,2,0),
          (11732,20498,30.0806,1,1,2,0),(11732,20499,58.629,1,1,2,0),(11732,20500,11.2903,1,1,1,0),
          (11733,20498,40.4384,1,1,2,0),(11733,20499,59.5616,1,1,2,0),
          (11734,20498,27.3794,1,1,2,0),(11734,20499,61.6688,1,1,2,0),(11734,20501,10.9518,1,1,1,0);

        SELECT COUNT(*) INTO @aq_hive_template_count
          FROM `creature_template` t
          JOIN `aq_classic_unskinnable_hive_templates` s ON s.entry=t.Entry AND s.name=t.Name
          WHERE t.SkinningLootId IN (t.Entry,0);
        IF @aq_hive_template_count<>15 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic Hive skinning template conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `creature_template` t
             JOIN `aq_classic_unskinnable_hive_templates` s ON s.entry=t.Entry
             WHERE t.Name<>s.name OR t.SkinningLootId NOT IN (t.Entry,0)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic Hive skinning template conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `creature_template` t
             JOIN `aq_classic_unskinnable_hive_templates` s ON s.entry=t.SkinningLootId
             WHERE t.Entry<>s.entry) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic Hive skinning template conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `skinning_loot_template` l
             LEFT JOIN `aq_classic_unskinnable_hive_rows` s ON s.entry=l.entry AND s.item=l.item
             WHERE l.entry IN (11698,11721,11722,11723,11724,11725,11726,11727,11728,11729,11730,11731,11732,11733,11734)
               AND (s.entry IS NULL OR l.ChanceOrQuestChance<>s.chance OR l.groupid<>s.groupid OR
                    l.mincountOrRef<>s.mincount OR l.maxcount<>s.maxcount OR l.condition_id<>s.condition_id)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic Hive skinning row conflict';
        END IF;

        DELETE FROM `skinning_loot_template`
          WHERE entry IN (11698,11721,11722,11723,11724,11725,11726,11727,11728,11729,11730,11731,11732,11733,11734);
        UPDATE `creature_template` SET `SkinningLootId`=0
          WHERE Entry IN (11698,11721,11722,11723,11724,11725,11726,11727,11728,11729,11730,11731,11732,11733,11734)
            AND SkinningLootId=Entry;
        INSERT INTO `db_version` VALUES ('22','06','045','Classic_Unskinnable_Hive_Mobs','Remove Zero-only Hive skinning loot');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='045' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic Hive skinning correction requires 22/06/044';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
