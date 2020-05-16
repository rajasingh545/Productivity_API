<?php
	include_once "lib/init.php";
	

class REPORTS
{
	public $common;

	function __construct(){
		global $commonObj;
		$this->common = $commonObj;
    }

    // function supervisorReport($obj){
	// 	global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
	// 	$db = new DB;
	// 	$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
	// 	$selectFileds=array("scaffoldSubCateId", "scaffoldSubCatName");
	// 	$whereClause = "scaffoldTypeId!=0";
	// 	$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["SCAFFOLDSUBCATEGORY"],$selectFileds,$whereClause);
	// 	$supervisor = 1;
	// 	$subCategoryArr = array();
	// 	if($res[1] > 0){
	// 		$resultArrArr = $db->fetchArray($res[0], 1)	;  
    //         foreach($resultArrArr as $key => $value){				
	// 			$subCategoryArr[$value["scaffoldSubCatName"]] = $this->getCategoryWiseCount($value["scaffoldSubCateId"], $supervisor);
	// 		} 
	// 	}
	// 	else{
	// 		$subCategoryArr=array(); 
	// 	}
 
	// 	return  $this->common->arrayToJson($subCategoryArr);
	// }
	// function getCategoryWiseCount($catid, $supervisor){
	// 	global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
	// 	$db = new DB;
	// 	$workTrackIds = $this->getSupervisorDailyWorkTrackIds($supervisor);
	// 	$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
	// 	$selectFileds=array("worktrackId");
	// 	$whereClause = "worktrackId IN(".$supervisor.") AND ";
	// 	$res=$db->select($dbcon, $DBNAME["NAME"], $TABLEINFO["DAILYWORKTRACK"], $selectFileds, $whereClause);
	// 	if($res[1] > 0){
	// 		$resultArrArr = $db->fetchArray($res[0], 1)	;  
    //         foreach($resultArrArr as $key => $value){

	// 		}
	// 	}


	// }

	// function getSupervisorDailyWorkTrackIds($supervisor){
	// 	$db = new DB;
	// 	$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
	// 	$selectFileds=array("worktrackId");
	// 	$whereClause = "baseSupervisor=".$supervisor;
	// 	$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$selectFileds,$whereClause);
	// 	if($res[1] > 0){
	// 		$resultArrArr = $db->fetchArray($res[0], 1)	;  
    //         foreach($resultArrArr as $value){	
	// 			$returnValue[] = $value["worktrackId"];
	// 		}
	// 	}
	// 	return implode(",",$returnValue)
	// }
	function getGrade($percentage){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("grade");		
		$whereClause = "$percentage BETWEEN gradeRangeFrom and gradeRangeTo";	
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["GRADE"],$selectFileds,$whereClause);
		$grade = "Poor";
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0]);          	
			$grade = $projectArr["grade"];
		}
		return $grade;
	}
	function dwtrReport($obj){	
	global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		// $db = new DB;
		// $dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		// $res=$db->execute_direct_query($dbcon, "CALL sp_productivityReport();");

		

		$startDate = $obj['startDate'];
		$endDate = $obj['endDate'];
		$supervisor = 	$obj['value_supervisorsel'];

		//run the store proc
		$connection = mysqli_connect("localhost", $DBINFO["USERNAME"], $DBINFO["PASSWORD"], $DBNAME["NAME"]);

		$sql = "CALL `sp_productivityReport`('$startDate', '$endDate', '$supervisor','')";
		$result = mysqli_query($connection, $sql);
		$resultset = array();
		$column = array();
		while ($row = mysqli_fetch_assoc($result)) {
			
			$resultset[] = $row;
		}
		$finalarray["column"] = array_keys($resultset[0]);
		$finalarray["resultset"] = $resultset;
		return $this->common->arrayToJson($finalarray);
	}
	function ProductivityReport($obj){	
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
			
		$startDate = $obj['startDate'];
		$endDate = $obj['endDate'];
		$supervisor = 	$obj['value_supervisorsel'];

		//run the store proc
		$connection = mysqli_connect("localhost", $DBINFO["USERNAME"], $DBINFO["PASSWORD"], $DBNAME["NAME"]);

		$sql = "CALL `sp_productivitySummaryReport`('$startDate', '$endDate', '$supervisor','')";
		$result = mysqli_query($connection, $sql);
		$resultset = array();
		$column = array();
		while ($row = mysqli_fetch_assoc($result)) {
			
			$resultset[] = $row;
		}
		$arrKeys = array_keys($resultset[0]);
		$finalarray["resultset"] = $resultset;
		
		$finalarray["column"] = array_slice($arrKeys, 2, 3);
		$rowfromColumn = array_slice($arrKeys, 5, 7);
		
		// pr($finalarray);

		$mapping["Total_WrHr"]= "Total No. of Working Hrs";
		$mapping["MaterialShifting"]= "Material Shifting";
		$mapping["HKeeping"]= "House Keeping";
		$mapping["ProductionHr"]= "Production Hrs";
		$mapping["Effective_Hr"]= "Effective Hrs";

		$mapping["Tot_ManPower_Used_8to5"]= "Total Manpower Used";
		$mapping["MaterialShiftingHrsPercent"]= "Material Shifting Hrs - 8am-9pm shift";
		// pr($resultset[0]);

		// additional rows
		$addintonalRows = array();
		foreach($rowfromColumn as $key) {
			if($mapping[$key]){
				array_push($addintonalRows, array('scaffoldSubCatName' => $mapping[$key], 'Prod_Erection'=> $resultset[0][$key]));
			}
		}

		// productive man pwr used
		$productiveManPowerUsed = 0;
		foreach($finalarray["resultset"] as $value){
			$productiveManPowerUsed = $productiveManPowerUsed + (float)$value["productivity_Erec_Slab"] + (float)$value["productivity_Dism_Slab"];
		}
		array_push($addintonalRows, array('scaffoldSubCatName' => "No/: of Pax - Productive Manpower used	
		", 'Prod_Erection'=> $productiveManPowerUsed));

		$wothoutperc = (($productiveManPowerUse/$resultset[0]["Total_WrHr"])*100);
		$wothoutperc = round($wothoutperc, 2);
		array_push($addintonalRows, array('scaffoldSubCatName' => "Without deduct any hours", 'Prod_Erection'=> $wothoutperc."%"));

	//percentage
		$percentage = (float)(($productiveManPowerUsed / $resultset[0]["Tot_ManPower_Used_8to5"])*100);
		$percentage = round($percentage, 2);
		array_push($addintonalRows, array('scaffoldSubCatName' => "Percentage", 'Prod_Erection'=> $percentage."%"));
		//grade
		array_push($addintonalRows, array('scaffoldSubCatName' => "Grade", 'Prod_Erection'=> $this->getGrade($percentage)));
		$finalarray["resultset"] = array_merge($finalarray["resultset"],$addintonalRows);
		
		
		
		return $this->common->arrayToJson($finalarray);
		}
}