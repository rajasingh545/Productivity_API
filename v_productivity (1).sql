-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 31, 2019 at 02:32 AM
-- Server version: 10.1.28-MariaDB
-- PHP Version: 5.6.32

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `v_productivity`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_productivityReport` (IN `FromDate` DATE, IN `ToDate` DATE, IN `Supervisor` VARCHAR(500), IN `BaseSupervisor` VARCHAR(500))  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_productivitySummaryReport` (IN `FromDate` DATE, IN `ToDate` DATE, IN `Supervisor` VARCHAR(500), IN `BaseSupervisor` VARCHAR(500))  BEGIN


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
(select sum(Productivity) from tempdwtr where scaffoldSubCategory =a.scaffoldSubCateId and tempdwtr.scaffoldWorkType =1) as Prod_Erection,
(select sum(Productivity) from tempdwtr where scaffoldSubCategory =a.scaffoldSubCateId and tempdwtr.scaffoldWorkType =2) as Prod_Dismantle
,(select sum(TotalWorkHr) from tempdwtr) as Total_WrHr,
(select 
Sum((TIMEDIFF(dwtrMat.outTime,dwtrMat.inTime) * dwtrMat.workerCount / 10000)) as TotalWorkHr
 from p_dailyworktrackmaterials dwtrMat
where workTrackId in (select workTrackId from tempdwtr) and material=1) as MaterialShifting
,(select 
Sum((TIMEDIFF(dwtrMat.outTime,dwtrMat.inTime) * dwtrMat.workerCount / 10000)) as TotalWorkHr
 from p_dailyworktrackmaterials dwtrMat
where workTrackId in (select workTrackId from tempdwtr) and material=2) as HKeeping
,(select 
Sum((TIMEDIFF(dwtrMat.outTime,dwtrMat.inTime) * dwtrMat.workerCount / 10000)) as TotalWorkHr
 from p_dailyworktrackmaterials dwtrMat
where workTrackId in (select workTrackId from tempdwtr) and material=3) as ProductionHr,
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
(9, 'Kajima', '29', 1, '2019-07-17 21:20:29', 2, '2019-07-17 21:20:29', 0),
(10, 'SMRT Trains', '30', 1, '2019-07-17 21:21:22', 2, '2019-07-17 21:21:22', 0),
(11, 'NamLee', '32', 1, '2019-07-17 21:21:38', 2, '2019-07-17 21:21:38', 0),
(12, 'Hexacon', '34', 1, '2019-07-17 21:22:00', 2, '2019-07-17 21:22:00', 0),
(13, 'Vision E&C', '42', 1, '2019-07-17 21:23:04', 2, '2019-07-17 21:23:04', 0),
(14, 'KM Construction', '36', 1, '2019-07-17 21:23:53', 2, '2019-07-17 21:23:53', 0),
(15, 'Tentronic', '36', 1, '2019-07-17 21:24:21', 2, '2019-07-17 21:24:21', 0),
(16, 'Specon Contractor', '46', 2, '2019-07-17 21:25:32', 2, '2019-07-20 13:09:17', 2);

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
(1, 3, 'Perimeter scaffold with every level plateform		', 1, '1a', 'level-3 to top', 231, 123, 2, 15, 0, 0, 0),
(2, 3, 'cantilever scaffold ', 1, '2b', 'top level', 112, 32, 8, 12, 0, 0, 0);

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
  `supervisor` int(11) NOT NULL,
  `baseSupervisor` int(11) NOT NULL,
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

INSERT INTO `p_dailyworktrack` (`worktrackId`, `projectId`, `ClientId`, `type`, `requestedBy`, `supervisor`, `baseSupervisor`, `workRequestId`, `photo_1`, `photo_2`, `photo_3`, `remarks`, `matMisuse`, `matRemarks`, `matPhotos`, `safetyVio`, `safetyRemarks`, `safetyPhoto`, `createdOn`, `uniqueId`, `status`) VALUES
(1, 3, 1, 1, '', 5, 5, 1, '', '', '', '', 2, '', '', 2, '', '', '2019-07-12 20:43:02', '1562956892774', 1),
(2, 3, 1, 1, '', 9, 9, 1, '', '', '', '', 0, '', '', 0, '', '', '2019-07-12 21:26:55', '1562959578109', 1),
(3, 3, 1, 1, '', 5, 5, 1, '', '', '', '', 2, '', '', 2, '', '', '2019-07-19 20:32:58', '1563561130477', 1);

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
  `createdOn` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_dailyworktrackmaterials`
--

INSERT INTO `p_dailyworktrackmaterials` (`id`, `workTrackId`, `subDevisionId`, `material`, `workerCount`, `inTime`, `outTime`, `createdOn`) VALUES
(1, 1, 1, 1, 3, '01:20:00', '11:20:00', '2019-07-12 20:43:03'),
(2, 2, 1, 1, 2, '21:00:00', '01:00:00', '2019-07-12 21:26:55'),
(3, 3, 0, 1, 12, '10:00:00', '00:01:00', '2019-07-19 20:32:58');

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
(1, 1, 1, 1, 1, 3, 2, 3, 1, 0, 0, 0, 0, 0, '2019-07-12 20:43:02'),
(2, 2, 1, 1, 12, 12, 1, 12, 1, 0, 0, 0, 0, 0, '2019-07-12 21:26:55'),
(3, 3, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2019-07-19 20:32:58');

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
(1, 1, 1, 1, 3, '01:00:00', '13:12:00', '2019-07-12 20:43:03'),
(2, 2, 1, 1, 12, '10:00:00', '23:30:00', '2019-07-12 21:26:55'),
(3, 3, 0, 1, 223, '00:10:00', '01:00:00', '2019-07-19 20:32:58');

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
  `createdOn` datetime NOT NULL,
  `modifiedBy` int(11) NOT NULL,
  `modifiedOn` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_grade`
