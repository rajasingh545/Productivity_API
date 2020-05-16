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
                    $insertSizeArr["scaffoldSubCategory"] = $itemList["value_scaffoldSubCategory"];
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
                        $insertSizeArr["workRequestId"] = $insid;
                        $insertSizeArr["itemListId"] = $insid2;
                        $insertSizeArr["scaffoldType"] = $itemList["value_scaffoldType"];
                        $insertSizeArr["scaffoldWorkType"] = $itemList["value_scaffoldWorkType"];
                        $insertSizeArr["scaffoldSubCategory"] = $itemList["value_scaffoldSubcategory"];
                        $insertSizeArr["length"] = $itemList["L"];
                        $insertSizeArr["height"] = $itemList["H"];
                        $insertSizeArr["width"] = $itemList["W"];
                        $insertSizeArr["setcount"] = $itemList["set"];
                        $insertSizeArr["ItemUniqueId"]=$wrUniqueId;
                        $insertSizeArr["createdOn"] = date("Y-m-d H:i:s");
                       
                        $insid3 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTSIZEBASED"],$insertSizeArr,1,2);
                       
                    }
                    if($itemList["workBased"] == 2){ //manpower
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
                       
                    }

                }
                $i++;
        }
    }

	function getWorkRequestList($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("workRequestId","projectId","clientId","requestedBy");

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
		}
		// pr($usersArr);
 
		return $this->common->arrayToJson($usersArr);
    }
    
    function getWorkRequestDetails($postArr){

        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("workRequestId","projectId","clientId","requestedBy","contractType","scaffoldRegister","remarks","description");
    	$whereClause = "workRequestId='".$postArr["listingId"]."'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$selectFileds,$whereClause);
		// pr($db);
		$requestArr = array();
		if($res[1] > 0){
            $requestArr["requestDetails"] = $db->fetchArray($res[0]);
            
            $selectFiledsitem=array("id","workRequestId","itemId","sizeType","previousWR","workBased","contractType");
            $whereClauseitem = "workRequestId='".$postArr["listingId"]."'";
            $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTITEMS"],$selectFiledsitem,$whereClauseitem);
            if($resitem[1] > 0){
                $itemList = $db->fetchArray($resitem[0],1);
                $k=0;
                $a =0;
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
                                if($item["contractType"] == 2)
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
                                $requestArr["requestManList"][$a] = $manDet;
                                if($item["contractType"] == 2)
                                    $a++;
                            }
                        }
                    }
                    $k++;
                    $a++;
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
			$insertArr["type"]=trim($postArr["cType"]);;
			$insertArr["requestedBy"]=trim($postArr["requestBy"]);
            $insertArr["remarks"]=trim($postArr["remarks"]);
            $insertArr["workRequestId"] = trim($postArr["value_wrno"]);
            $insertArr["photo_1"]=$this->fileGetContents(trim($postArr["uniqueId"]),"photo_1");
            $insertArr["photo_2"]=$this->fileGetContents(trim($postArr["uniqueId"]),"photo_2");
            $insertArr["photo_3"]=$this->fileGetContents(trim($postArr["uniqueId"]),"photo_3");
            $insertArr["supervisor"]=trim($postArr["value_supervisor"]);
            	
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
        

			
			$dbm = new DB;
			$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
			
            $insid = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACK"],$insertArr,1,2);
          
			if($insid != 0 && $insid != ''){ 
                foreach($postArr["itemList"] as $item){

                    $insertArr2["workTrackId"]=$insid;
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
                    $insertArr2["diffSubDivision"]=trim($item["value_subdivision2"]);
                    $insertArr2["createdOn"]=date("Y-m-d H:i:s");
                    

                    $insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKSUBDIVISION"],$insertArr2,1,2);
                }
                    if($insid2 != 0 && $insid2 != ''){ 

                        if($postArr["timing"] == 1){ //same timing

                            foreach($postArr["itemList"] as $item1){
                                
                                foreach($postArr["teamList"] as $team){                                  
                                        $insertArrTeam["workTrackId"]=$insid;
                                        $insertArrTeam["subDevisionId"]=$item1["value_subdivision"];
                                        $insertArrTeam["teamId"]=trim($team["value_team"]);
                                        $insertArrTeam["workerCount"]=trim($team["workerCount"]);
                                        $insertArrTeam["inTime"]=trim($team["inTime"]);
                                        $insertArrTeam["outTime"]=trim($team["outTime"]);
                                        $insertArrTeam["createdOn"]=date("Y-m-d H:i:s");
                                        $insid3 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKTEAMS"],$insertArrTeam,1,2);
                                }
                           
                                foreach($postArr["materialList"] as $material){
                                    $insertArrMaterial["workTrackId"]=$insid;
                                    $insertArrMaterial["subDevisionId"]=$item1["value_subdivision"];
                                    $insertArrMaterial["material"]=trim($material["value_materials"]);
                                    $insertArrMaterial["workerCount"]=trim($material["mWorkerCount"]);
                                    $insertArrMaterial["inTime"]=trim($material["minTime"]);
                                    $insertArrMaterial["outTime"]=trim($material["moutTime"]);
                                    $insertArrMaterial["createdOn"]=date("Y-m-d H:i:s");
                                    $insid4 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKMATERIALS"],$insertArrMaterial,1,2);
                                
                                }
                            }

                        }
                        else{ //different timing
                        
                            if(count($postArr["teamList"]) > 0){
                                foreach($postArr["teamList"] as $team){
                                    $insertArrTeam["workTrackId"]=$insid;
                                    $insertArrTeam["subDevisionId"]=$team["value_subdivision2"];
                                    $insertArrTeam["teamId"]=trim($team["value_team"]);
                                    $insertArrTeam["workerCount"]=trim($team["workerCount"]);
                                    $insertArrTeam["inTime"]=trim($team["inTime"]);
                                    $insertArrTeam["outTime"]=trim($team["outTime"]);
                                    $insertArrTeam["createdOn"]=date("Y-m-d H:i:s");
                                    $insid3 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKTEAMS"],$insertArrTeam,1,2);
                                }
                            }
                            if(count($postArr["materialList"]) > 0){
                                foreach($postArr["materialList"] as $material){
                                    $insertArrMaterial["workTrackId"]=$insid;
                                    $insertArrMaterial["subDevisionId"]=$material["value_subdivision2"];
                                    $insertArrMaterial["material"]=trim($material["value_materials"]);
                                    $insertArrMaterial["workerCount"]=trim($material["mWorkerCount"]);
                                    $insertArrMaterial["inTime"]=trim($material["minTime"]);
                                    $insertArrMaterial["outTime"]=trim($material["moutTime"]);
                                    $insertArrMaterial["createdOn"]=date("Y-m-d H:i:s");
                                    $insid4 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKMATERIALS"],$insertArrMaterial,1,2);
                                }
                            }

                        }
                    

                }
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

    function getDailyWorkTrackList($postArr){
        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("worktrackId","projectId","clientId","requestedBy");

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
		}
		// pr($usersArr);
 
		return $this->common->arrayToJson($usersArr);
    }

    function getDailyWorkTrackDetails($postArr){

        global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("worktrackId","projectId","clientId","requestedBy","type","remarks","workRequestId","supervisor","matMisuse","matRemarks","safetyVio","safetyRemarks","photo_1","photo_2","photo_3", "safetyPhoto", "matPhotos","uniqueId","baseSupervisor");
    	$whereClause = "worktrackId='".$postArr["listingId"]."'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACK"],$selectFileds,$whereClause);
		// pr($db);
        $requestArr = array();
        
		if($res[1] > 0){
            $listArr = $db->fetchArray($res[0]);
           
           
				$invID = str_pad($listArr["workRequestId"], 4, '0', STR_PAD_LEFT);
                $listArr["workRequestStrId"] = "WR".$invID;
				$requestArr["requestDetails"]= $listArr;
			
            
            $selectFiledsitem=array("id","workTrackId","subDivisionId","timing","length", "height","width","setcount","status","cLength","cHeight","cWidth","cSetcount","diffSubDivision");
            $whereClauseitem = "worktrackId='".$postArr["listingId"]."'";
            $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["DAILYWORKTRACKSUBDIVISION"],$selectFiledsitem,$whereClauseitem);
            if($resitem[1] > 0){
                $itemList = $db->fetchArray($resitem[0],1);
                $k=0;
                foreach($itemList as $item){
                       
                        $requestArr["requestItems"][$k] = $item;
                        $k++;
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
        }
        
        return $this->common->arrayToJson($requestArr);

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
                move_uploaded_file($file_tmp,"images/".$postArr["uniqueId"]."/".$postArr["imagefor"].".".$file_ext_orginal);
                $returnval["response"] ="success";
				$returnval["responsecode"] = 1; 
            }else{
                $returnval["response"] =$errors;
				$returnval["responsecode"] = 0; 
              
            }

         }
         return $this->common->arrayToJson($returnval);
    }
}

?>