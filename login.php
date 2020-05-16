<?php
include_once "lib/init.php";

include_once $ROOTPATH."/includes/class.login.php";

$username = $_REQUEST["username"];
$password = $_REQUEST["password"];


$loginObj = new LOGIN();

$login = $loginObj->checkLogin($username,$password);

echo $login;

?>