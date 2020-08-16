<?php
include_once "lib/init.php";

include_once $ROOTPATH."/includes/class.commonAPI.php";

$apiObj = new commonAPI();

 $json = file_get_contents('php://input');
 $obj = json_decode($json, true);
$requestCode = $obj["requestCode"];
$projectId = $obj["projectId"];
if($requestCode == 1){
	//$apis = $apiObj->supervisorDetails($projectId,$obj);
    $apis = $apiObj->availableworkersupervisorDetails($projectId,$obj);
}
else if($requestCode == 99){
    
    $apis = $apiObj->availableWorkerDetails($obj, true);
}
else if($requestCode == 5){
    $apis = $apiObj->getContracts($obj);
}
else if($requestCode == 6){
    $apis = $apiObj->getWorkRequestList($obj);
}
else if($requestCode == 7){
    $apis = $apiObj->getProjectWiseSupervisor($projectId);
}
else{
    $apis = $apiObj->commonAPIs($obj);
}

echo $apis;

?>