<?php
error_reporting(E_ALL);
ini_set("display_errors",1);
header('Access-Control-Allow-Origin: *.vinaya');
error_reporting(0);

// session_start();

//Global Class includes
// $_SERVER['DOCUMENT_ROOT'] = "/home/vinayakc/public_html/"; //to be enabled in production
$ROOTPATH = $_SERVER['DOCUMENT_ROOT']."/productivity-api";
include_once $ROOTPATH."/lib/class.db.php";

include_once $ROOTPATH."/lib/class.common.php";

//Global Vars includes 
// include_once $_SERVER['DOCUMENT_ROOT']."/vinayak/conf/serverip.inc";
include_once $ROOTPATH."/conf/dbinfo.php";
include_once $ROOTPATH."/conf/vars.php";

define("BASEPATH","http://productivity.vinayak.com.sg/");
//define("BASEPATH","http://localhost:8081/productivity-api/");


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
