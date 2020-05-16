<?php
	include_once "lib/init.php";
	

class REQUESTS
{
	public $common;

	function __construct(){
		global $commonObj;
		$this->common = $commonObj;
	}
	
	function getWorkArrangementList($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("workArrangementId","projectId","baseSupervsor","addSupervsor","createdOn","remarks");
		if($postArr["startDate"] && $postArr["startDate"]!=""){
			$addCond = "createdOn='".$postArr["startDate"]."'";
		}
		else{
			$addCond = "createdOn='".date("Y-m-d")."'";
		}		
		$whereClause = "status=".$postArr["requestType"]." AND $addCond order by workArrangementId desc";		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFileds,$whereClause);
		$results = array();
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0], 1);
			foreach($projectArr as $key=>$det){
				$whereClause2 = "workArrangementId=".$det["workArrangementId"];
				$selectFileds2 = array("workerId");
				$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds2,$whereClause2);
				$listingDetails = array();
				if($res2[1] > 0){
					$workerids = $db->fetchArray($res2[0],1); 
					$workeridFinal = array();;
					foreach($workerids as $ids){
						$workeridFinal[] = $ids["workerId"];
					}

					$results[$key] =  $det;
					$results[$key]["workers"] = $workeridFinal;

				}    
			}      	
	
		}
		else{
			$results = array(); 
		}

		
		return $this->common->arrayToJson($results);
	}
	function getWorkArrangementDetails($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("workArrangementId","projectId","baseSupervsor","addSupervsor", "createdOn", "remarks");		
		$whereClause = "workArrangementId=".$postArr["listingId"];		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFileds,$whereClause);
		$results = array();
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0]);
			
				$whereClause2 = "workArrangementId=".$projectArr["workArrangementId"];
				$selectFileds2 = array("workerId","partial");
				$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds2,$whereClause2);
				$listingDetails = array();
				if($res2[1] > 0){
					$workerids = $db->fetchArray($res2[0],1); 
					$workeridFinal = array();
					$partialWorkers = array();
					foreach($workerids as $ids){
						$workeridFinal[] = $ids["workerId"];
						if($ids["partial"] == 1){
							$partialWorkers[] = $ids["workerId"];
						}
					}

				
					$projectArr["workers"] = $workeridFinal;
					$projectArr["partialWorkers"] = $partialWorkers;

				}    
			      	
	
		}
		else{
			$projectArr = array(); 
		}

		
		return $this->common->arrayToJson($projectArr);
	}

	function updateWorkArranmentsStatus($obj){
			// foreach(ob)
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$dbm = new DB;
			// pr($obj);
			$arr = array();
			foreach($obj["ids"] as $val){
				array_push($arr, $val);
			}

			$ids = implode(",", $arr);
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$whereClause="workArrangementId IN(".$ids.")";
		$updateArr["status"] = 1;
		$insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$updateArr,$whereClause);
		$returnval["response"] ="success";
		$returnval["responsecode"] = 1; 
		return $this->common->arrayToJson($returnval);
		   
	}
	function updateWorkArranments($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
       
        $insertArr["projectId"]=trim($postArr["value_projects"]);
        $insertArr["baseSupervsor"]=trim($postArr["value_supervisors"]);
        $insertArr["addSupervsor"]=trim($postArr["value_supervisors2"]);
        
		$insertArr["createdOn"]=trim($postArr["startDate"]);
		$insertArr["remarks"]=trim($postArr["remarks"]);
		
        
        $dbm = new DB;
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$whereClause = "workArrangementId = ".$postArr["listingId"];
        $insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$insertArr,$whereClause);
		
		$deleteCount = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$whereClause);
		// if($deleteCount > 0){
			foreach($postArr["workerIds"] as $value){
				$arr = explode("-", trim($value));
				$insertArr2 = array();
				$insertArr2["workArrangementId"]=$postArr["listingId"];       
				$insertArr2["workerId"]=$arr[0];     
				$insertArr2["workerTeam"]=$arr[1];       
				$insertArr2["forDate"]=$postArr["startDate"];
				$insertArr2["createdOn"]=date("Y-m-d H:i:s");
				
					if(in_array(trim($value), $postArr["partialWorkers"])){
						$insertArr2["partial"]=1;     
					}
				
				
				$insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$insertArr2,1,2);
				// pr($dbm);
			}
		// }
		
		
        $dbm->dbClose();
       
            
            $returnval["response"] ="success";
			$returnval["responsecode"] = 1; 
			$returnval["requestID"] = $requestNumber; 
            
           
		
		return $this->common->arrayToJson($returnval);
	}	

	function getProjectAttendance($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$selectFileds=array("workArrangementId","attendanceRemark");
		$dbcon = $db->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		if($postArr["requestType"] == 1){ // if edit
			$whereClause = "workArrangementId = ".$postArr["listingId"]." and projectId = ".$postArr["projectId"]." and status = 1";
		}	
		else{
			if($postArr["startDate"]){
				$whereClause = "projectId = ".$postArr["projectId"]." and status = 1 and createdOn='".$postArr["startDate"]."'";
			}
			else{
				$whereClause = "projectId = ".$postArr["projectId"]." and status = 1 and createdOn='".date("Y-m-d")."'";
			}
		}
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFileds,$whereClause);
		$workeridFinal = array();
		if($res[1] > 0){
			$details = $db->fetchArray($res[0]); 

			$selectFileds2=array("workArrangementId","workerId","inTime","outTime","workerTeam", "reason", "status","statusOut");
			$dbcon = $db->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
			$whereClause2 ="workArrangementId= ".$details["workArrangementId"]." order by workerTeam";
			// $whereClause2 ="workArrangementId= ".$details["workArrangementId"]." AND ((partial = 0) OR (partial=1 AND statusOut = 1)) order by workerTeam";
			// if($postArr["userType"] == 5){ //exclude submitted list for supervisor
			// 	$whereClause2 ="workArrangementId= ".$details["workArrangementId"]." order by workerTeam";
			// }

			
			$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds2,$whereClause2);

			if($res2[1] > 0){
				$workerids = $db->fetchArray($res2[0],1); 
				$i = 0;
				foreach($workerids as $ids){
					
					$workeridFinal[$i] = $ids;
					$workeridFinal[$i]["remarks"] = $details["attendanceRemark"];
					$i++;
				}

			}    
			
		}
		return $this->common->arrayToJson($workeridFinal);	

	}
	function getSubmittedAttendanceList($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$selectFileds=array("workArrangementId","projectId", "createdOn","createdBy");
		$dbcon = $db->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		if($postArr["startDate"]){
			$whereClause = "attendanceStatus = '1' and status = 1 and createdOn='".$postArr["startDate"]."'";
		}
		else{
			$whereClause = "attendanceStatus = '1' and status = 1 and createdOn='".date("Y-m-d")."'";
		}
		// echo $whereClause;
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFileds,$whereClause);
		$workeridFinal = array();
		if($res[1] > 0){
			$details = $db->fetchArray($res[0], 1); 

			
			
		}
		else{
			$details = array();
		}
		return $this->common->arrayToJson($details);	

	}

	function updateAttendance($postArr){

		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$dbm = new DB;
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		foreach($postArr["finalValuesArr"] as $workerid => $val){
			if($val != ""){
				$arr = explode("-", trim($workerid));
				$whereClause="workArrangementId=".$postArr["WAId"]." and workerId=".$arr[0];
				if($val["IN"] != "")
					$updateArr["inTime"] = $val["IN"];

				if($val["OUT"] != "")
					$updateArr["outTime"] = $val["OUT"];

				if($val["reason"] != "")
					$updateArr["reason"] = $val["reason"];

				if($postArr["selectedOption"] == 1)
					$updateArr["status"] = $postArr["type"];
				if($postArr["selectedOption"] == 2)
					$updateArr["statusOut"] = $postArr["type"];

					if($postArr["userType"] == 1){
						$updateArr["status"] = $postArr["type"];
						$updateArr["statusOut"] = $postArr["type"];
					}

				$insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$updateArr,$whereClause);

			}
				
		}
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$whereClause = "workArrangementId = ".$postArr["WAId"];
		$updateArr2["attendanceRemark"] = $postArr["remarks"];
		if($postArr["type"] == 1){
			$updateArr2["attendanceStatus"] = $postArr["type"];
		}
		$insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$updateArr2,$whereClause);
		

			
		
		$returnval["response"] ="success";
		$returnval["responsecode"] = 1; 
		return $this->common->arrayToJson($returnval);

	}
	function workArrangementsExists($projectid, $date){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$selectFileds=array("workArrangementId");
		$dbcon = $db->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$whereClause = "projectId = ".$projectid." and createdOn='".$date."'";

		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFileds,$whereClause);
		
		if($res[1] > 0){
			return true;
		}
		else{
			return false;
		}
	}
	function createWorkArranments($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$proectExist = $this->workArrangementsExists(trim($postArr["value_projects"]), trim($postArr["startDate"]));
		if($proectExist == false){ 
       
			$insertArr["projectId"]=trim($postArr["value_projects"]);
			$insertArr["baseSupervsor"]=trim($postArr["value_supervisors"]);
			$insertArr["addSupervsor"]=trim($postArr["value_supervisors2"]);
			$insertArr["createdBy"]=trim($postArr["userId"]);
			$insertArr["createdOn"]=trim($postArr["startDate"]);
			$insertArr["remarks"]=trim($postArr["remarks"]);
			$insertArr["status"]=trim($postArr["status"]);		
			
			$dbm = new DB;
			$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
			
			$insid = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$insertArr,1,2);
			
			// tracking supervisor attendance
			$this->insertSupervisorAttendance($insid, $postArr["value_supervisors"], $postArr["startDate"]);
			$this->insertSupervisorAttendance($insid, $postArr["value_supervisors2"], $postArr["startDate"]);

			//tracking wrokers attendance
			foreach($postArr["workerIds"] as $value){
				$insertArr2 = array();
				$insertArr2["workArrangementId"]=$insid;
				$arr = explode("-", trim($value));
				$insertArr2["workerId"]=$arr[0];   
				$insertArr2["workerTeam"]=$arr[1];       
				$insertArr2["forDate"]=trim($postArr["startDate"]);
				$insertArr2["createdOn"]=date("Y-m-d H:i:s");
				if(in_array(trim($value), $postArr["partialWorkers"])){
					$insertArr2["partial"]=1;     
				}
				
				$insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$insertArr2,1,2);
				// pr($dbm);
			}
			
			
			$dbm->dbClose();
			if($insid == 0 || $insid == ''){ 
				$returnval["response"] ="fail";
				$returnval["responsecode"] = 0; 
			}else { 
				
				$returnval["response"] ="success";
				$returnval["responsecode"] = 1; 
				$returnval["requestID"] = $requestNumber; 
				
				}
		}else{
			$returnval["response"] ="fail";
               $returnval["responsecode"] = 2; //already exists
		}
			
		
		
		return $this->common->arrayToJson($returnval);
	}
		
	function insertSupervisorAttendance($insid, $supervisor, $startDate){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$dbm = new DB;
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$ins = array();
		$ins["workArrangementId"]=$insid;
		$ins["workerId"]=$supervisor;       
		$ins["forDate"]=$startDate;
		$ins["createdOn"]=date("Y-m-d H:i:s");
		$ins["isSupervisor"] = 1;
		$insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$ins,1,2);
		
	}
	

	
}

?>