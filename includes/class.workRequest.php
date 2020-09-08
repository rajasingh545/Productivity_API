<?php
    include_once "lib/init.php";
    
class WORKREQUESTS
{
	public $common;

	function __construct(){
		global $commonObj;
		$this->common = $commonObj;
	}
    function createWorkRequest($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		
       
			$insertArr["projectId"]=trim($postArr["value_projects"]);
			$insertArr["clientId"]=trim($postArr["value_clients"]);
			$insertArr["status"]=trim($postArr["status"]);
            $insertArr["requestedBy"]=trim($postArr["requestBy"]);
            $insertArr["description"]=trim($postArr["description"]);
			$insertArr["contractType"]=trim($postArr["cType"]);		
            $insertArr["remarks"]=trim($postArr["remarks"]);
            $insertArr["scaffoldRegister"] = trim($postArr["scaffoldRegister"]);
			$insertArr["createdOn"]=date("Y-m-d H:i:s");
			$insertArr["createdBy"]=trim($postArr["userId"]);	
			$insertArr["drawingAttach"]=trim($postArr["drawingAttached"]);	
			$insertArr["location"]=trim($postArr["location1"]);	

            if($insertArr["drawingAttach"]==1)
                $insertArr["drawingImage"]=trim($postArr["drawingimage"]);
            else
                $insertArr["drawingImage"]='';
			
			$dbm = new DB;
			$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
			
			$insid = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$insertArr,1,2);
			if($insid != 0 && $insid != ''){ 
                if(trim($postArr["cType"]) == 1){ //if its original contarct
                    $this->insertItemList($postArr, $insid);
                }
                if(trim($postArr["cType"]) == 2){ //if its variaion works
                    $this->insertVariationWorks($postArr, $insid);
                }
            }
			
            $dbm->dbClose();
            //createDailyWorkTrack($postArr);
			if($insid == 0 || $insid == ''){ 
				$returnval["response"] ="fail";
				$returnval["responsecode"] = 0; 
			}else { 
				
				$returnval["response"] ="success";
                $returnval["responsecode"] = 1; 
                $invID = str_pad($insid, 4, '0', STR_PAD_LEFT);
                $returnval["id"] = $invID;
				
				
				}
		
