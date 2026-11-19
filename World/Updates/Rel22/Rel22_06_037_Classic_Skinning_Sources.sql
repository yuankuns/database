-- Port the pinned Classic 4853 skinning tables for 16 direct donation-item sources.
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
    IF @v='22' AND @s='06' AND @c='036' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_classic_skinning_stage`;
        CREATE TEMPORARY TABLE `aq_classic_skinning_stage` (
          `entry` MEDIUMINT UNSIGNED NOT NULL,
          `item` MEDIUMINT UNSIGNED NOT NULL,
          `chance` FLOAT NOT NULL,
          `groupid` TINYINT UNSIGNED NOT NULL,
          `mincountOrRef` MEDIUMINT NOT NULL,
          `maxcount` TINYINT UNSIGNED NOT NULL,
          `condition_id` MEDIUMINT UNSIGNED NOT NULL,
          PRIMARY KEY (`entry`,`item`)
        );
        INSERT INTO `aq_classic_skinning_stage` VALUES
          (1511,4234,43.872,1,1,1,0),(1511,4235,2.9878,1,1,1,0),(1511,4304,49.5427,1,1,1,0),(1511,8169,3.5976,1,1,1,0),
          (1514,4234,44.4444,1,1,1,0),(1514,4235,2.2989,1,1,1,0),(1514,4304,49.4253,1,1,1,0),(1514,8169,3.8314,1,1,1,0),
          (1516,4234,36.9128,1,1,1,0),(1516,4235,1.3423,1,1,1,0),(1516,4304,54.698,1,1,1,0),(1516,8169,5.0336,1,1,1,0),
          (4342,4234,77,1,1,1,0),(4342,4235,3,1,1,1,0),(4342,4304,20,1,1,1,0),
          (4355,4234,77,1,1,1,0),(4355,4235,3,1,1,1,0),(4355,4304,20,1,1,1,0),
          (4396,4234,80,1,1,1,0),(4396,4235,3,1,1,1,0),(4396,4304,17,1,1,1,0),(4396,8167,25,2,1,1,0),
          (4398,4234,77,1,1,1,0),(4398,4235,3,1,1,1,0),(4398,4304,20,1,1,1,0),(4398,8167,25,2,1,1,0),
          (4399,4234,40,1,1,1,0),(4399,4235,2,1,1,1,0),(4399,4304,52,1,1,1,0),(4399,8167,50,2,1,1,0),(4399,8169,6,1,1,1,0),
          (4400,4234,42,1,1,1,0),(4400,4235,4,1,1,1,0),(4400,4304,51,1,1,1,0),(4400,8167,49,2,1,1,0),(4400,8169,3,1,1,1,0),
          (4504,4234,81.7308,1,1,1,0),(4504,4235,1.9231,1,1,1,0),(4504,4304,16.3462,1,1,1,0),
          (6071,2319,72.9554,1,1,1,0),(6071,4232,5.1956,1,1,1,0),(6071,4234,19.5575,1,1,1,0),(6071,4235,2.2718,1,1,1,0),
          (6215,2319,55.3571,1,1,2,0),(6215,4232,14.2857,1,1,1,0),(6215,4234,28.5714,1,1,2,0),(6215,4235,1.7857,1,1,1,0),
          (8138,4234,69.7725,1,1,2,0),(8138,4235,6.0672,1,1,1,0),(8138,4304,24.1603,1,1,2,0),
          (10882,2319,73.2218,1,1,1,0),(10882,4232,5.4393,1,1,1,0),(10882,4234,20.5021,1,1,1,0),(10882,4235,0.8368,1,1,1,0),
          (14232,4234,0,1,1,1,0),(14232,4235,3.81,1,1,1,0),(14232,4304,18.095,1,1,1,0),
          (14233,4234,0,1,1,1,0),(14233,4235,3.077,1,1,1,0),(14233,4304,24.615,1,1,1,0);

        DROP TEMPORARY TABLE IF EXISTS `aq_classic_skinning_templates`;
        CREATE TEMPORARY TABLE `aq_classic_skinning_templates` (
          `entry` MEDIUMINT UNSIGNED NOT NULL PRIMARY KEY,
          `name` VARCHAR(100) NOT NULL
        );
        INSERT INTO `aq_classic_skinning_templates` VALUES
          (1511,'Enraged Silverback Gorilla'),(1514,'Mokk the Savage'),(1516,'Konda'),
          (4342,'Drywallow Vicejaw'),(4355,'Bloodfen Scytheclaw'),(4396,'Mudrock Tortoise'),
          (4398,'Mudrock Burrower'),(4399,'Mudrock Borer'),(4400,'Mudrock Snapjaw'),
          (4504,'Frostmaw'),(6071,'Legion Hound'),(6215,'Chomper'),
          (8138,'Sul''lithuz Broodling'),(10882,'Arikara'),(14232,'Dart'),(14233,'Ripscale');

        SELECT COUNT(*),COALESCE(SUM(t.Entry IS NULL),0),
          COALESCE(SUM(t.Entry IS NOT NULL AND
            (t.Name<>s.name OR t.SkinningLootId NOT IN (0,s.entry))),0)
          INTO @aq_template_count,@aq_missing_templates,@aq_template_conflicts
          FROM `aq_classic_skinning_templates` s
          LEFT JOIN `creature_template` t ON t.Entry=s.entry;
        SELECT COUNT(*) INTO @aq_external_skinning_refs FROM `creature_template`
          WHERE SkinningLootId IN (1511,1514,1516,4342,4355,4396,4398,4399,4400,4504,6071,6215,8138,10882,14232,14233)
            AND Entry NOT IN (1511,1514,1516,4342,4355,4396,4398,4399,4400,4504,6071,6215,8138,10882,14232,14233);
        IF @aq_template_count<>16 OR @aq_missing_templates<>0 OR
           @aq_template_conflicts<>0 OR @aq_external_skinning_refs<>0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning template conflict';
        END IF;

        SELECT COUNT(*),COALESCE(SUM(l.entry IS NOT NULL AND
            (s.entry IS NULL OR ABS(l.ChanceOrQuestChance-s.chance)>0.0001 OR
             l.groupid<>s.groupid OR l.mincountOrRef<>s.mincountOrRef OR
             l.maxcount<>s.maxcount OR l.condition_id<>s.condition_id)),0)
          INTO @aq_expected_skinning_rows,@aq_bad_skinning_rows
          FROM `skinning_loot_template` l
          LEFT JOIN `aq_classic_skinning_stage` s ON s.entry=l.entry AND s.item=l.item
          WHERE l.entry IN (1511,1514,1516,4342,4355,4396,4398,4399,4400,4504,6071,6215,8138,10882,14232,14233);
        IF @aq_bad_skinning_rows<>0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning loot rows conflict';
        END IF;

        UPDATE `creature_template` t JOIN `aq_classic_skinning_templates` s ON s.entry=t.Entry
          SET t.SkinningLootId=t.Entry WHERE t.SkinningLootId=0;
        DELETE l FROM `skinning_loot_template` l JOIN `aq_classic_skinning_templates` s ON s.entry=l.entry;
        INSERT INTO `skinning_loot_template`
          (`entry`,`item`,`ChanceOrQuestChance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`)
          SELECT `entry`,`item`,`chance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`
          FROM `aq_classic_skinning_stage`;
        INSERT INTO `db_version` VALUES ('22','06','037','Classic_Skinning_Sources',
          'Restore Classic skinning tables for donation sources');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='037' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning source migration requires 22/06/036';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
