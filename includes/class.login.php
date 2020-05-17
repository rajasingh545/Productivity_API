<?php
	include_once "lib/init.php";

class LOGIN
{
	public $common;

	function __construct(){
		global $commonObj;
		$this->common = $commonObj;
	}

	function checkLogin($username,$password){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$selectFileds=array("userId","userType","Name","project");
		$whereClause = "username='$username' AND password='".md5($password)."'";
		$res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFileds,$whereClause);
		
		$userArr = array();
		if($res[1] > 0){
			$userInfo = $db->fetchArray($res[0]);
			$userArr["response"] = "success";
			$userArr["userId"] = $userInfo['userId'];
			$userArr["userType"] = $userInfo['userType'];
			$userArr["userName"] = $userInfo['Name'];
			$userArr["project"] = $userInfo['project'];
			
		}
		else{
			$userArr["response"] = "fail"; //invalid login
		}
 
		return $this->common->arrayToJson($userArr);
	}
}

?>
