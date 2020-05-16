<?php
	include_once "lib/init.php";

class commonAPI
{
	public $common;

	function __construct(){
		global $commonObj;
		$this->common = $commonObj;
	}

	function commonAPIs($obj){
		
        $allDetails = array();
		$allDetails["projects"] = $this->projectDetails($obj);
		$allDetails["workers"] = $this->workerDetails();
		$allDetails["team"] = $this->teamDetails($obj);
		$allDetails["clients"] = $this->cleintDetails($obj);
		$allDetails["scaffoldType"] = $this->scaffoldTypeDetails($obj);
		$allDetails["scaffoldWorkType"] = $this->scaffoldWorkTypeDetails($obj);
		$allDetails["clientsProjectMapping"] = $this->cleintProjectMapping($obj);
		
        // $allDetails["supervisors"] = $this->supervisorDetails();
        // $allDetails["category"] = $this->categoryDetails();
        $allDetails["subCategory"] = $this->subCategoryDetails();
		$allDetails["supervisorsList"] = $this->allSupervisorDetails();
		$allDetails["workRequestList"] = $this->getWorkRequestIDList();
		// $allDetails["allprojects"] = $this->allProjectDetails();
		// $allDetails["requestDetails"] = $this->requestDetails();
        
		return $this->common->arrayToJson($allDetails);
	}
    function projectDetails($obj){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("projectId","projectName");		
		$whereClause = "projectStatus='1'";	
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["PROJECTS"],$selectFileds,$whereClause);
		
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0], 1);          	
			
		}
		else{
			$projectArr = array(); 
		}
 
		return $projectArr;
	}
	function teamDetails($obj){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("teamid","teamName");		
		$whereClause = "status='1'";	
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["TEAM"],$selectFileds,$whereClause);
		
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0], 1);          	
			
		}
		else{
			$projectArr = array(); 
		}
 
		return $projectArr;
	}
	function cleintDetails($obj){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("clientId","clientName", "projects");		
		$whereClause = "status='1'";	
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["CLIENTS"],$selectFileds,$whereClause);
		$finalArr = array();
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0], 1);     
			
			
		}
		
//  pr($finalArr);
//  pr($projectArr);
		return $projectArr;
	}
	function cleintProjectMapping($obj){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("clientId","clientName", "projects");		
		$whereClause = "status='1'";	
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["CLIENTS"],$selectFileds,$whereClause);
		$finalArr = array();
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0], 1);     
			
			foreach($projectArr as $pro){
				$projectArr[$pro["projects"]] = $pro;
				
			}       	 
			
		}
		
