-- Restore Classic equipment on AQ war-effort and event-linked templates.
-- Private equipment IDs avoid changing shared templates. Sentinel Silversky
-- uses raw equipment because Zero's shared item 5598 has a different sheath.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='048' THEN
        IF EXISTS (SELECT 1 FROM `creature_template` WHERE
          (Entry=3296 AND (Name<>'Orgrimmar Grunt' OR EquipmentTemplateId NOT IN (133,903296))) OR
          (Entry=5595 AND (Name<>'Ironforge Guard' OR EquipmentTemplateId NOT IN (783,905595))) OR
          (Entry=15423 AND (Name<>'Kaldorei Infantry' OR EquipmentTemplateId NOT IN (2541,915423))) OR
          (Entry=15451 AND (Name<>'Sentinel Silversky' OR EquipmentTemplateId NOT IN (814,915451))) OR
          (Entry IN (15458,15459,15460,15469,15477,15508,15512,15515,15522,15525,15528,15532,15533,15534,15535,15700,15702,15703,15704,15707,15708,15853,15861) AND EquipmentTemplateId NOT IN (0,900000+Entry))) OR
          (SELECT COUNT(*) FROM `creature_template` WHERE Entry IN (3296,5595,15423,15451,15458,15459,15460,15469,15477,15508,15512,15515,15522,15525,15528,15532,15533,15534,15535,15700,15702,15703,15704,15707,15708,15853,15861))<>27 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ event equipment template conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `creature_equip_template` WHERE entry IN (903296,905595,915423,915458,915459,915460,915469,915477,915508,915512,915515,915522,915525,915528,915532,915533,915534,915535,915700,915702,915703,915704,915707,915708,915853,915861)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ event equipment ID conflict';
        END IF;
        IF (SELECT COUNT(*) FROM `creature_item_template` WHERE entry IN (5289,2507,5286,6254,2552,14881,5598,2557,1910,12629,6680,21123,2081,2198,12870,5278,11019,21122,12937,12754,2202,1117,6228,18419,5280,13707,10612,13312,14873,14870,10591))<>31 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ event equipment item missing';
        END IF;
        IF EXISTS (SELECT 1 FROM `creature_equip_template` WHERE entry IN (903296,905595,915423,915458,915459,915460,915469,915477,915508,915512,915515,915522,915525,915528,915532,915533,915534,915535,915700,915702,915703,915704,915707,915708,915853,915861)) OR EXISTS (SELECT 1 FROM `creature_equip_template_raw` WHERE entry=915451) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ event equipment row conflict';
        END IF;
        INSERT INTO `creature_equip_template` (`entry`,`equipentry1`,`equipentry2`,`equipentry3`) VALUES
          (903296,5289,0,2507),(905595,5286,6254,2552),(915423,14881,14881,0),
          (915458,2557,0,0),(915459,1910,0,0),(915460,12629,0,0),(915469,6680,0,0),
          (915477,21123,0,0),(915508,0,2081,0),(915512,2198,12870,0),(915515,5278,0,0),
          (915522,11019,0,0),(915525,21122,0,0),(915528,12937,0,0),(915532,12754,0,0),
          (915533,2202,0,0),(915534,1117,0,0),(915535,6228,0,0),(915700,18419,0,0),
          (915702,5280,0,0),(915703,13707,0,0),(915704,10612,0,0),(915707,13312,0,0),
          (915708,14873,0,0),(915853,14870,0,0),(915861,10591,6254,0);
        INSERT INTO `creature_equip_template_raw` (`entry`,`equipmodel1`,`equipmodel2`,`equipmodel3`,`equipinfo1`,`equipinfo2`,`equipinfo3`,`equipslot1`,`equipslot2`,`equipslot3`)
          VALUES (915451,8377,0,0,218169346,0,0,4,0,0);
        UPDATE `creature_template` SET EquipmentTemplateId=900000+Entry WHERE Entry IN (3296,5595,15423,15458,15459,15460,15469,15477,15508,15512,15515,15522,15525,15528,15532,15533,15534,15535,15700,15702,15703,15704,15707,15708,15853,15861) AND EquipmentTemplateId=0;
        UPDATE `creature_template` SET EquipmentTemplateId=903296 WHERE Entry=3296 AND EquipmentTemplateId=133;
        UPDATE `creature_template` SET EquipmentTemplateId=905595 WHERE Entry=5595 AND EquipmentTemplateId=783;
        UPDATE `creature_template` SET EquipmentTemplateId=915423 WHERE Entry=15423 AND EquipmentTemplateId=2541;
        UPDATE `creature_template` SET EquipmentTemplateId=915451 WHERE Entry=15451 AND EquipmentTemplateId=814;
        INSERT INTO `db_version` VALUES ('22','06','049','AQ_Event_Equipment_Parity','Restore Classic AQ event-linked creature equipment');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='049' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ event equipment parity requires 22/06/048';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
