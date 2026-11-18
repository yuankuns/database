-- Restore the Classic skinning loot binding for Qiraji Scarabs.
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
    IF @v='22' AND @s='06' AND @c='026' THEN
        IF NOT EXISTS (SELECT 1 FROM `creature_template` WHERE `entry`=15316) OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE `entry`=15316 AND `SkinningLootId` NOT IN (0,100003)) OR
           (SELECT COUNT(*) FROM `skinning_loot_template` WHERE `entry`=100003)<>2 OR
           NOT EXISTS (SELECT 1 FROM `skinning_loot_template` WHERE `entry`=100003 AND `item`=8170 AND
             `ChanceOrQuestChance`=80 AND `groupid`=1 AND `mincountOrRef`=1 AND `maxcount`=1 AND `condition_id`=0) OR
           NOT EXISTS (SELECT 1 FROM `skinning_loot_template` WHERE `entry`=100003 AND `item`=8171 AND
             `ChanceOrQuestChance`=20 AND `groupid`=1 AND `mincountOrRef`=1 AND `maxcount`=1 AND `condition_id`=0) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Qiraji Scarab skinning data conflict';
        END IF;

        UPDATE `creature_template` SET `SkinningLootId`=100003 WHERE `entry`=15316 AND `SkinningLootId`=0;
        INSERT INTO `db_version` VALUES ('22','06','027','AQ_Qiraji_Scarab_Skinning',
          'Restore Qiraji Scarab skinning');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='027' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ scarab skinning migration requires 22/06/026';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