//  pr($finalArr);
//  pr($projectArr);
		return $projectArr;
	}
	function allProjectDetails($obj){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("projectId","projectName");
		
		$whereClause = "projectStatus='1'";
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["PROJECTS"],$selectFileds,$whereClause);
		
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0], 1);          	
			
		}
		else{
			$projectArr = array(); 
		}
 
		return $projectArr;
	}
	function getSupervisorProjects($uid){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$selectFileds=array("projects");
		$whereClause = "userId=$uid";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFileds,$whereClause);
		
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0]);          	
			
		}
		else{
			$projectArr = array(); 
		}
		return $projectArr["projects"];
	}
    function workerDetails(){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("workerName","workerId", "teamId");
		$whereClause = "status=1";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKERS"],$selectFileds,$whereClause);
		
		
		$newWorkerArr = array();	
		if($res[1] > 0){
			$driverArr = $db->fetchArray($res[0], 1); 
					
			foreach($driverArr as $key => $val){
				$newWorkerArr[$key]["workerName"] = $val["workerName"];
				$newWorkerArr[$key]["workerId"] = $val["workerId"]."-".$val["teamId"];
				$newWorkerArr[$key]["workerIdActual"] = $val["workerId"];
			}  
			
		}
		else{
			$newWorkerArr=array(); 
		}
 
		return $newWorkerArr;
	}
	function availableWorkerDetails($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$whereClauseat = "forDate='".date("Y-m-d")."' and partial=0";
		$selectFiledsat=array("workerId");
		if($postArr["startDate"] != ""){
			$whereClauseat = "forDate='".$postArr["startDate"]."' and partial=0";
		}
		// echo $whereClauseat;
		$resat=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFiledsat,$whereClauseat);
		if($resat[1] > 0){
			$workerIds = $db->fetchArray($resat[0], 1);  
			$assignedWorkers = array();
			foreach($workerIds as $worker){
				array_push($assignedWorkers, $worker["workerId"]);
			}        	
			
		}
		else{
			$assignedWorkers =array();
		}

		$selectFileds=array("workerName","workerId","teamId");
		if(count($assignedWorkers) > 0){
			$whereClause = "status=1 and workerId NOT IN(".implode(",",$assignedWorkers).")";
		}
		else{
			$whereClause = "status=1";
		}
		// echo $whereClause;
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKERS"],$selectFileds,$whereClause);
		
		$newWorkerArr = array();
		if($res[1] > 0){
			$driverArr = $db->fetchArray($res[0], 1);  
			// pr($driverArr);
			foreach($driverArr as $key => $val){
				$newWorkerArr[$key]["workerName"] = $val["workerName"];
				$newWorkerArr[$key]["workerId"] = $val["workerId"]."-".$val["teamId"];
				$newWorkerArr[$key]["workerIdActual"] = $val["workerId"];
			}  
			// pr($newWorkerArr);
		}
		else{
			$newWorkerArr=array(); 
		}
		$avalableWorker["availableWorkers"] = $newWorkerArr;
		return $this->common->arrayToJson($avalableWorker);
	}
	function allSupervisorDetails(){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("userId","Name");
		
		$whereClause = "userStatus=1 and userType=5";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFileds,$whereClause);
		
		$vehiclesArr = array();
		if($res[1] > 0){
			$vehiclesArr = $db->fetchArray($res[0], 1);          	
			
		}
		else{
			$vehiclesArr=array(); 
		}
		
		return $vehiclesArr;
	}

	
    function supervisorDetails($pid, $postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		

		$whereClauseat = "forDate='".date("Y-m-d")."' and isSupervisor=1";
		$selectFiledsat=array("workerId");
		if($postArr["startDate"] != ""){
			$whereClauseat = "forDate='".$postArr["startDate"]."' and isSupervisor=1";
		}
		// echo $whereClauseat;
		$resat=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFiledsat,$whereClauseat);
		if($resat[1] > 0){
			$workerIds = $db->fetchArray($resat[0], 1);  
			$assignedWorkers = array();
			foreach($workerIds as $worker){
				array_push($assignedWorkers, $worker["workerId"]);
			}        	
			
		}
		else{
			$assignedWorkers =array();
		}

		$selectFileds=array("userId","Name");
		
		if(count($assignedWorkers) > 0){

		$whereClause = "project like '%$pid%' and userStatus=1 and userId NOT IN(".implode(",",$assignedWorkers).")";
		}
		else{
			$whereClause = "project like '%$pid%' and userStatus=1 ";
		}
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFileds,$whereClause);
		
		$vehiclesArr = array();
		if($res[1] > 0){
			$vehiclesArr["supervisors"] = $db->fetchArray($res[0], 1);          	
			
		}
		else{
			$vehiclesArr["supervisors"]=array(); 
		}
		
		return $this->common->arrayToJson($vehiclesArr);
	}
    function categoryDetails(){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("categoryId","categoryName");
		$whereClause = "categoryStatus='1'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["CATEGORY"],$selectFileds,$whereClause);
		
		$categoryArr = array();
		if($res[1] > 0){
			$categoryArr = $db->fetchArray($res[0], 1);
		}
		else{
			$categoryArr=array();
		}
 
		return $categoryArr;
	}
	function requestDetails($projectId){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("requestId","createdOn","requestStatus","requestNumber");
		$whereClause = "requestStatus >= 3 AND requestStatus <= 5 AND notificationType=1 and projectIdFrom=".$projectId;
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$selectFileds,$whereClause);
		
		$categoryArr = array();
		$doNumbers = array();
		if($res[1] > 0){
			$categoryArr = $db->fetchArray($res[0], 1);
			foreach($categoryArr as $key=>$value){
				 $doNumbers[$key]["requestNo"] = $value["requestNumber"];
					$doNumbers[$key]["requestId"] = $value["requestId"];

					$selectFileds=array("requestId","categoryId","subCategoryId","quantityRequested");
					$whereClause2 = "requestId=".$value["requestId"];
					if($value["requestStatus"] == 3){
						$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["MATREQUEST"],$selectFileds,$whereClause2);
					}
					else{
						$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$selectFileds,$whereClause2);
					}
					// pr($res2);
					$results = $db->fetchArray($res2[0], 1);
					$requestarr = array(); 
					foreach($results as $request){
						$uniqueid = $request["categoryId"]."-".$request["subCategoryId"];
						$requestarr[$uniqueid] = $request["quantityRequested"];
						$doNumbers[$key]["requests"] = $requestarr;
					}
			}
		}
		else{
			$doNumbers=array();
		}
		
		
 
		return $this->common->arrayToJson($doNumbers);
	}
	function idGenerator($id, $date){
		$month = date("m", strtotime($date));
		return $month."/".sprintf("%'.04d\n", $id);
	
	}
    function subCategoryDetails(){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("scaffoldTypeId", "scaffoldSubCateId", "scaffoldSubCatName");
		$whereClause = "scaffoldTypeId!=0";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["SCAFFOLDSUBCATEGORY"],$selectFileds,$whereClause);
		
		$subCategoryArr = array();
		if($res[1] > 0){
			$resultArrArr = $db->fetchArray($res[0], 1)	;  
            foreach($resultArrArr as $key => $value){
				if(count($subCategoryArr[$value["scaffoldTypeId"]]) > 0)
					$subCategoryArr[$value["scaffoldTypeId"]]= array_merge($subCategoryArr[$value["scaffoldTypeId"]], array($key => $value));
				else
					$subCategoryArr[$value["scaffoldTypeId"]][]=$value;
			} 
		}
		else{
			$subCategoryArr=array(); 
		}
 
		return $subCategoryArr;
	}
	function usersDetails(){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("Name","userId");
		$whereClause = "userStatus='1'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFileds,$whereClause);
		
		$usersArr = array();
		if($res[1] > 0){
			$usersArr = $db->fetchArray($res[0], 1);
		}
		else{
			$usersArr=array(); 
		}
 
		return $usersArr;
	}
	function scaffoldTypeDetails(){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("id","scaffoldName");
		$whereClause = "status='1'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["SCAFFOLDTYPE"],$selectFileds,$whereClause);
		
		$usersArr = array();
		if($res[1] > 0){
			$usersArr = $db->fetchArray($res[0], 1);
		}
		else{
			$usersArr=array(); 
		}
 
		return $usersArr;
	}
	function scaffoldWorkTypeDetails(){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("id","scaffoldName");
		$whereClause = "status='1'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["SCAFFOLDWORKTYPE"],$selectFileds,$whereClause);
		
		$usersArr = array();
		if($res[1] > 0){
			$usersArr = $db->fetchArray($res[0], 1);
		}
		else{
			$usersArr=array(); 
		}
 
		return $usersArr;
	}

	function getWorkRequestIDList(){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("workRequestId");
		$whereClause = "status='1'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$selectFileds,$whereClause);
		
		$usersArr = array();
		$listArr = array();
		if($res[1] > 0){

			
			$usersArr = $db->fetchArray($res[0], 1);
			foreach($usersArr as $key=>$item){
				$invID = str_pad($item["workRequestId"], 4, '0', STR_PAD_LEFT);
				$listArr[$key]["workRequestId"] = $item["workRequestId"];
				$listArr[$key]["workRequestIdStr"] = "WR".$invID;
			}
		}
		else{
			$listArr=array(); 
		}
 
		return $listArr;
	}

	function getContracts($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("id","description","item","location","length","height","width","sets");
		$whereClause = "projectId=".$postArr["value_projects"]." and clientId=".$postArr["value_clients"];
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["CONTRACTS"],$selectFileds,$whereClause);
		
		$usersArr = array();
		if($res[1] > 0){
			$i=0;
			$usersArr2 = $db->fetchArray($res[0], 1);
			foreach($usersArr2 as $item){

				$usersArr["contracts"][$i] = $item;
				$usersArr["contracts"][$i]["desc"] = trim($item["description"])." at ".$item["location"].", Size: ".$item["length"]."mL x ".$item["width"]."mW x ".$item["height"]."mH, Set:".$item["sets"];
				$i++;
			}
		}
		else{
			$usersArr["contracts"] = array(); 
		}
 
		return $this->common->arrayToJson($usersArr);
	}
	function getContractsDesc($id){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("id","description","item","location","length","height","width","setCount");
		$whereClause = "id=".$id;
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["CONTRACTS"],$selectFileds,$whereClause);
		// pr($db);
		$usersArr = array();
		if($res[1] > 0){
			
			$item = $db->fetchArray($res[0]);

			$usersArr["contractsname"] = $item["item"];
			$usersArr["desc"] = trim($item["description"])." at ".$item["location"].", Size: ".$item["length"]."mL x ".$item["width"]."mW x ".$item["height"]."mH";
		
		}
		else{
			$usersArr = array(); 
		}
 
		return $usersArr;
	}

	function getWorkRequestList($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("workRequestId","requestedBy");		
		$whereClause = "projectId=".$postArr["value_projects"]." and clientId=".$postArr["value_clients"];
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$selectFileds,$whereClause);
		// pr($db);
		$listArr = array();
		$resultArrr["workRequests"] = array();
		$resultArrr["items"] = array();
		if($res[1] > 0){
			$listArr = $db->fetchArray($res[0], 1);

			$resultArrr["workRequests"] = $listArr;

			foreach($listArr as $key => $val){
				$invID = str_pad($val["workRequestId"], 4, '0', STR_PAD_LEFT);
				$resultArrr["workRequests"][$key]["workRequestId"] = $val["workRequestId"];
				$resultArrr["workRequests"][$key]["workRequestStrId"] = "WR".$invID;
				$resultArrr["workRequests"][$key]["requestedBy"] = $val["requestedBy"];
			}
			foreach($listArr as $works){
				$selectFileds2=array("id","ItemUniqueId","length","height","width","scaffoldType","setcount");		
				$whereClause2 = "workRequestId=".$works["workRequestId"];
				
				$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTSIZEBASED"],$selectFileds2,$whereClause2);
				// pr($db);
				$listArr = array();
				if($res2[1] > 0){
					$items = $db->fetchArray($res2[0], 1);
					
					foreach($items as $item){
						$desc = "WR: ".$item["length"]."mL x ".$item["width"]."mW x ".$item["height"]."mH"." x ".$item["setcount"];
						$resultArrr["items"][$works["workRequestId"]][] = array("itemId"=>$item["id"], "itemName"=>$item["ItemUniqueId"],"type"=>"1","desc"=>$desc,"requestBy"=>$works["requestedBy"]);
						// $itemDesc = $this->getContractsDesc($item["itemId"]);
						// $resultArrr["items"][$works["workRequestId"]][] = array("itemId"=> $item["itemId"], "itemName"=> $itemDesc["contractsname"], "itemDesc"=>$itemDesc["desc"] );
						// $resultArrr["items"][$works["workRequestId"]]["itemId"] = $item["itemId"];
						// $resultArrr["items"][$works["workRequestId"]]["itemName"] = $itemDesc["contractsname"];
						// $resultArrr["items"][$works["workRequestId"]]["itemDesc"] = $itemDesc["desc"];
					}

				}
				$res3=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTSIZEBASED"],$selectFileds2,$whereClause2);

				if($res2[1] > 0){
					$items2 = $db->fetchArray($res2[0], 1);
					
					foreach($items2 as $item2){
						
						$resultArrr["items"][$works["workRequestId"]] = array("itemId"=>$item2["id"], "itemName"=>$item2["ItemUniqueId"], "type"=>"2");
						
					}

				}
			}
		}
		// pr($usersArr);
 
		return $this->common->arrayToJson($resultArrr);
    }
    
}

?>
