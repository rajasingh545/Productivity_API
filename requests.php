<?php
include_once "lib/init.php";

include_once $ROOTPATH."/includes/class.workAttendance.php";

// error_reporting(E_ALL);
// ini_set("display_errors",1);

$requestObj = new REQUESTS();
 $json = file_get_contents('php://input');
 $obj = json_decode($json, true);
//  $obj = $_POST;
//  pr($obj);exit;
 if($obj["requestCode"] === 1){ //create
    $response = $requestObj->createWorkArranments($obj);
 }
 elseif($obj["requestCode"] === 2){
     
     $response = $requestObj->getWorkArrangementList($obj);
 }
 elseif($obj["requestCode"] === 3){
     $response = $requestObj->getWorkArrangementDetails($obj);
 }
 elseif($obj["requestCode"] === 4){
     
     $response = $requestObj->updateWorkArranmentsStatus($obj);
 }
 elseif($obj["requestCode"] === 5){

     $response = $requestObj->updateWorkArranments($obj);
 }
 elseif($obj["requestCode"] === 6){
    // echo "---".$obj["requestDetails"]["request"]["rawRequestType"];
     $response = $requestObj->getProjectAttendance($obj);
 }
  elseif($obj["requestCode"] === 7){

     $response = $requestObj->updateAttendance($obj);
 }
 elseif($obj["requestCode"] === 8){

     $response = $requestObj->getSubmittedAttendanceList($obj);
 }
 elseif($obj["requestCode"] === 9){
    $requestStatus = $obj["requestStatus"];
     $response = $requestObj->getListings($requestStatus, $obj);
 }
 elseif($obj["requestCode"] === 10){
   
      $requestObj->setMismatchAlert($obj);
     $response = $requestObj->collectionUpdate($obj);
 }
 elseif($obj["requestCode"] === 11){
   
    $response = $requestObj->getAlerts();
}
elseif($obj["requestCode"] === 12){
   
    $response = $requestObj->EditAlerts($obj);
    
}
elseif($obj["requestCode"] === 13){

    $response = $requestObj->driverEdit($obj);
}
elseif($obj["requestCode"] === 14){

    $response = $requestObj->createWorkRequest($obj);
}
elseif($obj["requestCode"] === 15){

    $response = $requestObj->getWorkRequestList($obj);
}


echo $response;

?>