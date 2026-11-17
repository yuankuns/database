-- Add the 50 resource piles used by the AQ gathering progress tiers.
-- Source: CMaNGOS Classic Full_DB revision e4825cf48176edff313d78de66b0beb14371c8eb.
-- Event IDs 131-180 are controlled by the matching AQ core runtime.
DROP PROCEDURE IF EXISTS `update_mangos`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SHOW ERRORS;
        SELECT '* UPDATE FAILED *' AS `===== Status =====`,
               @cCurResult AS `===== DB is on Version: =====`;
        RESIGNAL;
    END;

    SET @cCurVersion := (SELECT `version` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cCurStructure := (SELECT `structure` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cCurContent := (SELECT `content` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);

    SET @cOldVersion = '22';
    SET @cOldStructure = '06';
    SET @cOldContent = '011';
    SET @cNewVersion = '22';
    SET @cNewStructure = '06';
    SET @cNewContent = '012';
    SET @cNewDescription = 'AQ_War_Effort_Resource_Visuals';
    SET @cNewComment = 'Add AQ supply tier visuals';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version`=@cOldVersion AND `structure`=@cOldStructure AND `content`=@cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version`=@cNewVersion AND `structure`=@cNewStructure AND `content`=@cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        START TRANSACTION;

        CREATE TEMPORARY TABLE IF NOT EXISTS `aq_resource_visual_stage` (
          `source_guid` INT UNSIGNED PRIMARY KEY, `guid` INT UNSIGNED NOT NULL,
          `entry` MEDIUMINT UNSIGNED NOT NULL, `map` INT UNSIGNED NOT NULL,
          `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL,
          `orientation` FLOAT NOT NULL, `r0` FLOAT NOT NULL, `r1` FLOAT NOT NULL,
          `r2` FLOAT NOT NULL, `r3` FLOAT NOT NULL,
          `respawn` INT UNSIGNED NOT NULL, `event` SMALLINT NOT NULL,
          `new_spawn` BOOLEAN NOT NULL
        ) ENGINE=InnoDB;
        DELETE FROM `aq_resource_visual_stage`;
        INSERT INTO `aq_resource_visual_stage` VALUES
          (155010,800100,180692,0,-4958.52,-1179.33,501.66,2.26893,0,0,0.906307,0.422619,120,131,1),
          (155020,800101,180693,0,-4958.52,-1179.33,501.66,2.26893,0,0,0.906307,0.422619,120,132,1),
          (155030,800102,180694,0,-4958.52,-1179.33,501.66,2.26893,0,0,0.906307,0.422619,120,133,1),
          (155040,800103,180695,0,-4958.52,-1179.33,501.66,2.26893,0,0,0.906307,0.422619,120,134,1),
          (155050,800104,180696,0,-4958.52,-1179.33,501.66,2.26893,0,0,0.906307,0.422619,120,135,1),
          (155011,800105,180674,0,-4968.33,-1152.89,501.93,2.27,0,0,0.906307,0.422619,120,136,1),
          (155021,800106,180675,0,-4969.21,-1143.84,509.25,2.2,0,0,0.909961,0.414694,120,137,1),
          (155031,800107,180676,0,-4983,-1136.22,501.67,2.3,0,0,0.913545,0.406738,120,138,1),
          (155041,800108,180677,0,-4975.6,-1147.33,509.25,2.27,0,0,0.906307,0.422619,120,139,1),
          (155051,800109,180678,0,-4974.11,-1148.4,510.85,2.27,0,0,0.906307,0.422619,120,140,1),
          (155012,800110,180780,0,-4913.85,-1226,501.651,2.25147,0,0,0.902585,0.430512,120,141,1),
          (155022,800111,180781,0,-4913.85,-1226,501.651,2.25147,0,0,0.902585,0.430512,120,142,1),
          (155032,800112,180782,0,-4913.85,-1226,501.651,2.25147,0,0,0.902585,0.430512,120,143,1),
          (155042,800113,180783,0,-4913.85,-1226,501.651,2.25147,0,0,0.902585,0.430512,120,144,1),
          (155052,800114,180784,0,-4913.85,-1226,501.651,2.25147,0,0,0.902585,0.430512,120,145,1),
          (155013,800115,180800,0,-4937.29,-1282.74,501.672,2.26893,0,0,0.906307,0.422619,120,146,1),
          (155023,800116,180806,0,-4937.29,-1282.74,501.672,2.26893,0,0,0.906307,0.422619,120,147,1),
          (155033,800117,180807,0,-4937.29,-1282.74,501.672,2.26893,0,0,0.906307,0.422619,120,148,1),
          (155043,800118,180808,0,-4937.29,-1282.74,501.672,2.26893,0,0,0.906307,0.422619,120,149,1),
          (155053,800119,180809,0,-4937.29,-1282.74,501.672,2.26893,0,0,0.906307,0.422619,120,150,1),
          (155014,800120,180801,0,-4935.58,-1284.82,501.671,2.25147,0,0,0.902585,0.430512,120,151,1),
          (155024,800121,180802,0,-4935.58,-1284.82,501.671,2.25147,0,0,0.902585,0.430512,120,152,1),
          (155034,800122,180803,0,-4935.58,-1284.82,501.671,2.25147,0,0,0.902585,0.430512,120,153,1),
          (155044,800123,180804,0,-4935.58,-1284.82,501.671,2.25147,0,0,0.902585,0.430512,120,154,1),
          (155054,800124,180805,0,-4935.58,-1284.82,501.671,2.25147,0,0,0.902585,0.430512,120,155,1),
          (155510,800125,180813,1,1590.88,-4155.33,36.298,3.68265,0,0,-0.96363,0.267241,120,156,1),
          (155520,800126,180814,1,1590.88,-4155.33,36.298,3.68265,0,0,-0.96363,0.267241,120,157,1),
          (155530,800127,180815,1,1590.88,-4155.33,36.298,3.68265,0,0,-0.96363,0.267241,120,158,1),
          (155540,800128,180816,1,1590.88,-4155.33,36.298,3.68265,0,0,-0.96363,0.267241,120,159,1),
          (155550,800129,180817,1,1590.88,-4155.33,36.298,3.68265,0,0,-0.96363,0.267241,120,160,1),
          (155511,800130,180819,1,1637.1,-4147.25,36.0531,3.73501,0,0,-0.956305,0.292372,120,161,1),
          (155521,800131,180820,1,1637.1,-4147.25,36.0531,3.73501,0,0,-0.956305,0.292372,120,162,1),
          (155531,800132,180821,1,1637.1,-4147.25,36.0531,3.73501,0,0,-0.956305,0.292372,120,163,1),
          (155541,800133,180822,1,1637.1,-4147.25,36.0531,3.73501,0,0,-0.956305,0.292372,120,164,1),
          (155551,800134,180823,1,1637.1,-4147.25,36.0531,3.73501,0,0,-0.956305,0.292372,120,165,1),
          (155512,800135,180827,1,1579.33,-4109.25,34.5487,3.71755,0,0,-0.958819,0.284016,120,166,1),
          (155522,800136,180828,1,1579.33,-4109.25,34.5487,3.71755,0,0,-0.958819,0.284016,120,167,1),
          (155532,800137,180829,1,1579.33,-4109.25,34.5487,3.71755,0,0,-0.958819,0.284016,120,168,1),
          (155542,800138,180830,1,1579.33,-4109.25,34.5487,3.71755,0,0,-0.958819,0.284016,120,169,1),
          (155552,800139,180831,1,1579.33,-4109.25,34.5487,3.71755,0,0,-0.958819,0.284016,120,170,1),
          (155513,800140,180833,1,1619.8,-4092.53,34.4888,3.7001,0,0,-0.961261,0.27564,120,171,1),
          (155523,800141,180834,1,1619.8,-4092.53,34.4888,3.7001,0,0,-0.961261,0.27564,120,172,1),
          (155533,800142,180835,1,1619.8,-4092.53,34.4888,3.7001,0,0,-0.961261,0.27564,120,173,1),
          (155543,800143,180836,1,1619.8,-4092.53,34.4888,3.7001,0,0,-0.961261,0.27564,120,174,1),
          (155553,800144,180837,1,1619.8,-4092.53,34.4888,3.7001,0,0,-0.961261,0.27564,120,175,1),
          (155514,800145,180839,1,1683.1,-4134.31,39.539,3.73501,0,0,-0.956305,0.292372,120,176,1),
          (155524,800146,180840,1,1683.1,-4134.31,39.539,3.73501,0,0,-0.956305,0.292372,120,177,1),
          (155534,800147,180841,1,1683.1,-4134.31,39.539,3.73501,0,0,-0.956305,0.292372,120,178,1),
          (155544,800148,180842,1,1683.1,-4134.31,39.539,3.73501,0,0,-0.956305,0.292372,120,179,1),
          (155554,800149,180843,1,1683.1,-4134.31,39.539,3.73501,0,0,-0.956305,0.292372,120,180,1);

        IF EXISTS (SELECT 1 FROM `game_event` WHERE `entry` BETWEEN 131 AND 180 AND
            (NOT (`description` <=> CONCAT('AQ War Effort ',
                CASE WHEN `entry` < 156 THEN 'Alliance' ELSE 'Horde' END, ' ',
                CASE MOD(FLOOR((`entry`-131)/5),5)
                  WHEN 0 THEN 'Skinning' WHEN 1 THEN 'Bandages' WHEN 2 THEN 'Bars'
                  WHEN 3 THEN 'Cooking' ELSE 'Herbs' END, ' Tier ',
                MOD(`entry`-131,5)+1)) OR `occurence`<>525600 OR `length`<>1 OR `holiday`<>0 OR
             `start_time`<>'2000-01-01 00:00:00' OR `end_time`<>'2000-01-01 00:00:01')) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ resource visual event ID conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `aq_resource_visual_stage` s LEFT JOIN `gameobject_template` t ON t.entry=s.entry WHERE t.entry IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ resource visual template missing';
        END IF;
        IF EXISTS (SELECT 1 FROM `aq_resource_visual_stage` s LEFT JOIN `gameobject` g ON g.guid=s.guid
                   WHERE g.guid IS NOT NULL AND (g.id<>s.entry OR g.map<>s.map OR
                     POW(g.position_x-s.x,2)+POW(g.position_y-s.y,2)+POW(g.position_z-s.z,2)>0.01 OR
                     ABS(g.orientation-s.orientation)>0.001 OR ABS(g.rotation0-s.r0)>0.001 OR
                     ABS(g.rotation1-s.r1)>0.001 OR ABS(g.rotation2-s.r2)>0.001 OR
                     ABS(g.rotation3-s.r3)>0.001 OR g.spawntimesecs<>s.respawn OR
                     g.animprogress<>100 OR g.state<>0)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ resource visual spawn GUID conflict';
        END IF;
        -- MySQL cannot reopen a temporary table twice in one statement.
        IF EXISTS (SELECT 1 FROM `aq_resource_visual_stage` s JOIN `game_event_gameobject` b ON b.guid=s.guid WHERE b.event<>s.event) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ resource visual event binding conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `game_event_gameobject` b WHERE ABS(b.event) BETWEEN 131 AND 180 AND NOT EXISTS
             (SELECT 1 FROM `aq_resource_visual_stage` s WHERE s.guid=b.guid AND s.event=b.event)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ resource visual event binding conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `game_event_creature` WHERE ABS(`event`) BETWEEN 131 AND 180) OR
           EXISTS (SELECT 1 FROM `game_event_quest` WHERE `event` BETWEEN 131 AND 180) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AQ resource visual event binding conflict';
        END IF;

        INSERT IGNORE INTO `game_event`
          (`entry`,`start_time`,`end_time`,`occurence`,`length`,`holiday`,`description`) VALUES
          (131,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Skinning Tier 1'),
          (132,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Skinning Tier 2'),
          (133,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Skinning Tier 3'),
          (134,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Skinning Tier 4'),
          (135,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Skinning Tier 5'),
          (136,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Bandages Tier 1'),
          (137,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Bandages Tier 2'),
          (138,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Bandages Tier 3'),
          (139,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Bandages Tier 4'),
          (140,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Bandages Tier 5'),
          (141,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Bars Tier 1'),
          (142,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Bars Tier 2'),
          (143,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Bars Tier 3'),
          (144,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Bars Tier 4'),
          (145,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Bars Tier 5'),
          (146,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Cooking Tier 1'),
          (147,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Cooking Tier 2'),
          (148,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Cooking Tier 3'),
          (149,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Cooking Tier 4'),
          (150,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Cooking Tier 5'),
          (151,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Herbs Tier 1'),
          (152,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Herbs Tier 2'),
          (153,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Herbs Tier 3'),
          (154,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Herbs Tier 4'),
          (155,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Alliance Herbs Tier 5'),
          (156,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Skinning Tier 1'),
          (157,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Skinning Tier 2'),
          (158,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Skinning Tier 3'),
          (159,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Skinning Tier 4'),
          (160,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Skinning Tier 5'),
          (161,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Bandages Tier 1'),
          (162,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Bandages Tier 2'),
          (163,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Bandages Tier 3'),
          (164,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Bandages Tier 4'),
          (165,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Bandages Tier 5'),
          (166,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Bars Tier 1'),
          (167,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Bars Tier 2'),
          (168,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Bars Tier 3'),
          (169,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Bars Tier 4'),
          (170,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Bars Tier 5'),
          (171,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Cooking Tier 1'),
          (172,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Cooking Tier 2'),
          (173,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Cooking Tier 3'),
          (174,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Cooking Tier 4'),
          (175,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Cooking Tier 5'),
          (176,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Herbs Tier 1'),
          (177,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Herbs Tier 2'),
          (178,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Herbs Tier 3'),
          (179,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Herbs Tier 4'),
          (180,'2000-01-01 00:00:00','2000-01-01 00:00:01',525600,1,0,'AQ War Effort Horde Herbs Tier 5');
        INSERT IGNORE INTO `gameobject`
          (`guid`,`id`,`map`,`position_x`,`position_y`,`position_z`,`orientation`,
           `rotation0`,`rotation1`,`rotation2`,`rotation3`,`spawntimesecs`,`animprogress`,`state`)
          SELECT s.guid,s.entry,s.map,s.x,s.y,s.z,s.orientation,s.r0,s.r1,s.r2,s.r3,s.respawn,100,0
          FROM `aq_resource_visual_stage` s;
        INSERT IGNORE INTO `game_event_gameobject` (`guid`,`event`)
          SELECT `guid`,`event` FROM `aq_resource_visual_stage`;

        INSERT INTO `db_version` VALUES (@cNewVersion,@cNewStructure,@cNewContent,@cNewDescription,@cNewComment);
        SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version`=@cNewVersion AND `structure`=@cNewStructure AND `content`=@cNewContent);
        COMMIT;
        SELECT '* UPDATE COMPLETE *' AS `===== Status =====`, @cNewResult AS `===== DB is now on Version =====`;
    ELSE
        IF (@cCurResult = @cNewResult) THEN
            SELECT '* UPDATE SKIPPED *' AS `===== Status =====`, @cCurResult AS `===== DB is already on Version =====`;
        ELSEIF (@cCurResult IS NULL) THEN
            SELECT '* UPDATE FAILED *' AS `===== Status =====`, 'Unable to locate DB Version Information' AS `============= Error Message =============`;
        ELSE
            SELECT '* UPDATE SKIPPED *' AS `===== Status =====`, @cCurResult AS `===== Found Version =====`;
        END IF;
    END IF;
END $$

DELIMITER ;

CALL update_mangos();
DROP PROCEDURE IF EXISTS `update_mangos`;