--

INSERT INTO `p_grade` (`id`, `gradeRangeFrom`, `gradeRangeTo`, `Percentage`, `grade`, `createdBy`, `createdOn`, `modifiedBy`, `modifiedOn`) VALUES
(4, 91, 100, 90, 'Good', 2, '2019-06-26 23:38:56', 2, '2019-06-29 12:53:39'),
(5, 95, 98, 95, '0', 2, '2019-06-26 23:45:29', 2, '2019-06-26 23:45:29'),
(6, 16, 21, 0, 'A', 2, '2019-06-26 23:49:11', 2, '2019-06-29 03:16:54'),
(7, 0, 50, 60, 'avg', 2, '2019-06-29 13:14:27', 2, '2019-07-13 11:44:12');

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
  `createdOn` datetime NOT NULL,
  `createdBy` int(11) NOT NULL,
  `modifiedBy` int(11) NOT NULL,
  `modifiedOn` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_productivityslab`
--

INSERT INTO `p_productivityslab` (`id`, `scaffoldType`, `scaffoldSubCategory`, `unit`, `typeWorkErection`, `typeWorkDismantle`, `createdOn`, `createdBy`, `modifiedBy`, `modifiedOn`) VALUES
(1, 0, 0, 2, '25.6', 31, '2019-06-15 11:58:14', 2, 2, '2019-07-12 12:23:24'),
(2, 0, 0, 2, '100.5', 201, '2019-06-15 12:01:26', 2, 2, '2019-07-12 12:25:37'),
(4, 2, 5, 2, '25', 60, '2019-06-15 12:11:14', 2, 2, '2019-07-13 11:45:13'),
(5, 0, 0, 1, '100', 150, '2019-06-26 23:08:17', 2, 2, '2019-06-29 12:22:59');

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
(28, 'CL Hotel', 1, '2019-07-17 13:12:18', 2, '2019-07-17 21:12:18'),
(29, 'ITE', 1, '2019-07-17 13:12:25', 2, '2019-07-17 21:12:25'),
(30, 'SMRT', 1, '2019-07-17 13:12:32', 2, '2019-07-17 21:12:32'),
(31, 'NUH', 1, '2019-07-17 13:12:52', 2, '2019-07-17 21:12:52'),
(32, 'Hampton Court', 1, '2019-07-17 13:12:58', 2, '2019-07-17 21:12:58'),
(33, 'NCID', 1, '2019-07-17 13:13:03', 2, '2019-07-17 21:13:03'),
(34, 'Anson Road', 1, '2019-07-17 13:13:11', 2, '2019-07-17 21:13:11'),
(35, 'Silat Road', 1, '2019-07-17 13:13:19', 2, '2019-07-17 21:13:19'),
(36, 'Tampines T20', 1, '2019-07-17 13:13:25', 2, '2019-07-17 21:13:25'),
(37, 'Micron', 1, '2019-07-17 13:13:55', 2, '2019-07-17 21:13:55'),
(38, 'Store', 1, '2019-07-17 13:14:24', 2, '2019-07-17 21:14:24'),
(39, 'PLQ', 1, '2019-07-17 13:15:53', 2, '2019-07-17 21:15:53'),
(40, 'Rochester Park', 1, '2019-07-17 13:15:59', 2, '2019-07-17 21:15:59'),
(41, 'F1', 1, '2019-07-17 13:16:16', 2, '2019-07-17 21:16:16'),
(42, 'Holland Hill', 1, '2019-07-17 13:16:44', 2, '2019-07-17 21:16:44'),
(43, 'Marina One', 1, '2019-07-17 13:17:00', 2, '2019-07-17 21:17:00'),
(44, 'Khatib MRT', 1, '2019-07-17 13:17:27', 2, '2019-07-17 21:17:27'),
(45, 'RGS', 1, '2019-07-17 13:18:06', 2, '2019-07-17 21:18:06'),
(46, 'SAS', 1, '2019-07-17 13:18:11', 2, '2019-07-17 21:18:11');

-- --------------------------------------------------------

--
-- Table structure for table `p_scaffoldsubcatergory`
--

CREATE TABLE `p_scaffoldsubcatergory` (
  `scaffoldSubCateId` int(11) NOT NULL,
  `scaffoldTypeId` int(11) NOT NULL,
  `scaffoldSubCatName` varchar(100) NOT NULL,
  `createdOn` datetime NOT NULL,
  `createdBy` int(11) NOT NULL,
  `modifiedBy` int(11) NOT NULL,
  `modifiedOn` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_scaffoldsubcatergory`
--

