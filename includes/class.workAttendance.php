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
		$requestType = $postArr["requestType"];
		$userID = $postArr["userId"];
		$userType = $postArr["userType"];
		$selectFileds=array("workArrangementId","projectId","baseSupervsor","addSupervsor","createdOn","remarks","createdBy");
		if($postArr["startDate"] && $postArr["startDate"]!=""){
			if($userType == 1){
				$addCond = "createdOn='".$postArr["startDate"]."'";
			}
			else{
				$addCond = "createdOn='".$postArr["startDate"]."' and (baseSupervsor = $userID or addSupervsor like '%$userID%')";
				//$addCond = "createdOn='".$postArr["startDate"]."' and (baseSupervsor = $userID)";
				
			}
			
		}
		else{
			$addCond = "createdOn='".date("Y-m-d")."'";
		}		
		if ($requestType == '')
		{
			$requestType='2';
		}
		$whereClause = "status=".$requestType." AND $addCond order by workArrangementId desc";		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFileds,$whereClause);
		$results = array();
		$projectArr = array();
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0], 1);
			foreach($projectArr as $key=>$det){
				$whereClause2 = "workArrangementId=".$det["workArrangementId"]." and isSupervisor !=1";
				$selectFileds2 = array("workerId","workerTeam");
				$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds2,$whereClause2);
				$listingDetails = array();
				if($res2[1] > 0){
					$workerids = $db->fetchArray($res2[0],1); 
					$workeridFinal = array();
					$workeridteams = array();
					$workerteamslist = array();
					foreach($workerids as $ids){
						$workeridFinal[] = $ids["workerId"];
						$workerid_team=$ids["workerTeam"];
						
						$whereClause4="teamid=".$workerid_team;	
						$selectFileds4 = array("teamName");
		                $res4=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["TEAM"],$selectFileds4,$whereClause4);
		                if($res4[1]>0)
		                {
		                    $workerteamnames = $db->fetchArray($res4[0],1);  
		                    $workerteam_name=$workerteamnames[0]['teamName'];
		                }
		                $workeridteams[]=array("worker_id"=>$ids["workerId"],"team_id"=>$workerid_team,"team_name"=>$workerteam_name);
					}
					$temp=$det['addSupervsor'];
					if(!empty($temp))
					    $det['addSupervsor']=explode(',',$temp);
					else
					    $det['addSupervsor']=[];
					$results[$key] =  $det;
					$results[$key]["workers"] = $workeridFinal;
					$results[$key]["isNew"] = true;
					$results[$key]["workersteamlist"] = $workeridteams;

					$selectFiledsitem=array("Name");
                    $whereClauseitem = "userId=".$det['createdBy'];
                    $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFiledsitem,$whereClauseitem);
                    if($resitem[1] > 0){
                        $itemList = $db->fetchArray($resitem[0]);
                        $results[$key]["createdByName"]=$itemList['Name'];
                    }
				}    
			}      	
	
		}
		else{
			$results = array(); 
		}
		
		$historysts=$postArr["requestType"];
		$historyArr=array();
		if($historysts==1)
		{
            $whereClause = "status=3 AND $addCond order by workArrangementId desc";		
            $res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFileds,$whereClause);
            $projectArr = array();
            $count_submit=count($results);
    		if($res[1] > 0){
    			$projectArr = $db->fetchArray($res[0], 1);
    			foreach($projectArr as $key=>$det){
    				$whereClause2 = "workArrangementId=".$det["workArrangementId"]." and isSupervisor !=1";
    				$selectFileds2 = array("workerId");
    				$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds2,$whereClause2);
    				$listingDetails = array();
    				if($res2[1] > 0){
    					$workerids = $db->fetchArray($res2[0],1); 
    					$workeridFinal = array();
    					$workeridteams = array();
    					foreach($workerids as $ids){
    						$workeridFinal[] = $ids["workerId"];
    						$whereClause3="workerId=".$ids["workerId"];	
    						$selectFileds3 = array("teamId");
    		                $res3=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKERS"],$selectFileds3,$whereClause3);
    		                if($res3[1] > 0){
    		                    $workerteamid = $db->fetchArray($res3[0],1);
    		                    $workerid_team=$workerteamid[0]['teamId'];
    		                    
    		                    $whereClause4="teamid=".$workerid_team;	
        						$selectFileds4 = array("teamName");
        		                $res4=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["TEAM"],$selectFileds4,$whereClause4);
        		                if($res4[1]>0)
        		                {
        		                    $workerteamnames = $db->fetchArray($res4[0],1);  
        		                    $workerteam_name=$workerteamnames[0]['teamName'];
        		                }
    		                }
    		                $workeridteams[]=array("worker_id"=>$ids["workerId"],"team_id"=>$workerid_team,"team_name"=>$workerteam_name);
    					}
    					$temp=$det['addSupervsor'];
    					if(!empty($temp))
    					    $det['addSupervsor']=explode(',',$temp);
    					else
    					    $det['addSupervsor']=[];
    					$results[$count_submit] =  $det;
    					$results[$count_submit]["workers"] = $workeridFinal;
    					$results[$count_submit]["isNew"] = false;
    					$results[$count_submit]["workersteamlist"] = $workeridteams;
    					$count_submit++;
					}    
					$selectFiledsitem=array("userName");
                    $whereClauseitem = "userId=".$det['createdBy'];
                    $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFiledsitem,$whereClauseitem);
                    if($resitem[1] > 0){
                        $itemList = $db->fetchArray($resitem[0]);
                        $results[$key]["createdByName"]=$itemList['userName'];
                    }
    			}      	
    		}
	    }
		return $this->common->arrayToJson($results);
		}
	function getWorkArrangementDetails($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$requestype = $postArr["requestType"];
		
		$workeridlist=[];
		$workassigned="";
		$whereClause = "workArrangementId=".$postArr["listingId"];
		$selectFileds2 = array("workerId","forDate");
		$selecteddate='';
		$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds2,$whereClause);
		if($res2[1] > 0){
		    $workerids = $db->fetchArray($res2[0],1);
		    foreach($workerids as $ids){
		        $workeridlist[] = $ids["workerId"];
		        $selecteddate=$ids["forDate"];
		    }
		    if(!empty($workeridlist))
		    {
		        $workeridlist=implode(',',$workeridlist);
		        $whereClause = "workerId IN(".$workeridlist.") and forDate='".$selecteddate."' and (partial=0 or (partial=1 and outTime='00:00:00')) and draftStatus=1";
        		$selectFileds2 = array("workerId");
        		$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds2,$whereClause);
        		if($res2[1] > 0){
        		    $workassigned="Worker or Supervisor Already Assigned Project";
        		}
		    }
		}
		$selectFileds=array("workArrangementId","projectId","baseSupervsor","addSupervsor", "createdOn", "remarks");		
		$whereClause = "workArrangementId=".$postArr["listingId"];		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFileds,$whereClause);
		$results = array();
		$projectArr = array();
		$project_id=0;
		if($res[1] > 0){
			$projectArr = $db->fetchArray($res[0]);
				if($projectArr['projectId'])
			        $project_id=$projectArr['projectId'];
			    else
			        $project_id=0;
			    foreach($projectArr as $key=>$det){
			        if($key=='addSupervsor')
			        {
                        $temp=$det;
                        if(!empty($temp))
                            $projectArr['addSupervsor']=explode(',',$temp);
                        else
                            $projectArr['addSupervsor']=[];
			        }
			    }
				$whereClause2 = "workArrangementId=".$projectArr["workArrangementId"];
				$selectFileds2 = array("workerId","partial","isSupervisor");
				$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds2,$whereClause2);
				$listingDetails = array();
				if($res2[1] > 0){
					$workerids = $db->fetchArray($res2[0],1); 
					$workeridFinal = array();
					$partialWorkers = array();
					$partialBaseSupervisors = array();
					$partialsupervisor = array();
					$temp_base_sup[]=$projectArr['baseSupervsor'];
                    $temp_base_sup=implode(',',$temp_base_sup);
					foreach($workerids as $ids){
						if($ids["isSupervisor"]==0)
					    {
    						$workeridFinal[] = $ids["workerId"];
    						if($ids["partial"] == 1){
    							$partialWorkers[] = $ids["workerId"];
    						}
					    }
					    else
					    {
							if($ids["partial"] == 1){
								//foreach($temp_base_sup as $baseSupervisorIds)
								{
									
										if($ids["workerId"] == $projectArr['baseSupervsor'])
										 {	
											$partialBaseSupervisors[] = $ids["workerId"];
										 }else{
											$partialsupervisor[] = $ids["workerId"]; 
										}			
								}
							}								
					    }
						
					}
                    $projectArr["workers"] = $workeridFinal;
					$projectArr["partialWorkers"] = $partialWorkers;
					$projectArr["partialsupervisor"] = $partialsupervisor;
					$projectArr["partialBaseSupervisors"] = $partialBaseSupervisors;
                    $projectArr["workdraft"] = $workassigned;
                    $getavailaleworkersup = $this->availableworkersupervisorDetails($project_id,$selecteddate);
                    if(!empty($getavailaleworkersup))
                    {
                        $projectArr["availablesupervisor"] = $getavailaleworkersup['supervisors'];
                        $projectArr["availableworker"] = $getavailaleworkersup['workers'];
                    }
                    else{
                        $projectArr["availablesupervisor"] = [];
                        $projectArr["availableworker"] = [];
                    }
                    if($requestype==1)
                    {
						$getsupervisor=[];
                        $temp_sup=[];
                        if(count($projectArr['addSupervsor'])>0)
                            $temp_sup=$projectArr['addSupervsor'];
                        if(count($temp_sup)>0)
                            $temp_sup[]=$projectArr['baseSupervsor'];
						 if(!empty($temp_sup))   
						 {
                        	$temp_sup=implode(',',$temp_sup);
							$getsupervisor= $this->getsupervisorname($temp_sup);
						 }
						$temp_ava_sup=array_merge($projectArr["availablesupervisor"],$getsupervisor);
						if(!empty(temp_ava_sup))
						$projectArr["availablesupervisor"]=$this->my_array_unique($temp_ava_sup);
						else{
							$projectArr["availablesupervisor"]=[];	
						}
                        
                        $getsupervisor= $this->getworkername(implode(',',$workeridFinal));
                        $temp_ava_wor = array_merge($projectArr["availableworker"],$getsupervisor);
                        $projectArr["availableworker"]=$this->my_array_unique($temp_ava_wor);
                    }
				}    
			      	
	
		}
		else{
			$projectArr = array(); 
		}

		
		return $this->common->arrayToJson($projectArr);
	}
	function my_array_unique($array, $keep_key_assoc = false){
        $duplicate_keys = array();
        $tmp = array();       
    
        foreach ($array as $key => $val){
            // convert objects to arrays, in_array() does not support objects
            if (is_object($val))
                $val = (array)$val;
    
            if (!in_array($val, $tmp))
                $tmp[] = $val;
            else
                $duplicate_keys[] = $key;
        }
    
        foreach ($duplicate_keys as $key)
            unset($array[$key]);
    
        return $keep_key_assoc ? $array : array_values($array);
    }
	function getsupervisorname($supervisors){
	    global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("userId","Name");
	    $whereClause = "userId IN(".$supervisors.")";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFileds,$whereClause);
		$vehiclesArr=[];
		if($res[1] > 0){
			$vehiclesArr = $db->fetchArray($res[0], 1);          	
		}
		return $vehiclesArr;
	}
	function getworkername($workers){
	    global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
	    $selectFileds=array("workerName","workerId","teamId");
		$whereClause = "workerId IN(".$workers.")";
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
		return $newWorkerArr;
	}
	function availableworkersupervisorDetails($pid, $date){
	    //return $this->common->arrayToJson($pid.' '.$date);
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		//$whereClauseat = "forDate='".date("Y-m-d")."' and draftStatus=1 and outTime='00:00:00' and isSupervisor=1";
		$selectFiledsat=array("workerId");
		if($date != ""){
			$whereClauseat = "forDate='".$date."' and draftStatus=1 and (partial=0 or (partial=1 and outTime='00:00:00')) and isSupervisor=1";
		}
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
		$vehiclesArr["availableArray"]=$assignedWorkers;
		//$whereClauseat = "forDate='".date("Y-m-d")."' and draftStatus=1 and outTime='00:00:00' and partial=0";
		$selectFiledsat=array("workerId");
		if($date != ""){
			$whereClauseat = "forDate='".$date."' and draftStatus=1 and (partial=0 or (partial=1 and outTime='00:00:00')) and isSupervisor=0";
		}
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
		
		/*$whereClauseat="teamName='Home Leave'";
        $selectFiledsat=array("teamid");
        $team_leave=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["TEAM"],$selectFiledsat,$whereClauseat);
		if($team_leave[1] > 0){
			$teamID = $db->fetchArray($team_leave[0], 1);
			$teamID=$teamID[0]['teamid'];
		}
		else
		{
		    $teamID=0;
		}*/
		
		$selectFileds=array("workerName","workerId","teamId");
		if(count($assignedWorkers) > 0){
			$whereClause = "project like '%$pid%' and status=1 and homeLeave !=2 and workerId NOT IN(".implode(",",$assignedWorkers).")";
		}
		else{
			$whereClause = "project like '%$pid%' and status=1 and homeLeave !=2";
		}
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
		$vehiclesArr['workers']=$newWorkerArr;
		return $vehiclesArr;
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
		$updateArr["status"] = 0;
		$updateArr["draftStatus"] = 1;
		$insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$updateArr,$whereClause);
		$returnval["response"] ="success";
		$returnval["responsecode"] = 1; 
		return $this->common->arrayToJson($returnval);
		   
	}
	function updateWorkArranments($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$dbm = new DB;
        $dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
        
        $insertArr["projectId"]=trim($postArr["value_projects"]);
        $insertArr["baseSupervsor"]=trim($postArr["value_supervisors"]);
        $base_sup=$insertArr["baseSupervsor"];
        $addsuplist=$postArr["value_supervisors2"];
        $partialsuper=$postArr["partialSupervisors"];
		$basePartialSupervisor=$postArr["selectedItemsBaseSup"];
        $work_arr_id=$postArr["listingId"];
        $for_date=trim($postArr["startDate"]);
        
        if(empty($partialsuper))
            $partialsuper=[];
        
        if(!empty($addsuplist))
        {
            $addSupervsor=implode(",",$addsuplist);
        }
        else
            $addSupervsor=0;
            
        $insertArr["addSupervsor"]=$addSupervsor;
		
		$insertArr["createdOn"]=trim($postArr["startDate"]);
		$insertArr["remarks"]=trim($postArr["remarks"]);
		$whereClause = "workArrangementId = ".$work_arr_id." and createdOn='".$for_date."'";
		$selectFiledsat=array("status","workArrangementId","baseSupervsor","addSupervsor","createdOn");
        $select_work = $dbm->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFiledsat,$whereClause);
        if($select_work[1] > 0){
			$selectArr = $dbm->fetchArray($select_work[0], 1);
			$work_arr_status=$selectArr[0]['status'];
			$base_super=$selectArr[0]['baseSupervsor'];
			$add_super=$selectArr[0]['addSupervsor'];
			$createon=$selectArr[0]['createdOn'];
			if($work_arr_status==1)
			{
			    $whereClause = "workArrangementId = ".$work_arr_id." and draftStatus=1";
        		$selectFiledsat=array("workerId");
                $select_work1 = $dbm->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFiledsat,$whereClause);
                if($select_work1[1] > 0){
                    $total_count_att=$select_work1[1];
                }
			    //$whereClause = "workArrangementId = ".$work_arr_id." and draftStatus=1 and statusOut IN(0,1)";
			    $whereClause = "workArrangementId = ".$work_arr_id." and draftStatus=1 and ((inTime='00:00:00' and outTime='00:00:00') or (inTime>'00:00:00' and outTime>'00:00:00'))";
        		$selectFiledsat=array("workerId");
                $select_work2 = $dbm->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFiledsat,$whereClause);
                if($select_work2[1] > 0){
                    if($total_count_att!=$select_work2[1])
                    {
                        $returnval["response"] ="Update Failure supervisor or worker already given intime";
                		$returnval["responsecode"] = 0; 
                	    return $this->common->arrayToJson($returnval);
                    }
                    $whereClause = "workArrangementId = ".$work_arr_id." and status=1";
                    $update_arr_work["status"]=3;
                    $updatework = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$update_arr_work,$whereClause);
                    $whereClause = "workArrangementId = ".$work_arr_id." and draftStatus=1";
                    $update_arr_att["draftStatus"]=3;
                    $updatework = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$update_arr_att,$whereClause);
                    
                    $insertArr["status"]=1;
                    $insid_new_work = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$insertArr,1,2);
                    $work_arr_id=$insid_new_work;
                }
			}
			else if($work_arr_status==2)
			{
		        $whereClause = "workArrangementId = ".$work_arr_id;
                $insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$insertArr,$whereClause);
        		$deleteCount = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$whereClause);	    
			}
        }
		foreach($postArr["workerIds"] as $value){
			$arr = explode("-", trim($value));
			$insertArr2 = array();
			$insertArr2["workArrangementId"]=$work_arr_id;       
			$insertArr2["workerId"]=$arr[0];     
			$insertArr2["workerTeam"]=$arr[1];       
			$insertArr2["forDate"]=$postArr["startDate"];
			$insertArr2["createdOn"]=date("Y-m-d H:i:s");
			
			if(in_array(trim($value), $postArr["partialWorkers"])){
				$insertArr2["partial"]=1;     
			}
			if($work_arr_status==1){
                $insertArr2["draftStatus"]=1;
            }
			$insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$insertArr2,1,2);
		}
		foreach($addsuplist as $value){
            if(in_array($value,$partialsuper))
                $t_partial=1;
            else
                $t_partial=0;
            $ins = array();
            $ins["workArrangementId"]=$work_arr_id;
            $ins["workerId"]=$value;       
            $ins["forDate"]=$postArr["startDate"];
            $ins["createdOn"]=date("Y-m-d H:i:s");
            $ins["isSupervisor"] = 1;
            $ins["partial"] = $t_partial;
            if($work_arr_status==1){
                $ins["draftStatus"] = 1;
            }
            $insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$ins,1,2);
		}
		if(!empty($base_sup))
		{
			$t_partial = 0;
			foreach($basePartialSupervisor as $value){
					$t_partial=$value['isPartial'];
			}
            $ins = array();
            $ins["workArrangementId"]=$work_arr_id;
            $ins["workerId"]=$base_sup;       
            $ins["forDate"]=$postArr["startDate"];
            $ins["createdOn"]=date("Y-m-d H:i:s");
            $ins["isSupervisor"] = 1;
            if($work_arr_status==1){
                $ins["draftStatus"] = 1;
            }
			$ins["partial"] = $t_partial;
            $insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$ins,1,2);
		}
        $dbm->dbClose();
        $returnval["response"] ="success";
		$returnval["responsecode"] = 1; 
		//$returnval["requestID"] = $requestNumber; 
	    return $this->common->arrayToJson($returnval);
	}

	function getProjectAttendance($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$projectIntime="";
		$projectOuttime="";
		$selectFileds=array("workArrangementId","attendanceRemark");
		$dbcon = $db->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$selectFileds1=array("startTime","endTime");
		$whereClause1 = "projectId = ".$postArr["projectId"];
		$res1=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["PROJECTS"],$selectFileds1,$whereClause1);
		
		if($res1[1] > 0)
						{
							$projectList =  $db->fetchArray($res1[0],1);
							foreach($projectList as $listDetails){
								$projectIntime=$listDetails['startTime'];
								$projectOuttime=$listDetails['endTime'];
							}
						}
		if($postArr["requestType"] == 1){ // if edit
			$whereClause = "workArrangementId = ".$postArr["listingId"]." and projectId = ".$postArr["projectId"]." and status = 1";
		}	
		else{
			$userID = $postArr["userId"];
			$addCond = "and (baseSupervsor = $userID or addSupervsor like '%$userID%')";
			//$addCond = "and (baseSupervsor = $userID)";
			if($postArr["userType"] == 1){
				$addCond= "";
			}
			if($postArr["startDate"]){
				$whereClause = "projectId = ".$postArr["projectId"]." and status = 1 and createdOn='".$postArr["startDate"]."' $addCond";
			}
			else{
				$whereClause = "projectId = ".$postArr["projectId"]." and status = 1 and createdOn='".date("Y-m-d")."'";
			}
		}
		
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFileds,$whereClause);
		$workeridFinal = array();
		$final_list = array();
		$supervisor_list=array();
		if($res[1] > 0){
			$details = $db->fetchArray($res[0]); 

			$selectFileds2=array("workArrangementId","workerId","inTime","outTime","workerTeam", "reason", "status","statusOut","isSupervisor");
			$dbcon = $db->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
			$whereClause2 ="workArrangementId= ".$details["workArrangementId"]." order by workerTeam";
			// $whereClause2 ="workArrangementId= ".$details["workArrangementId"]." AND ((partial = 0) OR (partial=1 AND statusOut = 1)) order by workerTeam";
			// if($postArr["userType"] == 5){ //exclude submitted list for supervisor
			// 	$whereClause2 ="workArrangementId= ".$details["workArrangementId"]." order by workerTeam";
			// }

			$assignedWorkers = $this->getAssignedPartialWorker($details["workArrangementId"]);

		
			$res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds2,$whereClause2);
         	if($res2[1] > 0){
				$workerids = $db->fetchArray($res2[0],1);
				foreach($workerids as $ids){

					/*$ids["outTimeEntered"] = false;
					$ids["inTimeEntered"] = false;*/
					$ids["remarks"] = $details["attendanceRemark"];
					$ids["projectIntime"]=$projectIntime;
					$ids["projectOuttime"]=$projectOuttime;	
					if(strcmp($ids["inTime"],"00:00:00") == 0)
					{
						$ids["inTimeEntered"] =false;
					}else{
						$ids["inTimeEntered"] =true;
					}
					if(strcmp($ids["outTime"],"00:00:00") == 0)
					{
						$ids["outTimeEntered"] =false;
					}else{
						$ids["outTimeEntered"] =true;
					}

					if(in_array($ids["workerId"], $assignedWorkers)){
						$ids["assignedWorker"] = 1;
					}
					else{
						$ids["assignedWorker"] = 0;
					}
				    $ids["remarks"] = $details["attendanceRemark"];

					if($ids['isSupervisor'])
    					$supervisor_list[] = $ids;
					else
						$workeridFinal[] = $ids;						
					$i++;
				}

			}    			
			$final_list["supervisorlist"]=$supervisor_list;
		    $final_list["workerlist"]=$workeridFinal;	
		}
		return $this->common->arrayToJson($final_list);	

	}

	function getAssignedPartialWorker($workArrangementID){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);

		$selectFileds = array("workerId");
		$whereClause = "workArrangementId != $workArrangementID AND dateWithOutTime != '0000-00-00 00:00:00' AND dateWithOutTime > '".date("Y-m-d h:i:s")."'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds,$whereClause);
		$finalWorkers = [];
		if($res[1] > 0){
			$workers = $db->fetchArray($res[0], 1); 

			foreach($workers as $worker){
				$finalWorkers[] = $worker["workerId"];
			}
		}

		return $finalWorkers;

	}
	function getSubmittedAttendanceList($postArr){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$selectFileds=array("workArrangementId","projectId", "createdOn","createdBy","attendanceRemark");
		$dbcon = $db->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		if($postArr["userType"]!=1){
		    $user_id=$postArr["userId"];
			$add_condition = "and (baseSupervsor = $user_id or addSupervsor like '%$user_id%')";
		    //$add_condition=" and baseSupervsor=".$user_id;
		}
		else
		    $add_condition='';
		if($postArr["startDate"]){
			$whereClause = "attendanceStatus = '1' and status = 1 and createdOn='".$postArr["startDate"]."'".$add_condition;
		}
		else{
			$whereClause = "attendanceStatus = '1' and status = 1 and createdOn='".date("Y-m-d")."'".$add_condition;
		}
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFileds,$whereClause);
		$workeridFinal = array();
		$final_list = array();
		$supervisor_list=array();
		if($res[1] > 0){
			$details = $db->fetchArray($res[0], 1); 
			foreach($details as $key=>$worklist)
		    {
				$selectFiledsitem=array("Name");
				$whereClauseitem = "userId=".$worklist['createdBy'];
				$resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFiledsitem,$whereClauseitem);
				if($resitem[1] > 0){
					$itemList = $db->fetchArray($resitem[0]);
					$details[$key]["createdByName"]=$itemList['Name'];
					
				}else{
					$details[$key]["createdByName"]="";
				}
			    $work_id=$worklist['workArrangementId'];
			    
			    $selectFileds2=array("workArrangementId","workerId","inTime","outTime","workerTeam", "reason", "status","statusOut","isSupervisor","createdBy");
                $whereClause2 ="workArrangementId= ".$work_id." order by workerTeam";
                $res2=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds2,$whereClause2);
                $supervisor_list=array();
				$workeridFinal=array();
                if($res2[1] > 0){
                    $workerids = $db->fetchArray($res2[0],1);
                    foreach($workerids as $ids){
                        $ids["remarks"] = $details[0]["attendanceRemark"];
                        
                        $worker_team = $ids["workerTeam"];
                        $whereClause4="teamid=".$worker_team;	
                        $selectFileds4 = array("teamName");
                        $res4=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["TEAM"],$selectFileds4,$whereClause4);
                        if($res4[1]>0)
                        {
                            $workerteamnames = $db->fetchArray($res4[0],1); 
                            $teamname=$workerteamnames[0]['teamName'];
                        }
                        else
                            $teamname='';
                        
                        if($ids['isSupervisor'])
                            $supervisor_list[] = $ids;
                        else
                        {
                            $ids["teamname"]=$teamname;
                            $workeridFinal[] = $ids;
						}
					
                    }
                }
                $final_list["supervisorlist"]=$supervisor_list;
                $final_list["workerlist"]=$workeridFinal;	
				$details[$key]["attendancelist"]=$final_list;
				
			}
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

				if($val["OUT"] != ""){
					$updateArr["outTime"] = $val["OUT"];
					$updateArr["dateWithOutTime"] = date("Y-m-d")." ".$val["OUT"];
				}
				else{
					$updateArr["dateWithOutTime"] = date("Y-m-d")." 22:00:00";
				}

				if($val["reason"] != "")
					$updateArr["reason"] = $val["reason"];
				else
				    $updateArr["reason"]=0;

				if($postArr["selectedOption"] == 1)
					$updateArr["status"] = $postArr["type"];
				if($postArr["selectedOption"] == 2)
					$updateArr["statusOut"] = $postArr["type"];

					if($postArr["userType"] == 1){
						$updateArr["status"] = $postArr["type"];
						$updateArr["statusOut"] = $postArr["type"];
					}
					$updateArr["createdBy"] = $postArr["userId"];
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
			if(!empty($postArr["selectedItemsAddSup"]))
			{
			    $addSupervsor=$postArr["selectedItemsAddSup"];
			    $temp_addsupid=array();
			    foreach($addSupervsor as $value)
			    {
			        $temp_addsupid[]=$value['userId'];
			    }
			    $addSupervsor=implode(",",$temp_addsupid);
			}
			else
			{
			    $addSupervsor=0;
			}
			$insertArr["projectId"]=trim($postArr["value_projects"]);
			$insertArr["baseSupervsor"]=trim($postArr["value_supervisors"]);
			//$insertArr["addSupervsor"]=trim($postArr["value_supervisors2"]);
			$insertArr["addSupervsor"]=$addSupervsor;
			$insertArr["createdBy"]=trim($postArr["userID"]);
			$insertArr["createdOn"]=trim($postArr["startDate"]);
			$insertArr["remarks"]=trim($postArr["remarks"]);
			$insertArr["status"]=trim($postArr["status"]);		
			
			$dbm = new DB;
			$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
			
			$insid = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$insertArr,1,2);
			
			// tracking supervisor attendance
			$this->insertSupervisorAttendance($insid, $postArr["value_supervisors"], $postArr["startDate"],$postArr["supervisors"]);
			if(trim($postArr["selectedItemsAddSup"]) != "" || !empty($postArr["selectedItemsAddSup"])){
				$this->insertaddSupervisorAttendance($insid, $postArr["selectedItemsAddSup"], $postArr["startDate"]);
			}
			

			//tracking wrokers attendance
			foreach($postArr["workerIds"] as $value){
				$insertArr2 = array();
				$insertArr2["workArrangementId"]=$insid;
				$arr = explode("-", trim($value));
				$insertArr2["workerId"]=$arr[0];   
				$insertArr2["workerTeam"]=$arr[1];       
				$insertArr2["forDate"]=trim($postArr["startDate"]);
				$insertArr2["createdOn"]=date("Y-m-d H:i:s");
				$insertArr2["createdBy"]=trim($postArr["userId"][0]);
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
		
	function insertSupervisorAttendance($insid, $supervisor, $startDate,$supervisors){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$dbm = new DB;
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		$ins = array();
		$t_partial=false;
		//if(trim($selectedSupervisors) != "" || !empty($selectedSupervisors)){
				foreach($supervisors as $value){
					$t_userid=$value['userId'];
					if($t_userid == $supervisor)
					{					 
						$t_partial=$value['isPartial'];
					    break;
					
				   }
				}
			//}
		$ins["workArrangementId"]=$insid;
		$ins["workerId"]=$supervisor;       
		$ins["forDate"]=$startDate;
		$ins["createdOn"]=date("Y-m-d H:i:s");
		$ins["isSupervisor"] = 1;
		$ins["partial"] = $t_partial;
		$insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$ins,1,2);
		
	}
	function insertaddSupervisorAttendance($insid, $supervisor, $startDate){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$dbm = new DB;
		$dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		foreach($supervisor as $value){
		    $t_userid=$value['userId'];
		    $t_partial=$value['isPartial'];
		    if($t_partial)
		        $t_partial=1;
		    else
		        $t_partial=0;
			$ins = array();
			$ins["workArrangementId"]=$insid;
			$ins["workerId"]=$t_userid;       
			$ins["forDate"]=$startDate;
			$ins["createdOn"]=date("Y-m-d H:i:s");
			$ins["isSupervisor"] = 1;
			$ins["partial"] = $t_partial;
			$insid2 = $dbm->insert($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$ins,1,2);
		}
	}
    function deletedraftworkarrangement($postArr){
	    global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$dbm = new DB;
        $dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
        $worklistingId = $postArr["deleteWorkArrangementIds"];
        if(!empty($worklistingId))
        {
            $worklistingId=implode(',',$worklistingId);
            $whereClause = "workArrangementId IN (".$worklistingId.") and status=2";
            $deleteCount = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$whereClause);
            $whereClause = "workArrangementId IN (".$worklistingId.") and draftStatus=2";
            $deleteCount = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$whereClause);
            
            $returnval["response"] ="success";
    		$returnval["responsecode"] = 2;
        }
        else
        {
            $returnval["response"] ="Failure";
    		$returnval["responsecode"] = 3;
        }
        return $this->common->arrayToJson($returnval);
	}
	
	function deleteSubmittedworkarrangement($postArr){
	    global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$dbm = new DB;
		$finalList = array();
        $dbcon = $dbm->connect('M',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
        $worklistingId = $postArr["deleteWorkArrangementIds"];
		$noAttWorkListingId = array();
		$attWorkListingId = array();
		$workArProjectIds = array();
		$attWorkListingNameMsg = array();
        if(!empty($worklistingId))
        {
			//$worklistingIdArray=explode(',',$worklistingId);
		
			foreach($worklistingId as $key=>$value){
				$whereClause1 = "workArrangementId=".$value." and draftStatus=1 and (inTime <> '00:00:00' or outTime <> '00:00:00' )";
				$selectFileds1 = array("workerId");
				$res2=$dbm->select($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$selectFileds1,$whereClause1);				
				if($res2[1] > 0){	
					array_push($attWorkListingId,	$value);
				}else{	
				    array_push($noAttWorkListingId,	$value);
				}	     
				
			}
			if(!empty($noAttWorkListingId))
			{
				$worklistingId=implode(',',$noAttWorkListingId);
				$whereClause = "workArrangementId IN (".$worklistingId.")";
				//$deleteCount = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$whereClause);
					$updateArr2["status"] = 3;
				$insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$updateArr2,$whereClause);
				$whereClause = "workArrangementId IN (".$worklistingId.")";
				$updateArr2["draftStatus"] = 3;
				//$deleteCount = $dbm->delete($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$whereClause);
				$insid = $dbm->update($dbcon, $DBNAME["NAME"],$TABLEINFO["ATTENDANCE"],$updateArr2,$whereClause);
				$finalList["response"] ="success";
				$finalList["responsecode"] =2;
				
			}
			if(!empty($attWorkListingId))
			{
				//$workArrIds = implode(",", $attWorkListingId);
				foreach ($attWorkListingId as $workArId)
				{
					$whereClause2 = "workArrangementId =".$workArId;
					$selectFileds2 = array("projectId");
					$res3=$dbm->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKARRANGEMENTS"],$selectFileds2,$whereClause2);	
					if($res3[1] > 0)
					{
						$workArProjectIds = $dbm->fetchArray($res3[0],1); 
					}
					//$finalList["workArProjectIds"]=$workArProjectIds;
					foreach ($workArProjectIds as $projectIdVal)
					{
						$whereClause4 = "projectId =".$projectIdVal["projectId"];
						$selectFileds4 = array("projectName");
						$res4=$dbm->select($dbcon, $DBNAME["NAME"],$TABLEINFO["PROJECTS"],$selectFileds4,$whereClause4);
						if($res4[1] > 0)
						{		
							 $projectNameVals = $dbm->fetchArray($res4[0],1);
							 foreach ($projectNameVals as $projectNameVal)
							 {
							   array_push($attWorkListingNameMsg,$projectNameVal["projectName"]." Not deleted due to valid attandance entry");	
							 }
						}
					}
				}
				$finalList["attWorkListingId"]=$attWorkListingId;
				$finalList["attWorkListingNameMsg"]=$attWorkListingNameMsg;
				$finalList["response"] ="success";
				$finalList["responsecode"] =2;
			}
			/*else{
				$finalList["attWorkListingId"]=$attWorkListingId;
				$finalList["noAttWorkListingId"]=$noAttWorkListingId ;
				$finalList["response"] ="Failure";
				$finalList["responsecode"] = 2;
			}
			*/
				
        }
        else
        {
			$finalList["attWorkListingId"]=$attWorkListingId;
            $finalList["response"] ="Failure";
    		$finalList["responsecode"] = 3;
        }
        return $this->common->arrayToJson($finalList);
	}
}

?>