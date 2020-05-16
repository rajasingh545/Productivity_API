<?php
/*
DB details defined here
*/

$DBINFO["USERNAME"] = "root";
$DBINFO["PASSWORD"] = "";
$MYSQLPORT = 3306;

$DBNAME["NAME"] = "v_productivity";

$TABLEINFO["USERS"] = "p_users";
$TABLEINFO["PROJECTS"] = "p_projects";
$TABLEINFO["WORKERS"] = "p_workers";
$TABLEINFO["SUPERVISORS"] = "p_supervisor";
$TABLEINFO["ATTENDANCE"] = "p_workattendance";
$TABLEINFO["WORKARRANGEMENTS"] = "p_workarrangement";
$TABLEINFO["TEAM"] = "p_workerteam";
$TABLEINFO["CLIENTS"] = "p_clients";
$TABLEINFO["CONTRACTS"] = "p_contracts";
$TABLEINFO["SCAFFOLDWORKTYPE"] = "p_scaffoldworktype";
$TABLEINFO["SCAFFOLDTYPE"] = " p_scaffoldtype";
$TABLEINFO["SCAFFOLDSUBCATEGORY"] = " p_scaffoldsubcatergory";
$TABLEINFO["WORKREQUEST"] = "p_workrequest";
$TABLEINFO["WORKREQUESTITEMS"] = "p_workrequestitems";
$TABLEINFO["WORKREQUESTSIZEBASED"] = "p_workrequestsizebased";
$TABLEINFO["WORKREQUESTMANPOWER"] = "p_workrequestmanpower";
$TABLEINFO["GRADE"] = "p_grade";
$TABLEINFO["DAILYWORKTRACK"] = "p_dailyworktrack";
$TABLEINFO["DAILYWORKTRACKSUBDIVISION"] = "p_dailyworktracksubdivision";
$TABLEINFO["DAILYWORKTRACKTEAMS"] = "p_dailyworktrackteams";
$TABLEINFO["DAILYWORKTRACKMATERIALS"] = "p_dailyworktrackmaterials";

$TABLEINFO["TRANSFERHISTORY"] = "v_transferhistory";
$TABLEINFO["PROJECTREPORT"] = "v_projectreport";
$TABLEINFO["MISATCHALERT"] = "v_misatchalert";
$SERVERS['DBHOST_MASTER'] = "localhost";
$SERVERS['DBHOST_SLAVE'] = "localhost";

?>