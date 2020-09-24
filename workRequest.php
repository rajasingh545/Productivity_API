<?php
include_once "lib/init.php";

include_once $ROOTPATH."/includes/class.workRequest.php";

// error_reporting(E_ALL);
// ini_set("display_errors",1);

$requestObj = new WORKREQUESTS();
 $json = file_get_contents('php://input');
 $obj = json_decode($json, true);
//  echo "<pre>";
//  //print_r($_POST);
//  print_r($obj);
//  echo "</pre>";
//  exit;
//  $obj = $_POST;
 
if($obj["requestCode"] === 14){
    $response = $requestObj->createWorkRequest($obj);
}
elseif($obj["requestCode"] === 15){
    $response = $requestObj->getWorkRequestList($obj);
}
elseif($obj["requestCode"] === 16){
    $response = $requestObj->getWorkRequestDetails($obj);
}
elseif($obj["requestCode"] === 17){
    
    $response = $requestObj->createDailyWorkTrack($obj);
}
elseif($obj["requestCode"] === 18){
    $response = $requestObj->getDailyWorkTrackList($obj);
}
elseif($obj["requestCode"] === 19){
    $response = $requestObj->getDailyWorkTrackDetails($obj);
}
elseif($obj["requestCode"] === 21){
    $response = $requestObj->updateWorkRequest($obj);
}
elseif($obj["requestCode"] === 22){
    $response = $requestObj->updateDailyWorkTrack($obj);
}
elseif($obj["requestCode"] === 23){
    $response = $requestObj->getWorkRequestListDate($obj);
}else if($obj["requestCode"] === 27){
    $response = $requestObj->deleteDrawImage($obj);
}else if($obj["requestCode"] === 28){
    $response = $requestObj->deleteCompleteImage($obj);
}

if($_POST["requestCode"] == 24){
    $response = $requestObj->drawingimageupload_multiple($_POST);
}else if($_POST["requestCode"] == 52){
    $response = $requestObj->update_drawing_image_upload($_POST);
}
else if($_POST["requestCode"] == 25){
    $response = $requestObj->completeimageuploads($_POST);
}else if($_POST["requestCode"] == 20){
    $response = $requestObj->imageUploads($_POST);
}
else if($_POST["requestCode"] == 26){
    $response = $requestObj->unlink_imageUploads($_POST);
}else if($obj["requestCode"] == 50){
    $response = $requestObj->updateWorkRequestSeq();
}


if($obj["requestCode"] == 30){
    $response = $requestObj->getWorkRequestLWHSCalulatedValue($obj);
}

echo $response;
 ?>