INSERT INTO `p_scaffoldsubcatergory` (`scaffoldSubCateId`, `scaffoldTypeId`, `scaffoldSubCatName`, `createdOn`, `createdBy`, `modifiedBy`, `modifiedOn`) VALUES
(1, 1, 'Tower (ELP- 3x3x10)', '2019-07-06 00:00:00', 1, 0, '0000-00-00 00:00:00'),
(2, 1, 'Tower (TLP- 3x3x10)', '2019-07-06 00:00:00', 1, 0, '0000-00-00 00:00:00'),
(3, 2, 'Perimeter (ELP- 10x1x15)', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(4, 2, 'Perimeter (TLP- 10x1x15)', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(5, 2, 'Perimeter (ELP- 20x1x15)', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(6, 2, 'Perimeter (TLP- 20x1x15)', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(7, 2, 'Perimeter (ELP->20x1x<10)', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(8, 2, 'Perimeter (TLP->20x1x<10)', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(9, 2, 'PERIMETER (Height >6m)', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(10, 3, 'Cantilever / Truss out', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(11, 4, 'Mobile=4mH', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(12, 4, 'Mobile<=3mH', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(13, 5, 'Birdcage (3x5x10)', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(14, 5, 'Birdcage (5x5x10)', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(15, 5, 'Birdcage (6x6x10)', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(16, 5, 'Birdcage (10x10x10)', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(17, 6, 'Hanging', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00'),
(18, 7, 'Lift shaft / Riser', '0000-00-00 00:00:00', 2, 2, '0000-00-00 00:00:00');

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
(8, 'Truss Out', 1),
(9, 'Cantilever I.Beam', 1),
(10, 'Cantilever T.Bracket', 1);

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
(5, 3, 1, '2019-03-07 00:00:00', 1),
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
  `project` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_users`
--

INSERT INTO `p_users` (`userId`, `Name`, `userName`, `password`, `userType`, `userStatus`, `createdBy`, `project`) VALUES
(2, 'Admin', 'admin', '0192023a7bbd73250516f069df18b500', 1, 1, 0, '0'),
(3, 'jeeva', 'storeman', 'c6f929f8c30078248c2a2151be9f0f39', 3, 1, 0, '0'),
(4, 'driver', 'driver', '703b02a2a8bb363f50386bb338892471', 4, 1, 0, '0'),
(5, 'super', 'super', 'f35364bc808b079853de5a1e343e7159', 5, 1, 0, '4,3,5'),
(6, 'Super 2', 'Super2', 'affc43cb08a4fd1d9b27fae06b3c57cd', 5, 1, 0, '5'),
(7, 'jeeva', 'ssjeeva', 'e8717e52966964f14a532ba011503c64', 5, 1, 0, '4'),
(8, 'driver2', 'driver2', '703b02a2a8bb363f50386bb338892471', 4, 1, 0, '0'),
(9, 'super 3', 'super3', '85511dc944c3765338deb0b3ad38e907', 5, 1, 0, '3'),
(11, 'super 4', 'super4', 'be3878a397a68ac10c4ef8727baa3b7d', 5, 1, 0, '4');

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
(1, 3, 5, 9, '2019-04-23 00:00:00', 2, '', 1, 0, ''),
(2, 4, 7, 11, '2019-04-23 00:00:00', 2, '', 1, 0, ''),
(3, 3, 9, 5, '2019-04-26 00:00:00', 2, '', 1, 1, ''),
(4, 3, 5, 9, '2019-04-27 00:00:00', 2, 'sfsfsasf asdasdasdas', 1, 1, ''),
(5, 4, 7, 11, '2019-04-27 00:00:00', 2, '', 2, 0, ''),
(6, 3, 9, 5, '2019-04-30 00:00:00', 2, '', 1, 0, ''),
(7, 3, 5, 5, '2019-05-01 00:00:00', 2, 'this is remarks', 2, 0, ''),
(8, 3, 5, 9, '2019-05-02 00:00:00', 2, 'ddfg', 1, 0, ''),
(9, 4, 11, 7, '2019-05-02 00:00:00', 2, '', 1, 1, ''),
(10, 3, 5, 9, '2019-05-04 00:00:00', 2, 'this is remarks', 1, 1, 'this is attendance remarkss mod'),
(11, 3, 5, 6, '2019-05-14 00:00:00', 2, '', 2, 0, ''),
(12, 3, 5, 9, '2019-05-13 00:00:00', 2, '', 2, 0, ''),
(13, 3, 5, 9, '2019-05-18 00:00:00', 2, '', 1, 1, ''),
(14, 4, 7, 7, '2019-05-18 00:00:00', 2, '', 1, 0, ''),
(15, 3, 5, 5, '2019-06-08 00:00:00', 2, '', 2, 0, ''),
(16, 4, 11, 0, '2019-06-08 00:00:00', 2, '', 2, 0, ''),
(17, 5, 6, 6, '2019-06-08 00:00:00', 2, '', 2, 0, ''),
(20, 4, 5, 0, '2019-07-11 00:00:00', 2, '', 1, 1, ''),
(21, 3, 5, 5, '2019-07-12 00:00:00', 2, '', 1, 1, ''),
(22, 4, 5, 7, '2019-07-12 00:00:00', 2, '', 2, 0, '');

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
  `partial` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_workattendance`
--

INSERT INTO `p_workattendance` (`id`, `workArrangementId`, `workerId`, `workerTeam`, `inTime`, `outTime`, `reason`, `forDate`, `createdOn`, `status`, `statusOut`, `partial`) VALUES
(24, 1, 3, 2, '00:00:00', '00:00:00', 0, '2019-04-23', '2019-04-23 15:34:48', 0, 0, 0),
(25, 1, 4, 1, '00:00:00', '00:00:00', 0, '2019-04-23', '2019-04-23 15:34:48', 0, 0, 0),
(26, 1, 5, 2, '00:00:00', '00:00:00', 0, '2019-04-23', '2019-04-23 15:34:49', 0, 0, 0),
(27, 1, 8, 3, '00:00:00', '00:00:00', 0, '2019-04-23', '2019-04-23 15:34:49', 0, 0, 0),
(28, 2, 1, 1, '00:00:00', '00:00:00', 0, '2019-04-23', '2019-04-23 15:35:40', 0, 0, 0),
(29, 2, 10, 4, '00:00:00', '00:00:00', 0, '2019-04-23', '2019-04-23 15:35:40', 0, 0, 0),
(30, 3, 1, 1, '01:00:00', '20:00:00', 0, '2019-04-27', '2019-04-26 20:34:44', 0, 0, 0),
(31, 3, 2, 1, '02:00:00', '10:00:00', 0, '2019-04-27', '2019-04-26 20:34:44', 0, 0, 0),
(32, 3, 4, 1, '02:30:00', '03:00:00', 0, '2019-04-27', '2019-04-26 20:34:44', 0, 0, 0),
(33, 3, 6, 2, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-26 20:34:44', 0, 0, 0),
(34, 4, 3, 2, '02:00:00', '01:00:00', 0, '2019-04-27', '2019-04-27 04:21:36', 0, 0, 0),
(35, 4, 7, 3, '10:00:00', '04:00:00', 0, '2019-04-27', '2019-04-27 04:21:36', 0, 0, 0),
(36, 4, 9, 4, '01:00:00', '02:00:00', 0, '2019-04-27', '2019-04-27 04:21:36', 0, 0, 0),
(37, 5, 5, 2, '00:00:00', '00:00:00', 0, '2019-04-27', '2019-04-27 05:49:45', 0, 0, 0),
(38, 6, 1, 1, '00:00:00', '00:00:00', 0, '2019-04-30', '2019-04-30 09:12:24', 0, 0, 0),
(39, 6, 2, 1, '00:00:00', '00:00:00', 0, '2019-04-30', '2019-04-30 09:12:24', 0, 0, 0),
(40, 6, 6, 2, '00:00:00', '00:00:00', 0, '2019-04-30', '2019-04-30 09:12:24', 0, 0, 0),
(41, 6, 7, 3, '00:00:00', '00:00:00', 0, '2019-04-30', '2019-04-30 09:12:24', 0, 0, 0),
(42, 7, 1, 1, '00:00:00', '00:00:00', 0, '2019-05-01', '2019-05-01 11:03:21', 0, 0, 0),
(43, 7, 3, 2, '00:00:00', '00:00:00', 0, '2019-05-01', '2019-05-01 11:03:21', 0, 0, 0),
(44, 7, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-01', '2019-05-01 11:03:21', 0, 0, 0),
(45, 7, 5, 2, '00:00:00', '00:00:00', 0, '2019-05-01', '2019-05-01 11:03:21', 0, 0, 0),
(46, 8, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-02', '2019-05-02 13:47:47', 0, 0, 0),
(47, 8, 3, 2, '00:00:00', '00:00:00', 0, '2019-05-02', '2019-05-02 13:47:47', 0, 0, 0),
(48, 9, 1, 1, '10:11:00', '03:30:00', 5, '2019-05-02', '2019-05-02 20:05:58', 1, 0, 0),
(49, 9, 5, 2, '11:02:00', '20:00:00', 4, '2019-05-02', '2019-05-02 20:05:58', 1, 0, 0),
(53, 10, 1, 1, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 03:01:27', 0, 0, 0),
(54, 10, 3, 2, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 03:01:27', 0, 0, 0),
(55, 10, 6, 2, '00:00:00', '00:00:00', 0, '2019-05-04', '2019-05-04 03:01:27', 0, 0, 0),
(58, 11, 1, 1, '00:00:00', '00:00:00', 0, '2019-05-14', '2019-05-15 11:41:29', 0, 0, 0),
(59, 11, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-14', '2019-05-15 11:41:29', 0, 0, 0),
(60, 12, 1, 1, '00:00:00', '00:00:00', 0, '2019-05-13', '2019-05-15 11:43:27', 0, 0, 0),
(61, 12, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-13', '2019-05-15 11:43:27', 0, 0, 0),
(62, 13, 1, 1, '13:00:00', '01:00:00', 0, '2019-05-18', '2019-05-18 03:01:22', 1, 0, 0),
(63, 13, 2, 1, '00:00:00', '00:00:00', 0, '2019-05-18', '2019-05-18 03:01:22', 0, 0, 0),
(64, 13, 3, 2, '00:00:00', '00:00:00', 0, '2019-05-18', '2019-05-18 03:01:23', 0, 0, 0),
(67, 14, 4, 1, '00:00:00', '00:00:00', 0, '2019-05-18', '2019-05-18 03:12:31', 0, 0, 0),
(68, 14, 5, 2, '00:00:00', '00:00:00', 0, '2019-05-18', '2019-05-18 03:12:32', 0, 0, 0),
(72, 16, 4, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 10:03:05', 0, 0, 0),
(73, 16, 5, 2, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 10:03:05', 0, 0, 0),
(74, 17, 4, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 10:04:21', 0, 0, 1),
(75, 17, 5, 2, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 10:04:21', 0, 0, 0),
(94, 15, 1, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 12:21:09', 0, 0, 1),
(95, 15, 2, 1, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 12:21:09', 0, 0, 0),
(96, 15, 3, 2, '00:00:00', '00:00:00', 0, '2019-06-08', '2019-06-08 12:21:09', 0, 0, 0),
(97, 18, 1, 1, '01:00:00', '03:00:00', 0, '2019-07-11', '2019-07-11 16:29:02', 1, 0, 1),
(98, 18, 2, 1, '02:00:00', '00:20:00', 0, '2019-07-11', '2019-07-11 16:29:02', 1, 0, 1),
(99, 18, 3, 2, '03:00:00', '00:10:00', 0, '2019-07-11', '2019-07-11 16:29:02', 1, 0, 0),
(100, 19, 1, 1, '00:01:00', '00:00:00', 0, '2019-07-11', '2019-07-11 16:56:47', 1, 0, 1),
(101, 19, 2, 1, '00:02:00', '00:00:00', 0, '2019-07-11', '2019-07-11 16:56:47', 1, 0, 1),
(102, 19, 4, 1, '00:03:00', '00:00:00', 0, '2019-07-11', '2019-07-11 16:56:47', 1, 0, 0),
(103, 19, 5, 2, '00:00:00', '00:30:00', 0, '2019-07-11', '2019-07-11 16:56:47', 1, 0, 1),
(104, 19, 7, 3, '00:00:00', '00:20:00', 0, '2019-07-11', '2019-07-11 16:56:47', 1, 0, 0),
(105, 20, 1, 1, '01:00:00', '01:00:00', 0, '2019-07-11', '2019-07-11 17:30:36', 1, 1, 1),
(106, 20, 2, 1, '02:00:00', '02:20:00', 0, '2019-07-11', '2019-07-11 17:30:36', 1, 1, 0),
(107, 20, 5, 2, '02:00:00', '02:00:00', 0, '2019-07-11', '2019-07-11 17:30:36', 1, 1, 0),
(108, 20, 6, 2, '03:00:00', '02:00:00', 0, '2019-07-11', '2019-07-11 17:30:36', 1, 1, 0),
(109, 21, 1, 1, '01:00:00', '00:10:00', 0, '2019-07-12', '2019-07-11 18:01:24', 1, 1, 0),
(110, 21, 2, 1, '01:00:00', '00:00:00', 0, '2019-07-12', '2019-07-11 18:01:24', 1, 0, 0),
(111, 21, 3, 2, '10:00:00', '00:00:00', 0, '2019-07-12', '2019-07-11 18:01:24', 2, 0, 0),
(112, 21, 5, 2, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-11 18:01:24', 0, 0, 0),
(122, 22, 6, 2, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 16:02:02', 0, 0, 0),
(123, 22, 7, 3, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 16:02:02', 0, 0, 0),
(124, 22, 8, 3, '00:00:00', '00:00:00', 0, '2019-07-12', '2019-07-12 16:02:02', 0, 0, 0);

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
(1, 'worker1', 1, '2019-03-02 00:00:00', 1, '0000-00-00 00:00:00', 1),
(2, 'worker2', 1, '2019-03-02 00:00:00', 1, '0000-00-00 00:00:00', 1),
(3, 'worker3', 2, '2019-03-14 00:00:00', 1, '2019-04-23 13:11:24', 1),
(4, 'worker4', 1, '2019-04-13 00:00:00', 1, '0000-00-00 00:00:00', 1),
(5, 'worker5', 2, '2019-04-13 00:00:00', 1, '2019-04-23 13:13:37', 1),
(6, 'worker6', 2, '2019-04-13 00:00:00', 1, '2019-04-23 13:13:37', 1),
(7, 'worker7', 3, '2019-04-13 00:00:00', 1, '2019-04-23 13:15:03', 1),
(8, 'worker8', 3, '2019-04-13 00:00:00', 1, '2019-04-23 13:15:03', 1),
(9, 'worker9', 4, '2019-04-13 00:00:00', 1, '2019-04-23 13:15:03', 1),
(10, 'worker10', 4, '2019-04-13 00:00:00', 1, '2019-04-23 13:15:03', 1),
(25, 'Sivanasan', 1, '2019-07-17 21:46:32', 2, '2019-07-17 13:46:32', 1),
(26, 'Mayaraj', 1, '2019-07-17 21:46:40', 2, '2019-07-17 13:46:40', 1),
(27, 'Muthukumaran', 1, '2019-07-17 21:46:46', 2, '2019-07-17 13:46:46', 1),
(28, 'Ramachandran', 1, '2019-07-17 21:46:52', 2, '2019-07-17 13:46:52', 1),
(29, 'Rafikul', 1, '2019-07-17 21:46:59', 2, '2019-07-17 13:46:59', 1),
(30, 'Monir', 1, '2019-07-17 21:47:06', 2, '2019-07-17 13:47:06', 1),
(31, 'Murugan', 1, '2019-07-17 21:47:14', 2, '2019-07-17 13:47:14', 1),
(32, 'Kalam', 1, '2019-07-17 21:47:21', 2, '2019-07-17 13:47:21', 1),
(33, 'U.Murugesan', 1, '2019-07-17 21:47:29', 2, '2019-07-17 13:47:29', 1),
(34, 'Jeganathan', 1, '2019-07-17 21:47:38', 2, '2019-07-17 13:47:38', 1),
(35, 'Vijithkumar', 1, '2019-07-17 21:47:45', 2, '2019-07-17 13:47:45', 1),
(36, 'M.Murugan', 1, '2019-07-17 21:47:55', 2, '2019-07-17 13:47:55', 1),
(37, 'Muthusamy', 1, '2019-07-17 21:48:02', 2, '2019-07-17 13:48:02', 1),
(38, 'Mahendran', 1, '2019-07-17 21:48:08', 2, '2019-07-17 13:48:08', 1),
(39, 'M.Saravanan', 1, '2019-07-17 21:48:16', 2, '2019-07-17 13:48:16', 1),
(40, 'R.Ranjithkumar', 1, '2019-07-17 21:48:26', 2, '2019-07-17 13:48:26', 1),
(41, 'Palkannu', 1, '2019-07-17 21:48:32', 2, '2019-07-17 13:48:32', 1),
(42, 'Senthilraja', 1, '2019-07-17 21:48:38', 2, '2019-07-17 13:48:38', 1),
(43, 'Prabu', 1, '2019-07-17 21:48:43', 2, '2019-07-17 13:48:43', 1),
(44, 'Ganesan', 1, '2019-07-17 21:48:49', 2, '2019-07-17 13:48:49', 1),
(45, 'Selvam', 1, '2019-07-17 21:48:54', 2, '2019-07-17 13:48:54', 1),
(46, 'Nagarajan', 1, '2019-07-17 21:49:00', 2, '2019-07-17 13:49:00', 1),
(47, 'Vinothkumar', 1, '2019-07-17 21:49:05', 2, '2019-07-17 13:49:05', 1),
(48, 'S.Ranjith Kumar', 1, '2019-07-17 21:49:14', 2, '2019-07-17 13:49:14', 1),
(49, 'Showkat', 1, '2019-07-17 21:49:22', 2, '2019-07-17 13:49:22', 1),
(50, 'Moorthi', 1, '2019-07-17 21:49:35', 2, '2019-07-17 13:49:35', 1),
(51, 'Pandian', 1, '2019-07-17 21:49:40', 2, '2019-07-17 13:49:40', 1),
(52, 'K.Sundaram', 1, '2019-07-17 21:49:57', 2, '2019-07-17 13:49:57', 1),
(53, 'Prabhaharan', 1, '2019-07-17 21:50:04', 2, '2019-07-17 13:50:04', 1),
(54, 'Elumalai', 1, '2019-07-17 21:50:09', 2, '2019-07-17 13:50:09', 1),
(55, 'Paramasivam', 1, '2019-07-17 21:50:15', 2, '2019-07-17 13:50:15', 1),
(56, 'Kamrul', 1, '2019-07-17 21:50:22', 2, '2019-07-17 13:50:22', 1),
(57, 'Babu', 1, '2019-07-17 21:50:36', 2, '2019-07-17 13:50:36', 1),
(58, 'Visuvakumar', 2, '2019-07-17 21:50:48', 2, '2019-07-17 13:50:48', 1),
(59, 'Habibur', 2, '2019-07-17 21:50:56', 2, '2019-07-17 13:50:56', 1),
(60, 'Roni', 2, '2019-07-17 21:51:05', 2, '2019-07-17 13:51:05', 1),
(61, 'Kiyasutheen', 2, '2019-07-17 21:51:10', 2, '2019-07-17 13:51:10', 1),
(62, 'S.Saravanan', 2, '2019-07-17 21:51:19', 2, '2019-07-17 13:51:19', 1),
(63, 'Vellaisamy', 13, '2019-07-17 21:51:29', 2, '2019-07-17 13:51:29', 1),
(64, 'Sagar', 13, '2019-07-17 21:51:35', 2, '2019-07-17 13:51:35', 1),
(65, 'K.Ramesh', 13, '2019-07-17 21:51:43', 2, '2019-07-17 13:51:43', 1),
(66, 'Ranganathan', 13, '2019-07-17 21:51:50', 2, '2019-07-17 13:51:50', 1),
(67, 'Palanisamy', 13, '2019-07-17 21:51:57', 2, '2019-07-17 13:51:57', 1);

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
(2, 'Team1', '2019-04-23 00:00:00', 1),
(3, 'Team2', '2019-04-23 00:00:00', 1),
(4, 'SW', '2019-04-23 00:00:00', 1);

-- --------------------------------------------------------

--
-- Table structure for table `p_workrequest`
--

CREATE TABLE `p_workrequest` (
  `workRequestId` int(11) NOT NULL,
  `projectId` int(11) NOT NULL,
  `clientId` int(11) NOT NULL,
  `requestedBy` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `contractType` tinyint(1) NOT NULL,
  `remarks` text NOT NULL,
  `createdOn` datetime NOT NULL,
  `createdBy` int(11) NOT NULL,
  `scaffoldRegister` tinyint(1) NOT NULL,
  `status` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_workrequest`
--

INSERT INTO `p_workrequest` (`workRequestId`, `projectId`, `clientId`, `requestedBy`, `description`, `contractType`, `remarks`, `createdOn`, `createdBy`, `scaffoldRegister`, `status`) VALUES
(1, 3, 1, 'sss', '', 1, '', '2019-07-12 16:47:52', 2, 0, 1),
(2, 3, 1, 'xxx', '', 1, '', '2019-07-12 17:04:29', 2, 0, 1),
(3, 3, 1, 'www', '', 1, '', '2019-07-12 18:12:11', 2, 0, 1),
(4, 3, 1, 'asfdsd', '', 1, '', '2019-07-12 19:59:02', 2, 0, 1),
(5, 3, 1, 'asa', '', 1, '', '2019-07-12 20:06:35', 2, 0, 1),
(6, 3, 1, '11', '', 1, '', '2019-07-12 20:09:43', 2, 0, 1),
(7, 3, 1, 'dd', '', 1, '', '2019-07-12 20:13:45', 2, 0, 1),
(8, 3, 1, 'ssss', '', 1, '', '2019-07-12 20:17:56', 2, 0, 1),
(9, 3, 1, 'srfzx', '', 1, '', '2019-07-12 20:20:27', 2, 0, 1),
(10, 3, 2, 'ssss', '', 2, '', '2019-07-14 07:53:26', 2, 0, 1),
(11, 5, 1, 'dd', '', 2, 'dfsdf', '2019-07-14 07:56:15', 2, 0, 1),
(12, 3, 1, '22', '', 1, '', '2019-07-14 07:57:33', 2, 0, 1),
(13, 3, 1, 'new', 'asads zdasdsad', 1, 'asdasd sasasssassa', '2019-07-14 08:10:12', 2, 0, 1),
(14, 3, 1, 'variation work', '', 2, '', '2019-07-15 17:20:31', 2, 0, 1),
(15, 3, 2, 'ss', '', 2, '', '2019-07-16 17:00:27', 2, 0, 1),
(16, 3, 1, 'xxx', '', 1, 'qqwe', '2019-07-19 18:41:21', 2, 0, 1),
(17, 3, 1, 'dsdf', 'asdd', 1, '', '2019-07-19 20:14:36', 2, 0, 2),
(18, 30, 10, 'xxx', 'assf description', 2, 'asfsaf', '2019-07-20 10:28:03', 2, 1, 1);

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
  `createdOn` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `p_workrequestitems`
--

INSERT INTO `p_workrequestitems` (`id`, `workRequestId`, `contractType`, `itemId`, `sizeType`, `workBased`, `createdOn`) VALUES
(1, 1, 1, 1, 1, 1, '2019-07-12 16:47:52'),
(2, 1, 1, 0, 0, 0, '2019-07-12 16:47:53'),
(3, 2, 1, 1, 1, 1, '2019-07-12 17:04:29'),
(4, 2, 1, 2, 1, 1, '2019-07-12 17:04:29'),
(5, 3, 1, 1, 1, 1, '2019-07-12 18:12:12'),
(6, 4, 1, 1, 1, 1, '2019-07-12 19:59:02'),
(7, 5, 1, 1, 1, 1, '2019-07-12 20:06:35'),
(8, 6, 1, 1, 1, 1, '2019-07-12 20:09:43'),
(9, 7, 1, 1, 1, 1, '2019-07-12 20:13:45'),
(10, 8, 1, 1, 1, 1, '2019-07-12 20:17:56'),
(11, 9, 1, 1, 1, 1, '2019-07-12 20:20:27'),
(12, 10, 2, 0, 0, 2, '2019-07-14 07:53:27'),
(13, 11, 2, 0, 0, 2, '2019-07-14 07:56:15'),
(14, 12, 1, 1, 1, 2, '2019-07-14 07:57:33'),
(15, 13, 1, 1, 1, 1, '2019-07-14 08:10:12'),
(16, 13, 1, 2, 1, 1, '2019-07-14 08:10:12'),
(17, 14, 2, 0, 0, 1, '2019-07-15 17:20:31'),
(18, 15, 2, 0, 0, 2, '2019-07-16 17:00:27'),
(19, 16, 1, 1, 1, 1, '2019-07-19 18:41:21'),
(20, 17, 1, 1, 1, 1, '2019-07-19 20:14:36'),
(21, 18, 2, 0, 0, 1, '2019-07-20 10:28:03');

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
(1, 10, 12, 22, 25, 23, 26, '02:00:00', '02:40:00', '2019-07-14 07:53:27', 'WR-0010A'),
(2, 11, 13, 2, 3, 2, 3, '04:00:00', '00:40:00', '2019-07-14 07:56:15', 'WR-0011A'),
(3, 12, 14, 22, 34, 34, 34, '02:04:00', '02:23:00', '2019-07-14 07:57:34', 'WR-0012A'),
(4, 15, 18, 2, 24, 24, 33, '02:30:00', '03:30:00', '2019-07-16 17:00:27', 'WR-0015A'),
(5, 15, 18, 2, 3, 3, 3, '03:30:00', '00:02:00', '2019-07-16 17:00:27', 'WR-0015B');

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
(1, 1, 1, 1, 1, 0, 231, 123, 2, 0, '2019-07-12 16:47:52', 'WR-0001A'),
(2, 2, 3, 1, 1, 0, 231, 123, 2, 0, '2019-07-12 17:04:29', 'WR-0002A'),
(3, 2, 4, 2, 2, 0, 112, 32, 8, 0, '2019-07-12 17:04:29', 'WR-0002B'),
(4, 3, 5, 1, 1, 0, 231, 123, 2, 1, '2019-07-12 18:12:12', 'WR-0003A'),
(5, 4, 6, 1, 1, 0, 231, 123, 2, 0, '2019-07-12 19:59:02', 'WR-0004A'),
(6, 5, 7, 1, 1, 0, 231, 123, 2, 0, '2019-07-12 20:06:35', 'WR-0005A'),
(7, 6, 8, 2, 1, 0, 231, 123, 2, 10, '2019-07-12 20:09:43', 'WR-0006A'),
(8, 7, 9, 1, 1, 0, 231, 123, 2, 10, '2019-07-12 20:13:45', 'WR-0007A'),
(9, 8, 10, 2, 1, 0, 1, 1, 1, 1, '2019-07-12 20:17:56', 'WR-0008A'),
(10, 9, 11, 2, 1, 3, 231, 123, 2, 10, '2019-07-12 20:20:27', 'WR-0009A'),
(11, 13, 15, 1, 1, 1, 231, 123, 2, 0, '2019-07-14 08:10:12', 'WR-0013A'),
(12, 13, 16, 0, 0, 1, 112, 32, 8, 120, '2019-07-14 08:10:12', 'WR-0013B'),
(13, 14, 17, 2, 1, 0, 1, 4, 3, 0, '2019-07-15 17:20:32', 'WR-0014A'),
(14, 14, 17, 3, 2, 0, 2, 3, 2, 3, '2019-07-15 17:20:32', 'WR-0014B'),
(15, 16, 19, 2, 1, 4, 231, 123, 2, 15, '2019-07-19 18:41:21', 'WR-0016A'),
(16, 17, 20, 2, 1, 5, 231, 123, 2, 15, '2019-07-19 20:14:36', 'WR-0017A'),
(17, 18, 21, 2, 1, 0, 1, 3, 2, 3, '2019-07-20 10:28:03', 'WR-0018A');

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
  `scaffoldWorkTypeName` varchar(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `Team` varchar(100) DEFAULT NULL,
  `teamId` int(11) NOT NULL,
  `length` int(11) NOT NULL,
  `width` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `setcount` int(11) NOT NULL,
  `Volume` bigint(41) NOT NULL,
  `Productivity` decimal(45,4) DEFAULT NULL,
  `clength` int(11) NOT NULL,
  `cWidth` int(11) NOT NULL,
  `cheight` int(11) NOT NULL,
  `csetcount` int(11) NOT NULL,
  `cVolume` bigint(41) NOT NULL,
  `workerCount` int(11) NOT NULL,
  `inTime` time NOT NULL,
  `outTime` time NOT NULL,
  `WorkHr` time DEFAULT NULL,
  `TotalWorkHr` decimal(24,4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tempdwtr`
--

INSERT INTO `tempdwtr` (`workTrackId`, `subDivisionId`, `WorkRequest`, `CreatedOn`, `clientId`, `ClientName`, `projectId`, `ProjectName`, `supervisor`, `SupervisorName`, `baseSupervisor`, `BaseSupervisorName`, `workRequestId`, `scaffoldType`, `scaffoldTypeName`, `scaffoldSubCategory`, `scaffoldSubCategoryName`, `scaffoldWorkType`, `scaffoldWorkTypeName`, `Team`, `teamId`, `length`, `width`, `height`, `setcount`, `Volume`, `Productivity`, `clength`, `cWidth`, `cheight`, `csetcount`, `cVolume`, `workerCount`, `inTime`, `outTime`, `WorkHr`, `TotalWorkHr`) VALUES
(1, 1, 'WR-0001A', '2019-07-12 20:43:02', 1, 'client1', 3, 'project5', 5, 'super', 5, 'super', 1, 1, 'Tower', 0, NULL, 1, 'Erection', 'CW', 1, 1, 2, 3, 3, 18, '0.0000', 0, 0, 0, 0, 0, 3, '01:00:00', '13:12:00', '12:12:00', '36.3600'),
(2, 1, 'WR-0001A', '2019-07-12 21:26:55', 1, 'client1', 3, 'project5', 9, 'super 3', 9, 'super 3', 1, 1, 'Tower', 0, NULL, 1, 'Erection', 'CW', 1, 12, 1, 12, 12, 1728, '0.0000', 0, 0, 0, 0, 0, 12, '10:00:00', '23:30:00', '13:30:00', '159.6000');

-- --------------------------------------------------------

--
-- Table structure for table `tempproductivitydetails`
--

CREATE TABLE `tempproductivitydetails` (
  `scaffoldTypeId` int(11) NOT NULL,
  `scaffoldSubCateId` int(11) NOT NULL,
  `scaffoldSubCatName` varchar(100) NOT NULL,
  `Prod_Erection` decimal(65,4) DEFAULT NULL,
  `Prod_Dismantle` decimal(65,4) DEFAULT NULL,
  `Total_WrHr` decimal(46,4) DEFAULT NULL,
  `MaterialShifting` decimal(46,4) DEFAULT NULL,
  `HKeeping` decimal(46,4) DEFAULT NULL,
  `ProductionHr` decimal(46,4) DEFAULT NULL,
  `TypeWorkErection` varchar(100),
  `TypeWorkDismantle` int(11)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tempproductivitydetails`
--

INSERT INTO `tempproductivitydetails` (`scaffoldTypeId`, `scaffoldSubCateId`, `scaffoldSubCatName`, `Prod_Erection`, `Prod_Dismantle`, `Total_WrHr`, `MaterialShifting`, `HKeeping`, `ProductionHr`, `TypeWorkErection`, `TypeWorkDismantle`) VALUES
(2, 5, 'Perimeter (ELP- 20x1x15)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, '25', 60),
(1, 1, 'Tower (ELP- 3x3x10)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(1, 2, 'Tower (TLP- 3x3x10)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(2, 3, 'Perimeter (ELP- 10x1x15)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(2, 4, 'Perimeter (TLP- 10x1x15)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(2, 6, 'Perimeter (TLP- 20x1x15)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(2, 7, 'Perimeter (ELP->20x1x<10)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(2, 8, 'Perimeter (TLP->20x1x<10)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(2, 9, 'PERIMETER (Height >6m)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(3, 10, 'Cantilever / Truss out', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(4, 11, 'Mobile=4mH', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(4, 12, 'Mobile<=3mH', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(5, 13, 'Birdcage (3x5x10)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(5, 14, 'Birdcage (5x5x10)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(5, 15, 'Birdcage (6x6x10)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(5, 16, 'Birdcage (10x10x10)', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(6, 17, 'Hanging', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL),
(7, 18, 'Lift shaft / Riser', NULL, NULL, '195.9600', '-10.0000', NULL, NULL, NULL, NULL);

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
  MODIFY `clientId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `p_contracts`
--
ALTER TABLE `p_contracts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `p_dailyworktrack`
--
ALTER TABLE `p_dailyworktrack`
  MODIFY `worktrackId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `p_dailyworktrackmaterials`
--
ALTER TABLE `p_dailyworktrackmaterials`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `p_dailyworktracksubdivision`
--
ALTER TABLE `p_dailyworktracksubdivision`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `p_dailyworktrackteams`
--
ALTER TABLE `p_dailyworktrackteams`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `p_grade`
--
ALTER TABLE `p_grade`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `p_productivityslab`
--
ALTER TABLE `p_productivityslab`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `p_projects`
--
ALTER TABLE `p_projects`
  MODIFY `projectId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `p_scaffoldsubcatergory`
--
ALTER TABLE `p_scaffoldsubcatergory`
  MODIFY `scaffoldSubCateId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `p_scaffoldtype`
--
ALTER TABLE `p_scaffoldtype`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `p_scaffoldworktype`
--
ALTER TABLE `p_scaffoldworktype`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `p_users`
--
ALTER TABLE `p_users`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `p_workarrangement`
--
ALTER TABLE `p_workarrangement`
  MODIFY `workArrangementId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `p_workattendance`
--
ALTER TABLE `p_workattendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT for table `p_workers`
--
ALTER TABLE `p_workers`
  MODIFY `workerId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT for table `p_workerteam`
--
ALTER TABLE `p_workerteam`
  MODIFY `teamid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `p_workrequest`
--
ALTER TABLE `p_workrequest`
  MODIFY `workRequestId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `p_workrequestitems`
--
ALTER TABLE `p_workrequestitems`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `p_workrequestmanpower`
--
ALTER TABLE `p_workrequestmanpower`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `p_workrequestsizebased`
--
ALTER TABLE `p_workrequestsizebased`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
