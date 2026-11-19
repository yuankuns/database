-- Restore Lieutenant General Nokhor's Classic two-handed axe on the dynamic
-- AQ officer roster. Zero already has the matching monster item in
-- creature_item_template; the template binding and equipment row were missing.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='047' THEN
        IF (SELECT COUNT(*) FROM `creature_template`
            WHERE Entry=15818 AND Name='Lieutenant General Nokhor' AND EquipmentTemplateId IN (0,15818))<>1 OR
           EXISTS (SELECT 1 FROM `creature_template`
            WHERE Entry=15818 AND (Name<>'Lieutenant General Nokhor' OR EquipmentTemplateId NOT IN (0,15818))) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Nokhor equipment template conflict';
        END IF;
        IF (SELECT COUNT(*) FROM `creature_item_template` WHERE entry=13706 AND class=2 AND subclass=1 AND
              material=1 AND displayid=24446 AND inventory_type=17 AND sheath_type=1)<>1 OR
           EXISTS (SELECT 1 FROM `creature_item_template` WHERE entry=13706 AND
              (class<>2 OR subclass<>1 OR material<>1 OR displayid<>24446 OR inventory_type<>17 OR sheath_type<>1)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Nokhor monster item data mismatch';
        END IF;
        IF EXISTS (SELECT 1 FROM `creature_equip_template` WHERE entry=15818 AND
             (equipentry1<>13706 OR equipentry2<>0 OR equipentry3<>0)) OR
           EXISTS (SELECT 1 FROM `creature_equip_template_raw` WHERE entry=15818) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Nokhor equipment row conflict';
        END IF;
        INSERT IGNORE INTO `creature_equip_template` (`entry`,`equipentry1`,`equipentry2`,`equipentry3`)
          VALUES (15818,13706,0,0);
        UPDATE `creature_template` SET EquipmentTemplateId=15818
          WHERE Entry=15818 AND Name='Lieutenant General Nokhor' AND EquipmentTemplateId=0;
        INSERT INTO `db_version` VALUES ('22','06','048','AQ_Nokhor_Equipment',
          'Restore Classic AQ roster weapon display');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='048' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ Nokhor equipment restoration requires 22/06/047';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
