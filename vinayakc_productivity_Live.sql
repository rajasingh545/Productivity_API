-- phpMyAdmin SQL Dump
-- version 4.9.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 06, 2020 at 01:11 PM
-- Server version: 5.6.47
-- PHP Version: 7.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vinayakc_productivity`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`vinayakc`@`localhost` PROCEDURE `sp_productivityReport` (IN `FromDate` DATE, IN `ToDate` DATE, IN `Supervisor` VARCHAR(500), IN `BaseSupervisor` VARCHAR(500))  BEGIN
/* CALL `taxiapp`.`sp_productivityReport`('2019-07-12', null, '9', '9');
CALL `taxiapp`.`sp_productivityReport`('2019-07-4', '2019-07-15', '12', '9'); */
SET @sqlselect:='SELECT dwtr.workTrackId,
WRSize.ItemUniqueId as WorkRequest, 
dwtr.CreatedOn,
dwtr.clientId,
(select p_clients.clientName  from p_clients where p_clients.clientId=dwtr.clientId) as ClientName,
dwtr.projectId,
(select p_projects.projectName  from p_projects where p_projects.projectId=dwtr.projectId) as ProjectName,
dwtr.supervisor,
(select p_users.name from p_users where p_users.userid=dwtr.supervisor) as SupervisorName,
dwtr.baseSupervisor,
(select p_users.name from p_users where p_users.userid=dwtr.baseSupervisor) as BaseSupervisorName,
dwtr.workRequestId,
WRSize.scaffoldType,
(select p_scaffoldtype.scaffoldName from p_scaffoldtype where p_scaffoldtype.id=WRSize.scaffoldType) as scaffoldTypeName,
WRSize.scaffoldSubCategory,
(select p_scaffoldsubcatergory.scaffoldSubCatName from p_scaffoldsubcatergory where p_scaffoldsubcatergory.scaffoldSubCateId=WRSize.scaffoldSubCategory and p_scaffoldsubcatergory.scaffoldTypeId =WRSize.scaffoldType ) as scaffoldSubCategoryName,
WRSize.scaffoldWorkType,
CASE
    WHEN WRSize.scaffoldWorkType = 1 then "Erection" Else "Dismantle" END scaffoldWorkTypeName, 
(select p_workerteam.teamName  from p_workerteam where p_workerteam.teamid=dwtrTeam.teamId) as Team,
dwtrTeam.teamId,
dwtrSD.length,dwtrSD.width,dwtrSD.height,
dwtrSD.setcount,
CAST(dwtrSD.length AS SIGNED ) * CAST(dwtrSD.Width  AS SIGNED ) * CAST(dwtrSD.height  AS SIGNED ) * CAST(dwtrSD.setcount  AS SIGNED) as Volume,
CASE
    WHEN dwtrTeam.teamId = 1 then CAST(dwtrSD.clength AS SIGNED ) * CAST(dwtrSD.cWidth  AS SIGNED ) * CAST(dwtrSD.cheight  AS SIGNED ) * CAST(dwtrSD.csetcount  AS SIGNED)   
    ELSE (CAST(dwtrSD.clength AS SIGNED ) * CAST(dwtrSD.cWidth  AS SIGNED ) * CAST(dwtrSD.cheight  AS SIGNED ) * CAST(dwtrSD.csetcount  AS SIGNED) )/1.5
END as Productivity,
dwtrSD.clength,dwtrSD.cWidth,dwtrSD.cheight,dwtrSD.csetcount,
CAST(dwtrSD.clength AS SIGNED ) * CAST(dwtrSD.cWidth  AS SIGNED ) * CAST(dwtrSD.cheight  AS SIGNED ) * CAST(dwtrSD.csetcount  AS SIGNED ) as cVolume,
dwtrTeam.workerCount, dwtrTeam.inTime,dwtrTeam.outTime, 
TIMEDIFF(dwtrTeam.outTime,dwtrTeam.inTime) as WorkHr,
(TIMEDIFF(dwtrTeam.outTime,dwtrTeam.inTime) * dwtrTeam.workerCount / 10000) as TotalWorkHr
FROM `p_dailyworktrack` dwtr
INNER JOIN p_workrequest WR ON WR.workRequestId = dwtr.workRequestId
INNER JOIN p_workrequestsizebased WRSize ON WRSize.workRequestId = WR.workRequestId
inner join p_dailyworktracksubdivision  dwtrSD on dwtr.workTrackId = dwtrSD.workTrackId and dwtrSD.subDivisionId = WRSize.id
INNER JOIN p_dailyworktrackteams dwtrTeam on dwtrTeam.workTrackId = dwtr.workTrackId AND dwtrTeam.subDevisionId = dwtrSD.subDivisionId';
set @WhereClause:= ' WHERE (1=1)';
SET @WhereClauseDate:= '';
SET @WhereClauseBaseSupervisor:= '';
SET @WhereClauseSupervisor:= '';
SET @sql:= '';
IF  IFNULL(FromDate, '')  != '0000-00-00' AND IFNULL(ToDate,'') = '0000-00-00' THEN
SET @WhereClauseDate:= CONCAT(@WhereClauseDate, ' AND CONVERT(dwtr.CreatedOn, DATE) >= ' ,QUOTE(FromDate));
END IF;
IF (IFNULL(FromDate, '')  != '0000-00-00' AND IFNULL(ToDate,'')  != '0000-00-00') THEN
SET @WhereClauseDate:= CONCAT(@WhereClauseDate, ' AND CONVERT(dwtr.CreatedOn, DATE) BETWEEN ' ,QUOTE(FromDate), ' AND ' ,QUOTE(ToDate));
END IF;
IF  IFNULL(FromDate, '')  = '0000-00-00' AND IFNULL(ToDate,'') != '0000-00-00' THEN
SET @WhereClauseDate:= CONCAT(@WhereClauseDate, ' AND CONVERT(dwtr.CreatedOn, DATE) <= ' ,QUOTE(ToDate));
END IF;
IF IFNULL(Supervisor, '')  != '' THEN
SET @WhereClauseSupervisor:= CONCAT(' AND dwtr.supervisor = ' ,Supervisor);
END IF;
IF IFNULL(BaseSupervisor, '')  != '' THEN
SET @WhereClauseBaseSupervisor:= CONCAT(' AND dwtr.baseSupervisor = ' ,BaseSupervisor);
END IF;
SET @sql:= CONCAT(@sqlselect , @WhereClause, @WhereClauseDate, @WhereClauseSupervisor, @WhereClauseBaseSupervisor);   
/*select  @sql;      */                    
PREPARE dynamic_statement FROM @sql;
EXECUTE dynamic_statement;  
END$$

CREATE DEFINER=`vinayakc`@`localhost` PROCEDURE `sp_productivitySummaryReport` (IN `FromDate` DATE, IN `ToDate` DATE, IN `Supervisor` VARCHAR(500), IN `BaseSupervisor` VARCHAR(500))  BEGIN
SET @sqlselect:= '';
SET @sqlselect:='SELECT dwtr.workTrackId, dwtrSD.subDivisionId,
WRSize.ItemUniqueId as WorkRequest, 
dwtr.CreatedOn,
dwtr.clientId,
(select p_clients.clientName  from p_clients where p_clients.clientId=dwtr.clientId) as ClientName,
dwtr.projectId,
(select p_projects.projectName  from p_projects where p_projects.projectId=dwtr.projectId) as ProjectName,
dwtr.supervisor,
(select p_users.name from p_users where p_users.userid=dwtr.supervisor) as SupervisorName,
dwtr.baseSupervisor,
(select p_users.name from p_users where p_users.userid=dwtr.baseSupervisor) as BaseSupervisorName,
dwtr.workRequestId,
WRSize.scaffoldType,
(select p_scaffoldtype.scaffoldName from p_scaffoldtype where p_scaffoldtype.id=WRSize.scaffoldType) as scaffoldTypeName,
WRSize.scaffoldSubCategory,
(select p_scaffoldsubcatergory.scaffoldSubCatName from p_scaffoldsubcatergory where p_scaffoldsubcatergory.scaffoldSubCateId=WRSize.scaffoldSubCategory and p_scaffoldsubcatergory.scaffoldTypeId =WRSize.scaffoldType ) as scaffoldSubCategoryName,
WRSize.scaffoldWorkType,
CASE
    WHEN WRSize.scaffoldWorkType = 1 then "Erection" Else "Dismantle" END scaffoldWorkTypeName, 
(select p_workerteam.teamName  from p_workerteam where p_workerteam.teamid=dwtrTeam.teamId) as Team,
dwtrTeam.teamId,
dwtrSD.length,dwtrSD.width,dwtrSD.height,
dwtrSD.setcount,
CAST(dwtrSD.length AS SIGNED ) * CAST(dwtrSD.Width  AS SIGNED ) * CAST(dwtrSD.height  AS SIGNED ) * CAST(dwtrSD.setcount  AS SIGNED) as Volume,
CASE
    WHEN dwtrTeam.teamId = 1 then CAST(dwtrSD.clength AS SIGNED ) * CAST(dwtrSD.cWidth  AS SIGNED ) * CAST(dwtrSD.cheight  AS SIGNED ) * CAST(dwtrSD.csetcount  AS SIGNED)   
    ELSE (CAST(dwtrSD.clength AS SIGNED ) * CAST(dwtrSD.cWidth  AS SIGNED ) * CAST(dwtrSD.cheight  AS SIGNED ) * CAST(dwtrSD.csetcount  AS SIGNED) )/1.5
END as Productivity,
dwtrSD.clength,dwtrSD.cWidth,dwtrSD.cheight,dwtrSD.csetcount,
CAST(dwtrSD.clength AS SIGNED ) * CAST(dwtrSD.cWidth  AS SIGNED ) * CAST(dwtrSD.cheight  AS SIGNED ) * CAST(dwtrSD.csetcount  AS SIGNED ) as cVolume,
dwtrTeam.workerCount, dwtrTeam.inTime,dwtrTeam.outTime, 
TIMEDIFF(dwtrTeam.outTime,dwtrTeam.inTime) as WorkHr,
(TIMEDIFF(dwtrTeam.outTime,dwtrTeam.inTime) * dwtrTeam.workerCount / 10000) as TotalWorkHr
FROM `p_dailyworktrack` dwtr
INNER JOIN p_workrequest WR ON WR.workRequestId = dwtr.workRequestId
INNER JOIN p_workrequestsizebased WRSize ON WRSize.workRequestId = WR.workRequestId
inner join p_dailyworktracksubdivision  dwtrSD on dwtr.workTrackId = dwtrSD.workTrackId and dwtrSD.subDivisionId = WRSize.id
INNER JOIN p_dailyworktrackteams dwtrTeam on dwtrTeam.workTrackId = dwtr.workTrackId AND dwtrTeam.subDevisionId = dwtrSD.subDivisionId' ;
set @WhereClause:= ' WHERE (1=1)';
SET @WhereClauseDate:= '';
SET @WhereClauseBaseSupervisor:= '';
SET @WhereClauseSupervisor:= '';
SET @InsertCluase:= '';
SET @dropTempTable:= '';
SET @SelectTempTable:='';
SET @SqlProductivityDetails:= '';
SET @SqlProductivity:= '';
SET @Basesql:= '';
IF  IFNULL(FromDate, '')  != '0000-00-00' AND IFNULL(ToDate,'') = '0000-00-00' THEN
SET @WhereClauseDate:= CONCAT(@WhereClauseDate, ' AND CONVERT(dwtr.CreatedOn, DATE) = ' ,QUOTE(FromDate));
END IF;
IF IFNULL(FromDate, '')  != '0000-00-00' AND IFNULL(ToDate,'') != '0000-00-00' THEN
SET @WhereClauseDate:= CONCAT(@WhereClauseDate, ' AND CONVERT(dwtr.CreatedOn, DATE) BETWEEN ' ,QUOTE(FromDate), ' AND ' ,QUOTE(ToDate));
END IF;
IF  IFNULL(FromDate, '')  = '0000-00-00' AND IFNULL(ToDate,'') != '0000-00-00' THEN
SET @WhereClauseDate:= CONCAT(@WhereClauseDate, ' AND CONVERT(dwtr.CreatedOn, DATE) = ' ,QUOTE(ToDate));
END IF;
IF IFNULL(Supervisor, '')  != '' THEN
SET @WhereClauseSupervisor:= CONCAT(' AND dwtr.supervisor = ' ,Supervisor);
END IF;
IF IFNULL(BaseSupervisor, '')  != '' THEN
SET @WhereClauseBaseSupervisor:= CONCAT(' AND dwtr.baseSupervisor = ' ,BaseSupervisor);
END IF;
SET @Basesql:= CONCAT(@sqlselect , @WhereClause, @WhereClauseDate, @WhereClauseSupervisor, @WhereClauseBaseSupervisor);   
SET @dropTempTable:= '';
SET @CreateTempTableCluase:= '';
SET @SelectTempTable:= '';
SET @sql1:= '';
SET @sql2:= '';
SET @dropTempTable:='DROP table IF EXISTS `tempDWTR`; ';
SET @CreateTempTableCluase:=' Create table `tempDWTR` as  ';
SET @SelectTempTable:=' SELECT * from tempDWTR ; ' ;
PREPARE drop_table FROM @dropTempTable;
EXECUTE drop_table; 
SET @sql2:= CONCAT( @CreateTempTableCluase, @Basesql );  
/*select @sql2;*/
PREPARE create_tempDWTR_stmt FROM @sql2;
EXECUTE create_tempDWTR_stmt; 
SET @dropTempTableProdDetails:='';
SET @dropTempTableProdDetails:=' DROP table IF EXISTS `tempProductivityDetails`; ';
PREPARE dropTempTableProdDetails FROM @dropTempTableProdDetails;
EXECUTE dropTempTableProdDetails; 
SET @SqlProductivityDetails:= '  Create  table `tempProductivityDetails` as 
select a.scaffoldTypeId,  a.scaffoldSubCateId, a.scaffoldSubCatName , 
(select sum(Productivity) from tempDWTR where scaffoldSubCategory =a.scaffoldSubCateId and tempDWTR.scaffoldWorkType =1) as Prod_Erection,
(select sum(Productivity) from tempDWTR where scaffoldSubCategory =a.scaffoldSubCateId and tempDWTR.scaffoldWorkType =2) as Prod_Dismantle
,(select sum(TotalWorkHr) from tempDWTR) as Total_WrHr,
(select 
Sum((TIMEDIFF(dwtrMat.outTime,dwtrMat.inTime) * dwtrMat.workerCount / 10000)) as TotalWorkHr
 from p_dailyworktrackmaterials dwtrMat
where workTrackId in (select workTrackId from tempDWTR) and material=1) as MaterialShifting
,(select 
Sum((TIMEDIFF(dwtrMat.outTime,dwtrMat.inTime) * dwtrMat.workerCount / 10000)) as TotalWorkHr
 from p_dailyworktrackmaterials dwtrMat
where workTrackId in (select workTrackId from tempDWTR) and material=2) as HKeeping
,(select 
Sum((TIMEDIFF(dwtrMat.outTime,dwtrMat.inTime) * dwtrMat.workerCount / 10000)) as TotalWorkHr
 from p_dailyworktrackmaterials dwtrMat
where workTrackId in (select workTrackId from tempDWTR) and material=3) as ProductionHr,
PSlab.TypeWorkErection, PSlab.TypeWorkDismantle
from (SELECT SsubCat.scaffoldSubCateId 
,SsubCat.scaffoldSubCatName, SsubCat.scaffoldTypeId 
FROM p_scaffoldsubcatergory SsubCat
) a left join p_productivityslab PSlab on PSlab.scaffoldType = a.scaffoldTypeId 
and PSlab.scaffoldSubCategory = a.scaffoldSubCateId ;';
 /*select @SqlProductivityDetails; */
PREPARE tempProductivityDetails FROM @SqlProductivityDetails;
EXECUTE tempProductivityDetails; 
 SET @SqlProductivity:= ' select 
*, Total_WrHr - (IFNULL(MaterialShifting,0) + IFNULL(HKeeping,0) + IFNULL(ProductionHr,0)) as Effective_Hr,
(Total_WrHr - (IFNULL(MaterialShifting,0) + IFNULL(HKeeping,0) + IFNULL(ProductionHr,0)))/8 Tot_ManPower_Used_8to5  
,Round((MaterialShifting / Total_WrHr) * 100,2) as MaterialShiftingHrsPercent
,round((Prod_Erection / TypeWorkErection),2) as productivity_Erec_Slab
,round((Prod_Dismantle / TypeWorkDismantle),2) as productivity_Dism_Slab 
 from tempProductivityDetails ;' ;
PREPARE select_tempProductivityDetails FROM @SqlProductivity;
EXECUTE select_tempProductivityDetails; 
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `p_clients`
--

CREATE TABLE `p_clients` (
  `clientId` int(11) NOT NULL,
  `clientName` varchar(100) NOT NULL,
  `projects` varchar(100) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `createdOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdBy` int(11) NOT NULL DEFAULT '0',
  `modifiedOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `modifiedBy` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_clients`
--

INSERT INTO `p_clients` (`clientId`, `clientName`, `projects`, `status`, `createdOn`, `createdBy`, `modifiedOn`, `modifiedBy`) VALUES
(1, 'client1', '19', 9, '2019-06-15 01:43:24', 0, '2019-07-17 21:09:35', 2),
(2, 'client2', '', 9, '2019-06-15 01:43:24', 0, '2019-06-21 23:40:39', 2),
(3, 'client3', '3', 9, '2019-06-15 01:43:24', 0, '2019-07-17 21:09:33', 2),
(4, 'Client 4', '0', 9, '2019-06-15 01:43:24', 0, '2019-06-15 01:43:24', 0),
(5, 'Client 1 for Project 2', '', 9, '2019-06-15 11:27:24', 2, '2019-07-17 21:09:30', 2),
(6, 'Client1-PLQ', '', 9, '2019-06-26 22:41:03', 2, '2019-07-17 21:09:28', 2),
(7, 'Sunray', '24', 1, '2019-07-17 21:19:50', 2, '2019-07-17 21:19:50', 0),
(8, 'Obayashi', '26', 1, '2019-07-17 21:20:07', 2, '2019-07-17 21:20:07', 0),
(9, 'Kajima', '29', 9, '2019-07-17 21:20:29', 2, '2019-11-14 20:40:52', 0),
(10, 'SMRT Trains', '30', 1, '2019-07-17 21:21:22', 2, '2019-07-17 21:21:22', 0),
(11, 'NamLee', '32', 9, '2019-07-17 21:21:38', 2, '2019-11-14 20:40:58', 0),
(12, 'Hexacon', '34', 1, '2019-07-17 21:22:00', 2, '2019-07-17 21:22:00', 0),
(13, 'Vision E&C', '42', 9, '2019-07-17 21:23:04', 2, '2019-11-14 20:41:04', 0),
(14, 'KM Construction', '36', 9, '2019-07-17 21:23:53', 2, '2019-11-14 20:41:07', 0),
(15, 'Tentronic', '36', 9, '2019-07-17 21:24:21', 2, '2019-11-14 20:41:10', 0),
(16, 'Specon Contractor', '46', 9, '2019-07-17 21:25:32', 2, '2019-11-14 20:41:14', 2),
(17, 'Kajima', '47', 1, '2019-11-14 20:45:04', 40, '2019-11-14 20:45:04', 0),
(18, 'NamLee', '32', 2, '2019-11-15 13:00:53', 40, '2020-04-21 12:59:47', 40),
(19, 'LSK', '26', 1, '2019-11-15 13:01:07', 40, '2019-11-15 13:01:07', 0),
(20, 'United Tech', '51', 1, '2019-11-15 13:02:22', 40, '2019-11-15 13:02:22', 0),
(21, 'Hyland Holdings', '53', 1, '2019-11-15 13:26:23', 40, '2019-11-15 13:26:23', 0),
(22, 'Projalma', '32', 2, '2020-04-21 12:53:57', 40, '2020-04-21 12:59:36', 40),
(23, 'Bond Building', '26', 1, '2020-04-21 12:56:19', 40, '2020-04-21 12:56:19', 0);

-- --------------------------------------------------------

--
-- Table structure for table `p_contracts`
--

CREATE TABLE `p_contracts` (
  `id` int(11) NOT NULL,
  `projectId` int(11) NOT NULL,
  `description` varchar(100) NOT NULL,
  `clientId` int(11) NOT NULL,
  `item` varchar(100) NOT NULL,
  `location` varchar(100) NOT NULL,
  `length` float NOT NULL,
  `height` float NOT NULL,
  `width` float NOT NULL,
  `sets` int(11) NOT NULL DEFAULT '0',
  `setCount` int(11) NOT NULL,
  `createdBy` int(11) NOT NULL,
  `createdOn` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_contracts`
--