		return $this->common->arrayToJson($returnval);
    }

    function updateWorkRequest($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		
       
			$insertArr["projectId"]=trim($postArr["value_projects"]);
			$insertArr["clientId"]=trim($postArr["value_clients"]);
			$insertArr["status"]=trim($postArr["status"]);
            $insertArr["requestedBy"]=trim($postArr["requestBy"]);
            $insertArr["description"]=trim($postArr["description"]);
			$insertArr["contractType"]=trim($postArr["cType"]);		
            $insertArr["remarks"]=trim($postArr["remarks"]);
            $insertArr["scaffoldRegister"] = trim($postArr["scaffoldRegister"]);
			$insertArr["createdOn"]=date("Y-m-d H:i:s");
			$insertArr["createdBy"]=trim($postArr["userId"]);	

			
			$insertArr["drawingAttach"]=trim($postArr["drawingAttached"]);	
			$insertArr["location"]=trim($postArr["location1"]);
			
            if($insertArr["drawingAttach"]==1)
                $insertArr["drawingImage"]=trim($postArr["drawingimage"]);
            else
                $insertArr["drawingImage"]='';

			
            $dbm = new DB;
            $workReqId = $postArr["listingId"];
			$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
			$whereClause = "workRequestId=".$workReqId;
            
            $insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$insertArr,$whereClause);

            $delete1 = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTITEMS"],$whereClause);
            $delete2 = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTSIZEBASED"],$whereClause);
            $delete3 = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTMANPOWER"],$whereClause);

			
            if(trim($postArr["cType"]) == 1){ //if its original contarct
                $this->insertItemList($postArr, $workReqId);
            }
            if(trim($postArr["cType"]) == 2){ //if its variaion works
                $this->insertVariationWorks($postArr, $workReqId);
            }
            
			
			$dbm->dbClose();
			// if($insid == 0 || $insid == ''){ 
			// 	$returnval["response"] ="fail";
			// 	$returnval["responsecode"] = 0; 
			// }else { 
				
            $returnval["response"] ="success";
            $returnval["responsecode"] = 1; 
            // $invID = str_pad($insid, 4, '0', STR_PAD_LEFT);
            // $returnval["id"] = $invID;
				
				
				// }
		
		return $this->common->arrayToJson($returnval);
    }

    function insertVariationWorks($postArr, $insid){
        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
        $dbm = new DB;
        $dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
        $insertItemArr["workRequestId"] = $insid;
        $insertItemArr["contractType"] = trim($postArr["cType"]);
        $insertItemArr["itemId"] = 0;
        $insertItemArr["workBased"] = $postArr["workBased"];
        $insertItemArr["sizeType"] = $postArr["sizeType"];
        $insertItemArr["createdOn"] = date("Y-m-d H:i:s");
        $insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTITEMS"],$insertItemArr,1,2);
        $azRange = range('A', 'Z');
        $i =0; 
        $invID = str_pad($insid, 4, '0', STR_PAD_LEFT);
        if($insid2 != 0 && $insid2 != ''){
            if($postArr["workBased"] == 1){
                foreach($postArr["sizeList"] as $itemList){
                    $wrUniqueId = "WR-".$invID.$azRange[$i];
                    $insertSizeArr["workRequestId"] = $insid;
                    $insertSizeArr["itemListId"] = $insid2;
                    $insertSizeArr["scaffoldType"] = $itemList["value_scaffoldType"];
                    $insertSizeArr["scaffoldWorkType"] = $itemList["value_scaffoldWorkType"];
                    $insertSizeArr["scaffoldSubCategory"] = $itemList["value_scaffoldSubcategory"];
                    $insertSizeArr["length"] = $itemList["L"];
                    $insertSizeArr["height"] = $itemList["H"];
                    $insertSizeArr["width"] = $itemList["W"];
                    $insertSizeArr["setcount"] = $itemList["set"];
                    $insertSizeArr["createdOn"] = date("Y-m-d H:i:s");
                    $insertSizeArr["ItemUniqueId"]=$wrUniqueId;
                   
                    $insid3 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTSIZEBASED"],$insertSizeArr,1,2);
                    $i++;
                }
            }
            if($postArr["workBased"] == 2){
                foreach($postArr["manpowerList"] as $itemList){
                    $wrUniqueId = "WR-".$invID.$azRange[$i];
                    $insertManPowerArr["workRequestId"] = $insid;
                    $insertManPowerArr["itemListId"] = $insid2;
                    $insertManPowerArr["safety"] = $itemList["safety"];
                    $insertManPowerArr["supervisor"] = $itemList["supervisor"];
                    $insertManPowerArr["erectors"] = $itemList["erectors"];
                    $insertManPowerArr["generalWorker"] = $itemList["gworkers"];
                    $insertManPowerArr["timeIn"] = $itemList["inTime"];
                    $insertManPowerArr["timeOut"] = $itemList["outTime"];
                    $insertManPowerArr["createdOn"] = date("Y-m-d H:i:s");
                    $insertManPowerArr["ItemUniqueId"]=$wrUniqueId;
                    $insid4 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTMANPOWER"],$insertManPowerArr,1,2);
                    $i++;
                }
            }
        }
    }
    
    function insertItemList($postArr, $insid){
        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
        $dbm = new DB;
        $dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);

        $azRange = range('A', 'Z');
        $i=0;

        foreach($postArr["itemList"] as $itemList){


            $insertItemArr["workRequestId"] = $insid;
            $insertItemArr["contractType"] = trim($postArr["cType"]);
            $insertItemArr["itemId"] = $itemList["value_item"];
            $insertItemArr["workBased"] = $itemList["workBased"];
            $insertItemArr["sizeType"] = $itemList["sizeType"];
            $insertItemArr["previousWR"] = $itemList["workRequestId"];
            $insertItemArr["createdOn"] = date("Y-m-d H:i:s");
            $insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTITEMS"],$insertItemArr,1,2);
            $invID = str_pad($insid, 4, '0', STR_PAD_LEFT);
            $wrUniqueId = "WR-".$invID.$azRange[$i];

                if($insid2 != 0 && $insid2 != ''){
                   
                    if($itemList["workBased"] == 1){ //size
                        $sizeList = $itemList["sizeList"][0];
                        $insertSizeArr["workRequestId"] = $insid;
                        $insertSizeArr["itemListId"] = $insid2;
                        $insertSizeArr["scaffoldType"] = $sizeList["value_scaffoldType"];
                        $insertSizeArr["scaffoldWorkType"] = $sizeList["value_scaffoldWorkType"];
                        $insertSizeArr["scaffoldSubCategory"] = $sizeList["value_scaffoldSubcategory"];
                        $insertSizeArr["length"] = $sizeList["L"];
                        $insertSizeArr["height"] = $sizeList["H"];
                        $insertSizeArr["width"] = $sizeList["W"];
                        $insertSizeArr["setcount"] = $sizeList["set"];
                        $insertSizeArr["ItemUniqueId"]=$wrUniqueId;
                        $insertSizeArr["createdOn"] = date("Y-m-d H:i:s");
                       
                        $insid3 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTSIZEBASED"],$insertSizeArr,1,2);
                       
                    }
                    if($itemList["workBased"] == 2){ //manpower
                        $manpowerList = $itemList["manpowerList"][0];
                        
                        $insertManPowerArr["workRequestId"] = $insid;
                        $insertManPowerArr["itemListId"] = $insid2;
                        $insertManPowerArr["safety"] = $manpowerList["safety"];
                        $insertManPowerArr["supervisor"] = $manpowerList["supervisor"];
                        $insertManPowerArr["erectors"] = $manpowerList["erectors"];
                        $insertManPowerArr["generalWorker"] = $manpowerList["gworkers"];
                        $insertManPowerArr["timeIn"] = $manpowerList["inTime"];
                        $insertManPowerArr["timeOut"] = $manpowerList["outTime"];
                        $insertManPowerArr["createdOn"] = date("Y-m-d H:i:s");
                        $insertManPowerArr["ItemUniqueId"]=$wrUniqueId;
                        $insid4 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTMANPOWER"],$insertManPowerArr,1,2);
                       
                    }

                }
                $i++;
        }
    }

	function getWorkRequestList($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("workRequestId","projectId","clientId","requestedBy","createdBy","createdOn");

		if($postArr["startDate"] && $postArr["startDate"]!=""){
			$addCond = "date(createdOn)='".$postArr["startDate"]."'";
		}
		else{
			$addCond = "date(createdOn)='".date("Y-m-d")."'";
		}		
		$whereClause = "status=".$postArr["requestType"]." AND $addCond order by workRequestId desc";
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$selectFileds,$whereClause);
		// pr($db);
		$usersArr = array();
		if($res[1] > 0){
            $usersArr = $db->fetchArray($res[0], 1);
            $selectFiledsitem=array("Name");
				$whereClauseitem = "userId=".$worklist['createdBy'];
				$resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFiledsitem,$whereClauseitem);
				if($resitem[1] > 0){
					$itemList = $db->fetchArray($resitem[0]);
					$usersArr["createdByName"]=$itemList['Name'];
					
				}else{
					$usersArr["createdByName"]="";
				}
		}
		// pr($usersArr);
 
		return $this->common->arrayToJson($usersArr);
    }
    
    function getWorkRequestListDate($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$requestdata=$postArr['requestJsonData'];
		$usersArr = array();
        if(!empty($requestdata))
        {
            $fromdate=$postArr['requestJsonData']['startDate'];
            $enddate=$postArr['requestJsonData']['endDate'];
            $requesttype=$postArr['requestJsonData']['requestData']['id'];
            $projectid=$postArr['requestJsonData']['selectedProjectData']['projectId'];
            $clientid=$postArr['requestJsonData']['selectedClientData']['clientId'];
            $workRequestCount = 1;      

            if(empty($fromdate))
            {
                $fromdate=date("Y-m-d");
                $enddate=$fromdate;
            }
            else if(empty($enddate) && !empty($fromdate))
                $enddate=$fromdate;
            if(empty($requesttype))
                $requesttype=1;
            $addCond = "date(createdOn) between '".$fromdate."' and '".$enddate."'";    
            if(!empty($projectid))
                $addCond.=" and projectId=".$projectid;
            if(!empty($clientid))
                $addCond.=" and clientId=".$clientid;
            if($postArr['userType'] != 1)
			{
				$addCond.=" and createdBy=".$postArr['userId'];
			}
            $whereClause = "status=".$requesttype." and $addCond order by workRequestId desc";
            $selectFileds=array("workRequestId","projectId","clientId","requestedBy","contractType","scaffoldRegister","remarks","description", "status","location","createdBy","createdOn");
            $res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$selectFileds,$whereClause);
    		if($res[1] > 0){
    			$usersArr = $db->fetchArray($res[0], 1);
    			$projectnewlist=array();
    			foreach($usersArr as $key=>$value)
    			{
    			    $usersArr[$key]["workbasedon"]="";
                    $usersArr[$key]["requestSizeList"]=[];
                    $usersArr[$key]["requestmanpower"]=[];
                    
    			    if($value['scaffoldRegister']==1)
    			        $usersArr[$key]["scaffoldregister"]="Yes";
    			    else
    			        $usersArr[$key]["scaffoldregister"]="No";
    			    $usersArr[$key]["remarks"]=$value['remarks'];
    			    $projectid=$value['projectId'];
    			    $selectFiledsitem=array("projectName","projectCode");
                    $whereClauseitem = "projectId=".$projectid;
                    $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["PROJECTS"],$selectFiledsitem,$whereClauseitem);
                    if($resitem[1] > 0){
                        $itemList = $db->fetchArray($resitem[0]);
                        $usersArr[$key]["projectname"]=$itemList['projectName'];
						$usersArr[$key]["projectcode"]=strtoupper($itemList['projectCode']);
                    }
                    /** */
                    $createdbyid=$value['createdBy'];
                    $selectFiledsitem=array("Name");
                    $whereClauseitem = "userId=".$createdbyid;
                    $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFiledsitem,$whereClauseitem);
                    if($resitem[1] > 0){
                        $itemList = $db->fetchArray($resitem[0]);
                        $usersArr[$key]["createdByName"]=$itemList['Name'];
                    }
                    /** */
                    $client_id=$value['clientId'];
    			    $selectFiledsitem=array("clientName","clientCode");
                    $whereClauseitem = "clientId=".$client_id;
                    $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["CLIENTS"],$selectFiledsitem,$whereClauseitem);
                    if($resitem[1] > 0){
                        $itemList = $db->fetchArray($resitem[0]);
                        $usersArr[$key]["clientname"]=$itemList['clientName'];
						 $usersArr[$key]["clientcode"]=strtoupper($itemList['clientCode']);
                    }
                    $whereClauseCount = "select count(projectId) as projectCount from p_workrequest where projectId=".$value['projectId']." and clientId=".$value['clientId'];
                    $connectionStr = mysqli_connect("localhost", $DBINFO["USERNAME"], $DBINFO["PASSWORD"], $DBNAME["NAME"]);
                   

                    $workRequestCount = mysqli_query($connectionStr, $whereClauseCount);
                    $data=mysqli_fetch_assoc($workRequestCount);
                    $usersArr[$key]['query']=$whereClauseCount;
                    //$workRequestCount=$db->execute_query($dbcon,$whereClauseCount);
                    $str_length = 3; 
                    $workRequestCount  = substr("000{$data['projectCount']}", -$str_length);
                    $usersArr[$key]['workReqCount']= $workRequestCount ;

                    //$selectFileds="count(projectId)";
                   // $workRequestCount=$db->execute_query($dbcon,$whereClauseCount);
                    //$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$selectFileds,$whereClause);
                   // if($workRequestCount > 0){
                        //$workRequestCount = $db->fetchArray($res[0], 1);
                     //   $str_length = 3; 
                     //   $workRequestCount  = substr("000{$workRequestCount}", -$str_length); 
                   // }
                    $usersArr[$key]["location"]=$value['location'];
                    if($value['contractType']==1)
                        $usersArr[$key]["contracttype"]="Original Contract";
                    else
                        $usersArr[$key]["contracttype"]="Variation Works";
                    $usersArr[$key]["description"]=$value['description'];
                    
    			    $wrequestid=$value['workRequestId'];
    			    $selectFiledsitem=array("id","workRequestId","itemId","sizeType","previousWR","workBased","contractType");
                    $whereClauseitem = "workRequestId='".$wrequestid."'";
                    $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTITEMS"],$selectFiledsitem,$whereClauseitem);
                    if($resitem[1] > 0){
                        $itemList = $db->fetchArray($resitem[0],1);
                        $k=0;
                        $a =0;
                        $b=0;
                        foreach($itemList as $item){
                            if($item["workBased"] == 1){
                                $usersArr[$key]["workbasedon"]="Size";
                                $selectFiledsSize=array("id","itemListId","scaffoldType","scaffoldWorkType","scaffoldSubCategory","length","height", "width","setcount");
                                $whereClauseSize = "workRequestId='".$wrequestid."' and itemListId=".$item["id"];
                                $resSize=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTSIZEBASED"],$selectFiledsSize,$whereClauseSize);
                                if($resSize[1] > 0){
                                    $sizeList = $db->fetchArray($resSize[0],1);
                                    $i=0;
                                    foreach($sizeList as $sizeDet){
                                        $scaffoldworktype=$sizeDet['scaffoldWorkType'];
                        			    $selectFiledsitem=array("scaffoldName");
                                        $whereClauseitem = "id=".$scaffoldworktype;
                                        $resitem_in=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["SCAFFOLDWORKTYPE"],$selectFiledsitem,$whereClauseitem);
                                        if($resitem_in[1] > 0){
                                            $itemList_in = $db->fetchArray($resitem_in[0]);
                                            $usersArr[$key]["requestSizeList"][$a]["scaffoldworktype"]=$itemList_in['scaffoldName'];
                                        }
                                        $scaffoldtype=$sizeDet['scaffoldType'];
                        			    $selectFiledsitem=array("scaffoldName");
                                        $whereClauseitem = "id=".$scaffoldtype;
                                        $resitem_in=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["SCAFFOLDTYPE"],$selectFiledsitem,$whereClauseitem);
                                        if($resitem_in[1] > 0){
                                            $itemList_in = $db->fetchArray($resitem_in[0]);
                                            $scaffoldtypename=$itemList_in['scaffoldName'];
                                            $usersArr[$key]["requestSizeList"][$a]["scaffoldtype"]=$itemList_in['scaffoldName'];
                                        }
                                        $scaffoldsubcategory=$sizeDet['scaffoldSubCategory'];
                        			    $selectFiledsitem=array("scaffoldSubCatName");
                                        $whereClauseitem = "scaffoldSubCateId=".$scaffoldsubcategory;
                                        $resitem_in=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["SCAFFOLDSUBCATEGORY"],$selectFiledsitem,$whereClauseitem);
                                        if($resitem_in[1] > 0){
                                            $itemList_in = $db->fetchArray($resitem_in[0]);
                                            $usersArr[$key]["requestSizeList"][$a]["scaffoldsubcategory"]=$itemList_in['scaffoldSubCatName'];
                                        }
                                        $usersArr[$key]["requestSizeList"][$a]["size"]=$scaffoldtypename."-".$sizeDet['length']."mL x ".$sizeDet['width']."mW x ".$sizeDet['height']."mH"." x ".$sizeDet['setcount']." No's";
                                        $a++;
                                    }
                                }
                            }
                            else if($item["workBased"] == 2){
                                $usersArr[$key]["workbasedon"]="ManPower";
                                $selectFiledsMan=array("id","itemListId","safety","supervisor","erectors","generalWorker","timeIn", "timeOut");
                                $whereClauseMan = "workRequestId='".$wrequestid."' and itemListId=".$item["id"];
                                $resMan=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTMANPOWER"],$selectFiledsMan,$whereClauseMan);
                                if($resMan[1] > 0){
                                    $manList = $db->fetchArray($resMan[0],1);
                                    $j=0;
                                    foreach($manList as $manDet){
                                        $safety=$manDet['safety'];
                                        $supervisor=$manDet['supervisor'];
                                        $erectors=$manDet['erectors'];
                                        $genworker=$manDet['generalWorker'];
                                        $timein=$manDet['timeIn'];
                                        $timeout=$manDet['timeOut'];
                                        $usersArr[$key]["requestmanpower"][$b]=array("safety"=>$safety,"supervisor"=>$supervisor,"erectors"=>$erectors,"generalworker"=>$genworker,"timein"=>$timein,"timeout"=>$timeout);
                                        $b++;
                                    }
                                }
                            }
                            $k++;
                        }
                    }
    			}
    		}
        }
		return $this->common->arrayToJson($usersArr);
    }
	
    function getWorkRequestDetails($postArr){

        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("workRequestId","projectId","clientId","requestedBy","contractType","scaffoldRegister","remarks","description", "status","drawingAttach","drawingImage","completionImages","location");
    	$whereClause = "workRequestId='".$postArr["listingId"]."'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$selectFileds,$whereClause);
		// pr($db);
		$requestArr = array();
		if($res[1] > 0){
            $requestArr["requestDetails"] = $db->fetchArray($res[0]);
            if(!empty($requestArr["requestDetails"]['drawingImage']))
            {
                $tempimgname=BASEPATH.$requestArr["requestDetails"]['drawingImage'];
                $requestArr["requestDetails"]['drawingImage'] = $tempimgname;
            }
            else{
                $requestArr["requestDetails"]['drawingImage'] = "";
            }
            if(!empty($requestArr["requestDetails"]['completionImages']))
            {
                $tempimgsname=explode(",",$requestArr["requestDetails"]['completionImages']);
                for($ik=0;$ik<count($tempimgsname);$ik++)
                {
                    $tempimgsname[$ik]=BASEPATH.$tempimgsname[$ik];
                }
                $requestArr["requestDetails"]['completionImages']=$tempimgsname;
            }
            else{
                $requestArr["requestDetails"]['completionImages']="";
            }
            
            $selectFiledsitem=array("id","workRequestId","itemId","sizeType","previousWR","workBased","contractType");
            $whereClauseitem = "workRequestId='".$postArr["listingId"]."'";
            $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTITEMS"],$selectFiledsitem,$whereClauseitem);
            if($resitem[1] > 0){
                $itemList = $db->fetchArray($resitem[0],1);
                $k=0;
                $a =0;
                $b=0;
                foreach($itemList as $item){

                    if($item["workBased"] == 1){
                        $selectFiledsSize=array("id","itemListId","scaffoldType","scaffoldWorkType","scaffoldSubCategory","length","height", "width","setcount");
                        $whereClauseSize = "workRequestId='".$postArr["listingId"]."' and itemListId=".$item["id"];
                        $resSize=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTSIZEBASED"],$selectFiledsSize,$whereClauseSize);
                        $requestArr["requestItems"][$k] = $item;

                        if($resSize[1] > 0){
                            $sizeList = $db->fetchArray($resSize[0],1);
                            $i=0;
                            foreach($sizeList as $sizeDet){
                                
                                $requestArr["requestSizeList"][$a] = $sizeDet;
                                $requestArr["requestItems"][$k]["sizeList"] = $sizeDet;
                                // if($item["contractType"] == 2)
                                    $a++;
                            }
                           
                        }
                    }
                    else if($item["workBased"] == 2){

                        $selectFiledsMan=array("id","itemListId","safety","supervisor","erectors","generalWorker","timeIn", "timeOut");
                        $whereClauseMan = "workRequestId='".$postArr["listingId"]."' and itemListId=".$item["id"];
                        $resMan=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTMANPOWER"],$selectFiledsMan,$whereClauseMan);
                        $requestArr["requestItems"][$k] = $item;

                        if($resMan[1] > 0){
                            $manList = $db->fetchArray($resMan[0],1);
                            $j=0;
                            foreach($manList as $manDet){
                                $requestArr["requestManList"][$b] = $manDet;
                                $requestArr["requestItems"][$k]["manpowerList"] = $manDet;
                                // if($item["contractType"] == 2)
                                    $b++;
                            }
                        }
                    }
                    $k++;
                    // $a++;
                }
            }
        }
        
        return $this->common->arrayToJson($requestArr);

    }
    function fileGetContents($uniqueId, $photoName){
        $path = "images/".$uniqueId."/".$photoName;

        $extensions= array("jpeg","jpg","png");
        $content = "";
        if(file_exists($path.".jpeg")){
            // $content = file_get_contents($path.".jpeg");
            $content = $path.".jpeg";
        }
        else if(file_exists($path.".jpg")){
            // $content = file_get_contents($path.".jpg");
            $content = $path.".jpg";
        }
        else if(file_exists($path.".png")){
            // $content = file_get_contents($path.".png");
            $content = $path.".png";

        }
        return $content;

    }

    function createDailyWorkTrack($postArr){
        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		
       
			$insertArr["projectId"]=trim($postArr["value_projects"]);
			$insertArr["clientId"]=trim($postArr["value_clients"]);
			$insertArr["type"]=trim($postArr["cType"]);
			$insertArr["requestedBy"]=trim($postArr["requestBy"]);
            $insertArr["remarks"]=trim($postArr["remarks"]);
            $insertArr["workRequestId"] = trim($postArr["value_wrno"]);
            //$insertArr["supervisor"]=trim($postArr["value_supervisor"]);
            $fieldsupervisors=$postArr["fieldSupervisors"];
            $fieldsuper=array();
            foreach($fieldsupervisors as $value){
                if($value['selected'] && $value['selected']==true)
                {
                    $fieldsuper[]=$value['userId'];
                }
            }
            $supervisors=implode(",",$fieldsuper);
            $insertArr["supervisor"]=$supervisors;
            $insertArr["baseSupervisor"]=trim($postArr["value_basesupervisor"]);
             $insertArr["matMisuse"]=trim($postArr["matMisuse"]);
            $insertArr["matRemarks"] = trim($postArr["matmisueremarks"]);
			$insertArr["matPhotos"]=$this->fileGetContents(trim($postArr["uniqueId"]),"matPhotos");
            $insertArr["safetyVio"]=trim($postArr["safetyvio"]);
            $insertArr["safetyRemarks"]=trim($postArr["safetyvioremarks"]);	
            $insertArr["safetyPhoto"]=$this->fileGetContents(trim($postArr["uniqueId"]),"safetyPhoto");
           $insertArr["createdOn"] = date("Y-m-d H:i:s");	
           $insertArr["status"] = trim($postArr["listingstatus"]);
           $insertArr["uniqueId"] = trim($postArr["uniqueId"]);
           $insertArr["createdBy"] = trim($postArr["userId"]);
        

			$dbm = new DB;
			$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
			
            $insid = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACK"],$insertArr,1,2);
          
			if($insid != 0 && $insid != ''){ 
                
                // insert photos for Others
                if($postArr["cType"] == 2){
                   
                    $this->insertPhotos($postArr, $insid, 0, $postArr["uniqueId"], $dbm, $dbcon);
                }
               
                $insid2 = $this->insertDWTRItemList($postArr,$insid, $dbm, $dbcon);
                $this->insertDifferentTiming($postArr, $insid, $dbm, $dbcon);
            }
			
			$dbm->dbClose();
			if($insid == 0 || $insid == ''){ 
				$returnval["response"] ="fail";
				$returnval["responsecode"] = 0; 
			}else { 
				
				$returnval["response"] ="success";
				$returnval["responsecode"] = 1; 
				
				
				}
		
		return $this->common->arrayToJson($returnval);
    }

    function updateDailyWorkTrack($postArr){
        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		
       
			$insertArr["projectId"]=trim($postArr["value_projects"]);
			$insertArr["clientId"]=trim($postArr["value_clients"]);
			$insertArr["type"]=trim($postArr["cType"]);
			$insertArr["requestedBy"]=trim($postArr["requestBy"]);
            $insertArr["remarks"]=trim($postArr["remarks"]);
            $insertArr["workRequestId"] = trim($postArr["value_wrno"]);
            $insertArr["photo_1"]=$this->fileGetContents(trim($postArr["uniqueId"]),"photo_1");
            $insertArr["photo_2"]=$this->fileGetContents(trim($postArr["uniqueId"]),"photo_2");
            $insertArr["photo_3"]=$this->fileGetContents(trim($postArr["uniqueId"]),"photo_3");
            //$insertArr["supervisor"]=trim($postArr["value_supervisor"]);
            $fieldsupervisors=$postArr["supervisors"];
            $fieldsuper=array();
            foreach($fieldsupervisors as $value){
                if($value['selected'] && $value['selected']==true)
                {
                    $fieldsuper[]=$value['userId'];
                }
            }
            $supervisors=implode(",",$fieldsuper);
            $insertArr["supervisor"]=$supervisors;	
            $insertArr["baseSupervisor"]=trim($postArr["value_basesupervisor"]);
             $insertArr["matMisuse"]=trim($postArr["matMisuse"]);
            $insertArr["matRemarks"] = trim($postArr["matmisueremarks"]);
			$insertArr["matPhotos"]=$this->fileGetContents(trim($postArr["uniqueId"]),"matPhotos");
            $insertArr["safetyVio"]=trim($postArr["safetyvio"]);
            $insertArr["safetyRemarks"]=trim($postArr["safetyvioremarks"]);	
            $insertArr["safetyPhoto"]=$this->fileGetContents(trim($postArr["uniqueId"]),"safetyPhoto");
           //$insertArr["createdOn"] = date("Y-m-d H:i:s");	
           $insertArr["status"] = trim($postArr["listingstatus"]);
           $insertArr["uniqueId"] = trim($postArr["uniqueId"]);
        
           $worktrackId = $postArr["listingId"];
			$dbm = new DB;
            $dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
            $whereClause = "worktrackId=".$worktrackId;


			
            $insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACK"],$insertArr, $whereClause);

            $delete1 = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKSUBDIVISION"],$whereClause);
            $delete2 = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKTEAMS"],$whereClause);
            $delete3 = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKMATERIALS"],$whereClause);
            // $whereClause = "DWTRId=".$worktrackId;
            // $delete4 = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["DWTRPHOTOS"],$whereClause);

            $insid2 = $this->insertDWTRItemList($postArr,$worktrackId , $dbm, $dbcon);
            if($insid2 != 0 && $insid2 != ''){ 

                // insert photos for Others
                if($postArr["cType"] == 2){
                   
                    $this->insertPhotos($postArr, $insid, 0, $postArr["uniqueId"], $dbm, $dbcon);
                }
                
                $this->insertDifferentTiming($postArr, $worktrackId, $dbm, $dbcon);
                
            }
         
			
			$dbm->dbClose();
			
            $returnval["response"] ="success";
            $returnval["responsecode"] = 1; 
				
				
			
		
		return $this->common->arrayToJson($returnval);
    }

    function insertDWTRItemList($postArr, $insid, $dbm, $dbcon){
        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;

        foreach($postArr["itemList"] as $item){

            $insertArr2["workTrackId"]=$insid;
            $insertArr2["workRequestId"]=trim($item["wr_no"]);
            $insertArr2["subDivisionId"]=trim($item["value_subdivision"]);
            $insertArr2["timing"]=trim($postArr["timing"]);
            $insertArr2["length"]=trim($item["L"]);
            $insertArr2["height"]=trim($item["H"]);
            $insertArr2["width"]=trim($item["W"]);
            $insertArr2["setcount"]=trim($item["set"]);
            $insertArr2["status"]=trim($item["value_workstatus"]);
            $insertArr2["cLength"]=trim($item["cL"]);

            $insertArr2["cHeight"]=trim($item["cH"]);
            $insertArr2["cWidth"]=trim($item["cW"]);
            $insertArr2["cSetcount"]=trim($item["cset"]);
            $insertArr2["createdOn"]=date("Y-m-d H:i:s");

            $this->insertPhotos($item, $insid, trim($item["value_subdivision"]), $item["uniqueId"], $dbm, $dbcon);
            

            $insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKSUBDIVISION"],$insertArr2,1,2);
           
        }

        return $insid2;
    }

    function insertSameTiming($postArr, $insid, $dbm, $dbcon){
        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;

        foreach($postArr["itemList"] as $item1){
                                
            foreach($postArr["teamList"] as $team){                                  
                    $insertArrTeam["workTrackId"]=$insid;
                    $insertArrTeam["subDevisionId"]=$item1["value_subdivision"];
                    $insertArrTeam["teamId"]=trim($team["value_team"]);
                    $insertArrTeam["workerCount"]=trim($team["workerCount"]);
                    $insertArrTeam["inTime"]=trim($team["inTime"]);
                    $insertArrTeam["outTime"]=trim($team["outTime"]);
                    $insertArrTeam["createdOn"]=date("Y-m-d H:i:s");
                    $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKTEAMS"],$insertArrTeam,1,2);
            }
       
            foreach($postArr["materialList"] as $material){
                $insertArrMaterial["workTrackId"]=$insid;
                $insertArrMaterial["subDevisionId"]=$item1["value_subdivision"];
                $insertArrMaterial["material"]=trim($material["value_materials"]);
                $insertArrMaterial["workerCount"]=trim($material["mWorkerCount"]);
                $insertArrMaterial["inTime"]=trim($material["minTime"]);
                $insertArrMaterial["outTime"]=trim($material["moutTime"]);
                $insertArrMaterial["createdOn"]=date("Y-m-d H:i:s");
                $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKMATERIALS"],$insertArrMaterial,1,2);
            
            }
        }
        
    }

    function insertDifferentTiming($postArr, $insid, $dbm, $dbcon){
        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;

        if(count($postArr["teamList"]) > 0){
            foreach($postArr["teamList"] as $team){
                $insertArrTeam["workTrackId"]=$insid;
                $insertArrTeam["subDevisionId"]=$team["subdivision"];
                $insertArrTeam["teamId"]=trim($team["value_team"]);
                $insertArrTeam["workerCount"]=trim($team["workerCount"]);
                $insertArrTeam["inTime"]=trim($team["inTime"]);
                $insertArrTeam["outTime"]=trim($team["outTime"]);
                $insertArrTeam["createdOn"]=date("Y-m-d H:i:s");
                $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKTEAMS"],$insertArrTeam,1,2);
            }
        }
        if(count($postArr["materialList"]) > 0){
            foreach($postArr["materialList"] as $material){
                $insertArrMaterial["workTrackId"]=$insid;
                $insertArrMaterial["subDevisionId"]=$material["subdivision"];
                $insertArrMaterial["material"]=trim($material["value_materials"]);
                $insertArrMaterial["workerCount"]=trim($material["workerCount"]);
                $insertArrMaterial["inTime"]=trim($material["inTime"]);
                $insertArrMaterial["outTime"]=trim($material["outTime"]);
                $insertArrMaterial["createdOn"]=date("Y-m-d H:i:s");
                $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKMATERIALS"],$insertArrMaterial,1,2);
            }
        }

    }

    function getDailyWorkTrackList($postArr){
        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("worktrackId","projectId","clientId","requestedBy","remarks","workRequestId","createdBy","createdOn");

		if($postArr["startDate"] && $postArr["startDate"]!=""){
			$addCond = "date(createdOn)='".$postArr["startDate"]."'";
		}
		else{
			$addCond = "date(createdOn)='".date("Y-m-d")."'";
		}		
		$whereClause = "status=".$postArr["requestType"]." AND $addCond order by workRequestId desc";
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACK"],$selectFileds,$whereClause);
		// pr($db);
		$usersArr = array();
		if($res[1] > 0){
			$usersArr = $db->fetchArray($res[0], 1);
			foreach($usersArr as $key=>$trackvalue)
			{
               // $usersArr[$key]["createdByName"]=$key;
              //  $usersArr[$key]["createdByVal"]=$trackvalue[$createdBy];
                $selectFiledsitem11=array("Name");
                        $whereClauseitem11 = "userId=".$trackvalue['createdBy'];
                        $resitem11=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFiledsitem11,$whereClauseitem11);
                        if($resitem11[1] > 0){
                            $itemList11 = $db->fetchArray($resitem11[0]);
                            $usersArr[$key]["createdByName"] =$itemList11['Name'];
                            
                        }else{
                            $usersArr[$key]["createdByName"]="";
                        }
                $usersArr[$key]["requestItems"]=[];
			    $usersArr[$key]["requestSizeList"]=[];
                $usersArr[$key]["requestMatList"]=[];                  
			    $wtrackid=$trackvalue["worktrackId"];
                $selectFiledsitem=array("id","workRequestId", "subDivisionId","length", "height","width","setcount","status");
                $whereClauseitem = "worktrackId='".$wtrackid."'";
                $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKSUBDIVISION"],$selectFiledsitem,$whereClauseitem);
                if($resitem[1] > 0){
                    $itemList = $db->fetchArray($resitem[0],1);
                    $k=0;
                    foreach($itemList as $item){
                        $item["WR_text"] = "WR".str_pad($item["workRequestId"], 4, '0', STR_PAD_LEFT);
                        if($item["status"]==1){
                            $cstatus="Ongoing";
                        }
                        else if($item["status"]==1){
                            $cstatus="Completed";
                        }
                        else{
                            $cstatus="Full Size";
                        }
                        $item["expanditems"]=$item["length"]."mL x ".$item["width"]."mW x ".$item["height"]."mH - "." X ".$item["setcount"]." No's";
                        $usersArr[$key]["requestItems"][$k] = $item;
                        
                        $k++;
                    }
                }
                $selectFiledsSize=array("id","subDevisionId","workTrackId","teamId","workerCount","inTime","outTime");
                $whereClauseSize = "workTrackId='".$wtrackid."'";
                $resSize=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKTEAMS"],$selectFiledsSize,$whereClauseSize);
                if($resSize[1] > 0){
                    $sizeList = $db->fetchArray($resSize[0],1);
                    $i=0;
                    foreach($sizeList as $sizeDet){
                        $teamid=$sizeDet["teamId"];
                        $sizeDet["teamname"]='';
                        $selectFiledsteam=array("teamName");
                        $whereClauseteam = "teamid='".$teamid."'";
                        $resteam=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["TEAM"],$selectFiledsteam,$whereClauseteam);
                        if($resteam[1] > 0){
                            $teamname = $db->fetchArray($resteam[0]);
                            $sizeDet["teamname"]=$teamname["teamName"];
                        }
                        $sizeDet["expandteams"]=$sizeDet["teamname"]." - ".$sizeDet["inTime"]." to ".$sizeDet["outTime"];
                        $usersArr[$key]["requestSizeList"][$i] = $sizeDet;
                        $i++;
                    }
                    
                }
                $selectFiledsMan=array("id","workTrackId","subDevisionId","material","workerCount","inTime","outTime");
                $whereClauseMan = "workTrackId='".$wtrackid."'";
                $resMan=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKMATERIALS"],$selectFiledsMan,$whereClauseMan);
                if($resMan[1] > 0){
                    $manList = $db->fetchArray($resMan[0],1);
                    $j=0;
                    foreach($manList as $manDet){
                        $materialid=$manDet["material"];
                        $manDet["materialname"]='';
                        $selectFiledsmat=array("materialName");
                        $whereClausemat = "id='".$materialid."'";
                        $resmat=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["MATERIAL"],$selectFiledsmat,$whereClausemat);
                        if($resmat[1] > 0){
                            $materialname = $db->fetchArray($resmat[0]);
                            $manDet["materialname"]=$materialname["materialName"];
                        }
                        $manDet["expandmaterials"]=$manDet["materialname"]." - ".$manDet["inTime"]." to ".$manDet["outTime"];
                        $usersArr[$key]["requestMatList"][$j] = $manDet;
                        $j++;
                    }
                }
			}
		}
		// pr($usersArr);
 
		return $this->common->arrayToJson($usersArr);
    }

    function getDailyWorkTrackDetails($postArr){

        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("worktrackId","projectId","clientId","requestedBy","type","remarks","workRequestId","supervisor","matMisuse","matRemarks","safetyVio","safetyRemarks", "safetyPhoto", "matPhotos","uniqueId","baseSupervisor","status");
    	$whereClause = "worktrackId='".$postArr["listingId"]."'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACK"],$selectFileds,$whereClause);
		// pr($db);
        $requestArr = array();

       
        
		if($res[1] > 0){
            $listArr = $db->fetchArray($res[0]);

            $temp_supervisor=$listArr["supervisor"];
            $listArr["supervisor"]=explode(",",$temp_supervisor);
            $photosOther = $this->getDWTRPhotos($postArr["listingId"],0);
            $listArr["photo_1"] = $photosOther["photo_1"];
            $listArr["photo_2"] = $photosOther["photo_2"];
            $listArr["photo_3"] = $photosOther["photo_3"];
           
           
				$invID = str_pad($listArr["workRequestId"], 4, '0', STR_PAD_LEFT);
                $listArr["workRequestStrId"] = "WR".$invID;
				$requestArr["requestDetails"]= $listArr;
			
            
            $selectFiledsitem=array("id","workTrackId","workRequestId", "subDivisionId","timing","length", "height","width","setcount","status","cLength","cHeight","cWidth","cSetcount","diffSubDivision");
            $whereClauseitem = "worktrackId='".$postArr["listingId"]."'";
            $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKSUBDIVISION"],$selectFiledsitem,$whereClauseitem);
            if($resitem[1] > 0){
                $itemList = $db->fetchArray($resitem[0],1);
                $k=0;
                foreach($itemList as $item){
                        $photos = $this->getDWTRPhotos($item["workTrackId"], $item["subDivisionId"]);
                        $item["photo_1"] = $photos["photo_1"];
                        $item["photo_2"] = $photos["photo_2"];
                        $item["photo_3"] = $photos["photo_3"];
                        $item["WR_text"] = "WR".str_pad($item["workRequestId"], 4, '0', STR_PAD_LEFT);
                        $requestArr["requestItems"][$k] = $item;
                        $k++;
                }
            }
            $selectFiledsSize=array("id","subDevisionId","workTrackId","teamId","workerCount","inTime","outTime");
            $whereClauseSize = "workTrackId='".$postArr["listingId"]."'";
            $resSize=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKTEAMS"],$selectFiledsSize,$whereClauseSize);
            if($resSize[1] > 0){
                $sizeList = $db->fetchArray($resSize[0],1);
                $i=0;
                foreach($sizeList as $sizeDet){
                    $requestArr["requestSizeList"][$i] = $sizeDet;
                    $i++;
                }
                
            }
                

            $selectFiledsMan=array("id","workTrackId","subDevisionId","material","workerCount","inTime","outTime");
            $whereClauseMan = "workTrackId='".$postArr["listingId"]."'";
            $resMan=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKMATERIALS"],$selectFiledsMan,$whereClauseMan);
            

            if($resMan[1] > 0){
                $manList = $db->fetchArray($resMan[0],1);
                $j=0;
                foreach($manList as $manDet){
                    $requestArr["requestMatList"][$j] = $manDet;
                    $j++;
                }
            }
                
            
        }
        
        return $this->common->arrayToJson($requestArr);

    }

    function insertPhotos($postArr, $dwtrId, $WRSubdivision, $uniqueId, $dbm, $dbcon) {

        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
        if($postArr["photo_1"] != "" || $postArr["photo_2"] != "" || $postArr["photo_3"] != ""){
            $insertPhotoArr["DWTRId"] = $dwtrId;
            $insertPhotoArr["WRSubdivision"] = $WRSubdivision;
            $insertPhotoArr["photo_1"]=$this->fileGetContents(trim($uniqueId),"photo_1");
            $insertPhotoArr["photo_2"]=$this->fileGetContents(trim($uniqueId),"photo_2");
            $insertPhotoArr["photo_3"]=$this->fileGetContents(trim($uniqueId),"photo_3");
    
            $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DWTRPHOTOS"],$insertPhotoArr,1,2);
        }

       

    }

    function getDWTRPhotos($DWTRId, $subDevisionId){
        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;

        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
        $dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
        
        $selectFiledsMan=array("photo_1","photo_2","photo_3");
       $whereClauseMan = "DWTRId=$DWTRId and WRSubdivision=$subDevisionId";
        $resMan=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DWTRPHOTOS"],$selectFiledsMan,$whereClauseMan);
        $photos = $db->fetchArray($resMan[0]);

        return $photos;
		
    }

    function imageUploads($postArr){
        $errors = "";
        if(isset($_FILES['image'])){
           
            $errors= array();
            $file_name = $_FILES['image']['name'];
            $file_size =$_FILES['image']['size'];
            $file_tmp =$_FILES['image']['tmp_name'];
            $file_type=$_FILES['image']['type'];            
            $file_ext_orginal=end(explode('.',$_FILES['image']['name']));
            $file_ext=strtolower(end(explode('.',$_FILES['image']['name'])));
            
            $extensions= array("jpeg","jpg","png");
            
            if(in_array($file_ext,$extensions)=== false){
                $errors="extension not allowed, please choose a JPEG or PNG file.";
            }
            
            if($file_size > 2097152){
               $errors='File size must be excately 2 MB';
            }

            if(trim($errors) == ""){
               
                mkdir("images/".$postArr["uniqueId"]);
                if(move_uploaded_file($file_tmp,"images/".$postArr["uniqueId"]."/".$postArr["imagefor"].".".$file_ext_orginal)){
                    $returnval["response"] ="success";
                    $returnval["responsecode"] = 1; 
                }
                else{
                    $returnval["response"] ="error";
				$returnval["responsecode"] = 0; 
                }
               
            }else{
                $returnval["response"] =$errors;
				$returnval["responsecode"] = 0; 
              
            }

         }
         return $this->common->arrayToJson($returnval);
    }
	function completeimageuploads($postArr){
	    global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
        $dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
        
        $wrequestid=$postArr['workrequestid'];
        $upload_url_temp=array();
        $selectFiledsSize=array("completionImages");
        $whereClauseSize = "workRequestId='".$wrequestid."'";
        $resSize=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$selectFiledsSize,$whereClauseSize);
        if($resSize[1] > 0){
            $workList = $db->fetchArray($resSize[0]);
            if($workList["completionImages"])
            {
                $upload_url_temp=explode(",",$workList["completionImages"]);
            }
        }
	    
        if(isset($_FILES['images'])){
            $filecount=count($_FILES['images']['name']);
            $upload_url=array();
            $folderpath="images/completedimage/";
            
            for($i=0;$i<$filecount;$i++)
            {
                $file_name = $_FILES['images']['name'][$i];
                $file_size =$_FILES['images']['size'][$i];
                $file_ext=strtolower(end(explode('.',$file_name)));
                $extensions= array("jpeg","jpg","png","pdf");
                if(in_array($file_ext,$extensions)=== false){
                    $returnval["response"] ="Extension not allowed, Please choose a JPEG, PNG or PDF each file.";
    			    $returnval["responsecode"] = 0;
                    return $this->common->arrayToJson($returnval);
                }
                if($file_size > 500000){
                    $returnval["response"] ="Each File size must be below 500 kb";
    			    $returnval["responsecode"] = 0;
                    return $this->common->arrayToJson($returnval);
                }
            }
            
            if(!file_exists($folderpath.$postArr["uniqueId"])) {
                mkdir($folderpath.$postArr["uniqueId"], 0777, true);
            }
            
            $count=count($upload_url_temp);
            for($i=0;$i<$filecount;$i++)
            {
                $file_name = $_FILES['images']['name'][$i];
                $file_size =$_FILES['images']['size'][$i];
                $file_tmp =$_FILES['images']['tmp_name'][$i];   
                $file_ext_orginal=end(explode('.',$file_name));
                $file_ext=strtolower(end(explode('.',$file_name)));
                
                $filepath=$folderpath.$postArr["uniqueId"]."/".($count+($i+1)).'_'.time().".".$file_ext_orginal;
                if(move_uploaded_file($file_tmp,$filepath)){
                    $upload_url[]=BASEPATH.$filepath;
                    $upload_url_temp[]=$filepath;
                }
            }
            
            if(!empty($upload_url_temp))
            {   
                $insertArr=array();
                $uploadimg=implode(",",$upload_url_temp);
                global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
                $connection = mysqli_connect("localhost", $DBINFO["USERNAME"], $DBINFO["PASSWORD"], $DBNAME["NAME"]);

                $sql = "UPDATE ".$TABLEINFO["WORKREQUEST"]." SET completionImages='".$uploadimg."' WHERE workRequestId=".$wrequestid;
                $insid = mysqli_query($connection, $sql);
                if($insid)
                {
                    $returnval["response"] ="Image upload success";
                    $returnval["imageurl"] =$upload_url;
        		    $returnval["responsecode"] = 1;
        		    return $this->common->arrayToJson($returnval);
                }
                else
                {
                    $returnval["response"] ="File Upload Failure";
    			    $returnval["responsecode"] = 0;
    			    return $this->common->arrayToJson($returnval);
                }
            }
            else
            {
                $returnval["response"] ="File Upload Failure";
			    $returnval["responsecode"] = 0;
			    return $this->common->arrayToJson($returnval);
            }
        }
        else
        {
            $returnval["response"] ="Image Need to Upload";
		    $returnval["responsecode"] = 0;
            return $this->common->arrayToJson($returnval);
        }
    }
	function drawingimageupload($postArr){
        if(isset($_FILES['drawingimage'])){
            $file_name = $_FILES['drawingimage']['name'];
            $file_size =$_FILES['drawingimage']['size'];
            $file_tmp =$_FILES['drawingimage']['tmp_name'];   
            $file_ext_orginal=end(explode('.',$file_name));
            $file_ext=strtolower(end(explode('.',$file_name)));
            
            $extensions= array("jpeg","jpg","png","pdf");
            if(in_array($file_ext,$extensions)=== false){
                $returnval["response"] ="Extension not allowed, Please choose a JPEG, PNG or PDF file.";
			    $returnval["responsecode"] = 0;
                return $this->common->arrayToJson($returnval);
            }
            if($file_size > 500000){
                $returnval["response"] ="File size must be below 500 kb";
                $returnval["responsecode"] = 0;
                return $this->common->arrayToJson($returnval);
            }
            if(!file_exists("images/drawingimage/".$postArr["uniqueId"])) {
                mkdir("images/drawingimage/".$postArr["uniqueId"], 0777, true);
            }
            $filepath="images/drawingimage/".$postArr["uniqueId"]."/".time().".".$file_ext_orginal;
            if(!move_uploaded_file($file_tmp,$filepath)){
                $returnval["response"] ="Error in image upload";
                $returnval["responsecode"] = 0; 
                return $this->common->arrayToJson($returnval);
            }
            
            $returnval["response"] ="Image upload success";
            $returnval["imageurl"] =$filepath;
            $returnval["basepath"] =BASEPATH;
		    $returnval["responsecode"] = 1;
            return $this->common->arrayToJson($returnval);
        }
        else
        {
            $returnval["response"] ="Image Need to Upload";
		    $returnval["responsecode"] = 0;
            return $this->common->arrayToJson($returnval);
        }
    }
}

?>