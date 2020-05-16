<?php
	include_once "lib/init.php";
	

class REQUESTS
{
	public $common;

	function __construct(){
		global $commonObj;
		$this->common = $commonObj;
	}
    function requestDetails($requestStatus, $obj){
// 		error_reporting(E_ALL);
// ini_set("display_errors",1);
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("requestId","createdBy","notificationType","projectIdFrom","requestStatus","createdOn","projectIdTo", "notificationNumber","requestNumber");
		// $userCond = "";
		// if($obj["userType"] != 1){
		// 	$userCond = "AND createdBy=".$obj["userId"];
		// }
		$whereClause = "requestStatus=".$requestStatus." order by requestId desc";
		if($obj["userType"] == "5"){
			// $whereClause = "requestId='".$value."' ;
			$whereClause = "requestStatus=".$requestStatus." and (projectIdFrom=".$obj["projectId"]." OR  projectIdTo=".$obj["projectId"].") order by requestId desc";
		}
		else{
			if($obj["userType"] == "3" && $obj["requestStatus"] == "3"){
				$whereClause = "requestStatus IN (3,12) order by requestId desc";
				// $whereClause = "requestStatus=".$requestStatus." order by requestId desc";
			}
			else{
				$whereClause = "requestStatus=".$requestStatus." order by requestId desc";
			}
		}
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$selectFileds,$whereClause);
		
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0], 1);          	
			
		}
		else{
			$projectArr = array(); 
		}

		$results = $projectArr;
		// if($requestStatus == "3"){
			foreach($projectArr as $key=>$value){
					
					$results[$key] = $value;
					// $results[$key]["REQID"] = $this->getDONumbers($value["requestId"]);
					$results[$key]["formattedReqID"] = $this->idGenerator($value["requestId"],$value["createdOn"]);
			}
		// }
		// pr($results);
 		// $results[$key]["REQID"] = 
		return $this->common->arrayToJson($results);
	}
	function getListings($requestStatus, $obj){
		
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("requestId");
		if($obj["userType"] == 1 && $obj["requestStatus"] == 4){
			$whereClause = "requestStatus IN (4, 14) order by requestId desc";
		}
		else{
			if($obj["userType"] == 4){//if driver login
				$whereClause = "requestStatus=".$requestStatus." and driverId=".$obj["userId"]." order by requestId desc";
				
			}
			else{
				$whereClause = "requestStatus=".$requestStatus." order by requestId desc";
			}
		}
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$selectFileds,$whereClause);
		
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0], 1);          	
			
		}
		else{
			$projectArr = array(); 
		}
		foreach($projectArr as $k=>$val){
			$uniqueReqId[$k] = $val["requestId"];
		}
			// pr($projectArr);

			if($obj["userType"] != 1){
				$userCond = "AND createdBy=".$obj["userId"];
			}
		
		$projectArr = array_unique($uniqueReqId);
		$results = array();
	
			$key = 0;
			foreach($projectArr as $k=>$value){
					$selectFileds=array("requestId","createdBy","notificationType","projectIdFrom","requestStatus","createdOn","projectIdTo", "notificationNumber","requestNumber");
					if($obj["userType"] == "5"){
						$whereClause = "requestId='".$value."' and (projectIdFrom=".$obj["projectId"]." OR  projectIdTo=".$obj["projectId"].")";
					}
					else{
						$whereClause = "requestId='".$value."'";
					}
					
					$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$selectFileds,$whereClause);
					$listingDetails = array();
					if($res2[1] > 0){
						$listingDetails = $db->fetchArray($res2[0]); 

						$results[$key] = $listingDetails;
						$results[$key]["REQID"] = $this->getDONumbers($value,$requestStatus, $obj["userType"]);
						$results[$key]["formattedReqID"] = $this->idGenerator($value,$listingDetails["createdOn"]);
						$key++;
					}	
								
					
			}
		
		return $this->common->arrayToJson($results);

	}
	
	function getDONumbers($requestId, $requestStatus, $userType){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$selectFileds=array("DONumber","createdOn","requestStatus");
		if($userType == 1 && $requestStatus == 4){
			$whereClause = "requestId=".$requestId." AND requestStatus IN (4, 14)";
		}
		else{
			$whereClause = "requestId=".$requestId." AND requestStatus=".$requestStatus;
		}
		$res1=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$selectFileds,$whereClause);
		$doNumbers = array();
		if($res1[1] > 0){
			$doresult = $db->fetchArray($res1[0], 1);		
			$i = 0;
			foreach($doresult as $dovalue){
				$doNumbers[$dovalue["DONumber"]]["id"] = $this->idGenerator($dovalue["DONumber"], $dovalue["createdOn"]);
				$doNumbers[$dovalue["DONumber"]]["requestStatus"] =$dovalue["requestStatus"];
				$i++;
			}
		}
		return $doNumbers;
	}
	function idGenerator($id, $date){
		$month = date("y/m", strtotime($date));
		return $month."/".sprintf("%'.04d\n", $id);
	
	}
	function idfromDONumber($id){
		
		// return $month."/".sprintf("%'.04d\n", $id);
		$idArr = explode("/", $id);

		return $idArr[2];
	
	}
    function getViewDetails($listingid, $doNumberReq){
            global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		

		$selectFileds=array("requestId","createdBy","notificationType","projectIdFrom","requestStatus","remarks","notificationNumber","createdOn","projectIdTo","requestNumber");
		$whereClause = "requestId='".$listingid."'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$selectFileds,$whereClause);
		
		$projectArr = array();
		if($res[1] > 0){
			$projectArr["request"] = $db->fetchArray($res[0]); 
		}
		else{
			$projectArr["request"] = array(); //invalid login
		}
        $projectArr["request"]["REQID"] = $this->idGenerator($projectArr["request"]["requestId"], $projectArr["request"]["createdOn"]);
		if($doNumberReq != ""){ //particular DO details
			$selectFileds=array("id","requestId","categoryId","subCategoryId","quantityRequested","quantityDelivered","quantityAccepted","description","DORemarks","collectionRemarks","driverId","vehicleId","driverRemarks","createdOn","requestStatus","approx");
			 $whereClause = "requestId=".$listingid." AND DONumber=".trim($doNumberReq);
			$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$selectFileds,$whereClause);

		}else{
			$selectFileds=array("id","categoryId","subCategoryId","quantityRequested","quantityDelivered","description","activeDoNumber","quantityRemaining","quantityAccepted","modfiedOn","quantityRemaining");
			 $whereClause = "requestId=".$listingid;
			$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["MATREQUEST"],$selectFileds,$whereClause);
		}
		
	
		if($res[1] > 0){
			$projectArr["matRequests"] = $db->fetchArray($res[0], 1); 
		}
		else{
			$projectArr["matRequests"] = array(); //invalid login
		}
        if($doNumberReq != ""){ 
			$projectArr["request"]["activeDoNumber"] = $this->idGenerator($doNumberReq, $projectArr["matRequests"][0]["createdOn"]);
		}else{
			$projectArr["request"]["activeDoNumber"] = $this->idGenerator($projectArr["matRequests"][0]["activeDoNumber"],$projectArr["matRequests"][0]["modfiedOn"]);
		}
		
		return $this->common->arrayToJson($projectArr);
    }
	function updateRequestStatus($listingId, $listingStatus, $remarks, $obj){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;

		$dbm = new DB;
		$updateArr["requestStatus"]=trim($listingStatus);
		$updateArr["approverComments"] = trim($remarks);
		if($obj["showProject"] == 1 && $obj["projectId"] != "" && $listingStatus==3){
			$updateArr["notificationType"]=3;
			$updateArr["projectIdFrom"]=trim($obj["projectId"]);
			$updateArr["projectIdTo"]=trim($obj["projectIdTo"]);
			$updateArr["requestStatus"]=12;
		}
        $dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$whereClause="requestId=".$listingId;
       $insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$updateArr,$whereClause);
		$returnval["response"] ="success";
        $returnval["responsecode"] = 1; 
		return $this->common->arrayToJson($returnval);
	}
	function generateDONumber(){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;		
 		
		$dbm = new DB;
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$selectFileds=array("max(DONumber) as DOno");
		$whereClause = "requestId!='0'";
		$res=$dbm->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$selectFileds,$whereClause);
		$DONumber = 1;
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $dbm->fetchArray($res[0]); 
			$DONumber = $projectArr["DOno"]+1;
		}
		return $DONumber;
	}
	function generateRequestNumber(){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;		
 		
		$dbm = new DB;
		$dbcon = $dbm->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$selectFileds=array("requestNumber");
		$whereClause = "requestNumber!='' order by createdOn desc limit 1";
		$res=$dbm->select($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$selectFileds,$whereClause);
		$reqNumberIncr = date("y/m")."/".sprintf("%'.04d\n", 1);
		$projectArr = array();
		
		if($res[1] > 0){
			
			$projectArr = $dbm->fetchArray($res[0]); 
			$numberArr = explode("/",$projectArr["requestNumber"]);
			// pr($projectArr);
			$monthNumber = $numberArr[0]."/".$numberArr[1];
			
			if($monthNumber == date("y/m")){
				$ym = date("y/m");
				$numberInc = $numberArr[2]+1;
				$reqNumberIncr = $ym."/".sprintf("%'.04d\n", $numberInc);
			}
			else{
				$reqNumberIncr = date("y/m")."/".sprintf("%'.04d\n", 1);
			}
			
			
		}
		return $reqNumberIncr;

	}
	function getCurrentBalance($catId, $subCatId){

		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;		
 		
		$dbm = new DB;
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$selectFileds=array("currentBalance","storeOut","storeIn");
		$whereClause = "categoryId=".$catId." and subCategoryId=".$subCatId;
		$res=$dbm->select($dbcon, $DBNAME["NAME"],$TABLEINFO["SUBCATEGORY"],$selectFileds,$whereClause);
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $dbm->fetchArray($res[0]); 
			$currentBalance["currentBalance"] = $projectArr["currentBalance"];
			$currentBalance["storeOut"] = $projectArr["storeOut"];
			$currentBalance["storeIn"] = $projectArr["storeIn"];
			$currentBalance["consumable"] = $projectArr["consumable"];
		}
		return $currentBalance;

	}
	function generateDO($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		
 		$listingId = $postArr["listingId"];
		$dbm = new DB;
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$DONumber = $this->generateDONumber();
		$whereClause2 = "requestId =".$listingId;
		$updid = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["MATREQUEST"],$whereClause2);
		// $updateArr["active"]=0;
		// $insid2 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$updateArr,$whereClause);
		
		$j = 0;
		$i = 0;
		foreach($postArr["multiCategory"] as $value){
			$insertArr2 = array();
			$uniqueId = $value["categoryId"]."-".$value["subCategoryId"]."-".$value["quantityRequested"];
			$qntyDelivered = trim($postArr[$uniqueId]);
			$qntityRemain = $postArr[$uniqueId."remain"];
			$remain = $qntityRemain - $qntyDelivered;
			$j++;
			if($remain == 0){
				$i++; 
			}
			$insertArr2["requestId"]=$listingId;     
			$insertArr2["categoryId"]=trim($value["categoryId"]);       
			$insertArr2["subCategoryId"]=trim($value["subCategoryId"]);
			$insertArr2["quantityRequested"]=trim($value["quantityRequested"]);
			$insertArr2["quantityDelivered"]=$qntyDelivered;
			$insertArr2["quantityAccepted"]=$qntyDelivered;
			$insertArr2["description"] = trim($value["description"]);
			$insertArr2["quantityRemaining"] = $remain;
			$insertArr2["activeDoNumber"] = $DONumber;
			$insertArr2["modfiedOn"] = date("Y-m-d H:i:s");
			// pr($insertArr2);
			$insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["MATREQUEST"],$insertArr2,$whereClause);

			$insertArr3["requestId"]=$listingId;     
			$insertArr3["categoryId"]=trim($value["categoryId"]);       
			$insertArr3["subCategoryId"]=trim($value["subCategoryId"]);			
			$insertArr3["quantityRequested"]=trim($value["quantityRequested"]);
			$insertArr3["quantityDelivered"]=$qntyDelivered;	
			$insertArr3["description"]=trim($value["description"]);			
			$insertArr3["DONumber"] = $DONumber;
			$insertArr3["DORemarks"]=trim($postArr["remarks"]);
			$insertArr3["driverId"]=trim($postArr["driverName"]);
			$insertArr3["vehicleId"]=trim($postArr["vehicleName"]);	
			$insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$insertArr3,$whereClause);
			//update store balance
			$currentBalance = $this->getCurrentBalance($value["categoryId"], $value["subCategoryId"]);
				$updateArr["storeOut"]=$currentBalance["storeOut"] + $qntyDelivered;
				$updateArr["currentBalance"]=$currentBalance["currentBalance"] - $qntyDelivered;
				$updateWhere = "categoryId=".$value["categoryId"]." and subCategoryId=".$value["subCategoryId"];
				if($postArr["requestType"] == 3 && $postArr["userType"] == "3"){//if partial do by storeman 
					$insid2 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["SUBCATEGORY"],$updateArr,$updateWhere);
				}
				else if($postArr["requestType"] == 1 || $postArr["requestType"] == 2){
					$insid2 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["SUBCATEGORY"],$updateArr,$updateWhere);
				}

				if($currentBalance["consumable"] == 0){
					// $this->updateProjectReport($postArr["projectId"], trim($value["categoryId"]), trim($value["subCategoryId"]), $qntyDelivered, 0);

					if($postArr["requestType"] == 3){	
						if($postArr["userType"] != "3"){	
							$this->updateProjectReport($postArr["projectId"], trim($value["categoryId"]), trim($value["subCategoryId"]), 0, $qntyDelivered);	
						}
										
							$this->updateProjectReport($postArr["projectIdTo"], trim($value["categoryId"]), trim($value["subCategoryId"]), $qntyDelivered, 0);
						
					}
					else{
						$this->updateProjectReport($postArr["projectId"], trim($value["categoryId"]), trim($value["subCategoryId"]), $qntyDelivered, 0);	
					}
				}

		}
		$requestType = $postArr["requestDetails"]["request"]["rawRequestType"];
		//update driver details
		$updateArr = array();
		if($i == $j){
			

			if($requestType == 3){
				$insertArr["requestStatus"]=10;
			}else{
				$insertArr["requestStatus"]=4;
			}
		}
		else{
			if($requestType == 3){
				$insertArr["requestStatus"]=12;
			}else{
				$insertArr["requestStatus"]=3;
			}
			
		}
		$insertArr["modifiedOn"] = date("Y-m-d H:i:s");
		$insertArr["requestStatus"] = $insertArr["requestStatus"];
		$insertArr["modifiedBy"] = trim($postArr["userId"]);
		// $insertArr["driverId"]=trim($postArr["driverName"]);
		// $insertArr["vehicleId"]=trim($postArr["vehicleName"]);		
		// $insertArr["DORemarks"]=trim($postArr["remarks"]);
		
		$whereClause="requestId=".$listingId;
		$insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$insertArr,$whereClause);
		
		if($requestType == 3){
			$updateArr["requestStatus"]=14;
		}else{
			$updateArr["requestStatus"]=4;
		}
		$whereClauseUpdate = "requestId=".$listingId." AND DONumber=".$DONumber;
		$insid2 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$updateArr,$whereClauseUpdate);
		$returnval["response"] ="success";
		$returnval["responsecode"] = 1;
		$returnval["doNumber"] = $this->idGenerator($DONumber,date("d-M-Y"));
		return $this->common->arrayToJson($returnval);
		
	}
	function updateProjectReport($projectId, $categoryId, $subCatId, $requestedCount=0, $receivedCount=0){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$reqQnty = (trim($requestedCount) == '' ? 0 : $requestedCount);
		$recQnty = (trim($receivedCount) == '' ? 0 : $receivedCount);
		 $sql ="INSERT INTO ".$DBNAME["NAME"].".".$TABLEINFO["PROJECTREPORT"]."(projectId,categoryId,subCategoryId,requestedQty,recievedQty) VALUES ($projectId,$categoryId,$subCatId,$reqQnty,$recQnty)
		ON DUPLICATE KEY UPDATE requestedQty=requestedQty+$reqQnty, recievedQty=recievedQty+$recQnty;";
	
		$dbm = new DB;
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$updid = $dbm->execute_direct_query($dbcon, $sql);
		

	}
	function collectionUpdate($postArr){

		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
 		$listingId = $postArr["listingId"];
		 $doNumber = $postArr["DOId"];
		$dbm = new DB;
		$insertArr["modifiedOn"] = date("Y-m-d H:i:s");
        // $insertArr["requestStatus"] = trim($postArr["requestStatus"]);
		$insertArr["modifiedBy"] = trim($postArr["userId"]);	
		if($postArr["requestType"] == 2){
			$insertArr["requestStatus"]=11;
		} 
		if($postArr["requestType"] == 3 && $postArr["requestStatus"] != "3" && $postArr["requestStatus"] != "12"){
			$insertArr["requestStatus"]=13;
		}		
		// $insertArr["collectionRemarks"]=trim($postArr["remarks"]);
		
        $dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$whereClause="requestId=".$listingId;
        $insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$insertArr,$whereClause);
		$l = 0;
			foreach($postArr["multiCategory"] as $value){
				$insertArr2 = array();
				$uniqueId = $value["categoryId"]."-".$value["subCategoryId"]."-".$value["quantityRequested"];
				$qntyAccepted = trim($postArr[$uniqueId]);			
				if($value["quantityDelivered"] > $qntyAccepted){
					$l++;
				}
				$insertArr2["quantityAccepted"]=$qntyAccepted;
				if($postArr["requestType"] == 2){
					$insertArr2["requestStatus"]=11;
				}
				else if($postArr["requestType"] == 3){
					$insertArr2["requestStatus"]=13;
				}
				else{
					$insertArr2["requestStatus"]=7;
				}
				
				// $insertArr2["quantityRemaining"] = $qntityRemain - $qntyDelivered;
				// $insertArr2["activeDoNumber"] = $DONumber;
				$insertArr2["modifiedOn"] = date("Y-m-d H:i:s");
				$insertArr2["modifiedBy"] = trim($postArr["userId"]);
				$insertArr2["collectionRemarks"]=trim($postArr["remarks"]);
				
				// pr($insertArr2);
				$whereClause2 = "requestId=".$listingId." AND id=".$value["id"]." AND DONumber=".$doNumber;
				 $insid2 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$insertArr2,$whereClause2);
				 $currentBalance = $this->getCurrentBalance($value["categoryId"], $value["subCategoryId"]);
				 if($postArr["requestType"] == 2){
					//update store balance if return 
					
					$updateArr["storeIn"]=$currentBalance["storeIn"] + $qntyAccepted;
					$updateArr["currentBalance"]=$currentBalance["currentBalance"] + $qntyAccepted;
					$updateWhere = "categoryId=".$value["categoryId"]." and subCategoryId=".$value["subCategoryId"];
					$insid2 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["SUBCATEGORY"],$updateArr,$updateWhere);
					
				 }
				 if($postArr["requestType"] == 2){
					if($currentBalance["consumable"] == 0){
						$this->updateProjectReport($postArr["projectId"], trim($value["categoryId"]), trim($value["subCategoryId"]), 0, $qntyAccepted);

						// if($postArr["requestType"] == 3){							
						// 	$this->updateProjectReport($postArr["projectIdTo"], trim($value["categoryId"]), trim($value["subCategoryId"]), $qntyAccepted, 0);
						// }
					}
				}

				

				
			}
