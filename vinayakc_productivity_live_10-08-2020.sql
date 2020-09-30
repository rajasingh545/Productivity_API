-- phpMyAdmin SQL Dump
-- version 4.9.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Aug 10, 2020 at 07:54 PM
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
  `modifiedBy` int(11) NOT NULL DEFAULT '0',
  `type` varchar(11) NOT NULL,
  `address` varchar(100) NOT NULL,
  `tel1` varchar(15) NOT NULL,
  `fax` varchar(15) NOT NULL,
  `attn1` varchar(100) NOT NULL,
  `emailaddress` varchar(50) NOT NULL,
  `hpdid` varchar(100) NOT NULL,
  `attn2` varchar(100) NOT NULL,
  `emailaddress1` varchar(50) NOT NULL,
  `hpdid2` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `supervisor` text NOT NULL,
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

-- --------------------------------------------------------

--
-- Table structure for table `p_dailyworktracksubdivision`
--

CREATE TABLE `p_dailyworktracksubdivision` (
  `id` int(11) NOT NULL,
  `workTrackId` int(11) NOT NULL,
  `workRequestId` int(11) NOT NULL,
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

-- --------------------------------------------------------

--
-- Table structure for table `p_dwtrPhotos`
--

CREATE TABLE `p_dwtrPhotos` (
  `id` int(11) NOT NULL,
  `DWTRId` int(11) NOT NULL,
  `WRSubdivision` int(11) NOT NULL DEFAULT '0',
  `photo_1` varchar(100) NOT NULL,
  `photo_2` varchar(100) NOT NULL,
  `photo_3` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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

-- --------------------------------------------------------

--
-- Table structure for table `p_material`
--

CREATE TABLE `p_material` (
  `id` int(11) NOT NULL,
  `materialName` text NOT NULL,
  `status` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

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
  `modifiedOn` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `project` int(11) NOT NULL,
  `client` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `createdOn` datetime NOT NULL,
  `clients` varchar(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `startTime` time NOT NULL,
  `endTime` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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

-- --------------------------------------------------------

--
-- Table structure for table `p_scaffoldtype`
--

CREATE TABLE `p_scaffoldtype` (
  `id` int(11) NOT NULL,
  `scaffoldName` varchar(100) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `p_scaffoldworktype`
--

CREATE TABLE `p_scaffoldworktype` (
  `id` int(11) NOT NULL,
  `scaffoldName` varchar(100) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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

-- --------------------------------------------------------

--
-- Table structure for table `p_workarrangement`
--

CREATE TABLE `p_workarrangement` (
  `workArrangementId` int(11) NOT NULL,
  `projectId` int(11) NOT NULL,
  `baseSupervsor` int(11) NOT NULL,
  `addSupervsor` text NOT NULL,
  `createdOn` datetime NOT NULL,
  `createdBy` int(11) NOT NULL,
  `remarks` text NOT NULL,
  `status` tinyint(1) NOT NULL,
  `attendanceStatus` tinyint(1) NOT NULL DEFAULT '0',
  `attendanceRemark` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `isSupervisor` tinyint(1) NOT NULL DEFAULT '0',
  `draftStatus` tinyint(1) DEFAULT '2' COMMENT '1 - submitted, 2 - draft'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `project` text,
  `homeLeave` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1 - Not Leave, 2 - Home Leave'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `status` tinyint(1) NOT NULL,
  `drawingAttach` tinyint(1) DEFAULT NULL,
  `drawingImage` varchar(100) DEFAULT NULL,
  `completionImages` text,
  `location` text
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  MODIFY `clientId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_contracts`
--
ALTER TABLE `p_contracts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_dailyworktrack`
--
ALTER TABLE `p_dailyworktrack`
  MODIFY `worktrackId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_dailyworktrackmaterials`
--
ALTER TABLE `p_dailyworktrackmaterials`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_dailyworktracksubdivision`
--
ALTER TABLE `p_dailyworktracksubdivision`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_dailyworktrackteams`
--
ALTER TABLE `p_dailyworktrackteams`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_grade`
--
ALTER TABLE `p_grade`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_material`
--
ALTER TABLE `p_material`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_productivityslab`
--
ALTER TABLE `p_productivityslab`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_projects`
--
ALTER TABLE `p_projects`
  MODIFY `projectId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_scaffoldsubcatergory`
--
ALTER TABLE `p_scaffoldsubcatergory`
  MODIFY `scaffoldSubCateId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_scaffoldtype`
--
ALTER TABLE `p_scaffoldtype`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_scaffoldworktype`
--
ALTER TABLE `p_scaffoldworktype`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_users`
--
ALTER TABLE `p_users`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_workarrangement`
--
ALTER TABLE `p_workarrangement`
  MODIFY `workArrangementId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_workattendance`
--
ALTER TABLE `p_workattendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_workers`
--
ALTER TABLE `p_workers`
  MODIFY `workerId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_workerteam`
--
ALTER TABLE `p_workerteam`
  MODIFY `teamid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_workrequest`
--
ALTER TABLE `p_workrequest`
  MODIFY `workRequestId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_workrequestitems`
--
ALTER TABLE `p_workrequestitems`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_workrequestmanpower`
--
ALTER TABLE `p_workrequestmanpower`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `p_workrequestsizebased`
--
ALTER TABLE `p_workrequestsizebased`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;


