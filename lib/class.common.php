<?php

class COMMON {
    
    function __construct(){
        
    }
    
    //Check empty value
    function checkIsEmpty($string){
        $string=preg_replace("/[\s]/","",$string);
        if(empty($string)){
                return true;
        }
        else{
                return false;
        }
    }
    function arrayToJson($array){

        return json_encode($array);
    }

   //set user session
   function setSession($CName, $CValue, $MaxAge='42000', $Path="/", $Domain='.digitalcrest.com'){
        $CValue = $this->Encrypt($CValue);
       /* header('Set-Cookie: ' . rawurlencode($CName) . '=' . rawurlencode($CValue)
        . (empty($MaxAge) ? '' : '; Max-Age='.$MaxAge)
        . (empty($Path)   ? '' : '; path='.$Path)
        . (empty($Domain) ? '' : '; domain='.$Domain)
        . (!$Secure       ? '' : '; secure')
        . (!$HTTPOnly     ? '' : '; HttpOnly'), false);*/

	//setcookie($CName, $CValue, time()+3600, "/~rasmus/", ".digitalcrest.com", 1);
	//session_start();

	$_SESSION[$CName] = $CValue;
    }
   //get user session
    function getSession($CName){
	
        //$value = $_COOKIE["$CName"];
	//session_start();
	$value = $_SESSION["$CName"];
        $value = $this->Decrypt($value);
        return $value;
    }
 
    //Send Mail
    function sendemail($fromEmail='',$to,$subject,$message,$headers='',$fromName='',$cc='') {
        global $IPVARS;
        $to = preg_replace("/\r/", "", $to);
        $to = preg_replace("/\n/", "", $to);
        if(trim($fromName)=="") {
                $fromName=$IPVARS['IPMAILFROMNAME'];
        }
        if(trim($fromEmail)=="") {
                $fromEmail = $IPVARS['IPINFOFROMMAILID'];
        }
        $fromEmail = preg_replace("/\r/", "", $fromEmail);
        $fromEmail = preg_replace("/\n/", "", $fromEmail);
        if(trim($headers)==""){
                $headers  = "MIME-Version: 1.0\n";
                $headers .= "Content-type: text/html; charset=iso-8859-1\n";
                $headers .= "From: $fromName <$fromEmail>\n";
                $headers .= "Sender: $fromEmail\n";
                if($cc!=''){
                        $headers .= "CC: $cc\n";
                }
        }			
        return mail($to,$subject,$message,$headers,$IPVARS['IPNOREPLYMAIL']);
    }
    function Encrypt($string){
        $result = '';
        $key = "qwerty123";
	for($i=0; $i<strlen($string); $i++)
        {
                $char = substr($string, $i, 1);
                $keychar = substr($key, ($i % strlen($key))-1, 1);
                $char = chr(ord($char)+ord($keychar));
                $result.=$char;
        }
	$result = base64_encode($result);
	$result = str_replace("+","*",$result);
	$result = str_replace("&","^",$result);
        return $result;
    }
    function Decrypt($string){
	$result = '';
	//$string = urldecode($string);
	$string = str_replace("*","+",$string);
	$string = str_replace("^","&",$string);
	$string = base64_decode($string);
        $key = "qwerty123";
        for($i=0; $i<strlen($string); $i++)
        {
                $char = substr($string, $i, 1);
                $keychar = substr($key, ($i % strlen($key))-1, 1);
                $char = chr(ord($char)-ord($keychar));
                $result.=$char;
        }
		return $result;
    }
    //create random password string
    function createRandomPassword(){
            $chars = "abcdefghijkmnopqrstuvwxyz0123456789";
            srand((double)microtime()*1000000);
            $i = 1;
            $pass = '' ;
            while ($i <= 6){
               $num = rand() % 33;
               $tmp = substr($chars, $num, 1);
               $pass = $pass . $tmp;
               $i++;
            }
            return $pass;
    }
    
    //Generate options for select box
    function selectArrayHash($arryhashname, $selectedval='',$startval='',$anyOpt=1) {	
            $op=(empty($startval) || $anyOpt==0)? "":'<option value="">Select Max Price</option> <option value="0">Any</option>'; 
            $selected = '';
            $i = 0;
            
    
            foreach ($arryhashname as $key => $value) {		
                    if($selectedval != '')
                    {
                            if ($selectedval == $key) {
                                            $selected = 'Selected';
                            }
                            else
                            {
                                     $selected = '';
                            }
                    }
                    if((empty($startval)))
                            $op .= "<option value=\"$key\" $selected>$value</option>";
                    else if($i > $startval)
                            $op .= "<option value=\"$key\" $selected>$value</option>";
                            $i++;
            }
            return $op;
    }
    
    // Format URL
    function formatURL($string){
            $string = strtolower($string);
            $string = str_replace("&amp;","&",$string);
            $matches = preg_replace("/[^A-Za-z0-9]/", " ", $string );
            $matches = preg_replace("/[\s]+/"," ",$matches);
            $matches = str_replace(" ","-",$matches);
    
            if(substr($matches,0,1) == "-")
                    $matches = substr_replace($matches,"",0,1);
    
            if(substr($matches,-1) == "-")
                    $matches = substr_replace($matches,"",-1);
    
            return $matches;
    }
    //Curl Function
    function GetCurlData($url,$param=array()){
        // Get cURL resource
        $curl = curl_init();
        // Set some options - we are passing in a useragent too here
        curl_setopt_array($curl, array(
            CURLOPT_RETURNTRANSFER => 1,
            CURLOPT_URL => $url,
            CURLOPT_USERAGENT => $_SERVER['HTTP_USER_AGENT'] ,
            CURLOPT_POST => 1,
            CURLOPT_POSTFIELDS => $param
        ));
        // Send the request & save response to $resp
        $respose = curl_exec($curl);
        // Close request to clear up some resources
        curl_close($curl);
        return $respose;
    }
    
    // to check given userid is numeric
    function ipCheckIsNumeric($regvalue) {
            $regexp = '/^[+-]?[0-9\.]*$/';
            if(is_numeric($regvalue)){
                    if (preg_match($regexp, $regvalue))
                            return 1;
                    else
                            return 0;
            } else {
                    return 0;
            }
    }
    //Check DB connections and reconnect if there is no db connection
    function ReConnectDB($dbcon, $Server="S"){
          global $DBNAME,$DBINFO,$TABLE;
              if(is_object($dbcon))
             {
               if(!$dbcon->mysqliDBPing($dbcon->db_link)){
                            $dbcon->connect($Server, $DBNAME['IPLISTING'], $DBINFO['USERNAME'], $DBINFO['PASSWORD']);
               }
             }
    }
  // Redirect url

   function RedirectTo($Url){
        echo "<script language='javascript'>";
        echo "window.location='".$Url."'";
        echo "</script>";
    }
    
    function __destruct(){
        
    }
    
        
}


?>