// 			error_reporting(E_ALL);
// ini_set("display_errors",1);
		// echo $l."===";
		// ini_set("SMTP","smtp.gmail.com");
		// ini_set("smtp_port","587");
		// ini_set("sendmail_from","jeevanantham.n@gmail.com");
		// if($l > 0){
		// 	// echo "inside<br>";
		// 	$to = "jeevanantham.n@gmail.com";
		// 	$subject = "Collection Notification";
		// 	$message = "There is variation between Quantity Delivered and Accepted. Details Below<br />
		// 	<strong>Request Number :</strong> ".$postArr["requestIdFormatted"]."<br /><strong>Request Number :</strong> ".$postArr["doIdFormatted"]."<br /><br />Thanks,<br />Admin.";
		// 	// echo $message;
		// 	$this->common->sendemail('admin@vk.com',$to,$subject,$message);
		// }
			$returnval["response"] ="success";
			$returnval["responsecode"] = 1; 
			return $this->common->arrayToJson($returnval);
		
	}
	function doApprove($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
 		$listingId = $postArr["listingId"];
		$dbm = new DB;
	
        $insertArr["modifiedOn"] = date("Y-m-d H:i:s");
        // $insertArr["requestStatus"] = trim($postArr["requestStatus"]);
		$insertArr["modifiedBy"] = trim($postArr["userId"]);		 		
		// $insertArr["driverRemarks"]=trim($postArr["remarks"]);
		if(trim($postArr["requestType"]) == 2){
				$insertArr["requestStatus"] = 8;
		}
		// if(trim($postArr["requestType"]) == 3 && trim($postArr["requestStatus"]) == 3){
		// 		$insertArr["requestStatus"] = 10;
		// }
		
        $dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$whereClause="requestId=".$listingId;
        $insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$insertArr,$whereClause);

		
		
		$DONumber = trim($postArr['DOId']);
		if($DONumber != ""){
			$insertArr2["modifiedOn"] = date("Y-m-d H:i:s");
			$insertArr2["modifiedBy"] = trim($postArr["userId"]);	
			if(trim($postArr["requestType"]) == 2){
				$insertArr2["requestStatus"] = 8;
			}
			else if(trim($postArr["requestType"]) == 3){
				$insertArr2["requestStatus"] = 10;
			}
			else{
				$insertArr2["requestStatus"] = trim($postArr["requestStatus"]);
			}
			$insertArr2["driverRemarks"]=trim($postArr["remarks"]);
			
			$whereClause="requestId=".$listingId." AND DONumber=".$DONumber;
			$insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$insertArr2,$whereClause);
		}
		
		$returnval["response"] ="success";
        $returnval["responsecode"] = 1; 
		return $this->common->arrayToJson($returnval);
	}
	function driverEdit($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
 		$listingId = $postArr["listingId"];
		$dbm = new DB;
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$DONumber = trim($postArr['DOId']);
		if($DONumber != ""){
			$insertArr2["modifiedOn"] = date("Y-m-d H:i:s");
			$insertArr2["modifiedBy"] = trim($postArr["userId"]);	
			
			$insertArr2["driverId"]=trim($postArr["driverName"]);
			$insertArr2["vehicleId"]=trim($postArr["vehicleName"]);
			
			$whereClause="requestId=".$listingId." AND DONumber=".$DONumber;
			$insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$insertArr2,$whereClause);
		}
		
		
		$returnval["response"] ="success";
        $returnval["responsecode"] = 1; 
		return $this->common->arrayToJson($returnval);
	}
	function updateRequestDetails($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
 		$listingId = $postArr["listingId"];
		$dbm = new DB;
	
        $insertArr["projectIdFrom"]=trim($postArr["cboProjectsFrom"]);
        $insertArr["projectIdTo"]=trim($postArr["cboProjectsTo"]);
        $insertArr["description"]=trim($postArr["description"]);
        // $insertArr["driverId"]=trim($postArr["driverName"]);
        // $insertArr["vehicleId"]=trim($postArr["vehicleName"]);
        $insertArr["remarks"]=trim($postArr["txtRemarks"]);
        $insertArr["notificationNumber"]=trim($postArr["notificationNo"]);
		if(trim($postArr["notificationNo"]) != ""){
			$insertArr["transferId"] = $this->idfromDONumber($postArr["notificationNo"]);
		}
        $insertArr["notificationType"]=trim($postArr["requestType"]);
        $insertArr["modifiedOn"] = date("Y-m-d H:i:s");
        // $insertArr["requestStatus"] = trim($postArr["requestStatus"]);
		$insertArr["modifiedBy"] = trim($postArr["userId"]);
		if($postArr["requestStatus"] == 1 && ($postArr["requestType"] == 2 || $postArr["requestType"] == 3)){
        	$insertArr["requestStatus"] = 4;
		}
		else{
			$insertArr["requestStatus"] = trim($postArr["requestStatus"]);
		}
		
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		if($postArr["requestType"] == 3){ // remove existing request if transfer
			$whereClause2="requestId=".$insertArr["transferId"];
			$updateArr2["requestStatus"] = 99;
			$insid99 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$updateArr2,$whereClause2);
			$insid399 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$updateArr2,$whereClause2);
		}
		$whereClause="requestId=".$listingId;
        $insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$insertArr,$whereClause);
		$insid = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["MATREQUEST"],$whereClause);
		$insid = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$whereClause);
		$DONumber = 0;
		if($postArr["requestType"] == 3){
			$DONumber = $this->generateDONumber();
		}
		foreach($postArr["multiCategory"] as $value){
			$insertArr2 = array();
			$insertArr2["requestId"]=$listingId;     
			$insertArr2["categoryId"]=trim($value["categoryId"]);       
			$insertArr2["subCategoryId"]=trim($value["subCategoryId"]);
			$insertArr2["quantityRequested"]=trim($value["quantityRequested"]);
			$insertArr2["quantityRemaining"]=trim($value["quantityRequested"]);
			$insertArr2["description"]=trim($value["description"]);
			$insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["MATREQUEST"],$insertArr2,1,2);
			
			//if request type Return or transfer
			if($postArr["requestStatus"] == 1 && ($postArr["requestType"] == 2 || $postArr["requestType"] == 3)){
				$insertArr3["requestId"]=$listingId;         
				$insertArr3["categoryId"]=trim($value["categoryId"]);       
				$insertArr3["subCategoryId"]=trim($value["subCategoryId"]);
				$insertArr3["quantityRequested"]=trim($value["quantityRequested"]);
				$insertArr3["requestStatus"]= ($postArr["requestType"] == 3) ? 12 : 4;	
				// if($postArr["requestType"] == 2){
					$insertArr3["approx"]= $value["rdoApprox"];
					$insertArr3["driverId"]= (trim($postArr["driverName"]) != "")? $postArr["driverName"] : 1;
					$insertArr3["vehicleId"]= (trim($postArr["vehicleName"]) != "")? $postArr["vehicleName"] : 2;
					$insertArr3["quantityDelivered"]=trim($value["quantityRequested"]);
					$insertArr3["DONumber"]=$DONumber;
				// }
				// pr($insertArr3);
				$insertArr3["description"]=trim($value["description"]);
				$insid3 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$insertArr3,1,2);
			}
			else{
				$insid3 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["TRANSFERHISTORY"],$insertArr2,1,2);
			}
		}
		
		$requestNumber = trim($postArr["requestNumber"]);
		// $reqWhereClause="requestId=".$insid;
		// $updateArrReq["requestNumber"] = $requestNumber;
		// $insid99 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$updateArrReq,$reqWhereClause);

		$returnval["response"] ="success";
		$returnval["responsecode"] = 1; 
		$returnval["requestID"] = $requestNumber; 
		return $this->common->arrayToJson($returnval);
	}

	function createRequest($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;

       
        $insertArr["projectIdFrom"]=trim($postArr["cboProjectsFrom"]);
        $insertArr["projectIdTo"]=trim($postArr["cboProjectsTo"]);
        $insertArr["description"]=trim($postArr["description"]);
        // $insertArr["driverId"]=trim($postArr["driverName"]);
        // $insertArr["vehicleId"]=trim($postArr["vehicleName"]);
        $insertArr["remarks"]=trim($postArr["txtRemarks"]);
        $insertArr["notificationNumber"]=trim($postArr["notificationNo"]);
		if(trim($postArr["notificationNo"]) != ""){
			$insertArr["transferId"] = $this->idfromDONumber($postArr["notificationNo"]);
		}
        $insertArr["notificationType"]=trim($postArr["requestType"]);
        $insertArr["createdOn"] = date("Y-m-d H:i:s");
		if($postArr["requestStatus"] == 1 && ($postArr["requestType"] == 2 || $postArr["requestType"] == 3)){
        	$insertArr["requestStatus"] = 4;
		}
		else{
			$insertArr["requestStatus"] = trim($postArr["requestStatus"]);
		}
        $insertArr["createdBy"] = trim($postArr["userId"]);
		
	

        
        $dbm = new DB;
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		if($postArr["requestType"] == 3){
			$whereClause="requestId=".$insertArr["transferId"];
			$updateArr["requestStatus"] = 99;
			$insid99 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$updateArr,$whereClause);
			$insid399 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$updateArr,$whereClause);
		}
        $insid = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$insertArr,1,2);
		$DONumber = 0;
		if($postArr["requestType"] == 3){
			$DONumber = $this->generateDONumber();
		}
		

		foreach($postArr["multiCategory"] as $value){
			$insertArr2 = array();
			$insertArr2["requestId"]=$insid;       
			$insertArr2["categoryId"]=trim($value["categoryId"]);       
			$insertArr2["subCategoryId"]=trim($value["subCategoryId"]);
			$insertArr2["quantityRequested"]=trim($value["quantityRequested"]);
			$insertArr2["quantityRemaining"]=trim($value["quantityRequested"]);			
			$insertArr2["description"]=trim($value["description"]);
			$insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["MATREQUEST"],$insertArr2,1,2);
			

			//if request type Return or transfer
			if($postArr["requestStatus"] == 1 && ($postArr["requestType"] == 2 || $postArr["requestType"] == 3)){
				$insertArr3["requestId"]=$insid;       
				$insertArr3["categoryId"]=trim($value["categoryId"]);       
				$insertArr3["subCategoryId"]=trim($value["subCategoryId"]);
				$insertArr3["quantityRequested"]=trim($value["quantityRequested"]);
				
				$insertArr3["requestStatus"]= ($postArr["requestType"] == 3) ? 12 : 4;	
				// if($postArr["requestType"] == 2){
					$insertArr3["approx"]= $value["rdoApprox"];
					$insertArr3["driverId"]= (trim($postArr["driverName"]) != "")? $postArr["driverName"] : 1;
					$insertArr3["vehicleId"]= (trim($postArr["vehicleName"]) != "")? $postArr["vehicleName"] : 2;
					$insertArr3["quantityDelivered"]=trim($value["quantityRequested"]);
					$insertArr3["DONumber"]=$DONumber;
					
				// }
				$insertArr3["description"]=trim($value["description"]);
				$insid3 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$insertArr3,1,2);
			}
			else{
				$insid3 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["TRANSFERHISTORY"],$insertArr2,1,2);
			}
		}
		//generate request number & update
		$requestNumber = $this->generateRequestNumber();
		$reqWhereClause="requestId=".$insid;
		$updateArrReq["requestNumber"] = $requestNumber;
		$insid99 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["REQUEST"],$updateArrReq,$reqWhereClause);

        $dbm->dbClose();
        if($insid == 0 || $insid == ''){ 
            $returnval["response"] ="fail";
               $returnval["responsecode"] = 0; 
        }else { 
            
            $returnval["response"] ="success";
			$returnval["responsecode"] = 1; 
			$returnval["requestID"] = $requestNumber; 
            
            }
			
		
		
		return $this->common->arrayToJson($returnval);
	}
	function setMismatchAlert($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;

		$dbm = new DB;		
	
		$updateArr["requestId"]=$postArr["listingId"];
		$updateArr["requestedBy"]=$postArr["userId"];
		$updateArr["dateRequested"]=date("y-m-d h:m:s");
		$updateArr["formattedId"]=$postArr["requestId"];
		$updateArr["doId"]=$postArr["doId"];
		$updateArr["doNumber"]=$postArr["DOId"];
		
        $dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
       $insid = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["MISATCHALERT"],$updateArr);
		$returnval["response"] ="success";
        $returnval["responsecode"] = 1; 
		return $this->common->arrayToJson($returnval);
	}
	function getAlerts(){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("requestId","dateRequested","formattedId","doId","doNumber");
		$whereClause = "status = 1";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["MISATCHALERT"],$selectFileds,$whereClause);
		// pr($res);
		if($res[1] > 0){
			$userInfo = $db->fetchArray($res[0],1);
			$returnval = $userInfo;
		}
		else{
			$returnval = 0; 
		}
		$db->dbClose();
		
		return $this->common->arrayToJson($returnval);
	}
	function getRemainingQnty($whereClause){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("quantityRemaining");
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["MATREQUEST"],$selectFileds,$whereClause);
		
		if($res[1] > 0){
			$userInfo = $db->fetchArray($res[0]);
			
		}
		else{
			$userInfo = 0; 
		}
		$db->dbClose();
		
		return $userInfo["quantityRemaining"];
	}

	function EditAlerts($postArr){

		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$listingId = $postArr["listingId"];
		$doNumber = $postArr["DOId"];
		$dbm = new DB;
        $dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
	
 
		$l = 0;
			foreach($postArr["multiCategory"] as $value){
				$insertArr2 = array();
				$uniqueId = $value["categoryId"]."-".$value["subCategoryId"]."-".$value["quantityRequested"];
				$qntyAccepted = trim($postArr[$uniqueId]);	
				$qntyAccepted_old = trim($postArr[$uniqueId."_old"]);
				// if($value["quantityDelivered"] > $qntyAccepted){
				// 	$l++;
				// }
				$qntyToBUpdated = $qntyAccepted - $qntyAccepted_old;
				$qntyToBReversed = $qntyAccepted_old - $qntyAccepted;
				$insertArr2["quantityDelivered"]=$qntyAccepted;
				
				
				// $insertArr2["quantityRemaining"] = $qntityRemain - $qntyDelivered;
				// $insertArr2["activeDoNumber"] = $DONumber;
				$insertArr2["modifiedOn"] = date("Y-m-d H:i:s");
				$insertArr2["modifiedBy"] = trim($postArr["userId"]);
				// $insertArr2["collectionRemarks"]=trim($postArr["remarks"]);
				
				// pr($insertArr2);
				$whereClause2 = "requestId=".$listingId." AND DONumber=".$doNumber;
				 $insid2 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["DOGENERATIONHISTORY"],$insertArr2,$whereClause2);
				 
							
				 $whereClause4 = "requestId=".$listingId." AND categoryId=".$value["categoryId"]." and subCategoryId=".$value["subCategoryId"];
				 $remainqnty = $this->getRemainingQnty($whereClause4);
				 $insertArr3["quantityDelivered"]=$qntyAccepted;	
				 $insertArr3["quantityRemaining"]=$remainqnty + $qntyToBReversed;
				 $insid2 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["MATREQUEST"],$insertArr3,$whereClause4);
				//  pr($dbm);

				 $currentBalance = $this->getCurrentBalance($value["categoryId"], $value["subCategoryId"]);
				//  if($postArr["requestType"] == 2){
					
					
				//  }
				//  if($postArr["requestType"] == 2 || $postArr["requestType"] == 3){
					if($currentBalance["consumable"] == 0){
						

						if($postArr["requestType"] == 3){							
							$this->updateProjectReport($postArr["projectIdTo"], trim($value["categoryId"]), trim($value["subCategoryId"]), $qntyToBUpdated, 0);
							$this->updateProjectReport($postArr["projectId"], trim($value["categoryId"]), trim($value["subCategoryId"]), 0, $qntyToBUpdated);
						}
						else{
							$this->updateProjectReport($postArr["projectId"], trim($value["categoryId"]), trim($value["subCategoryId"]), $qntyToBUpdated, 0);
							//update store balance  					
							$updateArr["storeOut"]=$currentBalance["storeOut"] + $qntyToBUpdated;
							$updateArr["currentBalance"]=$currentBalance["currentBalance"] - $qntyToBUpdated;
							$updateWhere = "categoryId=".$value["categoryId"]." and subCategoryId=".$value["subCategoryId"];
							
							$insid2 = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["SUBCATEGORY"],$updateArr,$updateWhere);
						}
					}
				// }
			}
			$updateArr2["status"]=2;
			$whereClause3 = "requestId=".$listingId." AND doNumber=".$doNumber;
			$insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["MISATCHALERT"],$updateArr2, $whereClause3);
			$returnval["response"] ="success";
			$returnval["responsecode"] = 1; 
			return $this->common->arrayToJson($returnval);
		
	}
}

?>