INSERT INTO `p_contracts` (`id`, `projectId`, `description`, `clientId`, `item`, `location`, `length`, `height`, `width`, `sets`, `setCount`, `createdBy`, `createdOn`) VALUES
(1, 24, 'Glass Panel Installation', 7, '1', 'L1', 50, 10, 2, 3, 0, 0, 0),
(2, 24, 'Roof works', 7, '2', 'L32', 15, 5, 3, 1, 0, 0, 0),
(3, 24, 'Plastering works', 7, '3', 'L5 to L7', 5, 10, 2, 2, 0, 0, 0),
(4, 26, 'Genset Installation', 19, '1', 'L3, 3M, Gantry A', 15, 2, 8, 1, 0, 0, 0),
(5, 26, 'Genset Installation', 19, '2', 'L3, 3M, Gantry B', 28, 2, 8, 2, 0, 0, 0),
(6, 24, 'Glass Panel Installation', 7, '4', 'L5 to L7', 15, 5, 8, 1, 0, 0, 0),
(7, 24, 'Gondola work', 7, '5', 'Roof', 20, 5, 2, 1, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `p_dailyworktrack`
--

CREATE TABLE `p_dailyworktrack` (
  `worktrackId` int(11) NOT NULL,
  `projectId` int(11) NOT NULL,
  `ClientId` int(11) NOT NULL,
  `type` tinyint(1) NOT NULL,
  `requestedBy` varchar(100) NOT NULL,
  `baseSupervisor` int(11) NOT NULL,
  `supervisor` int(11) NOT NULL,
  `workRequestId` int(11) NOT NULL,
  `photo_1` varchar(100) NOT NULL,
  `photo_2` varchar(100) NOT NULL,
  `photo_3` varchar(100) NOT NULL,
  `remarks` text NOT NULL,
  `matMisuse` tinyint(1) NOT NULL,
  `matRemarks` text NOT NULL,
  `matPhotos` varchar(100) NOT NULL,
  `safetyVio` tinyint(1) NOT NULL DEFAULT '0',
  `safetyRemarks` text NOT NULL,
  `safetyPhoto` varchar(100) NOT NULL,
  `createdOn` datetime NOT NULL,
  `uniqueId` varchar(50) NOT NULL,
  `status` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_dailyworktrack`
--

INSERT INTO `p_dailyworktrack` (`worktrackId`, `projectId`, `ClientId`, `type`, `requestedBy`, `baseSupervisor`, `supervisor`, `workRequestId`, `photo_1`, `photo_2`, `photo_3`, `remarks`, `matMisuse`, `matRemarks`, `matPhotos`, `safetyVio`, `safetyRemarks`, `safetyPhoto`, `createdOn`, `uniqueId`, `status`) VALUES
(1, 3, 1, 1, 'Client1-Mr.Tan', 0, 5, 3, '', '', '', 'Today\'s DWTR', 1, '', '', 0, '', '', '2019-06-01 12:10:43', '1559360700987', 2),
(2, 3, 1, 1, 'TestUser', 0, 5, 4, 'images/1559363648026/photo_1.png', 'images/1559363648026/photo_2.png', '', '', 1, '', 'images/1559363648026/matPhotos.png', 0, '', '', '2019-06-01 12:53:12', '1559363648026', 1),
(3, 3, 1, 2, 'Mark', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2019-06-10 11:31:49', '', 0),
(4, 3, 1, 1, 'mark', 0, 0, 4, 'images/1560137844965/photo_1.jpeg', '', '', '', 0, '', '', 0, '', '', '2019-06-10 11:45:00', '1560137844965', 1),
(5, 3, 1, 1, 'mark', 0, 5, 5, '', '', '', '', 0, '', '', 0, '', '', '2019-06-10 11:45:50', '1560138316469', 1),
(6, 3, 3, 1, '', 9, 9, 11, 'images/1562945038483/photo_1.png', 'images/1562945038483/photo_2.png', 'images/1562945038483/photo_3.png', '', 2, '', '', 2, '', '', '2019-07-12 23:46:00', '1562945038483', 1),
(7, 3, 3, 1, '', 9, 12, 11, 'images/1562952730298/photo_1.png', '', '', 'test', 2, '', '', 2, '', '', '2019-07-13 01:36:05', '1562952730298', 1),
(8, 3, 3, 1, '', 9, 12, 11, 'images/1562953270085/photo_1.png', '', '', '', 2, '', '', 2, '', '', '2019-07-13 01:45:04', '1562953270085', 1),
(9, 3, 3, 1, 'Ganesh', 0, 0, 0, '', '', '', 'WR Submitted', 0, '', '', 0, '', '', '2019-07-13 12:35:11', '', 0),
(10, 3, 3, 1, 'Ganesh', 0, 0, 0, '', '', '', 'WR Submitted', 0, '', '', 0, '', '', '2019-07-13 12:41:47', '', 0),
(11, 24, 7, 1, 'Manager', 0, 0, 0, '', '', '', '1a - full size and 2b - partial size', 0, '', '', 0, '', '', '2019-07-21 22:20:00', '', 0),
(12, 24, 7, 1, 'Manager', 0, 0, 0, '', '', '', '1a - full size and 2b - partial size', 0, '', '', 0, '', '', '2019-07-21 22:20:41', '', 0),
(13, 24, 7, 1, '', 42, 49, 15, '', 'images/1563719482996/photo_2.png', 'images/1563719482996/photo_3.png', 'test remarks', 1, '', '', 0, '', '', '2019-07-21 22:41:52', '1563719482996', 1),
(14, 24, 7, 1, '', 42, 49, 15, '', 'images/1563720208688/photo_2.png', 'images/1563720208688/photo_3.png', 'Overall remarks', 1, 'Mat.Misuse', 'images/1563720208688/matPhotos.png', 1, 'Safty Vio.', '', '2019-07-21 23:03:28', '1563720208688', 2),
(15, 24, 7, 1, '', 42, 49, 15, '', 'images/1563721466208/photo_2.png', 'images/1563721466208/photo_3.png', '', 1, 'tesgt', 'images/1563721466208/matPhotos.png', 1, 'rr', 'images/1563721466208/safetyPhoto.png', '2019-07-21 23:09:23', '1563721466208', 1),
(16, 24, 7, 1, '', 49, 51, 15, '', 'images/1563721864526/photo_2.png', 'images/1563721864526/photo_3.png', '', 1, '', '', 1, '', '', '2019-07-21 23:14:12', '1563721864526', 1),
(17, 24, 7, 1, '', 49, 42, 15, 'images/1564799824601/photo_1.jpg', 'images/1564799824601/photo_2.jpg', 'images/1564799824601/photo_3.jpg', '', 2, '', '', 2, '', '', '2019-08-03 10:42:30', '1564799824601', 1),
(18, 24, 7, 1, '', 49, 51, 16, 'images/1564800172201/photo_1.jpg', '', 'images/1564800172201/photo_3.jpg', '', 2, '', '', 1, '', '', '2019-08-03 10:45:01', '1564800172201', 1),
(19, 30, 10, 1, '', 41, 42, 17, 'images/1566011334584/photo_1.png', '', '', '', 2, '', '', 2, '', '', '2019-08-17 11:13:52', '1566011334584', 1),
(20, 24, 7, 1, '', 49, 51, 15, '', '', '', '', 2, '', '', 2, '', '', '2019-11-14 17:01:24', '1573721986251', 1),
(21, 24, 7, 1, '', 49, 51, 16, '', '', '', '', 2, '', '', 2, '', '', '2019-11-14 17:06:43', '1573722361201', 1),
(22, 24, 7, 1, 'Ng', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-01-11 15:29:25', '', 0),
(23, 24, 7, 1, 'Ng', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-01-11 15:30:02', '', 0),
(24, 24, 7, 1, 'Ng', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-01-11 15:32:33', '', 0),
(25, 24, 8, 1, '', 49, 51, 24, 'images/1580101441908/photo_1.jpg', 'images/1580101441908/photo_2.jpg', 'images/1580101441908/photo_3.jpg', '', 2, '', '', 2, '', '', '2020-01-27 13:09:11', '1580101441908', 2),
(26, 24, 7, 2, 'Ng', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-01-27 13:26:11', '', 0),
(27, 24, 7, 1, 'Nino', 0, 0, 0, '', '', '', 'none', 0, '', '', 0, '', '', '2020-04-21 16:35:25', '', 0),
(28, 24, 7, 1, 'Nino', 0, 0, 0, '', '', '', 'none', 0, '', '', 0, '', '', '2020-04-21 16:36:00', '', 0),
(29, 24, 7, 1, 'Nino', 0, 0, 0, '', '', '', 'none', 0, '', '', 0, '', '', '2020-04-21 16:36:38', '', 0),
(30, 24, 7, 2, 'nino', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-04-21 17:27:37', '', 0),
(31, 24, 7, 2, 'nino', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-04-21 17:37:12', '', 0),
(32, 24, 7, 2, 'nino', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-04-21 17:37:30', '', 0),
(33, 24, 7, 2, 'NG', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-04-21 17:50:12', '', 0),
(34, 24, 7, 2, 'NG', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-04-21 17:53:30', '', 0),
(35, 24, 7, 2, 'NG', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-04-21 17:54:23', '', 0),
(36, 24, 7, 1, '', 49, 51, 37, 'images/1587544839069/photo_1.jpg', 'images/1587544839069/photo_2.jpg', 'images/1587544839069/photo_3.jpg', '', 2, '', '', 2, '', '', '2020-04-22 16:53:47', '1587544839069', 1),
(37, 24, 7, 1, '', 51, 0, 37, 'images/1587545773816/photo_1.jpg', 'images/1587545773816/photo_2.jpg', 'images/1587545773816/photo_3.jpg', '', 2, '', '', 2, '', '', '2020-04-22 16:57:14', '1587545773816', 1),
(38, 24, 7, 1, '', 0, 0, 37, 'images/1587548094741/photo_1.jpg', 'images/1587548094741/photo_2.jpg', 'images/1587548094741/photo_3.jpg', '', 2, '', '', 2, '', '', '2020-04-22 17:37:45', '1587548094741', 1),
(39, 24, 7, 1, '', 49, 51, 37, 'images/1587548692712/photo_1.jpg', 'images/1587548692712/photo_2.jpg', 'images/1587548692712/photo_3.jpg', '', 2, '', '', 2, '', '', '2020-04-22 17:46:30', '1587548692712', 1),
(40, 26, 8, 1, '', 46, 50, 25, 'images/1587548894102/photo_1.jpg', 'images/1587548894102/photo_2.jpg', '', '', 2, '', '', 2, '', '', '2020-04-22 17:50:41', '1587548894102', 1),
(41, 26, 8, 1, '', 46, 46, 25, '', '', '', '', 2, '', '', 2, '', '', '2020-04-22 17:57:07', '1587549247041', 1),
(42, 26, 8, 1, '', 46, 46, 25, '', '', '', '', 2, '', '', 2, '', '', '2020-04-22 17:58:46', '1587549454843', 1),
(43, 24, 7, 2, 'Ng', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-04-23 12:40:56', '', 0),
(44, 24, 7, 2, 'ng', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-04-25 13:32:48', '', 0),
(45, 24, 7, 2, 'ng', 0, 0, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-04-25 13:34:36', '', 0),
(46, 25, 7, 0, '', 47, 41, 0, '', '', '', '', 0, '', '', 0, '', '', '2020-04-25 14:14:36', '1587794805001', 1),
(47, 24, 7, 1, '', 0, 49, 15, '', '', '', '', 2, '', '', 2, '', '', '2020-05-17 19:30:15', '1589714938363', 1),
(48, 24, 7, 1, '', 44, 44, 47, 'images/1590212096856/photo_1.jpeg', '', '', '', 2, '', '', 2, '', '', '2020-05-23 13:37:32', '1590212096856', 2),
(49, 24, 7, 1, '', 44, 49, 47, 'images/1590215301636/photo_1.jpeg', '', '', '', 2, '', '', 2, '', '', '2020-05-23 14:29:22', '1590215301636', 2),
(50, 24, 7, 1, '', 49, 49, 61, 'images/1590915183043/photo_1.jpg', '', '', '', 2, '', '', 2, '', '', '2020-05-31 17:18:13', '1590915183043', 1),
(51, 24, 7, 1, '', 49, 49, 61, 'images/1590917621656/photo_1.jpg', '', '', '', 0, '', '', 0, '', '', '2020-05-31 17:36:12', '1590917621656', 1),
(52, 24, 7, 1, '', 49, 49, 61, 'images/1590917817769/photo_1.jpg', '', '', '', 0, '', '', 0, '', '', '2020-05-31 17:40:50', '1590917817769', 1);

-- --------------------------------------------------------

--
-- Table structure for table `p_dailyworktrackmaterials`
--

CREATE TABLE `p_dailyworktrackmaterials` (
  `id` int(11) NOT NULL,
  `workTrackId` int(11) NOT NULL,
  `subDevisionId` int(11) NOT NULL,
  `material` int(11) NOT NULL,
  `workerCount` int(11) NOT NULL,
  `inTime` time NOT NULL,
  `outTime` time NOT NULL,
  `createdOn` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_dailyworktrackmaterials`
--

INSERT INTO `p_dailyworktrackmaterials` (`id`, `workTrackId`, `subDevisionId`, `material`, `workerCount`, `inTime`, `outTime`, `createdOn`) VALUES
(1, 1, 3, 1, 1, '09:00:00', '10:00:00', 2019),
(2, 1, 3, 2, 1, '04:00:00', '05:00:00', 2019),
(3, 1, 4, 1, 1, '09:00:00', '10:00:00', 2019),
(4, 1, 4, 2, 1, '04:00:00', '05:00:00', 2019),
(5, 2, 5, 1, 1, '05:11:00', '06:00:00', 2019),
(6, 4, 0, 0, 0, '00:00:00', '00:00:00', 2019),
(7, 4, 0, 1, 0, '08:30:00', '09:00:00', 2019),
(8, 5, 6, 0, 0, '00:00:00', '00:00:00', 2019),
(9, 6, 12, 1, 1, '08:00:00', '09:00:00', 2019),
(10, 6, 12, 2, 2, '11:00:00', '12:00:00', 2019),
(11, 6, 12, 3, 0, '00:00:00', '00:00:00', 2019),
(12, 6, 13, 1, 1, '08:00:00', '09:00:00', 2019),
(13, 6, 13, 2, 2, '11:00:00', '12:00:00', 2019),
(14, 6, 13, 3, 0, '00:00:00', '00:00:00', 2019),
(15, 7, 12, 1, 1, '08:00:00', '09:00:00', 2019),
(16, 7, 13, 1, 1, '08:00:00', '09:00:00', 2019),
(17, 8, 12, 1, 1, '12:00:00', '13:00:00', 2019),
(18, 8, 12, 2, 2, '15:00:00', '17:00:00', 2019),
(19, 8, 13, 1, 1, '12:00:00', '13:00:00', 2019),
(20, 8, 13, 2, 2, '15:00:00', '17:00:00', 2019),
(21, 13, 19, 1, 1, '09:00:00', '12:00:00', 2019),
(22, 14, 0, 2, 12, '08:00:00', '20:00:00', 2019),
(23, 14, 19, 2, 12, '08:00:00', '20:00:00', 2019),
(24, 14, 20, 2, 12, '08:00:00', '20:00:00', 2019),
(25, 15, 19, 1, 1, '11:00:00', '13:00:00', 2019),
(26, 15, 19, 3, 1, '11:00:00', '13:00:00', 2019),
(27, 15, 20, 1, 1, '11:00:00', '13:00:00', 2019),
(28, 15, 20, 3, 1, '11:00:00', '13:00:00', 2019),
(29, 16, 19, 1, 2, '08:00:00', '16:00:00', 2019),
(30, 16, 19, 2, 2, '08:00:00', '16:00:00', 2019),
(31, 16, 20, 1, 2, '08:00:00', '16:00:00', 2019),
(32, 16, 20, 2, 2, '08:00:00', '16:00:00', 2019),
(33, 17, 19, 0, 0, '00:00:00', '00:00:00', 2019),
(34, 18, 21, 0, 0, '00:00:00', '00:00:00', 2019),
(35, 19, 22, 1, 1, '10:00:00', '11:00:00', 2019),
(36, 19, 22, 2, 2, '08:00:00', '10:00:00', 2019),
(37, 19, 22, 3, 10, '08:00:00', '17:00:00', 2019),
(38, 20, 19, 0, 0, '00:00:00', '00:00:00', 2019),
(39, 21, 21, 0, 0, '00:00:00', '00:00:00', 2019),
(40, 25, 29, 2, 0, '08:30:00', '09:00:00', 2020),
(41, 36, 39, 1, 4, '11:30:00', '12:00:00', 2020),
(42, 37, 39, 1, 0, '11:30:00', '12:00:00', 2020),
(43, 38, 39, 0, 0, '00:00:00', '00:00:00', 2020),
(44, 39, 39, 0, 0, '00:00:00', '00:00:00', 2020),
(45, 40, 30, 2, 5, '13:00:00', '14:00:00', 2020),
(46, 41, 30, 2, 5, '13:00:00', '14:00:00', 2020),
(47, 42, 30, 2, 0, '13:00:00', '14:00:00', 2020),
(48, 46, 0, 0, 0, '00:00:00', '00:00:00', 2020),
(50, 47, 0, 1, 2, '12:30:00', '23:00:00', 2020),
(51, 48, 48, 1, 0, '01:00:00', '02:00:00', 2020),
(52, 49, 48, 0, 0, '00:00:00', '00:00:00', 2020),
(53, 50, 0, 1, 0, '08:00:00', '09:00:00', 2020),
(54, 51, 0, 0, 0, '00:00:00', '00:00:00', 2020),
(55, 52, 0, 0, 0, '00:00:00', '00:00:00', 2020);

-- --------------------------------------------------------

--
-- Table structure for table `p_dailyworktracksubdivision`
--

CREATE TABLE `p_dailyworktracksubdivision` (
  `id` int(11) NOT NULL,
  `workTrackId` int(11) NOT NULL,
  `subDivisionId` int(11) NOT NULL,
  `timing` tinyint(1) NOT NULL,
  `length` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `width` int(11) NOT NULL,
  `setcount` int(11) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `cLength` int(11) NOT NULL,
  `cHeight` int(11) NOT NULL,
  `cWidth` int(11) NOT NULL,
  `cSetcount` int(11) NOT NULL,
  `diffSubDivision` int(11) NOT NULL,
  `createdOn` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_dailyworktracksubdivision`
--

INSERT INTO `p_dailyworktracksubdivision` (`id`, `workTrackId`, `subDivisionId`, `timing`, `length`, `height`, `width`, `setcount`, `status`, `cLength`, `cHeight`, `cWidth`, `cSetcount`, `diffSubDivision`, `createdOn`) VALUES
(1, 1, 3, 1, 100, 50, 1, 5, 1, 0, 0, 0, 0, 0, '2019-06-01 12:10:43'),
(2, 1, 4, 1, 50, 1, 4, 1, 2, 112, 5, 8, 1, 0, '2019-06-01 12:10:43'),
(3, 2, 5, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, '2019-06-01 12:53:12'),
(4, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2019-06-10 11:31:49'),
(5, 4, 1, 2, 2, 2, 2, 1, 1, 0, 0, 0, 0, 0, '2019-06-10 11:45:00'),
(6, 5, 6, 1, 2, 3, 2, 1, 0, 0, 0, 0, 0, 0, '2019-06-10 11:45:50'),
(7, 6, 12, 1, 1, 10, 10, 1, 2, 1, 20, 10, 1, 0, '2019-07-12 23:46:00'),
(8, 6, 13, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 0, '2019-07-12 23:46:00'),
(9, 7, 12, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 0, '2019-07-13 01:36:05'),
(10, 7, 13, 1, 2, 2, 2, 2, 1, 0, 0, 0, 1, 0, '2019-07-13 01:36:05'),
(11, 8, 12, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 0, '2019-07-13 01:45:04'),
(12, 8, 13, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, '2019-07-13 01:45:04'),
(13, 9, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, '2019-07-13 12:35:11'),
(14, 10, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, '2019-07-13 12:41:47'),
(15, 11, 0, 0, 51, 23, 26, 0, 0, 0, 0, 0, 0, 0, '2019-07-21 22:20:00'),
(16, 11, 0, 0, 1, 1, 1, 100, 0, 0, 0, 0, 0, 0, '2019-07-21 22:20:00'),
(17, 11, 0, 0, 1, 1, 1, 100, 0, 0, 0, 0, 0, 0, '2019-07-21 22:20:00'),
(18, 12, 0, 0, 51, 23, 26, 0, 0, 0, 0, 0, 0, 0, '2019-07-21 22:20:41'),
(19, 12, 0, 0, 1, 1, 1, 100, 0, 0, 0, 0, 0, 0, '2019-07-21 22:20:41'),
(20, 12, 0, 0, 1, 1, 1, 100, 0, 0, 0, 0, 0, 0, '2019-07-21 22:20:41'),
(21, 13, 19, 1, 5, 5, 5, 5, 3, 2, 2, 2, 2, 0, '2019-07-21 22:41:52'),
(22, 14, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2019-07-21 23:03:28'),
(23, 14, 19, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, '2019-07-21 23:03:28'),
(24, 14, 20, 1, 2, 2, 2, 2, 1, 0, 0, 0, 0, 0, '2019-07-21 23:03:28'),
(25, 15, 19, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, '2019-07-21 23:09:23'),
(26, 15, 20, 1, 2, 2, 2, 2, 1, 0, 0, 0, 0, 0, '2019-07-21 23:09:23'),
(27, 16, 19, 1, 3, 3, 3, 3, 1, 0, 0, 0, 0, 0, '2019-07-21 23:14:12'),
(28, 16, 20, 1, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, '2019-07-21 23:14:12'),
(29, 17, 19, 1, 10, 10, 5, 1, 1, 0, 0, 0, 0, 0, '2019-08-03 10:42:30'),
(30, 18, 21, 1, 50, 5, 2, 1, 1, 0, 0, 0, 0, 0, '2019-08-03 10:45:01'),
(31, 19, 22, 2, 15, 15, 15, 1, 1, 0, 0, 0, 0, 22, '2019-08-17 11:13:52'),
(32, 20, 19, 1, 5, 5, 3, 1, 1, 0, 0, 0, 0, 0, '2019-11-14 17:01:24'),
(33, 21, 21, 1, 10, 8, 5, 15, 1, 0, 0, 0, 0, 0, '2019-11-14 17:06:43'),
(34, 22, 0, 0, 10, 10, 2, 1, 0, 0, 0, 0, 0, 0, '2020-01-11 15:29:25'),
(35, 22, 0, 0, 10, 10, 2, 1, 0, 0, 0, 0, 0, 0, '2020-01-11 15:29:25'),
(36, 23, 0, 0, 10, 10, 2, 1, 0, 0, 0, 0, 0, 0, '2020-01-11 15:30:02'),
(37, 23, 0, 0, 10, 10, 2, 1, 0, 0, 0, 0, 0, 0, '2020-01-11 15:30:02'),
(38, 24, 0, 0, 10, 10, 2, 1, 0, 0, 0, 0, 0, 0, '2020-01-11 15:32:33'),
(39, 24, 0, 0, 10, 10, 2, 1, 0, 0, 0, 0, 0, 0, '2020-01-11 15:32:33'),
(40, 25, 29, 1, 2, 2, 2, 4, 1, 0, 0, 0, 0, 0, '2020-01-27 13:09:11'),
(41, 27, 0, 0, 50, 10, 2, 1, 0, 0, 0, 0, 0, 0, '2020-04-21 16:35:25'),
(42, 27, 0, 0, 10, 10, 3, 3, 0, 0, 0, 0, 0, 0, '2020-04-21 16:35:25'),
(43, 28, 0, 0, 50, 10, 2, 1, 0, 0, 0, 0, 0, 0, '2020-04-21 16:36:00'),
(44, 28, 0, 0, 50, 10, 2, 1, 0, 0, 0, 0, 0, 0, '2020-04-21 16:36:00'),
(45, 29, 0, 0, 50, 10, 2, 1, 0, 0, 0, 0, 0, 0, '2020-04-21 16:36:38'),
(46, 29, 0, 0, 50, 10, 2, 1, 0, 0, 0, 0, 0, 0, '2020-04-21 16:36:38'),
(47, 36, 39, 1, 8, 8, 1, 1, 1, 0, 0, 0, 0, 0, '2020-04-22 16:53:47'),
(48, 37, 39, 1, 8, 8, 1, 1, 1, 0, 0, 0, 0, 0, '2020-04-22 16:57:14'),
(49, 38, 39, 1, 8, 8, 1, 1, 2, 8, 8, 1, 1, 0, '2020-04-22 17:37:45'),
(50, 39, 39, 1, 8, 8, 1, 1, 2, 8, 8, 1, 1, 0, '2020-04-22 17:46:30'),
(51, 40, 30, 2, 60, 2, 2, 1, 2, 60, 2, 2, 1, 30, '2020-04-22 17:50:41'),
(52, 41, 30, 2, 60, 1, 2, 1, 1, 0, 0, 0, 0, 30, '2020-04-22 17:57:07'),
(53, 42, 30, 2, 60, 1, 2, 1, 1, 0, 0, 0, 0, 30, '2020-04-22 17:58:46'),
(54, 46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2020-04-25 14:14:36'),
(56, 47, 0, 1, 222, 23, 23, 213, 0, 0, 0, 0, 0, 0, '2020-05-17 19:30:15'),
(57, 48, 48, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 48, '2020-05-23 13:37:32'),
(58, 49, 48, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 48, '2020-05-23 14:29:22'),
(59, 50, 65, 0, 10, 10, 2, 1, 1, 0, 0, 0, 0, 65, '2020-05-31 17:18:13'),
(60, 50, 66, 0, 2, 8, 2, 1, 1, 0, 0, 0, 0, 66, '2020-05-31 17:18:13'),
(61, 50, 67, 0, 2, 2, 1, 1, 2, 2, 2, 1, 1, 0, '2020-05-31 17:18:13'),
(62, 51, 65, 2, 10, 8, 2, 1, 1, 0, 0, 0, 0, 0, '2020-05-31 17:36:12'),
(63, 51, 66, 2, 2, 8, 2, 1, 2, 2, 8, 2, 1, 0, '2020-05-31 17:36:12'),
(64, 52, 66, 2, 2, 8, 2, 1, 2, 2, 8, 2, 1, 0, '2020-05-31 17:40:50');

-- --------------------------------------------------------

--
-- Table structure for table `p_dailyworktrackteams`
--

CREATE TABLE `p_dailyworktrackteams` (
  `id` int(11) NOT NULL,
  `workTrackId` int(11) NOT NULL,
  `subDevisionId` int(11) NOT NULL,
  `teamId` int(11) NOT NULL,
  `workerCount` int(11) NOT NULL,
  `inTime` time NOT NULL,
  `outTime` time NOT NULL,
  `createdOn` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_dailyworktrackteams`
--

INSERT INTO `p_dailyworktrackteams` (`id`, `workTrackId`, `subDevisionId`, `teamId`, `workerCount`, `inTime`, `outTime`, `createdOn`) VALUES
(1, 1, 3, 1, 10, '08:00:00', '05:00:00', '2019-06-01 12:10:43'),
(2, 1, 3, 2, 2, '12:00:00', '05:00:00', '2019-06-01 12:10:43'),
(3, 1, 4, 1, 10, '08:00:00', '05:00:00', '2019-06-01 12:10:44'),
(4, 1, 4, 2, 2, '12:00:00', '05:00:00', '2019-06-01 12:10:44'),
(5, 2, 5, 1, 1, '08:00:00', '10:00:00', '2019-06-01 12:53:12'),
(6, 4, 0, 1, 0, '00:00:00', '00:00:00', '2019-06-10 11:45:00'),
(7, 4, 0, 2, 0, '08:00:00', '08:30:00', '2019-06-10 11:45:00'),
(8, 5, 6, 3, 5, '00:00:00', '00:00:00', '2019-06-10 11:45:50'),
(9, 6, 12, 1, 5, '08:00:00', '16:00:00', '2019-07-12 23:46:00'),
(10, 6, 12, 2, 3, '08:00:00', '16:00:00', '2019-07-12 23:46:00'),
(11, 6, 13, 1, 5, '08:00:00', '16:00:00', '2019-07-12 23:46:00'),
(12, 6, 13, 2, 3, '08:00:00', '16:00:00', '2019-07-12 23:46:00'),
(13, 7, 12, 1, 1, '08:00:00', '16:00:00', '2019-07-13 01:36:05'),
(14, 7, 12, 2, 2, '08:00:00', '20:00:00', '2019-07-13 01:36:05'),
(15, 7, 13, 1, 1, '08:00:00', '16:00:00', '2019-07-13 01:36:05'),
(16, 7, 13, 2, 2, '08:00:00', '20:00:00', '2019-07-13 01:36:05'),
(17, 8, 12, 1, 1, '08:00:00', '16:00:00', '2019-07-13 01:45:04'),
(18, 8, 12, 2, 1, '09:00:00', '20:00:00', '2019-07-13 01:45:04'),
(19, 8, 12, 8, 2, '15:00:00', '23:00:00', '2019-07-13 01:45:04'),
(20, 8, 13, 1, 1, '08:00:00', '16:00:00', '2019-07-13 01:45:04'),
(21, 8, 13, 2, 1, '09:00:00', '20:00:00', '2019-07-13 01:45:04'),
(22, 8, 13, 8, 2, '15:00:00', '23:00:00', '2019-07-13 01:45:04'),
(23, 13, 19, 1, 10, '08:00:00', '20:00:00', '2019-07-21 22:41:52'),
(24, 14, 0, 1, 1, '09:00:00', '18:00:00', '2019-07-21 23:03:28'),
(25, 14, 0, 2, 1, '09:00:00', '18:00:00', '2019-07-21 23:03:28'),
(26, 14, 19, 1, 1, '09:00:00', '18:00:00', '2019-07-21 23:03:28'),
(27, 14, 19, 2, 1, '09:00:00', '18:00:00', '2019-07-21 23:03:28'),
(28, 14, 20, 1, 1, '09:00:00', '18:00:00', '2019-07-21 23:03:28'),
(29, 14, 20, 2, 1, '09:00:00', '18:00:00', '2019-07-21 23:03:28'),
(30, 15, 19, 1, 1, '08:00:00', '19:00:00', '2019-07-21 23:09:23'),
(31, 15, 19, 2, 1, '08:00:00', '19:00:00', '2019-07-21 23:09:23'),
(32, 15, 20, 1, 1, '08:00:00', '19:00:00', '2019-07-21 23:09:23'),
(33, 15, 20, 2, 1, '08:00:00', '19:00:00', '2019-07-21 23:09:23'),
(34, 16, 19, 1, 33, '08:00:00', '15:00:00', '2019-07-21 23:14:12'),
(35, 16, 19, 4, 33, '08:00:00', '15:00:00', '2019-07-21 23:14:12'),
(36, 16, 20, 1, 33, '08:00:00', '15:00:00', '2019-07-21 23:14:12'),
(37, 16, 20, 4, 33, '08:00:00', '15:00:00', '2019-07-21 23:14:12'),
(38, 17, 19, 1, 5, '08:00:00', '05:00:00', '2019-08-03 10:42:30'),
(39, 18, 21, 2, 6, '00:00:00', '00:00:00', '2019-08-03 10:45:01'),
(40, 19, 22, 1, 10, '08:00:00', '17:00:00', '2019-08-17 11:13:52'),
(41, 19, 22, 2, 3, '08:00:00', '17:00:00', '2019-08-17 11:13:52'),
(42, 20, 19, 1, 5, '08:00:00', '12:00:00', '2019-11-14 17:01:24'),
(43, 21, 21, 1, 5, '00:00:00', '00:00:00', '2019-11-14 17:06:43'),
(44, 25, 29, 1, 0, '09:00:00', '10:00:00', '2020-01-27 13:09:11'),
(45, 36, 39, 1, 4, '08:00:00', '11:30:00', '2020-04-22 16:53:47'),
(46, 37, 39, 1, 4, '08:00:00', '11:30:00', '2020-04-22 16:57:14'),
(47, 38, 39, 1, 4, '08:00:00', '11:00:00', '2020-04-22 17:37:45'),
(48, 39, 39, 1, 4, '08:00:00', '12:00:00', '2020-04-22 17:46:30'),
(49, 40, 30, 2, 7, '08:00:00', '12:00:00', '2020-04-22 17:50:41'),
(50, 41, 30, 2, 7, '08:00:00', '12:00:00', '2020-04-22 17:57:07'),
(51, 42, 0, 2, 7, '08:00:00', '12:00:00', '2020-04-22 17:58:46'),
(52, 46, 0, 1, 5, '08:00:00', '12:00:00', '2020-04-25 14:14:36'),
(54, 47, 0, 1, 23, '02:10:00', '01:23:00', '2020-05-17 19:30:15'),
(55, 47, 0, 4, 55, '00:20:00', '20:00:00', '2020-05-17 19:30:15'),
(56, 48, 48, 1, 2, '08:00:00', '10:00:00', '2020-05-23 13:37:32'),
(57, 49, 48, 1, 2, '08:00:00', '10:00:00', '2020-05-23 14:29:22'),
(58, 50, 66, 1, 3, '01:00:00', '03:00:00', '2020-05-31 17:18:13'),
(59, 51, 0, 1, 3, '11:10:00', '12:00:00', '2020-05-31 17:36:12'),
(60, 52, 0, 0, 0, '00:00:00', '00:00:00', '2020-05-31 17:40:50');

-- --------------------------------------------------------

--
-- Table structure for table `p_grade`
--

CREATE TABLE `p_grade` (
  `id` int(11) NOT NULL,
  `gradeRangeFrom` int(11) NOT NULL DEFAULT '0',
  `gradeRangeTo` int(11) NOT NULL,
  `Percentage` int(11) NOT NULL,
  `grade` varchar(10) NOT NULL DEFAULT '0',
  `createdBy` int(11) NOT NULL,
  `createdOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modifiedBy` int(11) NOT NULL,
  `modifiedOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_grade`
--

INSERT INTO `p_grade` (`id`, `gradeRangeFrom`, `gradeRangeTo`, `Percentage`, `grade`, `createdBy`, `createdOn`, `modifiedBy`, `modifiedOn`) VALUES
(8, 0, 50, 0, 'Poor', 40, '2019-11-14 20:15:39', 40, '2019-11-14 20:15:39'),
(13, 51, 70, 51, 'Below Avg', 40, '2019-11-14 20:19:25', 40, '2019-11-14 20:19:25'),
(14, 71, 80, 71, 'Above Avg', 40, '2019-11-14 20:19:54', 40, '2019-11-14 20:19:54'),
(15, 81, 90, 81, 'Good', 40, '2019-11-14 20:20:19', 40, '2019-11-14 20:20:19'),
(16, 91, 100, 91, 'Very Good', 40, '2019-11-14 20:20:34', 40, '2019-11-14 20:20:34');

-- --------------------------------------------------------

--
-- Table structure for table `p_material`
--

CREATE TABLE `p_material` (
  `id` int(11) NOT NULL,
  `materialName` text NOT NULL,
  `status` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_material`
--

INSERT INTO `p_material` (`id`, `materialName`, `status`) VALUES
(1, 'M.Shifting', 1),
(2, 'H.Keeping', 1),
(3, 'Prod. Hrs', 1);

-- --------------------------------------------------------

--
-- Table structure for table `p_productivityslab`
--

CREATE TABLE `p_productivityslab` (
  `id` int(11) NOT NULL,
  `scaffoldType` int(11) NOT NULL,
  `scaffoldSubCategory` int(11) NOT NULL,
  `unit` int(11) NOT NULL,
  `typeWorkErection` varchar(100) NOT NULL,
  `typeWorkDismantle` int(11) NOT NULL,
  `createdOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdBy` int(11) NOT NULL,
  `modifiedBy` int(11) NOT NULL,
  `modifiedOn` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_productivityslab`
--

INSERT INTO `p_productivityslab` (`id`, `scaffoldType`, `scaffoldSubCategory`, `unit`, `typeWorkErection`, `typeWorkDismantle`, `createdOn`, `createdBy`, `modifiedBy`, `modifiedOn`) VALUES
(9, 2, 5, 1, '25', 50, '2019-11-14 20:24:40', 40, 40, '2019-11-14 20:24:40'),
(10, 1, 9, 2, '25', 50, '2019-11-14 20:50:13', 40, 40, '2019-11-14 20:50:13'),
(11, 1, 10, 2, '25', 50, '2019-11-14 20:52:09', 40, 40, '2019-11-14 20:52:09'),
(12, 2, 11, 1, '25', 50, '2019-11-14 20:52:20', 40, 40, '2019-11-14 20:52:20'),
(13, 2, 12, 1, '25', 50, '2019-11-14 20:52:28', 40, 40, '2019-11-14 20:52:28'),
(14, 2, 13, 1, '30', 60, '2019-11-14 20:53:04', 40, 40, '2019-11-14 20:53:04'),
(15, 2, 14, 1, '30', 60, '2019-11-14 20:53:22', 40, 40, '2019-11-14 20:53:22'),
(16, 2, 15, 1, '35', 70, '2019-11-14 20:53:39', 40, 40, '2019-11-14 20:53:39'),
(17, 2, 16, 1, '35', 70, '2019-11-14 20:53:56', 40, 40, '2019-11-14 20:53:56'),
(18, 2, 17, 1, '30', 60, '2019-11-14 20:54:10', 40, 40, '2019-11-14 20:54:10'),
(19, 3, 18, 1, '20', 40, '2019-11-14 20:56:20', 40, 40, '2019-11-14 20:56:20'),
(20, 4, 19, 5, '1', 2, '2019-11-14 20:56:44', 40, 40, '2019-11-14 20:56:44'),
(21, 4, 20, 5, '1', 2, '2019-11-14 20:56:59', 40, 40, '2019-11-14 20:56:59'),
(22, 5, 21, 2, '30', 60, '2019-11-15 12:53:04', 40, 40, '2019-11-15 12:53:04'),
(23, 5, 22, 2, '50', 100, '2019-11-15 12:53:15', 40, 40, '2019-11-15 12:53:15'),
(24, 5, 23, 2, '75', 150, '2019-11-15 12:53:26', 40, 40, '2019-11-15 12:53:26'),
(25, 5, 24, 2, '100', 200, '2019-11-15 12:53:39', 40, 40, '2019-11-15 12:53:39'),
(26, 5, 25, 2, '150', 300, '2019-11-15 12:53:51', 40, 40, '2019-11-15 12:53:51'),
(27, 5, 41, 2, '200', 400, '2019-11-15 12:54:03', 40, 40, '2019-11-15 12:54:03'),
(28, 6, 26, 2, '20', 40, '2019-11-15 12:54:18', 40, 40, '2019-11-15 12:54:18'),
(29, 7, 27, 2, '20', 40, '2019-11-15 12:54:28', 40, 40, '2019-11-15 12:54:28'),
(30, 7, 28, 1, '20', 40, '2019-11-15 12:54:40', 40, 40, '2019-11-15 12:54:40'),
(31, 16, 31, 4, '4', 8, '2019-11-15 12:54:57', 40, 40, '2019-11-15 12:54:57'),
(32, 17, 32, 1, '50', 100, '2019-11-15 12:55:09', 40, 40, '2019-11-15 12:55:09'),
(33, 17, 33, 4, '75', 100, '2019-11-15 12:55:24', 40, 40, '2019-11-15 12:55:24'),
(34, 4, 29, 5, '1', 2, '2019-11-15 12:56:26', 40, 40, '2019-11-15 12:56:26'),
(35, 4, 30, 5, '1', 2, '2019-11-15 12:56:38', 40, 40, '2019-11-15 12:56:38'),
(36, 18, 34, 5, '12', 20, '2019-11-15 12:56:59', 40, 40, '2019-11-15 12:56:59'),
(37, 19, 35, 5, '8', 15, '2019-11-15 12:57:14', 40, 40, '2019-11-15 12:57:14'),
(38, 19, 36, 5, '15', 30, '2019-11-15 12:57:35', 40, 40, '2019-11-15 12:57:35'),
(39, 20, 37, 1, '15', 30, '2019-11-15 12:57:53', 40, 40, '2019-11-15 12:57:53'),
(40, 20, 38, 2, '20', 40, '2019-11-15 12:58:06', 40, 40, '2019-11-15 12:58:06'),
(41, 21, 39, 4, '25', 50, '2019-11-15 12:58:20', 40, 40, '2019-11-15 12:58:20'),
(42, 21, 40, 4, '30', 60, '2019-11-15 12:58:32', 40, 40, '2019-11-15 12:58:32'),
(43, 22, 42, 2, '20', 40, '2019-11-15 12:58:51', 40, 40, '2019-11-15 13:00:05'),
(44, 22, 44, 2, '30', 60, '2019-11-15 12:59:34', 40, 40, '2019-11-15 12:59:34'),
(45, 23, 43, 2, '75', 150, '2019-11-15 12:59:53', 40, 40, '2019-11-15 12:59:53');

-- --------------------------------------------------------

--
-- Table structure for table `p_projects`
--

CREATE TABLE `p_projects` (
  `projectId` int(11) NOT NULL,
  `projectName` varchar(100) NOT NULL,
  `projectStatus` tinyint(1) NOT NULL DEFAULT '1',
  `modifiedOn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdBy` int(11) NOT NULL,
  `createdOn` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_projects`
--

INSERT INTO `p_projects` (`projectId`, `projectName`, `projectStatus`, `modifiedOn`, `createdBy`, `createdOn`) VALUES
(3, 'project5', 9, '2018-04-29 05:06:33', 2, '2018-04-29 00:00:00'),
(4, 'project2', 9, '2018-04-29 05:06:33', 2, '2018-04-29 00:00:00'),
(5, 'project 3', 9, '2018-09-29 18:35:06', 0, '0000-00-00 00:00:00'),
(6, 'project6', 9, '2019-04-13 04:12:30', 1, '2019-04-13 00:00:00'),
(7, 'project7', 9, '2019-04-13 04:12:30', 1, '2019-04-13 00:00:00'),
(8, 'project8', 9, '2019-04-13 04:13:03', 1, '2019-04-13 00:00:00'),
(9, 'project9', 9, '2019-04-13 04:13:03', 1, '2019-04-13 00:00:00'),
(10, 'proejct10', 9, '2019-04-13 04:13:45', 1, '2019-04-13 00:00:00'),
(11, 'project11', 9, '2019-05-26 04:13:45', 1, '2019-04-13 00:00:00'),
(12, 'Fairmont', 9, '2019-05-26 04:13:45', 1, '2019-05-26 12:13:45'),
(13, 'Chevron', 9, '2019-05-26 04:13:45', 1, '2019-05-26 12:13:45'),
(14, 'Loyang', 9, '2019-05-26 04:13:45', 1, '2019-05-26 12:13:45'),
(15, 'NCID', 9, '2019-05-26 04:13:45', 1, '2019-05-26 12:13:45'),
(16, 'RGS', 9, '2019-05-26 04:13:45', 1, '2019-05-26 12:13:45'),
(17, 'Mandai Zoo', 9, '2019-05-26 04:13:45', 1, '2019-05-26 12:13:45'),
(18, 'Strling', 9, '2019-05-26 04:13:45', 1, '2019-05-26 12:13:45'),
(19, 'STORE', 9, '2019-05-26 04:13:45', 1, '2019-05-26 12:13:45'),
(20, 'PLQ', 9, '2019-05-26 04:13:45', 1, '2019-05-26 12:13:45'),
(21, 'Micron', 9, '2019-06-05 14:32:03', 2, '2019-06-05 22:32:03'),
(22, 'Project Testing', 9, '2019-06-09 14:54:07', 2, '2019-06-09 22:54:07'),
(23, 'testpr', 9, '2019-06-14 17:58:08', 2, '2019-06-15 01:58:08'),
(24, 'Chevron House', 1, '2019-07-17 13:11:17', 2, '2019-07-17 21:11:17'),
(25, 'Fairmont Hotel', 1, '2019-07-17 13:11:28', 2, '2019-07-17 21:11:28'),
(26, 'AT-SGP1 -Loyang', 1, '2019-07-17 13:11:58', 2, '2019-07-17 21:11:58'),
(27, 'Mandai Zoo', 1, '2019-07-17 13:12:07', 2, '2019-07-17 21:12:07'),
(28, 'CL Hotel', 9, '2019-07-17 13:12:18', 2, '2019-07-17 21:12:18'),
(29, 'ITE', 9, '2019-07-17 13:12:25', 2, '2019-07-17 21:12:25'),
(30, 'SMRT', 1, '2019-07-17 13:12:32', 2, '2019-07-17 21:12:32'),
(31, 'NUH', 9, '2019-07-17 13:12:52', 2, '2019-07-17 21:12:52'),
(32, 'Hampton Court', 1, '2019-07-17 13:12:58', 2, '2019-07-17 21:12:58'),
(33, 'NCID', 9, '2019-07-17 13:13:03', 2, '2019-07-17 21:13:03'),
(34, 'Anson Road', 1, '2019-07-17 13:13:11', 2, '2019-07-17 21:13:11'),
(35, 'Silat Road', 9, '2019-07-17 13:13:19', 2, '2019-07-17 21:13:19'),
(36, 'Tampines T20', 9, '2019-07-17 13:13:25', 2, '2019-07-17 21:13:25'),
(37, 'Micron', 9, '2019-07-17 13:13:55', 2, '2019-07-17 21:13:55'),
(38, 'Store', 9, '2019-07-17 13:14:24', 2, '2019-07-17 21:14:24'),
(39, 'PLQ', 9, '2019-07-17 13:15:53', 2, '2019-07-17 21:15:53'),
(40, 'Rochester Park', 1, '2019-07-17 13:15:59', 2, '2019-07-17 21:15:59'),
(41, 'F1', 9, '2019-07-17 13:16:16', 2, '2019-07-17 21:16:16'),
(42, 'Holland Hill', 9, '2019-07-17 13:16:44', 2, '2019-07-17 21:16:44'),
(43, 'Marina One', 1, '2019-07-17 13:17:00', 2, '2019-07-17 21:17:00'),
(44, 'Khatib MRT', 9, '2019-07-17 13:17:27', 2, '2019-07-17 21:17:27'),
(45, 'RGS', 9, '2019-07-17 13:18:06', 2, '2019-07-17 21:18:06'),
(46, 'SAS', 9, '2019-07-17 13:18:11', 2, '2019-07-17 21:18:11'),
(47, 'RWT', 1, '2019-11-14 12:44:48', 40, '2019-11-14 20:44:48'),
(48, 'SGA', 1, '2019-11-14 12:45:41', 40, '2019-11-14 20:45:41'),
(49, 'SVD', 1, '2019-11-14 12:45:50', 40, '2019-11-14 20:45:50'),
(50, 'MRT', 1, '2019-11-14 12:47:14', 40, '2019-11-14 20:47:14'),
(51, 'NTUC', 1, '2019-11-15 05:01:31', 40, '2019-11-15 13:01:31'),
(52, 'MBS Casino', 1, '2019-11-15 05:10:58', 40, '2019-11-15 13:10:58'),
(53, 'Yunnan Crescent', 1, '2019-11-15 05:25:55', 40, '2019-11-15 13:25:55'),
(54, 'Swiss Club', 1, '2019-11-15 05:26:58', 40, '2019-11-15 13:26:58'),
(55, 'BOS', 1, '2019-11-15 05:27:08', 40, '2019-11-15 13:27:08'),
(56, 'COURSE', 1, '2019-11-15 05:27:31', 40, '2019-11-15 13:27:31'),
(57, 'Swissotel', 1, '2019-11-15 05:28:24', 40, '2019-11-15 13:28:24'),
(58, 'STORE', 1, '2019-11-15 05:28:41', 40, '2019-11-15 13:28:41'),
(59, 'NTP', 1, '2020-01-27 04:48:08', 40, '2020-01-27 12:48:08'),
(60, 'AT-SGP1 -Loyang-1', 1, '2020-04-21 04:57:05', 39, '2020-04-21 12:57:05'),
(61, 'Chevron House-Sub1', 1, '2020-04-23 03:26:00', 39, '2020-04-23 11:26:00');

-- --------------------------------------------------------

--
-- Table structure for table `p_scaffoldsubcatergory`
--

CREATE TABLE `p_scaffoldsubcatergory` (
  `scaffoldSubCateId` int(11) NOT NULL,
  `scaffoldTypeId` int(11) NOT NULL,
  `scaffoldSubCatName` varchar(100) NOT NULL,
  `createdOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdBy` int(11) NOT NULL,
  `modifiedBy` int(11) NOT NULL,
  `modifiedOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_scaffoldsubcatergory`
--

INSERT INTO `p_scaffoldsubcatergory` (`scaffoldSubCateId`, `scaffoldTypeId`, `scaffoldSubCatName`, `createdOn`, `createdBy`, `modifiedBy`, `modifiedOn`) VALUES
(9, 1, 'Tower (ELP- 3x3x10)', '2019-11-14 20:25:42', 40, 40, '2019-11-14 20:25:42'),
(10, 1, 'Tower (TLP- 3x3x10)', '2019-11-14 20:25:48', 40, 40, '2019-11-14 20:25:48'),
(11, 2, 'Perimeter (ELP- 10x1x15)', '2019-11-14 20:26:00', 40, 40, '2019-11-14 20:26:00'),
(12, 2, 'Perimeter (TLP- 10x1x15)', '2019-11-14 20:26:08', 40, 40, '2019-11-14 20:26:08'),
(13, 2, 'Perimeter (ELP- 20x1x15)', '2019-11-14 20:26:17', 40, 40, '2019-11-14 20:26:17'),
(14, 2, 'Perimeter (TLP- 20x1x15)', '2019-11-14 20:26:23', 40, 40, '2019-11-14 20:26:23'),
(15, 2, 'Perimeter (ELP->20x1x<10)', '2019-11-14 20:26:30', 40, 40, '2019-11-14 20:26:30'),
(16, 2, 'Perimeter (TLP->20x1x<10)', '2019-11-14 20:26:35', 40, 40, '2019-11-14 20:26:35'),
(17, 2, 'PERIMETER (Height >6m)', '2019-11-14 20:26:42', 40, 40, '2019-11-14 20:26:42'),
(18, 3, 'Cantilever / Truss out', '2019-11-14 20:26:49', 40, 40, '2019-11-14 20:26:49'),
(19, 4, 'Mobile=4mH', '2019-11-14 20:26:56', 40, 40, '2019-11-14 20:26:56'),
(20, 4, 'Mobile<=3mH', '2019-11-14 20:27:02', 40, 40, '2019-11-14 20:27:02'),
(21, 5, 'Birdcage (3x5x10)', '2019-11-14 20:27:14', 40, 40, '2019-11-14 20:27:14'),
(22, 5, 'Birdcage (5x5x10)', '2019-11-14 20:27:21', 40, 40, '2019-11-14 20:27:21'),
(23, 5, 'Birdcage (6x6x10)', '2019-11-14 20:27:27', 40, 40, '2019-11-14 20:27:27'),
(24, 5, 'Birdcage (10x10x10)', '2019-11-14 20:27:33', 40, 40, '2019-11-14 20:27:33'),
(25, 5, 'Birdcage (15x15x10)', '2019-11-14 20:27:39', 40, 40, '2019-11-14 20:27:39'),
(26, 6, 'Hanging', '2019-11-14 20:27:45', 40, 40, '2019-11-14 20:27:45'),
(27, 7, 'Lift shaft', '2019-11-14 20:27:55', 40, 40, '2019-11-14 20:27:55'),
(28, 7, 'Riser', '2019-11-14 20:28:00', 40, 40, '2019-11-14 20:28:00'),
(29, 4, 'Al.Mobile (2x2x6)', '2019-11-14 20:30:29', 40, 40, '2019-11-14 20:30:29'),
(30, 4, 'Al.Tower (2x2x10)', '2019-11-14 20:30:51', 40, 40, '2019-11-14 20:30:51'),
(31, 16, 'Catching Platform', '2019-11-14 20:31:13', 40, 40, '2019-11-14 20:31:13'),
(32, 17, 'Additional Platform m2', '2019-11-14 20:31:23', 40, 40, '2019-11-14 20:31:23'),
(33, 17, 'Additional Platform m3', '2019-11-14 20:31:38', 40, 40, '2019-11-14 20:31:38'),
(34, 18, 'Cantilever Bracket', '2019-11-14 20:31:45', 40, 40, '2019-11-14 20:31:45'),
(35, 19, 'Cantilever I-Beam', '2019-11-14 20:31:54', 40, 40, '2019-11-14 20:31:54'),
(36, 19, 'Cantilever Truss Beam', '2019-11-14 20:32:03', 40, 40, '2019-11-14 20:32:03'),
(37, 20, 'Heavy Duty m2 (Spacing <1m)', '2019-11-14 20:32:12', 40, 40, '2019-11-14 20:32:12'),
(38, 20, 'Heavy Duty m3 (Spacing >1m)', '2019-11-14 20:32:19', 40, 40, '2019-11-14 20:32:19'),
(39, 21, 'Hard Barricade with Anchor', '2019-11-14 20:32:31', 40, 40, '2019-11-14 20:32:31'),
(40, 21, 'Hard Barricade', '2019-11-14 20:32:39', 40, 40, '2019-11-14 20:32:39'),
(41, 5, 'Birdcage (Higher)', '2019-11-14 20:34:11', 40, 40, '2019-11-14 20:34:11'),
(42, 22, 'Access Tower (DSL)', '2019-11-14 20:37:02', 40, 40, '2019-11-14 20:37:02'),
(43, 23, 'Skeleton (NO Platform)', '2019-11-14 20:40:23', 40, 40, '2019-11-14 20:40:23'),
(44, 22, 'Access Tower (SSL)', '2019-11-15 12:59:16', 40, 40, '2019-11-15 12:59:16');

-- --------------------------------------------------------

--
-- Table structure for table `p_scaffoldtype`
--

CREATE TABLE `p_scaffoldtype` (
  `id` int(11) NOT NULL,
  `scaffoldName` varchar(100) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_scaffoldtype`
--

INSERT INTO `p_scaffoldtype` (`id`, `scaffoldName`, `status`) VALUES
(1, 'Tower', 1),
(2, 'Perimeter', 1),
(3, 'Cantilever', 1),
(4, 'Mobile', 1),
(5, 'Birdcage', 1),
(6, 'Hanging', 1),
(7, 'Lift Shaft', 1),
(16, 'Catching Platform', 1),
(17, 'Additional Platform', 1),
(18, 'Cantilever Bracket', 1),
(19, 'Cantilever I-Beam', 1),
(20, 'Heavy Duty', 1),
(21, 'Hard Barricade', 1),
(22, 'Access Tower', 1),
(23, 'Skeleton (NO Platform)', 1);

-- --------------------------------------------------------

--
-- Table structure for table `p_scaffoldworktype`
--

CREATE TABLE `p_scaffoldworktype` (
  `id` int(11) NOT NULL,
  `scaffoldName` varchar(100) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_scaffoldworktype`
--

INSERT INTO `p_scaffoldworktype` (`id`, `scaffoldName`, `status`) VALUES
(1, 'Erection', 1),
(2, 'Dismandle', 1),
(3, 'Modification', 1),
(4, 'Erection & Dismandle', 1),
(5, 'Re-Erection', 1),
(6, 'Modification & Dismandle', 1),
(11, 'Top-Up', 1),
(12, 'Dismandle & Re-Erection', 1);

-- --------------------------------------------------------

--
-- Table structure for table `p_supervisor`
--

CREATE TABLE `p_supervisor` (
  `supervisorId` int(11) NOT NULL,
  `projectId` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `createdOn` datetime NOT NULL,
  `createdBy` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_supervisor`
--

INSERT INTO `p_supervisor` (`supervisorId`, `projectId`, `type`, `createdOn`, `createdBy`) VALUES
(5, 3, 1, '2019-03-07 00:00:00', 1);

-- --------------------------------------------------------

--
-- Table structure for table `p_users`
--

CREATE TABLE `p_users` (
  `userId` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `userName` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `userType` smallint(2) NOT NULL,
  `userStatus` tinyint(1) NOT NULL DEFAULT '1',
  `createdBy` int(11) NOT NULL,
  `project` varchar(100) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_users`
--

INSERT INTO `p_users` (`userId`, `Name`, `userName`, `password`, `userType`, `userStatus`, `createdBy`, `project`) VALUES
(2, 'Admin', 'admin', '0192023a7bbd73250516f069df18b500', 1, 1, 0, '0'),
(38, 'Mani', 'Mani', 'efcf354e118cd694064dc0b3b9e023ba', 1, 1, 2, '0'),
(39, 'Kathir', 'Kathir', '3f841bac59348bda5d32394ff88d6b25', 1, 1, 2, '0'),
(40, 'Vijay', 'Vijay', '03f8e154b1ff9a18c1a238a42e558f1a', 1, 1, 2, '0'),
(41, 'Amirthalingam', 'Lingam', 'ba0ff8ccb63a9838f7f36ee8c61a24ae', 5, 1, 2, '25,30,34,40,43,47,48,51,52'),
(43, 'R.Rethinam', 'Rethinam', '533d01d130e5f1396e2e85a199ef8536', 5, 1, 2, '26,27,32,34,40,47,48,49,50,51'),
(44, 'T.Arulmurugan', 'Arul', 'f020193202b1b7f56eb7fa07e3edf2bd', 5, 1, 2, '24,26,27'),
(45, 'J.Nallusamy', 'Nallusamy', 'da9414575226afc5410f794f728b50d9', 5, 1, 2, '26,30,32,34,40'),
(46, 'R.Sasikumar', 'Sasi', '54f79eb0053fea7d829e86f7e7ce9d7f', 5, 1, 2, '26'),
(47, 'Joseph Leo', 'Joseph', '6a1a376d8169cfc1835f59ac934edbb7', 5, 1, 2, '25,34,40,43'),
(48, 'Anisur', 'Anisur', 'fbdb2cf51a9dc47d7582ce7187ea3ba0', 5, 1, 2, '27,32,43'),
(49, 'M.Ananthan', 'Ananthan', 'e36e452973568a6f939aa2e59804868a', 5, 1, 2, '24'),
(50, 'S.Sundaram', 'Sundaram', '039ed05c5d28907a3294ee505761623e', 5, 1, 2, '26,32,49,50,51'),
(51, 'Venkatapathy', 'Pathy', 'c7ba02df9ea8150c811fee3aacfe0f0f', 5, 1, 2, '24,25'),
(52, 'K.Kalai', 'Kalai', '03c7602c1746571039dfdc41f4e731ef', 3, 1, 2, '0'),
(53, 'Bala', 'Bala', '886b5c4cc901db0ff4d3b317169fabcc', 1, 1, 40, '0'),
(54, 'Suresh Pandian', 'Suresh', 'bac015e70aa82a58423deae70f973c27', 5, 1, 40, '25,40,43,51,53,55,57'),
(55, 'Kannan', 'Kannan', 'c77ecd8be1ba400dad3fc819105511fa', 4, 1, 40, '0'),
(56, 'jeeva4test', 'jeeva', '05566da9f547a347a8b4904006957ba9', 5, 1, 2, '24,25,26,27,30,32,34,40,43,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61'),
(57, 'Test Supervisor', 'test-supervisor', '81dc9bdb52d04dc20036dbd8313ed055', 5, 1, 2, '24,25,26,27,30,32,34,40,43,47,48,49,50,51,52'),
(58, 'Test Admin User', 'test-admin', '81dc9bdb52d04dc20036dbd8313ed055', 1, 1, 2, '0');

-- --------------------------------------------------------

--
-- Table structure for table `p_workarrangement`
--

CREATE TABLE `p_workarrangement` (
  `workArrangementId` int(11) NOT NULL,
  `projectId` int(11) NOT NULL,
  `baseSupervsor` int(11) NOT NULL,
  `addSupervsor` int(11) NOT NULL,
  `createdOn` datetime NOT NULL,
  `createdBy` int(11) NOT NULL,
  `remarks` text NOT NULL,
  `status` tinyint(1) NOT NULL,
  `attendanceStatus` tinyint(1) NOT NULL DEFAULT '0',
  `attendanceRemark` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_workarrangement`
--

INSERT INTO `p_workarrangement` (`workArrangementId`, `projectId`, `baseSupervsor`, `addSupervsor`, `createdOn`, `createdBy`, `remarks`, `status`, `attendanceStatus`, `attendanceRemark`) VALUES
(1, 3, 5, 9, '2019-04-27 00:00:00', 2, '', 1, 1, ''),
(2, 3, 5, 9, '2019-04-27 00:00:00', 2, 'These 2 worker will start at 2pm', 1, 0, ''),
(3, 4, 11, 11, '2019-04-27 00:00:00', 2, 'They will start at 8.00 am', 1, 0, ''),
(4, 3, 5, 5, '2019-04-28 00:00:00', 2, '@2pm', 2, 0, ''),
(5, 4, 7, 7, '2019-04-27 00:00:00', 2, '@2pm', 1, 0, ''),
(6, 3, 5, 9, '2019-04-28 00:00:00', 2, '', 2, 0, ''),
(7, 3, 5, 9, '2019-04-28 00:00:00', 2, '', 2, 0, ''),
(8, 4, 11, 7, '2019-04-28 00:00:00', 2, '', 2, 0, ''),
(9, 3, 5, 9, '2019-05-04 00:00:00', 2, 'js asas', 1, 1, 'Worker 4 is late'),
(10, 4, 7, 7, '2019-05-04 00:00:00', 2, '3 company workers', 1, 0, ''),
(11, 5, 6, 0, '2019-05-04 00:00:00', 2, '2 team 1 worker', 1, 0, ''),
(12, 4, 13, 13, '2019-05-07 00:00:00', 2, '2 workers', 1, 0, ''),
(13, 3, 5, 5, '2019-05-07 00:00:00', 2, '3 pax', 1, 0, ''),
(14, 3, 5, 9, '2019-05-06 00:00:00', 2, '', 2, 0, ''),
(15, 3, 5, 9, '2019-05-09 00:00:00', 2, '', 1, 0, ''),
(16, 4, 11, 11, '2019-05-09 00:00:00', 2, '', 2, 0, ''),
(17, 3, 5, 9, '2019-05-11 00:00:00', 2, '', 1, 1, ''),
(18, 3, 5, 5, '2019-05-12 00:00:00', 2, '5 Workers assigned to project 5', 1, 0, ''),
(19, 4, 7, 7, '2019-05-12 00:00:00', 2, '3 worker assigned for project 2', 1, 0, ''),
(20, 4, 7, 7, '2019-05-11 00:00:00', 2, '', 2, 0, ''),
(21, 5, 6, 6, '2019-05-11 00:00:00', 2, '', 2, 0, ''),
(22, 3, 14, 14, '2019-05-10 00:00:00', 2, 'all go to Hooland', 2, 0, ''),
(23, 3, 5, 9, '2019-05-19 00:00:00', 2, '3 worker', 1, 0, ''),
(24, 4, 7, 7, '2019-05-19 00:00:00', 2, '5 worker for project 2', 1, 0, ''),
(25, 3, 5, 5, '2019-05-18 00:00:00', 2, '5 paxs', 1, 1, 'only person came on time'),
(26, 4, 11, 11, '2019-05-18 00:00:00', 2, 'testing', 2, 0, ''),
(27, 5, 6, 6, '2019-05-20 00:00:00', 2, '', 2, 0, ''),
(28, 4, 7, 11, '2019-05-20 00:00:00', 2, '', 2, 0, ''),
(29, 3, 5, 9, '2019-06-08 00:00:00', 2, 'sddg', 1, 0, ''),
(30, 4, 7, 7, '2019-06-08 00:00:00', 2, '', 2, 0, ''),
(31, 12, 17, 18, '2019-06-08 00:00:00', 2, 'Worker will start in another project after 12pm', 2, 0, ''),
(32, 13, 21, 20, '2019-06-08 00:00:00', 2, 'Worker will login after 12pm', 2, 0, ''),
(33, 3, 5, 9, '2019-06-09 00:00:00', 2, 'Worker start from 8 to 1', 1, 0, ''),
(34, 4, 7, 13, '2019-06-09 00:00:00', 2, 'worker 2 start from 1 to 5', 1, 0, ''),
(35, 5, 15, 0, '2019-06-09 00:00:00', 2, 'Project 3 assignment', 1, 0, ''),
(36, 3, 5, 9, '2019-06-11 00:00:00', 2, '', 1, 1, ''),
(37, 4, 13, 16, '2019-06-11 00:00:00', 2, '', 2, 0, ''),
(38, 5, 12, 12, '2019-06-11 00:00:00', 2, '', 1, 1, ''),
(39, 15, 23, 23, '2019-06-11 00:00:00', 2, '', 1, 0, ''),
(40, 3, 12, 12, '2019-06-10 00:00:00', 2, '', 1, 1, ''),
(41, 3, 5, 9, '2019-06-25 00:00:00', 2, 'dghg', 2, 0, ''),
(42, 19, 26, 27, '2019-06-29 00:00:00', 2, 'Worker 10 will go to project RGS after 12pm', 1, 0, ''),
(43, 16, 25, 25, '2019-06-29 00:00:00', 2, 'Worker 10 will start after 12pm', 1, 0, ''),
(44, 3, 5, 9, '2019-06-29 00:00:00', 2, 'will go RGS project after 12pm', 1, 1, 'Worker 8 on leave'),
(45, 3, 5, 9, '2019-07-11 00:00:00', 2, 'test', 1, 1, ''),
(46, 3, 9, 5, '2019-07-12 00:00:00', 2, '', 1, 0, ''),
(47, 15, 23, 0, '2019-07-12 00:00:00', 2, 'Worker 11 has partial work at Mandai Zoo', 1, 1, 'Late - worker 7'),
(48, 17, 5, 3, '2019-07-12 00:00:00', 2, 'Start after 12pm', 1, 1, 'Attendance Submitted'),
(49, 18, 24, 31, '2019-07-13 00:00:00', 2, 'worker3 is arranged for partial work arrangement.', 1, 1, 'Leaving early for course'),
(50, 16, 29, 0, '2019-07-31 00:00:00', 2, '', 2, 0, ''),
(51, 4, 5, 7, '2019-07-12 00:00:00', 2, 'test', 2, 0, ''),
(52, 19, 26, 27, '2019-07-13 00:00:00', 2, 'House keeping work', 1, 1, ''),
(53, 15, 23, 0, '2019-07-13 00:00:00', 2, '', 2, 0, ''),
(54, 24, 49, 51, '2019-07-18 00:00:00', 38, '', 1, 0, ''),
(55, 25, 41, 47, '2019-07-18 00:00:00', 38, '', 1, 0, ''),
(56, 27, 44, 0, '2019-07-18 00:00:00', 38, '', 1, 0, ''),
(57, 27, 44, 44, '2019-07-17 00:00:00', 2, '', 1, 1, ''),
(58, 25, 41, 47, '2019-07-17 00:00:00', 2, '', 1, 1, ''),
(59, 24, 49, 42, '2019-07-17 00:00:00', 2, '', 1, 0, ''),
(60, 25, 41, 47, '2019-07-19 00:00:00', 38, '', 1, 0, ''),
(61, 24, 49, 51, '2019-07-19 00:00:00', 38, '', 1, 0, ''),
(62, 27, 44, 43, '2019-07-19 00:00:00', 38, '', 1, 1, ''),
(63, 45, 48, 50, '2019-07-19 00:00:00', 38, '', 1, 0, ''),
(64, 29, 43, 44, '2019-07-19 00:00:00', 38, 'Note: Afternoon go to RGS', 1, 0, ''),
(65, 24, 41, 42, '2019-07-21 00:00:00', 2, '', 1, 1, ''),
(66, 25, 41, 41, '2019-07-21 00:00:00', 2, '', 1, 1, ''),
(67, 26, 43, 44, '2019-07-21 00:00:00', 2, '', 1, 1, ''),
(68, 27, 43, 44, '2019-07-21 00:00:00', 2, '', 1, 0, ''),
(69, 28, 41, 44, '2019-07-21 00:00:00', 2, '', 1, 1, ''),
(70, 29, 43, 44, '2019-07-21 00:00:00', 2, '', 1, 0, ''),
(71, 24, 42, 49, '2019-07-22 00:00:00', 2, '', 1, 0, ''),
(72, 26, 43, 44, '2019-07-22 00:00:00', 2, '', 1, 0, ''),
(73, 27, 43, 44, '2019-07-22 00:00:00', 2, '', 1, 0, ''),
(74, 25, 41, 51, '2019-07-22 00:00:00', 2, '', 1, 0, ''),
(75, 29, 43, 44, '2019-07-22 00:00:00', 2, '', 1, 0, ''),
(76, 24, 42, 49, '2019-07-20 00:00:00', 2, 'Muthukumaran - afternoon will go to ITE', 1, 0, ''),
(77, 29, 43, 44, '2019-07-20 00:00:00', 2, '', 1, 1, ''),
(78, 28, 41, 44, '2019-07-20 00:00:00', 2, '', 1, 0, ''),
(79, 27, 44, 43, '2019-07-20 00:00:00', 2, 'test', 1, 1, ''),
(80, 24, 49, 0, '2019-07-23 00:00:00', 38, '', 1, 1, ''),
(81, 24, 49, 0, '2019-07-24 00:00:00', 2, 'Monir go to Mandai after 10am', 2, 0, ''),
(82, 25, 41, 47, '2019-07-24 00:00:00', 2, '', 2, 0, ''),
(83, 24, 49, 51, '2019-07-25 00:00:00', 40, '', 2, 0, ''),
(84, 25, 41, 47, '2019-07-23 00:00:00', 40, '', 1, 0, ''),
(85, 26, 46, 0, '2019-07-23 00:00:00', 40, '', 1, 1, ''),
(86, 27, 44, 0, '2019-07-23 00:00:00', 40, '', 1, 1, ''),
(87, 24, 49, 0, '2019-07-26 00:00:00', 40, '', 2, 0, ''),
(88, 24, 49, 49, '2019-08-03 00:00:00', 40, '', 2, 0, ''),
(89, 24, 49, 0, '2020-01-09 00:00:00', 40, '', 1, 1, ''),
(90, 24, 49, 51, '2020-01-10 00:00:00', 40, '', 1, 0, ''),
(91, 25, 47, 51, '2020-01-10 00:00:00', 40, '', 1, 0, ''),
(92, 26, 46, 0, '2020-01-10 00:00:00', 40, '', 1, 0, ''),
(93, 27, 48, 0, '2020-01-10 00:00:00', 40, '', 1, 0, ''),
(94, 34, 41, 45, '2020-01-10 00:00:00', 40, '', 1, 0, ''),
(95, 51, 41, 50, '2020-01-10 00:00:00', 40, '', 1, 0, ''),
(96, 40, 47, 0, '2020-01-10 00:00:00', 40, '', 1, 0, ''),
(97, 47, 43, 0, '2020-01-10 00:00:00', 40, '', 1, 0, ''),
(98, 27, 43, 44, '2020-01-11 00:00:00', 40, '', 2, 0, ''),
(99, 24, 49, 51, '2020-01-11 00:00:00', 40, '', 2, 0, ''),
(100, 26, 44, 0, '2020-01-09 00:00:00', 40, '', 1, 1, ''),
(101, 32, 48, 0, '2020-01-09 00:00:00', 40, '', 1, 0, ''),
(102, 40, 41, 0, '2020-01-09 00:00:00', 40, '', 1, 0, ''),
(103, 43, 47, 0, '2020-01-09 00:00:00', 40, '', 1, 0, ''),
(104, 49, 43, 43, '2020-01-09 00:00:00', 40, '', 1, 1, ''),
(105, 47, 41, 0, '2020-01-09 00:00:00', 40, '', 1, 1, ''),
(106, 26, 43, 0, '2020-01-12 00:00:00', 40, '', 1, 0, ''),
(107, 27, 44, 0, '2020-01-12 00:00:00', 40, '', 1, 0, ''),
(108, 25, 47, 41, '2020-04-21 00:00:00', 40, 'Supply-3 pax', 1, 1, ''),
(109, 24, 49, 51, '2020-04-22 00:00:00', 39, '', 1, 0, ''),
(110, 26, 43, 43, '2020-04-21 00:00:00', 40, '', 1, 0, ''),
(111, 24, 49, 51, '2020-04-21 00:00:00', 40, '', 1, 1, ''),
(112, 24, 49, 51, '2020-04-23 00:00:00', 40, '', 1, 1, ''),
(113, 26, 46, 50, '2020-04-23 00:00:00', 40, '', 1, 1, ''),
(114, 25, 47, 0, '2020-04-23 00:00:00', 40, '', 1, 0, ''),
(115, 24, 49, 49, '2020-04-25 00:00:00', 40, '', 1, 1, ''),
(116, 25, 47, 0, '2020-04-25 00:00:00', 40, '', 1, 1, ''),
(117, 25, 56, 51, '2020-05-02 00:00:00', 2, '', 2, 0, ''),
(118, 24, 49, 51, '2020-05-02 00:00:00', 40, '', 1, 0, ''),
(119, 24, 49, 51, '2020-05-03 00:00:00', 40, '', 1, 1, ''),
(120, 25, 41, 47, '2020-05-03 00:00:00', 40, '', 2, 0, ''),
(121, 27, 48, 43, '2020-05-03 00:00:00', 40, '', 2, 0, ''),
(122, 34, 45, 0, '2020-05-03 00:00:00', 40, '', 2, 0, ''),
(123, 27, 44, 48, '2020-05-07 00:00:00', 40, '', 1, 1, ''),
(124, 26, 43, 50, '2020-05-07 00:00:00', 40, '', 1, 0, ''),
(125, 24, 49, 51, '2020-05-07 00:00:00', 40, '', 1, 0, ''),
(126, 25, 47, 54, '2020-05-07 00:00:00', 40, '', 1, 0, ''),
(127, 30, 45, 0, '2020-05-07 00:00:00', 40, '', 1, 0, ''),
(128, 24, 44, 49, '2020-05-25 00:00:00', 40, '', 1, 0, ''),
(129, 24, 51, 49, '2020-06-03 00:00:00', 58, 'test', 1, 0, ''),
(130, 26, 57, 56, '2020-05-30 00:00:00', 58, '', 1, 1, 'test'),
(131, 25, 47, 51, '2020-05-30 00:00:00', 58, 'tst draft', 2, 0, ''),
(132, 24, 44, 49, '2020-06-05 00:00:00', 58, '', 2, 0, ''),
(133, 25, 41, 47, '2020-06-05 00:00:00', 58, '', 2, 0, '');

-- --------------------------------------------------------

--
-- Table structure for table `p_workattendance`
--

CREATE TABLE `p_workattendance` (
  `id` int(11) NOT NULL,
  `workArrangementId` int(11) NOT NULL,
  `workerId` int(11) NOT NULL,
  `workerTeam` tinyint(3) NOT NULL,
  `inTime` time NOT NULL,
  `outTime` time NOT NULL,
  `reason` tinyint(2) NOT NULL,
  `forDate` date NOT NULL,
  `createdOn` datetime NOT NULL,
  `status` tinyint(2) NOT NULL,
  `statusOut` tinyint(2) NOT NULL,
  `partial` tinyint(1) NOT NULL DEFAULT '0',
  `isSupervisor` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_workattendance`
--

INSERT INTO `p_workattendance` (`id`, `workArrangementId`, `workerId`, `workerTeam`, `inTime`, `outTime`, `reason`, `forDate`, `createdOn`, `status`, `statusOut`, `partial`, `isSupervisor`) VALUES
(1, 1, 1, 1, '08:35:00', '01:10:00', 0, '2019-04-27', '2019-04-27 10:41:49', 0, 0, 0, 0),
(2, 1, 2, 1, '08:00:00', '03:00:00', 0, '2019-04-27', '2019-04-27 10:41:49', 0, 0, 0, 0),
(3, 1, 5, 1, '08:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 10:41:49', 0, 0, 0, 0),
(4, 1, 6, 1, '08:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 10:41:49', 0, 0, 0, 0),
(5, 2, 3, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 11:02:19', 0, 0, 0, 0),
(6, 2, 4, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 11:02:19', 0, 0, 0, 0),
(7, 3, 7, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 11:03:18', 0, 0, 0, 0),
(8, 3, 8, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 11:03:18', 0, 0, 0, 0),
(9, 4, 1, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 13:10:03', 0, 0, 0, 0),
(10, 4, 2, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 13:10:03', 0, 0, 0, 0),
(11, 4, 3, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 13:10:03', 0, 0, 0, 0),
(12, 5, 9, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 13:11:52', 0, 0, 0, 0),
(13, 5, 10, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 13:11:52', 0, 0, 0, 0),
(14, 5, 11, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 13:11:52', 0, 0, 0, 0),
(15, 6, 1, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 18:27:01', 0, 0, 0, 0),
(16, 6, 2, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 18:27:01', 0, 0, 0, 0),
(17, 6, 3, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 18:27:01', 0, 0, 0, 0),
(18, 6, 4, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 18:27:01', 0, 0, 0, 0),
(19, 7, 1, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 18:28:22', 0, 0, 0, 0),
(20, 7, 2, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 18:28:22', 0, 0, 0, 0),
(21, 7, 3, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 18:28:22', 0, 0, 0, 0),
(22, 7, 4, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 18:28:22', 0, 0, 0, 0),
(23, 8, 4, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 18:28:52', 0, 0, 0, 0),
(24, 8, 5, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 18:28:52', 0, 0, 0, 0),
(25, 8, 6, 1, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 18:28:52', 0, 0, 0, 0),
(26, 9, 1, 1, '23:33:00', '02:20:00', 0, '2019-05-04', '2019-05-04 09:24:42', 1, 0, 0, 0),
(27, 9, 2, 1, '08:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 09:24:42', 1, 0, 0, 0),
(28, 9, 4, 1, '10:05:00', '00:00:00', 5, '2019-05-04', '2019-05-04 09:24:42', 1, 0, 0, 0),
(32, 10, 3, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 10:58:36', 0, 0, 0, 0),
(33, 10, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 10:58:36', 0, 0, 0, 0),
(34, 10, 5, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 10:58:36', 0, 0, 0, 0),
(35, 10, 6, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 10:58:36', 0, 0, 0, 0),
(36, 11, 7, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 11:20:11', 0, 0, 0, 0),
(37, 11, 8, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 11:20:11', 0, 0, 0, 0),
(38, 12, 1, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 11:33:17', 0, 0, 0, 0),
(39, 12, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 11:33:17', 0, 0, 0, 0),
(40, 13, 3, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 11:37:55', 0, 0, 0, 0),
(41, 13, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 11:37:55', 0, 0, 0, 0),
(42, 13, 5, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 11:37:55', 0, 0, 0, 0),
(43, 14, 1, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 13:29:55', 0, 0, 0, 0),
(44, 14, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 13:29:55', 0, 0, 0, 0),
(45, 14, 3, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 13:29:55', 0, 0, 0, 0),
(46, 14, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 13:29:55', 0, 0, 0, 0),
(47, 15, 1, 1, '00:00:00', '00:00:00', 0, '2019-05-09', '2019-05-09 16:57:51', 0, 0, 0, 0),
(48, 15, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-09', '2019-05-09 16:57:51', 0, 0, 0, 0),
(49, 16, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-09', '2019-05-09 19:36:57', 0, 0, 0, 0),
(52, 18, 1, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 10:49:07', 0, 0, 0, 0),
(53, 18, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 10:49:07', 0, 0, 0, 0),
(54, 18, 3, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 10:49:07', 0, 0, 0, 0),
(55, 18, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 10:49:07', 0, 0, 0, 0),
(56, 18, 5, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 10:49:07', 0, 0, 0, 0),
(75, 19, 6, 1, '00:00:00', '00:00:00', 0, '2019-05-12', '2019-05-11 10:53:41', 0, 0, 0, 0),
(76, 19, 7, 1, '00:00:00', '00:00:00', 0, '2019-05-12', '2019-05-11 10:53:42', 0, 0, 0, 0),
(77, 19, 8, 1, '00:00:00', '00:00:00', 0, '2019-05-12', '2019-05-11 10:53:42', 0, 0, 0, 0),
(78, 20, 6, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 12:13:58', 0, 0, 0, 0),
(79, 20, 7, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 12:13:58', 0, 0, 0, 0),
(80, 20, 8, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 12:13:58', 0, 0, 0, 0),
(81, 21, 9, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 12:15:06', 0, 0, 0, 0),
(82, 21, 10, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 12:15:06', 0, 0, 0, 0),
(83, 21, 11, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 12:15:06', 0, 0, 0, 0),
(84, 22, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 12:23:55', 0, 0, 0, 0),
(85, 22, 3, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 12:23:55', 0, 0, 0, 0),
(86, 22, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 12:23:55', 0, 0, 0, 0),
(90, 17, 1, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 12:24:42', 0, 0, 0, 0),
(91, 17, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-11', '2019-05-11 12:24:42', 0, 0, 0, 0),
(92, 23, 1, 1, '00:00:00', '00:00:00', 0, '2019-05-19', '2019-05-18 09:36:10', 0, 0, 0, 0),
(93, 23, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-19', '2019-05-18 09:36:10', 0, 0, 0, 0),
(94, 23, 3, 1, '00:00:00', '00:00:00', 0, '2019-05-19', '2019-05-18 09:36:10', 0, 0, 0, 0),
(95, 24, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-19', '2019-05-18 09:36:55', 0, 0, 0, 0),
(96, 24, 5, 1, '00:00:00', '00:00:00', 0, '2019-05-19', '2019-05-18 09:36:55', 0, 0, 0, 0),
(97, 24, 6, 1, '00:00:00', '00:00:00', 0, '2019-05-19', '2019-05-18 09:36:55', 0, 0, 0, 0),
(98, 24, 7, 1, '00:00:00', '00:00:00', 0, '2019-05-19', '2019-05-18 09:36:55', 0, 0, 0, 0),
(99, 24, 8, 1, '00:00:00', '00:00:00', 0, '2019-05-19', '2019-05-18 09:36:55', 0, 0, 0, 0),
(105, 26, 6, 1, '00:00:00', '00:00:00', 0, '2019-05-18', '2019-05-18 10:39:42', 0, 0, 0, 0),
(106, 26, 7, 1, '00:00:00', '00:00:00', 0, '2019-05-18', '2019-05-18 10:39:42', 0, 0, 0, 0),
(107, 25, 1, 1, '08:00:00', '00:00:00', 0, '2019-05-18', '2019-05-18 10:47:19', 1, 0, 0, 0),
(108, 25, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-18', '2019-05-18 10:47:19', 0, 0, 0, 0),
(109, 25, 3, 1, '00:00:00', '00:00:00', 0, '2019-05-18', '2019-05-18 10:47:19', 0, 0, 0, 0),
(110, 25, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-18', '2019-05-18 10:47:19', 0, 0, 0, 0),
(111, 25, 5, 1, '00:00:00', '00:00:00', 0, '2019-05-18', '2019-05-18 10:47:19', 0, 0, 0, 0),
(112, 27, 1, 1, '00:00:00', '00:00:00', 0, '2019-05-20', '2019-05-18 12:13:56', 0, 0, 0, 0),
(113, 27, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-20', '2019-05-18 12:13:56', 0, 0, 0, 0),
(114, 27, 3, 1, '00:00:00', '00:00:00', 0, '2019-05-20', '2019-05-18 12:13:56', 0, 0, 0, 0),
(115, 28, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-20', '2019-05-18 12:14:51', 0, 0, 0, 0),
(116, 28, 5, 1, '00:00:00', '00:00:00', 0, '2019-05-20', '2019-05-18 12:14:51', 0, 0, 0, 0),
(117, 28, 6, 1, '00:00:00', '00:00:00', 0, '2019-05-20', '2019-05-18 12:14:51', 0, 0, 0, 0),
(120, 29, 1, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 18:26:16', 0, 0, 1, 0),
(121, 29, 4, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 18:26:16', 0, 0, 0, 0),
(122, 30, 3, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 18:26:52', 0, 0, 1, 0),
(123, 30, 5, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 18:26:52', 0, 0, 0, 0),
(124, 30, 6, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 18:26:52', 0, 0, 0, 0),
(125, 31, 1, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 21:33:05', 0, 0, 1, 0),
(126, 31, 2, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 21:33:05', 0, 0, 0, 0),
(127, 31, 3, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 21:33:05', 0, 0, 0, 0),
(128, 31, 7, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 21:33:05', 0, 0, 0, 0),
(129, 32, 1, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 21:34:35', 0, 0, 0, 0),
(130, 32, 8, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 21:34:35', 0, 0, 0, 0),
(131, 32, 9, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 21:34:35', 0, 0, 0, 0),
(132, 33, 1, 1, '00:00:00', '00:00:00', 0, '2019-06-09', '2019-06-09 10:27:56', 0, 0, 0, 0),
(133, 33, 2, 1, '00:00:00', '00:00:00', 0, '2019-06-09', '2019-06-09 10:27:56', 0, 0, 1, 0),
(134, 33, 3, 1, '00:00:00', '00:00:00', 0, '2019-06-09', '2019-06-09 10:27:56', 0, 0, 0, 0),
(135, 34, 2, 1, '00:00:00', '00:00:00', 0, '2019-06-09', '2019-06-09 10:33:31', 0, 0, 1, 0),
(136, 34, 4, 1, '00:00:00', '00:00:00', 0, '2019-06-09', '2019-06-09 10:33:31', 0, 0, 0, 0),
(137, 34, 5, 1, '00:00:00', '00:00:00', 0, '2019-06-09', '2019-06-09 10:33:31', 0, 0, 0, 0),
(145, 35, 6, 1, '00:00:00', '00:00:00', 0, '2019-06-09', '2019-06-09 10:38:23', 0, 0, 0, 0),
(146, 35, 7, 1, '00:00:00', '00:00:00', 0, '2019-06-09', '2019-06-09 10:38:23', 0, 0, 0, 0),
(147, 35, 8, 1, '00:00:00', '00:00:00', 0, '2019-06-09', '2019-06-09 10:38:23', 0, 0, 0, 0),
(148, 36, 1, 1, '08:00:00', '00:00:00', 0, '2019-06-11', '2019-06-10 10:15:33', 1, 0, 0, 0),
(149, 36, 2, 1, '08:00:00', '00:00:00', 0, '2019-06-11', '2019-06-10 10:15:33', 1, 0, 0, 0),
(150, 36, 3, 1, '08:00:00', '00:00:00', 0, '2019-06-11', '2019-06-10 10:15:33', 1, 0, 0, 0),
(151, 37, 4, 1, '00:00:00', '00:00:00', 0, '2019-06-11', '2019-06-10 10:15:58', 0, 0, 1, 0),
(152, 37, 5, 1, '00:00:00', '00:00:00', 0, '2019-06-11', '2019-06-10 10:15:58', 0, 0, 1, 0),
(153, 37, 6, 1, '00:00:00', '00:00:00', 0, '2019-06-11', '2019-06-10 10:15:58', 0, 0, 1, 0),
(154, 38, 4, 1, '08:00:00', '00:00:00', 0, '2019-06-11', '2019-06-10 10:16:26', 1, 0, 1, 0),
(155, 38, 5, 1, '08:00:00', '00:00:00', 0, '2019-06-11', '2019-06-10 10:16:26', 1, 0, 1, 0),
(156, 38, 6, 1, '00:00:00', '00:00:00', 5, '2019-06-11', '2019-06-10 10:16:26', 1, 0, 1, 0),
(157, 39, 7, 1, '00:00:00', '00:00:00', 0, '2019-06-11', '2019-06-10 10:17:02', 0, 0, 0, 0),
(158, 39, 8, 1, '00:00:00', '00:00:00', 0, '2019-06-11', '2019-06-10 10:17:02', 0, 0, 0, 0),
(159, 39, 9, 1, '00:00:00', '00:00:00', 0, '2019-06-11', '2019-06-10 10:17:02', 0, 0, 0, 0),
(160, 40, 1, 1, '08:00:00', '00:00:00', 0, '2019-06-10', '2019-06-10 10:47:48', 1, 0, 0, 0),
(161, 40, 2, 1, '08:00:00', '00:00:00', 0, '2019-06-10', '2019-06-10 10:47:48', 1, 0, 0, 0),
(162, 40, 3, 1, '08:00:00', '00:00:00', 0, '2019-06-10', '2019-06-10 10:47:48', 1, 0, 0, 0),
(163, 40, 4, 1, '00:00:00', '00:00:00', 0, '2019-06-10', '2019-06-10 10:47:48', 0, 0, 0, 0),
(164, 41, 1, 1, '00:00:00', '00:00:00', 0, '2019-06-25', '2019-06-25 23:51:29', 0, 0, 0, 0),
(165, 41, 3, 1, '00:00:00', '00:00:00', 0, '2019-06-25', '2019-06-25 23:51:29', 0, 0, 0, 0),
(166, 41, 5, 1, '00:00:00', '00:00:00', 0, '2019-06-25', '2019-06-25 23:51:29', 0, 0, 0, 0),
(167, 42, 1, 1, '00:00:00', '00:00:00', 0, '2019-06-29', '2019-06-29 10:57:35', 0, 0, 0, 0),
(168, 42, 2, 1, '00:00:00', '00:00:00', 0, '2019-06-29', '2019-06-29 10:57:35', 0, 0, 0, 0),
(169, 42, 3, 1, '00:00:00', '00:00:00', 0, '2019-06-29', '2019-06-29 10:57:35', 0, 0, 0, 0),
(170, 42, 10, 1, '00:00:00', '00:00:00', 0, '2019-06-29', '2019-06-29 10:57:35', 0, 0, 1, 0),
(174, 43, 4, 1, '00:00:00', '00:00:00', 0, '2019-06-29', '2019-06-29 11:00:19', 0, 0, 0, 0),
(175, 43, 5, 1, '00:00:00', '00:00:00', 0, '2019-06-29', '2019-06-29 11:00:19', 0, 0, 0, 0),
(176, 43, 6, 1, '00:00:00', '00:00:00', 0, '2019-06-29', '2019-06-29 11:00:19', 0, 0, 0, 0),
(177, 43, 10, 1, '00:00:00', '00:00:00', 0, '2019-06-29', '2019-06-29 11:00:19', 0, 0, 1, 0),
(178, 44, 7, 1, '08:00:00', '06:00:00', 0, '2019-06-29', '2019-06-29 11:16:01', 1, 0, 0, 0),
(179, 44, 8, 1, '08:00:00', '05:00:00', 3, '2019-06-29', '2019-06-29 11:16:01', 1, 0, 0, 0),
(180, 44, 9, 1, '00:00:00', '00:00:00', 0, '2019-06-29', '2019-06-29 11:16:01', 0, 0, 1, 0),
(181, 44, 10, 1, '00:00:00', '00:00:00', 0, '2019-06-29', '2019-06-29 11:16:01', 0, 0, 0, 0),
(182, 45, 1, 1, '12:00:00', '00:00:00', 0, '2019-07-11', '2019-07-11 22:58:06', 1, 0, 0, 0),
(183, 45, 2, 1, '08:00:00', '00:00:00', 0, '2019-07-11', '2019-07-11 22:58:06', 1, 0, 0, 0),
(184, 45, 3, 1, '00:00:00', '00:00:00', 0, '2019-07-11', '2019-07-11 22:58:06', 0, 0, 0, 0),
(185, 45, 4, 1, '00:00:00', '00:00:00', 0, '2019-07-11', '2019-07-11 22:58:06', 0, 0, 0, 0),
(186, 45, 5, 1, '00:00:00', '00:00:00', 0, '2019-07-11', '2019-07-11 22:58:06', 0, 0, 0, 0),
(187, 46, 1, 1, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 01:37:46', 0, 0, 0, 0),
(188, 46, 2, 1, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 01:37:46', 0, 0, 0, 0),
(189, 46, 3, 1, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 01:37:46', 0, 0, 0, 0),
(190, 46, 4, 1, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 01:37:46', 0, 0, 0, 0),
(191, 46, 5, 1, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 01:37:46', 0, 0, 0, 0),
(192, 47, 7, 1, '10:00:00', '18:00:00', 5, '2019-07-12', '2019-07-12 20:29:58', 1, 1, 0, 0),
(193, 47, 8, 1, '08:00:00', '18:00:00', 0, '2019-07-12', '2019-07-12 20:29:58', 1, 1, 0, 0),
(194, 47, 9, 1, '08:00:00', '18:00:00', 0, '2019-07-12', '2019-07-12 20:29:58', 1, 1, 0, 0),
(195, 47, 11, 1, '08:00:00', '18:00:00', 0, '2019-07-12', '2019-07-12 20:29:58', 1, 1, 1, 0),
(204, 51, 13, 2, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 21:45:05', 0, 0, 0, 0),
(205, 51, 14, 2, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 21:45:05', 0, 0, 0, 0),
(212, 48, 6, 1, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 23:46:40', 0, 0, 0, 0),
(213, 48, 10, 1, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 23:46:40', 0, 0, 0, 0),
(214, 48, 11, 1, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 23:46:40', 0, 0, 1, 0),
(215, 50, 11, 1, '00:00:00', '00:00:00', 0, '2019-07-31', '2019-07-12 23:49:54', 0, 0, 0, 0),
(216, 50, 12, 2, '00:00:00', '00:00:00', 0, '2019-07-31', '2019-07-12 23:49:54', 0, 0, 0, 0),
(217, 49, 1, 1, '08:00:00', '18:00:00', 0, '2019-07-13', '2019-07-13 11:51:02', 1, 1, 0, 0),
(218, 49, 2, 1, '08:00:00', '17:00:00', 0, '2019-07-13', '2019-07-13 11:51:02', 1, 1, 0, 0),
(219, 49, 3, 1, '08:00:00', '12:00:00', 99, '2019-07-13', '2019-07-13 11:51:02', 1, 1, 1, 0),
(220, 52, 8, 1, '09:00:00', '18:00:00', 0, '2019-07-13', '2019-07-13 11:52:46', 1, 1, 0, 0),
(223, 53, 3, 1, '00:00:00', '00:00:00', 0, '2019-07-13', '2019-07-13 12:06:45', 0, 0, 0, 0),
(224, 53, 4, 1, '00:00:00', '00:00:00', 0, '2019-07-13', '2019-07-13 12:06:45', 0, 0, 0, 0),
(225, 54, 25, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 21:57:40', 0, 0, 0, 0),
(226, 54, 26, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 21:57:40', 0, 0, 0, 0),
(227, 54, 27, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 21:57:40', 0, 0, 0, 0),
(228, 54, 28, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 21:57:40', 0, 0, 0, 0),
(229, 54, 29, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 21:57:40', 0, 0, 0, 0),
(230, 55, 30, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 22:01:24', 0, 0, 0, 0),
(231, 55, 31, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 22:01:24', 0, 0, 0, 0),
(232, 55, 32, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 22:01:24', 0, 0, 0, 0),
(233, 55, 33, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 22:01:24', 0, 0, 1, 0),
(234, 55, 34, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 22:01:24', 0, 0, 1, 0),
(235, 56, 33, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 22:02:15', 0, 0, 0, 0),
(236, 56, 34, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 22:02:15', 0, 0, 0, 0),
(237, 56, 35, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 22:02:15', 0, 0, 0, 0),
(238, 56, 36, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 22:02:15', 0, 0, 0, 0),
(239, 56, 37, 1, '00:00:00', '00:00:00', 0, '2019-07-18', '2019-07-17 22:02:15', 0, 0, 0, 0),
(240, 57, 25, 1, '08:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:07:20', 1, 0, 0, 0),
(241, 57, 26, 1, '08:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:07:20', 1, 0, 0, 0),
(242, 57, 27, 1, '08:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:07:20', 1, 0, 0, 0),
(243, 57, 28, 1, '08:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:07:20', 1, 0, 0, 0),
(244, 57, 29, 1, '08:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:07:20', 1, 0, 0, 0),
(245, 57, 30, 1, '00:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:07:20', 0, 0, 0, 0),
(246, 58, 31, 1, '08:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:08:02', 1, 0, 0, 0),
(247, 58, 32, 1, '08:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:08:02', 1, 0, 0, 0),
(248, 58, 33, 1, '08:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:08:02', 1, 0, 0, 0),
(249, 58, 34, 1, '08:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:08:02', 1, 0, 0, 0),
(250, 58, 35, 1, '08:30:00', '00:00:00', 5, '2019-07-17', '2019-07-17 22:08:02', 1, 0, 0, 0),
(256, 59, 25, 1, '00:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:10:37', 0, 0, 0, 0),
(257, 59, 26, 1, '00:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:10:37', 0, 0, 0, 0),
(258, 59, 27, 1, '00:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:10:37', 0, 0, 0, 0),
(259, 59, 37, 1, '00:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:10:37', 0, 0, 0, 0),
(260, 59, 38, 1, '00:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:10:37', 0, 0, 0, 0),
(261, 59, 39, 1, '00:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:10:37', 0, 0, 0, 0),
(262, 59, 40, 1, '00:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:10:37', 0, 0, 0, 0),
(263, 59, 41, 1, '00:00:00', '00:00:00', 0, '2019-07-17', '2019-07-17 22:10:37', 0, 0, 0, 0),
(264, 60, 29, 1, '08:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:36:51', 2, 2, 0, 0),
(265, 60, 39, 1, '08:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:36:51', 2, 2, 0, 0),
(266, 60, 47, 1, '08:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:36:51', 2, 2, 0, 0),
(267, 60, 48, 1, '08:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:36:51', 2, 2, 0, 0),
(268, 60, 49, 1, '08:00:00', '00:00:00', 99, '2019-07-19', '2019-07-18 11:36:51', 2, 2, 0, 0),
(269, 61, 31, 1, '00:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:39:00', 0, 0, 0, 0),
(270, 61, 38, 1, '00:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:39:00', 0, 0, 0, 0),
(271, 61, 41, 1, '00:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:39:00', 0, 0, 0, 0),
(272, 61, 42, 1, '00:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:39:00', 0, 0, 0, 0),
(273, 61, 56, 1, '00:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:39:00', 0, 0, 0, 0),
(274, 62, 33, 1, '08:00:00', '00:00:00', 99, '2019-07-19', '2019-07-18 11:41:11', 1, 1, 0, 0),
(275, 62, 43, 1, '08:00:00', '00:00:00', 99, '2019-07-19', '2019-07-18 11:41:11', 1, 1, 0, 0),
(276, 62, 44, 1, '08:00:00', '00:00:00', 99, '2019-07-19', '2019-07-18 11:41:11', 1, 1, 0, 0),
(277, 62, 46, 1, '08:00:00', '00:00:00', 99, '2019-07-19', '2019-07-18 11:41:11', 1, 1, 0, 0),
(278, 62, 51, 1, '09:00:00', '00:00:00', 99, '2019-07-19', '2019-07-18 11:41:11', 1, 1, 0, 0),
(279, 62, 53, 1, '08:00:00', '00:00:00', 99, '2019-07-19', '2019-07-18 11:41:11', 1, 1, 0, 0),
(280, 63, 63, 13, '00:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:59:38', 0, 0, 0, 0),
(281, 63, 64, 13, '00:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:59:38', 0, 0, 0, 0),
(282, 63, 65, 13, '00:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:59:38', 0, 0, 0, 0),
(283, 63, 66, 13, '00:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:59:38', 0, 0, 0, 0),
(284, 63, 67, 13, '00:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 11:59:38', 0, 0, 0, 0),
(285, 64, 27, 1, '08:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 12:01:47', 2, 2, 1, 0),
(286, 64, 30, 1, '08:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 12:01:47', 2, 2, 1, 0),
(287, 64, 34, 1, '00:00:00', '00:00:00', 0, '2019-07-19', '2019-07-18 12:01:47', 0, 0, 1, 0),
(291, 66, 28, 1, '10:00:00', '00:00:00', 5, '2019-07-21', '2019-07-20 11:36:43', 1, 1, 0, 0),
(292, 66, 29, 1, '11:00:00', '00:00:00', 5, '2019-07-21', '2019-07-20 11:36:43', 1, 1, 0, 0),
(293, 65, 25, 1, '08:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:37:57', 1, 1, 0, 0),
(294, 65, 26, 1, '00:00:00', '09:00:00', 0, '2019-07-21', '2019-07-20 11:37:57', 1, 1, 0, 0),
(295, 65, 27, 1, '00:00:00', '17:00:00', 0, '2019-07-21', '2019-07-20 11:37:57', 1, 1, 0, 0),
(300, 67, 31, 1, '08:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:39:45', 1, 1, 0, 0),
(301, 67, 32, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:39:45', 0, 0, 0, 0),
(302, 67, 33, 1, '07:00:00', '00:00:00', 2, '2019-07-21', '2019-07-20 11:39:45', 1, 1, 0, 0),
(303, 67, 34, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:39:45', 0, 0, 0, 0),
(304, 68, 30, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:40:47', 0, 0, 0, 0),
(305, 68, 35, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:40:47', 0, 0, 0, 0),
(306, 68, 36, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:40:47', 0, 0, 0, 0),
(307, 68, 37, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:40:47', 0, 0, 0, 0),
(308, 68, 38, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:40:47', 0, 0, 0, 0),
(309, 69, 39, 1, '08:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 1, 1, 0, 0),
(310, 69, 40, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(311, 69, 41, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(312, 69, 42, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(313, 69, 43, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(314, 69, 44, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(315, 69, 45, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(316, 69, 46, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(317, 69, 47, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(318, 69, 48, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(319, 69, 49, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(320, 69, 50, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(321, 69, 51, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(322, 69, 52, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(323, 69, 53, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(324, 69, 54, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(325, 69, 55, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(326, 69, 56, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(327, 69, 57, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(328, 69, 58, 2, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(329, 69, 59, 2, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(330, 69, 60, 2, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(331, 69, 61, 2, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(332, 69, 62, 2, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(333, 69, 63, 13, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(334, 69, 64, 13, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(335, 69, 65, 13, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(336, 69, 66, 13, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(337, 69, 67, 13, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:42:07', 0, 0, 0, 0),
(342, 70, 25, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:43:21', 0, 0, 0, 0),
(343, 70, 26, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:43:21', 0, 0, 0, 0),
(344, 70, 27, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:43:21', 0, 0, 0, 0),
(345, 70, 28, 1, '00:00:00', '00:00:00', 0, '2019-07-21', '2019-07-20 11:43:21', 0, 0, 0, 0),
(346, 71, 25, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(347, 71, 26, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(348, 71, 27, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(349, 71, 28, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(350, 71, 29, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(351, 71, 30, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(352, 71, 31, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(353, 71, 32, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(354, 71, 33, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(355, 71, 34, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(356, 71, 35, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(357, 71, 36, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(358, 71, 37, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(359, 71, 38, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:44:50', 0, 0, 0, 0),
(360, 72, 39, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:46:36', 0, 0, 0, 0),
(361, 72, 40, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:46:36', 0, 0, 0, 0),
(362, 72, 41, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:46:36', 0, 0, 0, 0),
(363, 72, 42, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:46:36', 0, 0, 0, 0),
(364, 72, 43, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:46:36', 0, 0, 0, 0),
(365, 72, 44, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:46:36', 0, 0, 0, 0),
(366, 72, 45, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:46:36', 0, 0, 0, 0),
(367, 72, 46, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:46:36', 0, 0, 0, 0),
(368, 72, 47, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:46:36', 0, 0, 0, 0),
(369, 73, 48, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:47:24', 0, 0, 0, 0),
(370, 73, 49, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:47:24', 0, 0, 0, 0),
(371, 73, 50, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:47:24', 0, 0, 0, 0),
(372, 73, 51, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:47:24', 0, 0, 0, 0),
(373, 73, 52, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:47:24', 0, 0, 0, 0),
(374, 73, 53, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:47:24', 0, 0, 0, 0),
(375, 73, 54, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:47:24', 0, 0, 0, 0),
(376, 73, 55, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:47:24', 0, 0, 0, 0),
(377, 73, 56, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:47:24', 0, 0, 0, 0),
(378, 73, 57, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:47:24', 0, 0, 0, 0),
(379, 74, 58, 2, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:48:49', 0, 0, 0, 0),
(380, 74, 59, 2, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:48:49', 0, 0, 0, 0),
(381, 74, 60, 2, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:48:49', 0, 0, 0, 0),
(382, 74, 61, 2, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:48:49', 0, 0, 0, 0),
(383, 74, 62, 2, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:48:49', 0, 0, 0, 0),
(384, 74, 63, 13, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:48:49', 0, 0, 0, 0),
(385, 74, 64, 13, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:48:49', 0, 0, 0, 0),
(386, 74, 65, 13, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:48:49', 0, 0, 0, 0),
(387, 74, 66, 13, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:48:49', 0, 0, 0, 0),
(388, 74, 67, 13, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:48:49', 0, 0, 0, 0),
(389, 75, 25, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:49:59', 0, 0, 0, 0),
(390, 75, 26, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:49:59', 0, 0, 0, 0),
(391, 75, 27, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:49:59', 0, 0, 0, 0),
(392, 75, 28, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:49:59', 0, 0, 0, 0),
(393, 75, 29, 1, '00:00:00', '00:00:00', 0, '2019-07-22', '2019-07-20 11:49:59', 0, 0, 0, 0),
(397, 77, 27, 1, '08:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 11:58:03', 1, 0, 1, 0),
(398, 77, 28, 1, '00:00:00', '17:00:00', 0, '2019-07-20', '2019-07-20 11:58:03', 0, 1, 0, 0),
(399, 77, 29, 1, '00:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 11:58:03', 0, 0, 0, 0),
(400, 77, 30, 1, '00:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 11:58:03', 0, 0, 0, 0),
(405, 76, 25, 1, '00:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 12:00:53', 0, 0, 0, 0),
(406, 76, 26, 1, '00:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 12:00:53', 0, 0, 0, 0),
(407, 76, 27, 1, '00:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 12:00:53', 0, 0, 1, 0),
(408, 76, 35, 1, '00:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 12:00:53', 0, 0, 0, 0),
(409, 76, 37, 1, '00:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 12:00:53', 0, 0, 0, 0),
(410, 78, 27, 1, '00:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 12:20:42', 0, 0, 0, 0),
(411, 78, 31, 1, '00:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 12:20:42', 0, 0, 0, 0),
(412, 78, 32, 1, '00:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 12:20:42', 0, 0, 1, 0),
(413, 79, 32, 1, '00:00:00', '10:00:00', 5, '2019-07-20', '2019-07-20 12:21:57', 0, 1, 1, 0),
(414, 79, 38, 1, '00:00:00', '00:00:00', 1, '2019-07-20', '2019-07-20 12:21:57', 1, 0, 0, 0),
(415, 79, 39, 1, '11:00:00', '00:00:00', 0, '2019-07-20', '2019-07-20 12:21:57', 1, 0, 0, 0),
(421, 81, 30, 1, '00:00:00', '00:00:00', 0, '2019-07-24', '2019-07-20 13:29:04', 0, 0, 1, 0),
(422, 81, 31, 1, '00:00:00', '00:00:00', 0, '2019-07-24', '2019-07-20 13:29:04', 0, 0, 0, 0),
(423, 81, 32, 1, '00:00:00', '00:00:00', 0, '2019-07-24', '2019-07-20 13:29:04', 0, 0, 0, 0),
(424, 81, 33, 1, '00:00:00', '00:00:00', 0, '2019-07-24', '2019-07-20 13:29:04', 0, 0, 0, 0),
(425, 82, 28, 1, '00:00:00', '00:00:00', 0, '2019-07-24', '2019-07-20 13:29:53', 0, 0, 0, 0),
(426, 82, 29, 1, '00:00:00', '00:00:00', 0, '2019-07-24', '2019-07-20 13:29:53', 0, 0, 0, 0),
(427, 82, 30, 1, '00:00:00', '00:00:00', 0, '2019-07-24', '2019-07-20 13:29:53', 0, 0, 0, 0),
(428, 82, 34, 1, '00:00:00', '00:00:00', 0, '2019-07-24', '2019-07-20 13:29:53', 0, 0, 0, 0),
(431, 83, 25, 1, '00:00:00', '00:00:00', 0, '2019-07-25', '2019-07-23 20:31:25', 0, 0, 0, 0),
(432, 83, 26, 1, '00:00:00', '00:00:00', 0, '2019-07-25', '2019-07-23 20:31:25', 0, 0, 0, 0),
(433, 83, 27, 1, '00:00:00', '00:00:00', 0, '2019-07-25', '2019-07-23 20:31:25', 0, 0, 0, 0),
(434, 83, 28, 1, '00:00:00', '00:00:00', 0, '2019-07-25', '2019-07-23 20:31:25', 0, 0, 0, 0),
(435, 84, 30, 1, '00:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:34:55', 0, 0, 0, 0),
(436, 84, 31, 1, '00:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:34:55', 0, 0, 0, 0),
(437, 84, 32, 1, '00:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:34:55', 0, 0, 0, 0),
(438, 85, 33, 1, '08:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:35:23', 1, 0, 0, 0),
(439, 85, 34, 1, '08:00:00', '00:00:00', 3, '2019-07-23', '2019-07-23 20:35:23', 1, 0, 0, 0),
(440, 85, 35, 1, '10:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:35:23', 1, 0, 0, 0),
(441, 85, 36, 1, '09:00:00', '00:00:00', 5, '2019-07-23', '2019-07-23 20:35:23', 1, 0, 0, 0),
(442, 86, 37, 1, '08:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:35:47', 1, 0, 0, 0),
(443, 86, 38, 1, '08:30:00', '00:00:00', 5, '2019-07-23', '2019-07-23 20:35:47', 1, 0, 0, 0),
(444, 86, 39, 1, '08:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:35:47', 1, 0, 0, 0),
(445, 86, 40, 1, '08:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:35:47', 1, 0, 0, 0),
(446, 86, 41, 1, '00:00:00', '00:00:00', 5, '2019-07-23', '2019-07-23 20:35:47', 1, 0, 0, 0),
(447, 80, 25, 1, '08:00:00', '07:00:00', 0, '2019-07-23', '2019-07-23 20:46:36', 1, 1, 0, 0),
(448, 80, 26, 1, '08:00:00', '07:00:00', 0, '2019-07-23', '2019-07-23 20:46:36', 1, 1, 0, 0),
(449, 80, 27, 1, '00:00:00', '07:00:00', 0, '2019-07-23', '2019-07-23 20:46:36', 1, 1, 0, 0),
(450, 80, 28, 1, '08:00:00', '07:00:00', 0, '2019-07-23', '2019-07-23 20:46:36', 1, 1, 0, 0),
(451, 80, 29, 1, '00:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:46:36', 0, 0, 0, 0),
(452, 80, 30, 1, '00:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:46:36', 0, 0, 0, 0),
(453, 80, 31, 1, '00:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:46:36', 0, 0, 0, 0),
(454, 80, 32, 1, '00:00:00', '00:00:00', 0, '2019-07-23', '2019-07-23 20:46:36', 0, 0, 0, 0),
(455, 87, 25, 1, '00:00:00', '00:00:00', 0, '2019-07-26', '2019-07-23 20:54:50', 0, 0, 0, 0),
(456, 87, 26, 1, '00:00:00', '00:00:00', 0, '2019-07-26', '2019-07-23 20:54:50', 0, 0, 0, 0),
(457, 87, 27, 1, '00:00:00', '00:00:00', 0, '2019-07-26', '2019-07-23 20:54:50', 0, 0, 0, 0),
(458, 87, 35, 1, '00:00:00', '00:00:00', 0, '2019-07-26', '2019-07-23 20:54:50', 0, 0, 0, 0),
(459, 88, 25, 1, '00:00:00', '00:00:00', 0, '2019-08-03', '2019-08-03 11:43:36', 0, 0, 0, 0),
(460, 88, 26, 1, '00:00:00', '00:00:00', 0, '2019-08-03', '2019-08-03 11:43:36', 0, 0, 0, 0),
(461, 88, 27, 1, '00:00:00', '00:00:00', 0, '2019-08-03', '2019-08-03 11:43:36', 0, 0, 0, 0),
(462, 88, 28, 1, '00:00:00', '00:00:00', 0, '2019-08-03', '2019-08-03 11:43:36', 0, 0, 0, 0),
(463, 88, 29, 1, '00:00:00', '00:00:00', 0, '2019-08-03', '2019-08-03 11:43:36', 0, 0, 0, 0),
(464, 89, 25, 1, '08:00:00', '10:00:00', 0, '2020-01-09', '2020-01-09 17:10:22', 1, 1, 0, 0),
(465, 89, 27, 1, '21:58:00', '22:00:00', 0, '2020-01-09', '2020-01-09 17:10:22', 1, 1, 0, 0),
(472, 92, 33, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:18:31', 0, 0, 0, 0),
(473, 92, 34, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:18:31', 0, 0, 0, 0),
(474, 92, 35, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:18:31', 0, 0, 0, 0),
(475, 92, 36, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:18:31', 0, 0, 0, 0),
(476, 93, 37, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:18:53', 0, 0, 0, 0),
(477, 93, 38, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:18:53', 0, 0, 0, 0),
(478, 93, 39, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:18:53', 0, 0, 0, 0),
(479, 94, 41, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:19:26', 0, 0, 0, 0),
(480, 94, 42, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:19:26', 0, 0, 0, 0),
(481, 94, 44, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:19:26', 0, 0, 0, 0),
(482, 94, 45, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:19:26', 0, 0, 0, 0),
(483, 94, 46, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:19:26', 0, 0, 0, 0),
(484, 95, 48, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:20:02', 0, 0, 0, 0),
(485, 95, 49, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:20:02', 0, 0, 0, 0),
(486, 95, 51, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:20:02', 0, 0, 0, 0),
(487, 95, 52, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:20:02', 0, 0, 0, 0),
(488, 95, 56, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:20:02', 0, 0, 0, 0),
(489, 95, 57, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:20:02', 0, 0, 0, 0),
(490, 95, 58, 2, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:20:02', 0, 0, 0, 0),
(491, 95, 59, 2, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:20:02', 0, 0, 0, 0),
(492, 95, 60, 2, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:20:02', 0, 0, 0, 0),
(493, 95, 62, 2, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:20:02', 0, 0, 0, 0),
(507, 98, 25, 1, '00:00:00', '00:00:00', 0, '2020-01-11', '2020-01-09 17:36:15', 0, 0, 1, 0),
(508, 98, 27, 1, '00:00:00', '00:00:00', 0, '2020-01-11', '2020-01-09 17:36:15', 0, 0, 1, 0),
(509, 98, 28, 1, '00:00:00', '00:00:00', 0, '2020-01-11', '2020-01-09 17:36:15', 0, 0, 1, 0),
(510, 98, 29, 1, '00:00:00', '00:00:00', 0, '2020-01-11', '2020-01-09 17:36:15', 0, 0, 0, 0),
(511, 98, 30, 1, '00:00:00', '00:00:00', 0, '2020-01-11', '2020-01-09 17:36:15', 0, 0, 0, 0),
(512, 99, 25, 1, '00:00:00', '00:00:00', 0, '2020-01-11', '2020-01-09 17:36:58', 0, 0, 0, 0),
(513, 99, 27, 1, '00:00:00', '00:00:00', 0, '2020-01-11', '2020-01-09 17:36:58', 0, 0, 0, 0),
(514, 99, 28, 1, '00:00:00', '00:00:00', 0, '2020-01-11', '2020-01-09 17:36:58', 0, 0, 0, 0),
(515, 97, 73, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:38:51', 0, 0, 1, 0),
(516, 97, 74, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:38:51', 0, 0, 1, 0),
(517, 97, 75, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:38:51', 0, 0, 1, 0),
(528, 100, 28, 1, '09:00:00', '10:00:00', 0, '2020-01-09', '2020-01-09 17:45:03', 1, 1, 0, 0),
(529, 100, 29, 1, '09:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 17:45:03', 1, 1, 0, 0),
(530, 100, 30, 1, '10:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 17:45:03', 1, 1, 0, 0),
(531, 100, 32, 1, '09:00:00', '00:00:00', 5, '2020-01-09', '2020-01-09 17:45:03', 1, 0, 0, 0),
(532, 100, 33, 1, '09:00:00', '00:00:00', 1, '2020-01-09', '2020-01-09 17:45:03', 1, 0, 0, 0),
(533, 91, 29, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:51:00', 0, 0, 0, 0),
(534, 91, 30, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:51:00', 0, 0, 0, 0),
(535, 91, 32, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:51:00', 0, 0, 0, 0),
(536, 91, 33, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 17:51:00', 0, 0, 0, 0),
(549, 96, 56, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 18:24:41', 0, 0, 0, 0),
(550, 96, 57, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 18:24:41', 0, 0, 0, 0),
(551, 90, 32, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 18:26:51', 0, 0, 0, 0),
(552, 90, 33, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 18:26:51', 0, 0, 0, 0),
(553, 90, 34, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 18:26:51', 0, 0, 0, 0),
(554, 90, 35, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 18:26:51', 0, 0, 0, 0),
(555, 90, 36, 1, '00:00:00', '00:00:00', 0, '2020-01-10', '2020-01-09 18:26:51', 0, 0, 0, 0),
(556, 101, 34, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:17', 0, 0, 0, 0),
(557, 101, 35, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:17', 0, 0, 0, 0),
(558, 101, 36, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:17', 0, 0, 0, 0),
(559, 101, 37, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:17', 0, 0, 0, 0),
(560, 101, 38, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:17', 0, 0, 0, 0),
(561, 102, 39, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:35', 0, 0, 0, 0),
(562, 102, 41, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:35', 0, 0, 0, 0),
(563, 102, 42, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:35', 0, 0, 0, 0),
(564, 102, 44, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:35', 0, 0, 0, 0),
(565, 102, 45, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:35', 0, 0, 0, 0),
(566, 103, 46, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:50', 0, 0, 0, 0),
(567, 103, 48, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:50', 0, 0, 0, 0),
(568, 103, 49, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:50', 0, 0, 0, 0),
(569, 103, 51, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:50', 0, 0, 0, 0),
(570, 103, 56, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 18:38:50', 0, 0, 0, 0),
(590, 106, 25, 1, '00:00:00', '00:00:00', 0, '2020-01-12', '2020-01-09 19:26:16', 0, 0, 1, 0),
(591, 106, 27, 1, '00:00:00', '00:00:00', 0, '2020-01-12', '2020-01-09 19:26:16', 0, 0, 1, 0),
(592, 106, 28, 1, '00:00:00', '00:00:00', 0, '2020-01-12', '2020-01-09 19:26:16', 0, 0, 0, 0),
(593, 107, 25, 1, '00:00:00', '00:00:00', 0, '2020-01-12', '2020-01-09 19:26:48', 0, 0, 0, 0),
(594, 107, 27, 1, '00:00:00', '00:00:00', 0, '2020-01-12', '2020-01-09 19:26:48', 0, 0, 0, 0),
(595, 107, 29, 1, '00:00:00', '00:00:00', 0, '2020-01-12', '2020-01-09 19:26:48', 0, 0, 0, 0),
(596, 107, 30, 1, '00:00:00', '00:00:00', 0, '2020-01-12', '2020-01-09 19:26:48', 0, 0, 0, 0),
(597, 107, 32, 1, '00:00:00', '00:00:00', 0, '2020-01-12', '2020-01-09 19:26:48', 0, 0, 0, 0),
(598, 105, 63, 2, '20:29:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:14', 1, 0, 1, 0),
(599, 105, 64, 2, '20:29:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:14', 1, 0, 1, 0),
(600, 105, 68, 1, '20:29:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:14', 1, 0, 1, 0),
(601, 105, 71, 1, '20:29:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:14', 1, 0, 0, 0),
(602, 105, 72, 1, '20:29:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:14', 1, 0, 0, 0),
(603, 105, 73, 1, '20:29:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:14', 1, 0, 0, 0),
(604, 105, 74, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:14', 0, 0, 0, 0),
(605, 105, 75, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:14', 0, 0, 0, 0),
(606, 104, 52, 1, '20:27:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 1, 0, 0, 0),
(607, 104, 57, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 0, 0, 0, 0),
(608, 104, 58, 2, '20:27:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 1, 0, 0, 0),
(609, 104, 59, 2, '20:27:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 1, 0, 0, 0),
(610, 104, 60, 2, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 0, 0, 0, 0),
(611, 104, 62, 2, '20:27:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 1, 0, 0, 0),
(612, 104, 63, 2, '20:27:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 1, 0, 0, 0),
(613, 104, 64, 2, '20:27:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 1, 0, 0, 0),
(614, 104, 65, 2, '20:27:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 1, 0, 0, 0),
(615, 104, 66, 2, '20:27:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 1, 0, 0, 0),
(616, 104, 67, 2, '20:27:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 1, 0, 0, 0),
(617, 104, 68, 1, '20:27:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 1, 0, 0, 0),
(618, 104, 69, 1, '20:27:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 1, 0, 0, 0),
(619, 104, 70, 1, '00:00:00', '00:00:00', 0, '2020-01-09', '2020-01-09 19:28:48', 0, 0, 0, 0),
(630, 109, 27, 1, '00:00:00', '00:00:00', 0, '2020-04-22', '2020-04-20 18:53:28', 0, 0, 0, 0),
(631, 109, 28, 1, '00:00:00', '00:00:00', 0, '2020-04-22', '2020-04-20 18:53:28', 0, 0, 0, 0),
(632, 109, 29, 1, '00:00:00', '00:00:00', 0, '2020-04-22', '2020-04-20 18:53:28', 0, 0, 1, 0),
(633, 109, 30, 1, '00:00:00', '00:00:00', 0, '2020-04-22', '2020-04-20 18:53:28', 0, 0, 1, 0),
(634, 109, 32, 1, '00:00:00', '00:00:00', 0, '2020-04-22', '2020-04-20 18:53:28', 0, 0, 1, 0),
(646, 111, 25, 1, '09:15:00', '10:15:00', 0, '2020-04-21', '2020-04-21 12:07:26', 1, 1, 0, 0),
(647, 111, 27, 1, '08:15:00', '10:15:00', 0, '2020-04-21', '2020-04-21 12:07:26', 1, 1, 0, 0),
(648, 111, 28, 1, '09:15:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:07:26', 1, 0, 0, 0),
(649, 111, 29, 1, '09:15:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:07:26', 1, 0, 0, 0),
(650, 111, 30, 1, '09:15:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:07:26', 1, 0, 0, 0),
(656, 108, 25, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:40', 0, 0, 1, 0),
(657, 108, 27, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:40', 0, 0, 1, 0),
(658, 108, 28, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:40', 0, 0, 1, 0),
(659, 108, 29, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:40', 0, 0, 1, 0),
(660, 108, 30, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:40', 0, 0, 1, 0),
(661, 110, 25, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:54', 0, 0, 0, 0),
(662, 110, 27, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:54', 0, 0, 0, 0),
(663, 110, 28, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:54', 0, 0, 0, 0),
(664, 110, 29, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:54', 0, 0, 0, 0),
(665, 110, 30, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:54', 0, 0, 0, 0),
(666, 110, 32, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:54', 0, 0, 0, 0),
(667, 110, 33, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:54', 0, 0, 0, 0),
(668, 110, 34, 1, '00:00:00', '00:00:00', 0, '2020-04-21', '2020-04-21 12:44:54', 0, 0, 0, 0),
(673, 113, 30, 1, '23:18:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:10:56', 1, 1, 0, 0),
(674, 113, 32, 1, '23:18:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:10:56', 1, 1, 0, 0),
(675, 113, 33, 1, '23:18:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:10:56', 1, 1, 0, 0),
(676, 113, 34, 1, '00:00:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:10:56', 0, 0, 0, 0),
(677, 112, 25, 1, '12:09:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:11:26', 1, 0, 1, 0),
(678, 112, 27, 1, '12:09:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:11:26', 1, 0, 1, 0),
(679, 112, 28, 1, '12:10:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:11:26', 1, 0, 1, 0),
(680, 112, 29, 1, '00:00:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:11:26', 0, 0, 1, 0),
(681, 114, 25, 1, '00:00:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:11:48', 0, 0, 0, 0),
(682, 114, 27, 1, '00:00:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:11:48', 0, 0, 0, 0),
(683, 114, 28, 1, '00:00:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:11:48', 0, 0, 0, 0),
(684, 114, 29, 1, '00:00:00', '00:00:00', 0, '2020-04-23', '2020-04-23 12:11:48', 0, 0, 0, 0),
(691, 116, 25, 1, '12:17:00', '00:00:00', 0, '2020-04-25', '2020-04-25 12:15:46', 1, 0, 0, 0),
(692, 116, 27, 1, '00:00:00', '00:00:00', 0, '2020-04-25', '2020-04-25 12:15:46', 0, 0, 0, 0),
(693, 115, 25, 1, '00:00:00', '00:00:00', 0, '2020-04-25', '2020-04-25 12:32:36', 0, 0, 1, 0),
(694, 115, 27, 1, '00:00:00', '00:00:00', 0, '2020-04-25', '2020-04-25 12:32:36', 0, 0, 1, 0),
(710, 117, 25, 1, '00:00:00', '00:00:00', 0, '2020-05-02', '2020-05-02 17:41:55', 0, 0, 0, 0),
(711, 117, 27, 1, '00:00:00', '00:00:00', 0, '2020-05-02', '2020-05-02 17:41:55', 0, 0, 0, 0),
(712, 117, 28, 1, '00:00:00', '00:00:00', 0, '2020-05-02', '2020-05-02 17:41:55', 0, 0, 0, 0),
(713, 117, 41, 1, '00:00:00', '00:00:00', 0, '2020-05-02', '2020-05-02 17:41:55', 0, 0, 0, 0),
(714, 117, 51, 1, '00:00:00', '00:00:00', 0, '2020-05-02', '2020-05-02 17:41:55', 0, 0, 0, 0),
(721, 118, 29, 1, '00:00:00', '00:00:00', 0, '2020-05-02', '2020-05-02 18:24:21', 0, 0, 0, 0),
(722, 118, 30, 1, '00:00:00', '00:00:00', 0, '2020-05-02', '2020-05-02 18:24:21', 0, 0, 0, 0),
(723, 118, 32, 1, '00:00:00', '00:00:00', 0, '2020-05-02', '2020-05-02 18:24:21', 0, 0, 0, 0),
(724, 118, 33, 1, '00:00:00', '00:00:00', 0, '2020-05-02', '2020-05-02 18:24:21', 0, 0, 0, 0),
(725, 118, 49, 1, '00:00:00', '00:00:00', 0, '2020-05-02', '2020-05-02 18:24:21', 0, 0, 0, 0),
(726, 118, 51, 1, '00:00:00', '00:00:00', 0, '2020-05-02', '2020-05-02 18:24:21', 0, 0, 0, 0),
(733, 119, 25, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:01', 0, 0, 0, 0),
(734, 119, 27, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:01', 0, 0, 0, 0),
(735, 119, 28, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:01', 0, 0, 0, 0),
(736, 119, 29, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:01', 0, 0, 0, 0),
(737, 119, 49, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:01', 0, 0, 0, 0),
(738, 119, 51, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:01', 0, 0, 0, 0),
(739, 120, 41, 0, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 1),
(740, 120, 47, 0, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 1),
(741, 120, 30, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 0),
(742, 120, 32, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 0),
(743, 120, 33, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 0),
(744, 120, 34, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 0),
(745, 120, 35, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 0),
(746, 120, 36, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 0),
(747, 120, 37, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 0),
(748, 120, 38, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 0),
(749, 120, 39, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 0),
(750, 120, 41, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 0),
(751, 120, 42, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:06:36', 0, 0, 0, 0),
(752, 121, 48, 0, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 1),
(753, 121, 43, 0, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 1),
(754, 121, 44, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 0);
INSERT INTO `p_workattendance` (`id`, `workArrangementId`, `workerId`, `workerTeam`, `inTime`, `outTime`, `reason`, `forDate`, `createdOn`, `status`, `statusOut`, `partial`, `isSupervisor`) VALUES
(755, 121, 45, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 0),
(756, 121, 46, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 0),
(757, 121, 48, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 0),
(758, 121, 52, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 0),
(759, 121, 56, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 0),
(760, 121, 57, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 0),
(761, 121, 58, 2, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 0),
(762, 121, 59, 2, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 0),
(763, 121, 60, 2, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:07:28', 0, 0, 0, 0),
(812, 122, 44, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(813, 122, 45, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(814, 122, 48, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(815, 122, 62, 2, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(816, 122, 63, 2, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(817, 122, 64, 2, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(818, 122, 65, 2, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(819, 122, 66, 2, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(820, 122, 67, 2, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(821, 122, 68, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(822, 122, 69, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(823, 122, 70, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(824, 122, 71, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(825, 122, 72, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(826, 122, 73, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(827, 122, 74, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(828, 122, 75, 1, '00:00:00', '00:00:00', 0, '2020-05-03', '2020-05-03 09:10:37', 0, 0, 0, 0),
(829, 123, 44, 0, '13:24:00', '00:00:00', 0, '2020-05-07', '2020-05-07 13:26:30', 1, 0, 0, 1),
(830, 123, 48, 0, '13:24:00', '00:00:00', 0, '2020-05-07', '2020-05-07 13:26:30', 1, 0, 0, 1),
(831, 123, 25, 1, '13:24:00', '00:00:00', 0, '2020-05-07', '2020-05-07 13:26:30', 1, 0, 0, 0),
(832, 123, 27, 1, '13:24:00', '00:00:00', 0, '2020-05-07', '2020-05-07 13:26:30', 1, 0, 0, 0),
(833, 123, 28, 1, '13:24:00', '00:00:00', 0, '2020-05-07', '2020-05-07 13:26:30', 1, 0, 0, 0),
(834, 123, 29, 1, '13:24:00', '00:00:00', 0, '2020-05-07', '2020-05-07 13:26:30', 1, 0, 0, 0),
(835, 123, 30, 1, '13:24:00', '00:00:00', 0, '2020-05-07', '2020-05-07 13:26:30', 1, 0, 0, 0),
(836, 123, 32, 1, '13:24:00', '00:00:00', 0, '2020-05-07', '2020-05-07 13:26:30', 1, 0, 0, 0),
(837, 123, 33, 1, '13:24:00', '00:00:00', 0, '2020-05-07', '2020-05-07 13:26:30', 1, 0, 0, 0),
(838, 123, 34, 1, '13:24:00', '00:00:00', 0, '2020-05-07', '2020-05-07 13:26:30', 1, 0, 0, 0),
(934, 127, 45, 0, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:15', 0, 0, 0, 1),
(935, 127, 68, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:15', 0, 0, 0, 0),
(936, 127, 69, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:15', 0, 0, 0, 0),
(937, 127, 70, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:15', 0, 0, 0, 0),
(938, 125, 51, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 1, 0),
(939, 125, 52, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 1, 0),
(940, 125, 56, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 1, 0),
(941, 125, 57, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 1, 0),
(942, 125, 58, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 1, 0),
(943, 125, 59, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 1, 0),
(944, 125, 60, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 0, 0),
(945, 125, 62, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 0, 0),
(946, 125, 63, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 0, 0),
(947, 125, 64, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 0, 0),
(948, 125, 65, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 0, 0),
(949, 125, 66, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 0, 0),
(950, 125, 67, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:55:49', 0, 0, 0, 0),
(951, 126, 51, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:07', 0, 0, 1, 0),
(952, 126, 52, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:07', 0, 0, 1, 0),
(953, 126, 56, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:07', 0, 0, 1, 0),
(954, 126, 57, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:07', 0, 0, 1, 0),
(955, 126, 58, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:07', 0, 0, 1, 0),
(956, 126, 59, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:07', 0, 0, 1, 0),
(957, 126, 71, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:07', 0, 0, 0, 0),
(958, 126, 72, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:07', 0, 0, 0, 0),
(959, 126, 73, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:07', 0, 0, 0, 0),
(960, 126, 74, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:07', 0, 0, 0, 0),
(961, 126, 75, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:07', 0, 0, 0, 0),
(962, 124, 35, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(963, 124, 36, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(964, 124, 37, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(965, 124, 38, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(966, 124, 39, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(967, 124, 41, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(968, 124, 42, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(969, 124, 46, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(970, 124, 49, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(971, 124, 51, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(972, 124, 52, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(973, 124, 56, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(974, 124, 57, 1, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(975, 124, 58, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(976, 124, 59, 2, '00:00:00', '00:00:00', 0, '2020-05-07', '2020-05-07 14:57:57', 0, 0, 0, 0),
(977, 128, 44, 0, '00:00:00', '00:00:00', 0, '2020-05-25', '2020-05-23 13:13:00', 0, 0, 0, 1),
(978, 128, 49, 0, '00:00:00', '00:00:00', 0, '2020-05-25', '2020-05-23 13:13:00', 0, 0, 0, 1),
(979, 128, 25, 1, '00:00:00', '00:00:00', 0, '2020-05-25', '2020-05-23 13:13:00', 0, 0, 0, 0),
(980, 128, 27, 1, '00:00:00', '00:00:00', 0, '2020-05-25', '2020-05-23 13:13:00', 0, 0, 0, 0),
(981, 128, 28, 1, '00:00:00', '00:00:00', 0, '2020-05-25', '2020-05-23 13:13:00', 0, 0, 0, 0),
(982, 129, 51, 0, '00:00:00', '00:00:00', 0, '2020-06-03', '2020-05-30 11:46:05', 0, 0, 0, 1),
(983, 129, 49, 0, '00:00:00', '00:00:00', 0, '2020-06-03', '2020-05-30 11:46:05', 0, 0, 0, 1),
(984, 129, 27, 1, '00:00:00', '00:00:00', 0, '2020-06-03', '2020-05-30 11:46:05', 0, 0, 0, 0),
(985, 129, 28, 1, '00:00:00', '00:00:00', 0, '2020-06-03', '2020-05-30 11:46:05', 0, 0, 1, 0),
(986, 129, 29, 1, '00:00:00', '00:00:00', 0, '2020-06-03', '2020-05-30 11:46:05', 0, 0, 0, 0),
(987, 130, 57, 0, '08:00:00', '00:00:00', 99, '2020-05-30', '2020-05-30 11:53:15', 1, 0, 0, 1),
(988, 130, 56, 0, '09:00:00', '00:00:00', 5, '2020-05-30', '2020-05-30 11:53:15', 1, 0, 0, 1),
(989, 130, 28, 1, '08:56:00', '00:00:00', 99, '2020-05-30', '2020-05-30 11:53:15', 1, 0, 0, 0),
(990, 130, 29, 1, '08:00:00', '00:00:00', 99, '2020-05-30', '2020-05-30 11:53:15', 1, 0, 1, 0),
(991, 130, 30, 1, '10:56:00', '00:00:00', 0, '2020-05-30', '2020-05-30 11:53:15', 1, 0, 0, 0),
(992, 131, 47, 0, '00:00:00', '00:00:00', 0, '2020-05-30', '2020-05-30 12:24:17', 0, 0, 0, 1),
(993, 131, 51, 0, '00:00:00', '00:00:00', 0, '2020-05-30', '2020-05-30 12:24:17', 0, 0, 0, 1),
(994, 131, 29, 1, '00:00:00', '00:00:00', 0, '2020-05-30', '2020-05-30 12:24:17', 0, 0, 0, 0),
(995, 131, 32, 1, '00:00:00', '00:00:00', 0, '2020-05-30', '2020-05-30 12:24:17', 0, 0, 0, 0),
(996, 131, 33, 1, '00:00:00', '00:00:00', 0, '2020-05-30', '2020-05-30 12:24:17', 0, 0, 0, 0),
(997, 132, 44, 0, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:42:51', 0, 0, 0, 1),
(998, 132, 49, 0, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:42:51', 0, 0, 0, 1),
(999, 132, 25, 1, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:42:51', 0, 0, 1, 0),
(1000, 132, 27, 1, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:42:51', 0, 0, 1, 0),
(1001, 132, 28, 1, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:42:51', 0, 0, 0, 0),
(1002, 132, 29, 1, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:42:51', 0, 0, 0, 0),
(1003, 133, 41, 0, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:44:53', 0, 0, 0, 1),
(1004, 133, 47, 0, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:44:53', 0, 0, 0, 1),
(1005, 133, 25, 1, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:44:53', 0, 0, 0, 0),
(1006, 133, 27, 1, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:44:53', 0, 0, 0, 0),
(1007, 133, 28, 1, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:44:53', 0, 0, 0, 0),
(1008, 133, 29, 1, '00:00:00', '00:00:00', 0, '2020-06-05', '2020-06-04 22:44:53', 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `p_workers`
--

CREATE TABLE `p_workers` (
  `workerId` int(11) NOT NULL,
  `workerName` varchar(100) NOT NULL,
  `teamId` int(11) NOT NULL,
  `createdOn` datetime NOT NULL,
  `createdBy` int(11) NOT NULL,
  `modifiedOn` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
  `status` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_workers`
--

INSERT INTO `p_workers` (`workerId`, `workerName`, `teamId`, `createdOn`, `createdBy`, `modifiedOn`, `status`) VALUES
(25, 'Sivanasan', 1, '2019-07-17 21:46:32', 2, '2019-07-17 13:46:32', 1),
(27, 'Muthukumaran', 1, '2019-07-17 21:46:46', 2, '2019-07-17 13:46:46', 1),
(28, 'Ramachandran', 1, '2019-07-17 21:46:52', 2, '2019-07-17 13:46:52', 1),
(29, 'Rafikul', 1, '2019-07-17 21:46:59', 2, '2019-07-17 13:46:59', 1),
(30, 'Monir', 1, '2019-07-17 21:47:06', 2, '2019-07-17 13:47:06', 1),
(32, 'Kalam', 1, '2019-07-17 21:47:21', 2, '2019-07-17 13:47:21', 1),
(33, 'U.Murugesan', 1, '2019-07-17 21:47:29', 2, '2019-07-17 13:47:29', 1),
(34, 'Jeganathan', 1, '2019-07-17 21:47:38', 2, '2019-07-17 13:47:38', 1),
(35, 'Vijithkumar', 1, '2019-07-17 21:47:45', 2, '2019-07-17 13:47:45', 1),
(36, 'M.Murugan', 1, '2019-07-17 21:47:55', 2, '2019-07-17 13:47:55', 1),
(37, 'Muthusamy', 1, '2019-07-17 21:48:02', 2, '2019-07-17 13:48:02', 1),
(38, 'Mahendran', 1, '2019-07-17 21:48:08', 2, '2019-07-17 13:48:08', 1),
(39, 'M.Saravanan', 1, '2019-07-17 21:48:16', 2, '2019-07-17 13:48:16', 1),
(41, 'Palkannu', 1, '2019-07-17 21:48:32', 2, '2019-07-17 13:48:32', 1),
(42, 'Senthilraja', 1, '2019-07-17 21:48:38', 2, '2019-07-17 13:48:38', 1),
(44, 'Ganesan', 1, '2019-07-17 21:48:49', 2, '2019-07-17 13:48:49', 1),
(45, 'Selvam', 1, '2019-07-17 21:48:54', 2, '2019-07-17 13:48:54', 1),
(46, 'Nagarajan', 1, '2019-07-17 21:49:00', 2, '2019-07-17 13:49:00', 1),
(48, 'S.Ranjith Kumar', 1, '2019-07-17 21:49:14', 2, '2019-07-17 13:49:14', 1),
(49, 'Showkat', 1, '2019-07-17 21:49:22', 2, '2019-07-17 13:49:22', 1),
(51, 'Pandian', 1, '2019-07-17 21:49:40', 2, '2019-07-17 13:49:40', 1),
(52, 'K.Sundaram', 1, '2019-07-17 21:49:57', 2, '2019-07-17 13:49:57', 1),
(56, 'Kamrul', 1, '2019-07-17 21:50:22', 2, '2019-07-17 13:50:22', 1),
(57, 'Babu', 1, '2019-07-17 21:50:36', 2, '2019-07-17 13:50:36', 1),
(58, 'Visuvakumar', 2, '2019-07-17 21:50:48', 2, '2019-07-17 13:50:48', 1),
(59, 'Habibur', 2, '2019-07-17 21:50:56', 2, '2019-07-17 13:50:56', 1),
(60, 'Roni', 2, '2019-07-17 21:51:05', 2, '2019-07-17 13:51:05', 1),
(62, 'S.Saravanan', 2, '2019-07-17 21:51:19', 2, '2019-07-17 13:51:19', 1),
(63, 'Vellaisamy', 2, '2019-07-17 21:51:29', 2, '2019-11-15 05:05:43', 1),
(64, 'Sagar', 2, '2019-07-17 21:51:35', 2, '2019-11-15 05:05:53', 1),
(65, 'K.Ramesh', 2, '2019-07-17 21:51:43', 2, '2019-11-15 05:06:00', 1),
(66, 'Ranganathan', 2, '2019-07-17 21:51:50', 2, '2019-11-15 05:06:07', 1),
(67, 'Palanisamy', 2, '2019-07-17 21:51:57', 2, '2019-11-15 05:06:14', 1),
(68, 'R.Murugan', 1, '2019-11-15 13:03:51', 40, '2019-11-15 05:03:51', 1),
(69, 'Elango', 1, '2019-11-15 13:07:00', 40, '2019-11-15 05:07:00', 1),
(70, 'Kathick', 1, '2019-11-15 13:07:16', 40, '2019-11-15 05:07:16', 1),
(71, 'Asaduz', 1, '2019-11-15 13:07:27', 40, '2019-11-15 05:07:27', 1),
(72, 'Vimal', 1, '2019-11-15 13:07:37', 40, '2019-11-15 05:07:37', 1),
(73, 'Elumalai', 1, '2019-11-15 13:08:20', 40, '2019-11-15 05:08:20', 1),
(74, 'Palanikumar', 1, '2019-11-15 13:08:33', 40, '2019-11-15 05:08:33', 1),
(75, 'Raihan', 1, '2019-11-15 13:08:42', 40, '2019-11-15 05:08:42', 1);

-- --------------------------------------------------------

--
-- Table structure for table `p_workerteam`
--

CREATE TABLE `p_workerteam` (
  `teamid` int(11) NOT NULL,
  `teamName` varchar(100) NOT NULL,
  `createdOn` datetime NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_workerteam`
--

INSERT INTO `p_workerteam` (`teamid`, `teamName`, `createdOn`, `status`) VALUES
(1, 'CW', '2019-04-23 00:00:00', 1),
(2, 'Team#1', '2019-04-23 00:00:00', 1),
(3, 'Team#2', '2019-04-23 00:00:00', 1),
(4, 'Supply Worker', '2019-04-23 00:00:00', 1),
(12, 'Team#3', '2019-07-17 21:00:14', 1),
(13, 'Team#4', '2019-07-17 21:00:21', 1);

-- --------------------------------------------------------

--
-- Table structure for table `p_workrequest`
--

CREATE TABLE `p_workrequest` (
  `workRequestId` int(11) NOT NULL,
  `projectId` int(11) NOT NULL,
  `clientId` int(11) NOT NULL,
  `requestedBy` varchar(100) NOT NULL,
  `contractType` tinyint(1) NOT NULL,
  `remarks` text NOT NULL,
  `description` text NOT NULL,
  `createdOn` datetime NOT NULL,
  `createdBy` int(11) NOT NULL,
  `scaffoldRegister` tinyint(1) NOT NULL,
  `status` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_workrequest`
--

INSERT INTO `p_workrequest` (`workRequestId`, `projectId`, `clientId`, `requestedBy`, `contractType`, `remarks`, `description`, `createdOn`, `createdBy`, `scaffoldRegister`, `status`) VALUES
(11, 3, 3, 'Mr.Tan', 1, 'test', '', '2019-07-12 23:14:33', 2, 1, 1),
(12, 19, 1, 'user1', 1, 'test', '', '2019-07-12 23:17:02', 2, 1, 1),
(13, 3, 3, 'Ganesh', 1, 'WR Submitted', '', '2019-07-13 12:34:52', 2, 1, 2),
(14, 3, 1, 'ssd', 2, '', '', '2019-07-14 12:57:19', 2, 0, 1),
(15, 24, 7, 'Manager', 1, '1a - full size and 2b - partial size', 'Desc', '2019-07-21 19:35:36', 2, 1, 2),
(16, 24, 7, 'Asst. Manager', 1, 'Remarks - 1a full size\n2b - partial size', 'Desc', '2019-07-21 22:27:49', 2, 1, 1),
(17, 30, 10, 'SMRT Manager', 1, 'Test Remarks', '50x50x50', '2019-08-17 11:06:37', 2, 1, 1),
(18, 24, 7, 'Ng', 1, '', '', '2020-01-11 15:29:02', 44, 1, 2),
(19, 24, 7, 'NG', 1, '', '', '2020-01-11 15:33:28', 44, 1, 1),
(20, 24, 7, 'NG', 1, '', '', '2020-01-11 15:34:36', 44, 1, 1),
(21, 26, 19, 'Kenny', 1, '', '', '2020-01-11 15:36:09', 44, 1, 1),
(22, 24, 7, 'Bernold', 2, '', '', '2020-01-11 15:37:44', 40, 1, 1),
(23, 24, 8, 'kok', 2, '', 'Steel works', '2020-01-11 15:40:27', 44, 1, 1),
(24, 24, 8, 'Nino', 2, '', 'Glass replace', '2020-01-27 13:01:19', 40, 1, 1),
(25, 26, 8, 'kok', 2, '', 'Plaster', '2020-01-27 13:02:52', 40, 1, 1),
(26, 24, 7, 'Ng', 2, '', '', '2020-01-27 13:21:11', 40, 1, 1),
(27, 24, 7, 'Nino', 1, 'none', 'Plastering works', '2020-04-21 16:34:34', 44, 1, 2),
(28, 26, 19, 'Kok', 1, '-', 'Genset installation', '2020-04-21 17:09:15', 44, 1, 1),
(29, 26, 19, 'kenny', 2, '', 'plastering', '2020-04-21 17:12:29', 44, 1, 2),
(30, 24, 7, 'Nino', 1, '', 'ceiling works', '2020-04-21 17:15:10', 44, 0, 1),
(31, 24, 7, 'nino', 1, '', 'ceiling works', '2020-04-21 17:16:25', 44, 1, 1),
(32, 24, 7, 'nino', 2, '', '', '2020-04-21 17:24:24', 44, 1, 1),
(33, 24, 7, 'nino', 2, '', 'Ceiling works', '2020-04-21 17:27:06', 44, 0, 1),
(34, 24, 8, 'Ng', 2, '', 'Plastering', '2020-04-21 17:29:57', 44, 0, 1),
(35, 26, 8, 'kok', 2, 'Modification', 'Modification', '2020-04-21 17:33:48', 44, 0, 1),
(36, 24, 7, 'ng', 2, '', '', '2020-04-21 17:41:19', 44, 0, 1),
(37, 24, 7, 'NG', 2, '', 'Painting works', '2020-04-21 17:49:52', 47, 1, 1),
(38, 24, 7, 'Ng', 1, '', '', '2020-04-23 12:32:24', 49, 0, 1),
(39, 24, 7, 'Ng', 1, '', '', '2020-04-23 12:33:19', 49, 0, 1),
(40, 24, 7, 'Ng', 1, '', '', '2020-04-23 12:34:53', 49, 0, 1),
(41, 24, 7, 'ng', 2, '', '', '2020-04-23 12:40:01', 49, 0, 2),
(42, 24, 7, 'Ng', 2, '', '', '2020-04-23 12:40:42', 49, 0, 2),
(43, 24, 7, 'ng', 2, '', '', '2020-04-25 13:32:22', 49, 0, 2),
(44, 24, 7, 'Ng', 2, '', 'Plastering', '2020-04-25 13:42:50', 49, 0, 1),
(45, 24, 7, 'test', 1, '', '', '2020-05-10 22:13:47', 2, 0, 1),
(46, 24, 7, 'test', 1, '', '', '2020-05-10 22:21:56', 2, 0, 1),
(47, 24, 7, 'Nino', 2, '', 'plastering works', '2020-05-23 13:23:10', 44, 1, 1),
(48, 24, 7, 'ng', 2, '', 'plastering', '2020-05-23 13:25:03', 44, 1, 1),
(49, 24, 7, 'ng', 2, '', 'plastering', '2020-05-23 13:31:55', 40, 1, 1),
(50, 24, 7, 'ng', 2, '', 'Plastering', '2020-05-23 13:32:53', 44, 1, 1),
(51, 24, 7, 'ng', 2, '', '', '2020-05-23 14:25:53', 44, 1, 1),
(52, 24, 7, 'tesr', 2, '', '', '2020-05-23 15:20:51', 2, 0, 1),
(53, 24, 7, 'test request', 2, '', '', '2020-05-30 18:00:42', 2, 0, 1),
(54, 25, 7, 'Ng', 2, '', '', '2020-05-30 16:34:37', 44, 1, 1),
(55, 27, 7, 'nino', 2, '', 'Plastering', '2020-05-30 16:37:21', 44, 0, 1),
(56, 27, 7, 'ng', 2, '', 'Plastering', '2020-05-30 16:39:33', 44, 1, 1),
(57, 27, 7, 'ng', 2, '', 'plastering', '2020-05-30 16:41:09', 40, 1, 1),
(58, 24, 7, 'ng', 2, '', '', '2020-05-30 16:53:28', 44, 1, 1),
(59, 27, 7, 'nino', 2, '', '', '2020-05-30 16:55:36', 44, 0, 1),
(60, 24, 7, 'Ng', 1, '', 'Plastering', '2020-05-31 16:08:02', 44, 1, 1),
(61, 24, 7, 'ng', 2, '', 'Plastering', '2020-05-31 16:20:26', 44, 1, 1),
(62, 24, 7, 'nino', 2, '', 'Modification', '2020-05-31 16:21:53', 44, 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `p_workrequestitems`
--

CREATE TABLE `p_workrequestitems` (
  `id` int(11) NOT NULL,
  `workRequestId` int(11) NOT NULL,
  `contractType` tinyint(2) NOT NULL,
  `itemId` int(11) NOT NULL,
  `sizeType` tinyint(2) NOT NULL,
  `workBased` tinyint(2) NOT NULL,
  `previousWR` int(11) NOT NULL,
  `createdOn` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_workrequestitems`
--

INSERT INTO `p_workrequestitems` (`id`, `workRequestId`, `contractType`, `itemId`, `sizeType`, `workBased`, `previousWR`, `createdOn`) VALUES
(1, 1, 1, 1, 1, 1, 0, '2019-06-01 10:35:21'),
(2, 2, 1, 2, 1, 1, 0, '2019-06-01 11:04:58'),
(3, 3, 1, 1, 1, 1, 0, '2019-06-01 11:18:40'),
(4, 3, 1, 2, 1, 1, 0, '2019-06-01 11:18:40'),
(5, 3, 1, 0, 0, 0, 0, '2019-06-01 11:18:40'),
(6, 4, 1, 1, 1, 1, 0, '2019-06-01 12:39:06'),
(7, 5, 2, 0, 0, 1, 0, '2019-06-10 11:27:08'),
(8, 6, 1, 1, 1, 1, 0, '2019-06-22 00:10:06'),
(9, 7, 1, 1, 1, 1, 0, '2019-06-22 00:13:23'),
(10, 8, 1, 1, 1, 1, 0, '2019-06-22 00:30:57'),
(11, 9, 1, 0, 0, 0, 0, '2019-06-25 23:48:30'),
(12, 9, 1, 2, 1, 2, 0, '2019-06-25 23:48:30'),
(13, 10, 1, 1, 1, 1, 0, '2019-06-29 11:29:13'),
(14, 10, 1, 2, 1, 1, 0, '2019-06-29 11:29:13'),
(15, 11, 1, 11, 1, 1, 0, '2019-07-12 23:14:33'),
(16, 11, 1, 12, 2, 1, 0, '2019-07-12 23:14:33'),
(17, 12, 1, 9, 1, 1, 0, '2019-07-12 23:17:02'),
(18, 12, 1, 10, 1, 2, 0, '2019-07-12 23:17:02'),
(19, 13, 1, 11, 1, 1, 0, '2019-07-13 12:34:52'),
(20, 13, 1, 12, 2, 1, 0, '2019-07-13 12:34:52'),
(21, 14, 2, 0, 0, 1, 0, '2019-07-14 12:57:19'),
(22, 15, 1, 16, 1, 1, 0, '2019-07-21 19:35:36'),
(23, 15, 1, 18, 2, 1, 0, '2019-07-21 19:35:36'),
(24, 16, 1, 16, 1, 1, 0, '2019-07-21 22:27:49'),
(25, 16, 1, 18, 2, 2, 0, '2019-07-21 22:27:49'),
(26, 17, 1, 19, 2, 1, 0, '2019-08-17 11:06:37'),
(27, 18, 1, 1, 2, 1, 0, '2020-01-11 15:29:02'),
(28, 19, 1, 2, 1, 1, 0, '2020-01-11 15:33:28'),
(29, 20, 1, 3, 2, 1, 0, '2020-01-11 15:34:36'),
(30, 21, 1, 4, 1, 1, 0, '2020-01-11 15:36:09'),
(31, 22, 2, 0, 0, 1, 0, '2020-01-11 15:37:44'),
(32, 23, 2, 0, 0, 1, 0, '2020-01-11 15:40:27'),
(33, 24, 2, 0, 0, 1, 0, '2020-01-27 13:01:19'),
(34, 25, 2, 0, 0, 1, 0, '2020-01-27 13:02:52'),
(35, 26, 2, 0, 0, 1, 0, '2020-01-27 13:21:11'),
(36, 27, 1, 1, 2, 1, 0, '2020-04-21 16:34:34'),
(37, 28, 1, 4, 1, 1, 0, '2020-04-21 17:09:15'),
(38, 29, 2, 0, 0, 1, 0, '2020-04-21 17:12:29'),
(39, 30, 1, 2, 2, 1, 0, '2020-04-21 17:15:10'),
(40, 31, 1, 2, 2, 1, 0, '2020-04-21 17:16:25'),
(41, 32, 2, 0, 0, 1, 0, '2020-04-21 17:24:24'),
(42, 33, 2, 0, 0, 1, 0, '2020-04-21 17:27:06'),
(43, 34, 2, 0, 0, 1, 0, '2020-04-21 17:29:57'),
(44, 35, 2, 0, 0, 2, 0, '2020-04-21 17:33:48'),
(45, 36, 2, 0, 0, 2, 0, '2020-04-21 17:41:19'),
(46, 37, 2, 0, 0, 1, 0, '2020-04-21 17:49:52'),
(47, 38, 1, 2, 2, 1, 0, '2020-04-23 12:32:24'),
(48, 39, 1, 2, 2, 1, 0, '2020-04-23 12:33:19'),
(49, 40, 1, 2, 1, 1, 0, '2020-04-23 12:34:53'),
(50, 41, 2, 0, 0, 1, 0, '2020-04-23 12:40:01'),
(51, 42, 2, 0, 0, 1, 0, '2020-04-23 12:40:42'),
(52, 43, 2, 0, 1, 1, 0, '2020-04-25 13:32:22'),
(53, 44, 2, 0, 0, 1, 0, '2020-04-25 13:42:50'),
(55, 46, 1, 2, 1, 1, 0, '2020-05-10 22:21:56'),
(56, 46, 1, 3, 1, 2, 0, '2020-05-10 22:21:56'),
(58, 47, 2, 0, 0, 1, 0, '2020-05-23 13:23:10'),
(59, 48, 2, 0, 0, 1, 0, '2020-05-23 13:25:03'),
(60, 49, 2, 0, 0, 1, 0, '2020-05-23 13:31:55'),
(61, 50, 2, 0, 0, 1, 0, '2020-05-23 13:32:53'),
(62, 51, 2, 0, 0, 1, 0, '2020-05-23 14:25:53'),
(63, 52, 2, 0, 0, 1, 0, '2020-05-23 15:20:51'),
(67, 54, 2, 0, 0, 1, 0, '2020-05-30 16:34:37'),
(69, 55, 2, 0, 0, 1, 0, '2020-05-30 16:37:21'),
(70, 56, 2, 0, 0, 1, 0, '2020-05-30 16:39:33'),
(71, 57, 2, 0, 0, 1, 0, '2020-05-30 16:41:09'),
(72, 58, 2, 0, 0, 1, 0, '2020-05-30 16:53:28'),
(73, 59, 2, 0, 0, 2, 0, '2020-05-30 16:55:36'),
(74, 53, 2, 0, 0, 1, 0, '2020-05-30 18:00:42'),
(75, 60, 1, 1, 2, 1, 0, '2020-05-31 16:08:02'),
(76, 61, 2, 0, 0, 1, 0, '2020-05-31 16:20:26'),
(77, 62, 2, 0, 0, 2, 0, '2020-05-31 16:21:53');

-- --------------------------------------------------------

--
-- Table structure for table `p_workrequestmanpower`
--

CREATE TABLE `p_workrequestmanpower` (
  `id` int(11) NOT NULL,
  `workRequestId` int(11) NOT NULL,
  `itemListId` int(11) NOT NULL,
  `safety` int(11) NOT NULL,
  `supervisor` int(11) NOT NULL,
  `erectors` int(11) NOT NULL,
  `generalWorker` int(11) NOT NULL,
  `timeIn` time NOT NULL,
  `timeOut` time NOT NULL,
  `createdOn` datetime NOT NULL,
  `ItemUniqueId` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_workrequestmanpower`
--

INSERT INTO `p_workrequestmanpower` (`id`, `workRequestId`, `itemListId`, `safety`, `supervisor`, `erectors`, `generalWorker`, `timeIn`, `timeOut`, `createdOn`, `ItemUniqueId`) VALUES
(1, 9, 12, 0, 0, 0, 0, '03:43:00', '11:11:00', '2019-06-25 23:48:30', 'WR-0009B'),
(2, 12, 18, 1, 1, 1, 5, '08:00:00', '18:00:00', '2019-07-12 23:17:02', 'WR-0012B'),
(3, 16, 25, 1, 1, 5, 10, '08:00:00', '19:00:00', '2019-07-21 22:27:49', 'WR-0016B'),
(4, 35, 44, 0, 1, 5, 0, '08:00:00', '18:00:00', '2020-04-21 17:33:48', 'WR-0035A'),
(5, 36, 45, 0, 0, 0, 5, '08:00:00', '12:00:00', '2020-04-21 17:41:19', 'WR-0036A'),
(6, 46, 56, 32, 332, 2, 23, '02:00:00', '02:00:00', '2020-05-10 22:21:56', 'WR-0046B'),
(7, 59, 73, 1, 1, 7, 1, '08:00:00', '17:00:00', '2020-05-30 16:55:36', 'WR-0059A'),
(8, 62, 77, 0, 1, 5, 3, '08:00:00', '17:00:00', '2020-05-31 16:21:53', 'WR-0062A');

-- --------------------------------------------------------

--
-- Table structure for table `p_workrequestsizebased`
--

CREATE TABLE `p_workrequestsizebased` (
  `id` int(11) NOT NULL,
  `workRequestId` int(11) NOT NULL,
  `itemListId` int(11) NOT NULL,
  `scaffoldType` int(11) NOT NULL,
  `scaffoldWorkType` int(11) NOT NULL,
  `scaffoldSubCategory` int(11) NOT NULL,
  `length` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `width` int(11) NOT NULL,
  `setcount` int(11) NOT NULL,
  `createdOn` datetime NOT NULL,
  `ItemUniqueId` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_workrequestsizebased`
--

INSERT INTO `p_workrequestsizebased` (`id`, `workRequestId`, `itemListId`, `scaffoldType`, `scaffoldWorkType`, `scaffoldSubCategory`, `length`, `height`, `width`, `setcount`, `createdOn`, `ItemUniqueId`) VALUES
(1, 1, 1, 1, 1, 0, 231, 123, 2, 0, '2019-06-01 10:35:21', 'WR-0001A'),
(2, 2, 2, 0, 0, 0, 112, 32, 8, 10, '2019-06-01 11:04:58', 'WR-0002A'),
(3, 3, 3, 1, 1, 0, 231, 123, 2, 0, '2019-06-01 11:18:40', 'WR-0003A'),
(4, 3, 4, 2, 2, 0, 112, 0, 8, 5, '2019-06-01 11:18:40', 'WR-0003B'),
(5, 4, 6, 0, 0, 0, 231, 123, 2, 10, '2019-06-01 12:39:06', 'WR-0004A'),
(6, 5, 7, 1, 1, 0, 2, 3, 2, 2, '2019-06-10 11:27:08', 'WR-0005A'),
(7, 6, 8, 0, 0, 0, 231, 123, 2, 10, '2019-06-22 00:10:06', 'WR-0006A'),
(8, 7, 9, 0, 0, 0, 231, 123, 2, 10, '2019-06-22 00:13:23', 'WR-0007A'),
(9, 8, 10, 0, 0, 0, 231, 123, 2, 10, '2019-06-22 00:30:57', 'WR-0008A'),
(10, 10, 13, 1, 1, 0, 231, 123, 2, 0, '2019-06-29 11:29:13', 'WR-0010A'),
(11, 10, 14, 2, 1, 0, 112, 32, 8, 10, '2019-06-29 11:29:13', 'WR-0010B'),
(12, 11, 15, 1, 1, 1, 12, 23, 35, 1, '2019-07-12 23:14:33', 'WR-0011A'),
(13, 11, 16, 2, 2, 5, 1, 1, 1, 1, '2019-07-12 23:14:33', 'WR-0011B'),
(14, 12, 17, 0, 0, 0, 12, 24, 34, 0, '2019-07-12 23:17:02', 'WR-0012A'),
(15, 13, 19, 3, 1, 6, 12, 23, 35, 0, '2019-07-13 12:34:52', 'WR-0013A'),
(16, 13, 20, 0, 0, 6, 0, 0, 0, 1, '2019-07-13 12:34:52', 'WR-0013B'),
(17, 14, 21, 2, 1, 0, 22, 4, 3, 0, '2019-07-14 12:57:19', 'WR-0014A'),
(18, 14, 21, 1, 2, 0, 4, 3, 3, 3, '2019-07-14 12:57:19', 'WR-0014B'),
(19, 15, 22, 1, 1, 1, 51, 23, 26, 0, '2019-07-21 19:35:36', 'WR-0015A'),
(20, 15, 23, 2, 2, 5, 1, 1, 1, 100, '2019-07-21 19:35:36', 'WR-0015B'),
(21, 16, 24, 2, 1, 5, 51, 23, 26, 0, '2019-07-21 22:27:49', 'WR-0016A'),
(22, 17, 26, 1, 1, 1, 50, 50, 50, 1, '2019-08-17 11:06:37', 'WR-0017A'),
(23, 18, 27, 1, 1, 9, 10, 10, 2, 1, '2020-01-11 15:29:02', 'WR-0018A'),
(24, 19, 28, 5, 1, 22, 15, 5, 3, 1, '2020-01-11 15:33:28', 'WR-0019A'),
(25, 20, 29, 1, 1, 9, 5, 10, 2, 1, '2020-01-11 15:34:36', 'WR-0020A'),
(26, 21, 30, 6, 1, 26, 15, 2, 8, 1, '2020-01-11 15:36:09', 'WR-0021A'),
(27, 22, 31, 2, 4, 0, 50, 12, 1, 1, '2020-01-11 15:37:44', 'WR-0022A'),
(28, 23, 32, 3, 1, 0, 15, 3, 2, 1, '2020-01-11 15:40:27', 'WR-0023A'),
(29, 24, 33, 1, 1, 0, 2, 6, 2, 1, '2020-01-27 13:01:19', 'WR-0024A'),
(30, 25, 34, 3, 2, 0, 60, 2, 2, 1, '2020-01-27 13:02:52', 'WR-0025A'),
(31, 26, 35, 0, 0, 0, 2, 2, 2, 5, '2020-01-27 13:21:11', 'WR-0026A'),
(32, 26, 35, 1, 1, 0, 2, 6, 2, 0, '2020-01-27 13:21:11', 'WR-0026B'),
(33, 27, 36, 1, 1, 9, 50, 10, 2, 1, '2020-04-21 16:34:34', 'WR-0027A'),
(34, 28, 37, 3, 1, 18, 15, 2, 8, 1, '2020-04-21 17:09:15', 'WR-0028A'),
(35, 29, 38, 1, 2, 0, 2, 6, 2, 7, '2020-04-21 17:12:29', 'WR-0029A'),
(36, 30, 39, 5, 1, 21, 15, 2, 3, 1, '2020-04-21 17:15:10', 'WR-0030A'),
(37, 31, 40, 5, 1, 21, 15, 5, 3, 1, '2020-04-21 17:16:25', 'WR-0031A'),
(38, 33, 42, 1, 1, 0, 2, 8, 2, 1, '2020-04-21 17:27:06', 'WR-0033A'),
(39, 37, 46, 2, 4, 0, 8, 8, 1, 1, '2020-04-21 17:49:52', 'WR-0037A'),
(40, 38, 47, 1, 1, 9, 15, 3, 2, 1, '2020-04-23 12:32:24', 'WR-0038A'),
(41, 39, 48, 1, 1, 9, 15, 3, 3, 1, '2020-04-23 12:33:19', 'WR-0039A'),
(42, 40, 49, 1, 1, 9, 15, 5, 3, 1, '2020-04-23 12:34:53', 'WR-0040A'),
(43, 42, 51, 1, 1, 0, 2, 8, 2, 1, '2020-04-23 12:40:42', 'WR-0042A'),
(44, 43, 52, 1, 1, 0, 15, 5, 3, 1, '2020-04-25 13:32:22', 'WR-0043A'),
(46, 46, 55, 1, 1, 9, 15, 5, 3, 0, '2020-05-10 22:21:56', 'WR-0046A'),
(48, 47, 58, 3, 1, 18, 2, 2, 1, 2, '2020-05-23 13:23:10', 'WR-0047A'),
(49, 52, 63, 1, 1, 10, 4, 2, 2, 0, '2020-05-23 15:20:51', 'WR-0052A'),
(50, 52, 63, 2, 3, 12, 3, 9, 6, 4, '2020-05-23 15:20:51', 'WR-0052B'),
(57, 55, 69, 2, 1, 11, 10, 8, 1, 1, '2020-05-30 16:37:21', 'WR-0055A'),
(58, 56, 70, 1, 1, 9, 2, 8, 2, 1, '2020-05-30 16:39:33', 'WR-0056A'),
(59, 58, 72, 1, 1, 9, 5, 10, 2, 1, '2020-05-30 16:53:28', 'WR-0058A'),
(60, 58, 72, 3, 1, 18, 5, 2, 1, 1, '2020-05-30 16:53:28', 'WR-0058B'),
(61, 58, 72, 2, 1, 12, 10, 8, 1, 1, '2020-05-30 16:53:28', 'WR-0058C'),
(62, 53, 74, 3, 1, 18, 1, 3, 2, 4, '2020-05-30 18:00:42', 'WR-0053A'),
(63, 53, 74, 3, 1, 18, 4, 1, 5, 1, '2020-05-30 18:00:42', 'WR-0053B'),
(64, 53, 74, 3, 2, 18, 1, 1, 1, 1, '2020-05-30 18:00:42', 'WR-0053C'),
(65, 60, 75, 1, 1, 9, 50, 10, 2, 1, '2020-05-31 16:08:02', 'WR-0060A'),
(66, 61, 76, 1, 1, 9, 2, 8, 2, 1, '2020-05-31 16:20:26', 'WR-0061A'),
(67, 61, 76, 3, 1, 18, 2, 2, 1, 1, '2020-05-31 16:20:26', 'WR-0061B');

-- --------------------------------------------------------

--
-- Table structure for table `tempdwtr`
--

CREATE TABLE `tempdwtr` (
  `workTrackId` int(11) NOT NULL DEFAULT '0',
  `subDivisionId` int(11) NOT NULL,
  `WorkRequest` varchar(20) NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `clientId` int(11) NOT NULL,
  `ClientName` varchar(100) DEFAULT NULL,
  `projectId` int(11) NOT NULL,
  `ProjectName` varchar(100) DEFAULT NULL,
  `supervisor` int(11) NOT NULL,
  `SupervisorName` varchar(100) DEFAULT NULL,
  `baseSupervisor` int(11) NOT NULL,
  `BaseSupervisorName` varchar(100) DEFAULT NULL,
  `workRequestId` int(11) NOT NULL,
  `scaffoldType` int(11) NOT NULL,
  `scaffoldTypeName` varchar(100) DEFAULT NULL,
  `scaffoldSubCategory` int(11) NOT NULL,
  `scaffoldSubCategoryName` varchar(100) DEFAULT NULL,
  `scaffoldWorkType` int(11) NOT NULL,
  `scaffoldWorkTypeName` varchar(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `Team` varchar(100) DEFAULT NULL,
  `teamId` int(11) NOT NULL,
  `length` int(11) NOT NULL,
  `width` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `setcount` int(11) NOT NULL,
  `Volume` bigint(41) NOT NULL DEFAULT '0',
  `Productivity` decimal(45,4) DEFAULT NULL,
  `clength` int(11) NOT NULL,
  `cWidth` int(11) NOT NULL,
  `cheight` int(11) NOT NULL,
  `csetcount` int(11) NOT NULL,
  `cVolume` bigint(41) NOT NULL DEFAULT '0',
  `workerCount` int(11) NOT NULL,
  `inTime` time NOT NULL,
  `outTime` time NOT NULL,
  `WorkHr` time DEFAULT NULL,
  `TotalWorkHr` decimal(21,4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tempDWTR`
--

CREATE TABLE `tempDWTR` (
  `workTrackId` int(11) NOT NULL DEFAULT '0',
  `subDivisionId` int(11) NOT NULL,
  `WorkRequest` varchar(20) NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `clientId` int(11) NOT NULL,
  `ClientName` varchar(100) DEFAULT NULL,
  `projectId` int(11) NOT NULL,
  `ProjectName` varchar(100) DEFAULT NULL,
  `supervisor` int(11) NOT NULL,
  `SupervisorName` varchar(100) DEFAULT NULL,
  `baseSupervisor` int(11) NOT NULL,
  `BaseSupervisorName` varchar(100) DEFAULT NULL,
  `workRequestId` int(11) NOT NULL,
  `scaffoldType` int(11) NOT NULL,
  `scaffoldTypeName` varchar(100) DEFAULT NULL,
  `scaffoldSubCategory` int(11) NOT NULL,
  `scaffoldSubCategoryName` varchar(100) DEFAULT NULL,
  `scaffoldWorkType` int(11) NOT NULL,
  `scaffoldWorkTypeName` varchar(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `Team` varchar(100) DEFAULT NULL,
  `teamId` int(11) NOT NULL,
  `length` int(11) NOT NULL,
  `width` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `setcount` int(11) NOT NULL,
  `Volume` bigint(41) NOT NULL DEFAULT '0',
  `Productivity` decimal(45,4) DEFAULT NULL,
  `clength` int(11) NOT NULL,
  `cWidth` int(11) NOT NULL,
  `cheight` int(11) NOT NULL,
  `csetcount` int(11) NOT NULL,
  `cVolume` bigint(41) NOT NULL DEFAULT '0',
  `workerCount` int(11) NOT NULL,
  `inTime` time NOT NULL,
  `outTime` time NOT NULL,
  `WorkHr` time DEFAULT NULL,
  `TotalWorkHr` decimal(21,4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tempDWTR`
--

INSERT INTO `tempDWTR` (`workTrackId`, `subDivisionId`, `WorkRequest`, `CreatedOn`, `clientId`, `ClientName`, `projectId`, `ProjectName`, `supervisor`, `SupervisorName`, `baseSupervisor`, `BaseSupervisorName`, `workRequestId`, `scaffoldType`, `scaffoldTypeName`, `scaffoldSubCategory`, `scaffoldSubCategoryName`, `scaffoldWorkType`, `scaffoldWorkTypeName`, `Team`, `teamId`, `length`, `width`, `height`, `setcount`, `Volume`, `Productivity`, `clength`, `cWidth`, `cheight`, `csetcount`, `cVolume`, `workerCount`, `inTime`, `outTime`, `WorkHr`, `TotalWorkHr`) VALUES
(41, 30, 'WR-0025A', '2020-04-22 17:57:07', 8, 'Obayashi', 26, 'AT-SGP1 -Loyang', 46, 'R.Sasikumar', 46, 'R.Sasikumar', 25, 3, 'Cantilever', 0, NULL, 2, 'Dismantle', 'Team#1', 2, 60, 2, 1, 1, 120, 0.0000, 0, 0, 0, 0, 0, 7, '08:00:00', '12:00:00', '04:00:00', 28.0000);

-- --------------------------------------------------------

--
-- Table structure for table `tempProductivityDetails`
--

CREATE TABLE `tempProductivityDetails` (
  `scaffoldTypeId` int(11) NOT NULL,
  `scaffoldSubCateId` int(11) NOT NULL DEFAULT '0',
  `scaffoldSubCatName` varchar(100) NOT NULL,
  `Prod_Erection` decimal(65,4) DEFAULT NULL,
  `Prod_Dismantle` decimal(65,4) DEFAULT NULL,
  `Total_WrHr` decimal(43,4) DEFAULT NULL,
  `MaterialShifting` decimal(43,4) DEFAULT NULL,
  `HKeeping` decimal(43,4) DEFAULT NULL,
  `ProductionHr` decimal(43,4) DEFAULT NULL,
  `TypeWorkErection` varchar(100),
  `TypeWorkDismantle` int(11)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tempProductivityDetails`
--

INSERT INTO `tempProductivityDetails` (`scaffoldTypeId`, `scaffoldSubCateId`, `scaffoldSubCatName`, `Prod_Erection`, `Prod_Dismantle`, `Total_WrHr`, `MaterialShifting`, `HKeeping`, `ProductionHr`, `TypeWorkErection`, `TypeWorkDismantle`) VALUES
(1, 9, 'Tower (ELP- 3x3x10)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '25', 50),
(1, 10, 'Tower (TLP- 3x3x10)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '25', 50),
(2, 11, 'Perimeter (ELP- 10x1x15)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '25', 50),
(2, 12, 'Perimeter (TLP- 10x1x15)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '25', 50),
(2, 13, 'Perimeter (ELP- 20x1x15)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '30', 60),
(2, 14, 'Perimeter (TLP- 20x1x15)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '30', 60),
(2, 15, 'Perimeter (ELP->20x1x<10)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '35', 70),
(2, 16, 'Perimeter (TLP->20x1x<10)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '35', 70),
(2, 17, 'PERIMETER (Height >6m)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '30', 60),
(3, 18, 'Cantilever / Truss out', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '20', 40),
(4, 19, 'Mobile=4mH', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '1', 2),
(4, 20, 'Mobile<=3mH', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '1', 2),
(5, 21, 'Birdcage (3x5x10)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '30', 60),
(5, 22, 'Birdcage (5x5x10)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '50', 100),
(5, 23, 'Birdcage (6x6x10)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '75', 150),
(5, 24, 'Birdcage (10x10x10)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '100', 200),
(5, 25, 'Birdcage (15x15x10)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '150', 300),
(5, 41, 'Birdcage (Higher)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '200', 400),
(6, 26, 'Hanging', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '20', 40),
(7, 27, 'Lift shaft', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '20', 40),
(7, 28, 'Riser', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '20', 40),
(16, 31, 'Catching Platform', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '4', 8),
(17, 32, 'Additional Platform m2', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '50', 100),
(17, 33, 'Additional Platform m3', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '75', 100),
(4, 29, 'Al.Mobile (2x2x6)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '1', 2),
(4, 30, 'Al.Tower (2x2x10)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '1', 2),
(18, 34, 'Cantilever Bracket', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '12', 20),
(19, 35, 'Cantilever I-Beam', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '8', 15),
(19, 36, 'Cantilever Truss Beam', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '15', 30),
(20, 37, 'Heavy Duty m2 (Spacing <1m)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '15', 30),
(20, 38, 'Heavy Duty m3 (Spacing >1m)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '20', 40),
(21, 39, 'Hard Barricade with Anchor', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '25', 50),
(21, 40, 'Hard Barricade', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '30', 60),
(22, 42, 'Access Tower (DSL)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '20', 40),
(22, 44, 'Access Tower (SSL)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '30', 60),
(23, 43, 'Skeleton (NO Platform)', NULL, NULL, 28.0000, NULL, 5.0000, NULL, '75', 150);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `p_clients`
--
ALTER TABLE `p_clients`
  ADD PRIMARY KEY (`clientId`);

--
-- Indexes for table `p_contracts`
--
ALTER TABLE `p_contracts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_dailyworktrack`
--
ALTER TABLE `p_dailyworktrack`
  ADD PRIMARY KEY (`worktrackId`);

--
-- Indexes for table `p_dailyworktrackmaterials`
--
ALTER TABLE `p_dailyworktrackmaterials`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_dailyworktracksubdivision`
--
ALTER TABLE `p_dailyworktracksubdivision`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_dailyworktrackteams`
--
ALTER TABLE `p_dailyworktrackteams`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_grade`
--
ALTER TABLE `p_grade`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_material`
--
ALTER TABLE `p_material`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_productivityslab`
--
ALTER TABLE `p_productivityslab`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_projects`
--
ALTER TABLE `p_projects`
  ADD PRIMARY KEY (`projectId`);

--
-- Indexes for table `p_scaffoldsubcatergory`
--
ALTER TABLE `p_scaffoldsubcatergory`
  ADD PRIMARY KEY (`scaffoldSubCateId`);

--
-- Indexes for table `p_scaffoldtype`
--
ALTER TABLE `p_scaffoldtype`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_scaffoldworktype`
--
ALTER TABLE `p_scaffoldworktype`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_users`
--
ALTER TABLE `p_users`
  ADD PRIMARY KEY (`userId`),
  ADD KEY `userName` (`userName`,`password`);

--
-- Indexes for table `p_workarrangement`
--
ALTER TABLE `p_workarrangement`
  ADD PRIMARY KEY (`workArrangementId`);

--
-- Indexes for table `p_workattendance`
--
ALTER TABLE `p_workattendance`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_workers`
--
ALTER TABLE `p_workers`
  ADD PRIMARY KEY (`workerId`);

--
-- Indexes for table `p_workerteam`
--
ALTER TABLE `p_workerteam`
  ADD PRIMARY KEY (`teamid`);

--
-- Indexes for table `p_workrequest`
--
ALTER TABLE `p_workrequest`
  ADD PRIMARY KEY (`workRequestId`);

--
-- Indexes for table `p_workrequestitems`
--
ALTER TABLE `p_workrequestitems`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_workrequestmanpower`
--
ALTER TABLE `p_workrequestmanpower`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `p_workrequestsizebased`
--
ALTER TABLE `p_workrequestsizebased`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `p_clients`
--
ALTER TABLE `p_clients`
  MODIFY `clientId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `p_contracts`
--
ALTER TABLE `p_contracts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `p_dailyworktrack`
--
ALTER TABLE `p_dailyworktrack`
  MODIFY `worktrackId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT for table `p_dailyworktrackmaterials`
--
ALTER TABLE `p_dailyworktrackmaterials`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `p_dailyworktracksubdivision`
--
ALTER TABLE `p_dailyworktracksubdivision`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `p_dailyworktrackteams`
--
ALTER TABLE `p_dailyworktrackteams`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT for table `p_grade`
--
ALTER TABLE `p_grade`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `p_material`
--
ALTER TABLE `p_material`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `p_productivityslab`
--
ALTER TABLE `p_productivityslab`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT for table `p_projects`
--
ALTER TABLE `p_projects`
  MODIFY `projectId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT for table `p_scaffoldsubcatergory`
--
ALTER TABLE `p_scaffoldsubcatergory`
  MODIFY `scaffoldSubCateId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `p_scaffoldtype`
--
ALTER TABLE `p_scaffoldtype`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `p_scaffoldworktype`
--
ALTER TABLE `p_scaffoldworktype`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `p_users`
--
ALTER TABLE `p_users`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `p_workarrangement`
--
ALTER TABLE `p_workarrangement`
  MODIFY `workArrangementId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=134;

--
-- AUTO_INCREMENT for table `p_workattendance`
--
ALTER TABLE `p_workattendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1009;

--
-- AUTO_INCREMENT for table `p_workers`
--
ALTER TABLE `p_workers`
  MODIFY `workerId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;

--
-- AUTO_INCREMENT for table `p_workerteam`
--
ALTER TABLE `p_workerteam`
  MODIFY `teamid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `p_workrequest`
--
ALTER TABLE `p_workrequest`
  MODIFY `workRequestId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

--
-- AUTO_INCREMENT for table `p_workrequestitems`
--
ALTER TABLE `p_workrequestitems`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- AUTO_INCREMENT for table `p_workrequestmanpower`
--
ALTER TABLE `p_workrequestmanpower`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `p_workrequestsizebased`
--
ALTER TABLE `p_workrequestsizebased`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
