<?php
error_reporting(E_ALL);
ini_set("display_errors",1);
// header('Access-Control-Allow-Origin: *');
error_reporting(0);

// session_start();

//Global Class includes
$ROOTPATH = $_SERVER['DOCUMENT_ROOT']."/productivity-api";
include_once $ROOTPATH."/lib/class.db.php";

include_once $ROOTPATH."/lib/class.common.php";

//Global Vars includes 
// include_once $_SERVER['DOCUMENT_ROOT']."/vinayak/conf/serverip.inc";
include_once $ROOTPATH."/conf/dbinfo.php";
include_once $ROOTPATH."/conf/vars.php";

//get use sessions
$commonObj = new COMMON;

// $session_name = $commonObj->getSession('lnams');
// $session_id = $commonObj->getSession('lids');
// $session_type = $commonObj->getSession('lutys');



function pr($arr){
	echo "<pre>";
		print_r($arr);
	echo "</pre>";
}
?>
