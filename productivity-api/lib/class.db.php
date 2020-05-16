<?php

class DB {

    public $query;
    public $error;
    public $error_code;
    public $error_content;
    private $db_link;
    private $resource;

    //CONSTRUCTOR //
    public function __construct() {	
            $this->resetAll();
    }

    //FUNCTION TO RESET CLASS VARIABLES //
    private function resetAll() {
            $this->error = false;
            $this->error_code = "";
            $this->error_content = "";
            $this->query = "";
            $this->reqStart = "";
            $this->resource = "";
            $this->reqEnd = "";  
            $this->affectedRows = "";
            $this->db_link = "";
    }
    
    // CREATE MYSQL CONNECTION //
    public function connect($conType, $dbName, $dbUsername='', $dbPassword='') 
    {		
            global $DBINFO,$SERVERS, $MYSQLPORT;

            if(trim($dbUsername) == '' || trim($dbPassword) == '')
            {
                    $dbUsername = $DBINFO['USERNAME'];
                    $dbPassword = $DBINFO['PASSWORD'];
            }

            if ($conType == 'M') 
            {
                    $dbhost = $SERVERS['DBHOST_MASTER'];
            } 
            elseif ($conType ==  'S') 
            {
                    $dbhost = $SERVERS['DBHOST_SLAVE'];
            } 	

            $this->db_link = @new mysqli($dbhost, $dbUsername, $dbPassword, $dbName, $MYSQLPORT);
            
            if(!$this->db_link) {
                //     $this->recordError("DB_CONNECTION_ERR");
                    die("Connection error: " . mysqli_connect_error());
            }
        //     $this->db_link = $link;
            return $this->db_link;          
    
    }
    
    // QUERY EXECUTE METHOD //
    private function execute_query($dbLink, $query) 
    {	
            $this->resetAll();
            if($this->checkSQLInjection($query))
	    {
                    
                if(!mysqli_ping($dbLink))
                {
                        $this->recordError("DB_CONNECTION_ERR");
                        return false;
                }
    
                $this->query = $query;		
                $this->reqStart = time();
                $resource = mysqli_query($dbLink, $this->query);
    
                $this->reqEnd = time();  
                $resTime = $this->reqEnd - $this->reqStart;
                if($resTime > 6) 
                {
                        $this->logError('',2);
                }
                if(mysqli_error($dbLink)) 
                {
                        $this->recordError("DB_EXEC_QRY_ERR");
                        
                }
                return $resource;
            }
    }
    
    // EXECUTE DIRECT QUERY //
    public function execute_direct_query($db_link, $query, $returnType=1) 
    {          		
            $this->resetAll();
        //     if($this->checkSQLInjection($query,$stopProcess))
	//     {
                if(!mysqli_ping($db_link))
                {
                        $this->recordError("DB_CONNECTION_ERR");
                        return false;
                }
    
                $this->query = $query;		
                $this->reqStart = time();
                $this->resource = mysqli_query($db_link, $this->query);
                $this->affectedRows=mysqli_affected_rows($db_link);
    
                $this->reqEnd = time();  
                $resTime = $this->reqEnd - $this->reqStart;
                if($resTime > 6) 
                {
                        $this->logError('',2);
                }
                if(mysqli_error($db_link)) 
                {
                        $this->recordError("DB_EXEC_QRY_ERR");
                        return false;
                }
                else{
                         if($returnType == 2)
                            return mysqli_insert_id($db_link);
                        else
                                return $this->affectedRows;
                }
                    
        //     }

    }
    
    // SELECT QUERY EXECUTION //
    
    public function select($dbLink, $dbName, $tableName, $selectFields, $whereClause) 
    {
            
            $stringSelectFields = implode(',', $selectFields);
            $selectQuery  = "SELECT ".$stringSelectFields. " FROM ".trim($dbName).".".trim($tableName)." WHERE ".$whereClause;	          
            
            $this->query = $selectQuery;

            if(strpos($stringSelectFields,"*") > 0)	
            {	
                    //* should not be sent in select query; COUNT(*) should not be available;	
                    $this->recordError("INVALID_SELECT_QRY");
            }
            else if(trim($whereClause) != '' && is_array($selectFields) && count($selectFields) > 0 && trim($tableName) != '' && trim($dbName) != '')
            {	
                    if ($resource = $this->execute_query($dbLink, $selectQuery)) 
                    {

                            $result[0] = $resource;
                            $result[1] = mysqli_num_rows($resource);
                            //$result[2] = mysql_num_rows(mysql_query($this->query));
                            return $result;
                    }
                    else 
                    {
                            $this->recordError("CONNECTION_ERROR_OR_SELECT_QRY_ERR");			
                    }
            }
            else
            {
                    $this->recordError("SELECT_QRY_WHERE-CLAUSE-ERR__DB-TBL-ERR__SELECT-FIELD-NOTARRAY");
            }

    }

    // FETCHING ARRAY RESULT //
    public function fetchArray($resource,$returnAsArray = 0) 
    {
            /*
            *	$returnAsArray = 0	//Return Result Set	
            *	$returnAsArray = 1	//Return Complete result Set
            */
                
            if($returnAsArray == 1)
            {
                    while($row = mysqli_fetch_assoc($resource))
                    {
                            $resultrow[] = $row;
                    }
                    mysqli_free_result($resource);/* free all memory associated with the result identifier */
            }
            else
            {
                    $resultrow = mysqli_fetch_assoc($resource);
            }	
                            
            return $resultrow;
    }


    // FUNCTION TO INSERT THE ARRAY VALUES TO THE TABLE //
    public function insert($dbLink, $dbName, $tableName, $insertData, $insertType = 1, $returnType = 1, $primaryKeyFields = '')
    {
            /*
            * $insertType = 1 // INSERT INTO 
            * $insertType = 2 // INSERT IGNORE INTO
            * $insertType = 3 // INSERT ON DUPLICATE KEY
            */
            
            /*
            * $returnType = 1 // Return Affected Rows 
            * $returnType = 2 // Return Insert Id (AutoIncrement)
            */
            $field_list = "";
            $value_list = "";
            if(is_array($insertData) && count($insertData) > 0) 
            {
                    foreach($insertData as $field => $value) 
                    {
                            $field_list .= trim($field).", ";
            
                            if(is_numeric($value) || is_float($value))  
                            {
                                    $value_list .= trim($value).", ";
                            }
                            else
                            {
                                    $value = ltrim(trim($value),"'");
                                    $value = rtrim(trim($value),"'");
                                    $value_list .= "'".mysqli_real_escape_string($dbLink, trim($value))."', ";	                                
                            }
                    }			
            }
            
            if($insertType == 3 && is_array($primaryKeyFields) && count($primaryKeyFields) > 0)
            {
                    $updateData = $insertData;
                    foreach($primaryKeyFields as $primaryField => $primaryValue)
                    {
                            unset($updateData[$primaryValue]);
                    }						
                    foreach($updateData as $field => $value)
                    {
                            if(is_numeric($value) || is_float($value)) 
                            {
                                    $u_query .= $field."=".trim($value).", ";
                            }
                            else
                            {
                                    $value = ltrim(trim($value),"'");
                                    $value = rtrim(trim($value),"'");
                                    $u_query .= $field."='".mysqli_real_escape_string($dbLink, trim($value))."', ";                                    
                            }
                    }
                    $updateFieldValue .= rtrim($u_query,', ');
            }
            
            $field_list = rtrim($field_list,", ");
            $value_list = rtrim($value_list,", ");
            
            if($insertType == 3)
            {
                    $insert_query = "INSERT INTO ".$dbName.".".$tableName."(".$field_list.") VALUES (".$value_list.") ON DUPLICATE KEY UPDATE ".$updateFieldValue;
            }
            else if($insertType == 2)
            {
                    $insert_query = "INSERT IGNORE INTO ".$dbName.".".$tableName."(".$field_list.") VALUES (".$value_list.")";
            }
            else 
            {
                    $insert_query = "INSERT INTO ".$dbName.".".$tableName."(".$field_list.") VALUES (".$value_list.")";
            }
            
            if (!$this->execute_query($dbLink, $insert_query)) {
                    $this->recordError("INSERT_QRY_ERR");
            }
            else{ 
                    if($returnType == 2)
                            return mysqli_insert_id($dbLink);
                    else
                            return $this->getAffectedRows(); 
            }

    }

    // FUNCTION TO UPDATE THE TABLE WITH PASSED ARRAY VALUE WITH WHERE CONDITION //
    public function update($dbLink, $dbName, $tableName, $updateData, $whereClause) 
    {
            if(trim($whereClause) == "" || stripos($whereClause," limit") > 0) 
            {
                    //Where clause is must and Limit should not be given in where clause
                    $this->recordError("UPDATE_QRY_WHERE-CLAUSE-ERR__LIMIT-NOT-AVAIL");
            }
            else if(is_array($updateData))
            {				 
                    $u_query = "";
                     
                    foreach($updateData as $field => $value)
                    {
                            if(is_numeric($value) || is_float($value)) 
                            {
                                    $u_query .= $field."=".trim($value).", ";
                            }
                            else
                            {                                   
                                    $value = ltrim(trim($value),"'");
                                    $value = rtrim(trim($value),"'");
                                    $u_query .= $field."='".mysqli_real_escape_string($dbLink, trim($value))."', ";
                           
                            }
                    }
                 $update_query = "UPDATE ".$dbName.".".$tableName." SET ".rtrim($u_query,', ')." WHERE ".$whereClause;
                    			
                    
                    if (!$this->execute_query($dbLink, $update_query)) 
                    {
                            $this->recordError("UPDATE_QRY_ERR");
                    }
                    else
                    { 
                            return $this->getAffectedRows(); 
                    }
            }
    }
    // DELETE QUERY EXECUTE METHOD //
    public function delete($dbLink, $dbName, $tableName, $whereClause)
    {		
            if(trim($whereClause) == "" || stripos($whereClause," limit") > 0) 
            {
                    //Where clause is must and Limit should not be given in where clause
                    $this->recordError("DEL_QRY_WHERE-CLAUSE-ERR__LIMIT-AVAIL");
            }
            else if (trim($whereClause) != "" || stripos($whereClause,"limit") === FALSE) 
            {
                    $delQuery  = "DELETE FROM ".$dbName.".".$tableName." WHERE ".$whereClause;			
                    if (!$this->execute_query($dbLink, $delQuery)) 
                    {
                            $this->recordError("DEL_QRY_ERR");
                    }
                    else
                    { 
                            return $this->getAffectedRows(); 
                    }
            }
    }
    
    // GET NUMBER OF ROWS RETURNED BY THE INSERT/UPDATE/DELETE QUERY EXECUTED //
    private function getAffectedRows() 
    {
            $affected_rows = mysqli_affected_rows($this->db_link);
            $affected_rows = ($affected_rows<0)?0:$affected_rows;
            return $affected_rows;
    }
    
    // SQL INJECTION CHECKING //
    private function checkSQLInjection($query)
    { 
        
         global $_SQLINJECTIONPATTERN,$_DOMAINNAME,$_EMAILFROM,$_ADMINEMAIL;

            foreach($_SQLINJECTIONPATTERN as $k => $patVal)
            {
                    if(stripos($query, $patVal) > 0)
                    {
                            $to = $_ADMINEMAIL;
                            $message = "<br>File Name: ".$_SERVER['PHP_SELF']."; <br> Mem IP : ".$memIp."; <br> Query : ".$this->query."; <br> Time : ".date("d-M-Y H:i:s")."<br> Pattern Match : ".$patVal;
                            $header = "From: SQL WATCH<".$_EMAILFROM.">\r\nReturn-Path: noreply@bounces.".$_DOMAINNAME."\r\nContent-type: text/html\r\n";
                            mail($to,"[Critical]SQL Injection Alert",$message,$header);
                            return false; //query will be skipped
                          
                    }
            }
            
            return true;
    }
    // MYSQL DB CLOSE METHOD //
    public function dbClose() 
    { 
            @mysqli_close($this->db_link); 
    }
    
    // TO GET THE DEBUG PARAMETERS OF THE CLASS  //
    public function getDebugParam() 
    {
            $param["host"] = $this->db_host;
            $param["db_link"] = $this->db_link;
            $param["query"] = $this->query;
            $param["db_resource"] = $this->resource;
            $param["error_code"] = $this->error_code;
            $param["db_error"] = mysqli_error();
            return $param;
    }

    // COMMON FUNCTION TO RECORD ERRORS WITH OPTIONAL LOGGING //
    private function recordError($errorcode,$logerror=true)
    {		
            $this->error = true;
            $this->error_code = $errorcode;
            $this->error_content = mysqli_error();
            if($logerror)
                    $this->logError(mysqli_error(), 1);
    }

    // WRITE SLOW QUERY LOG //
    private function logError($message='',$type=1) 
    {
        global $_LOGFILEPATH;
        
            /*
            * $type = 1	//Log mysql error  
            * $type = 2 //Log slow query 
            */
            $error = '';
            $error = debug_backtrace();
            $file_list = "";
            $fn_list = "";
            foreach ($error as $row => $error_det) 
            {
                    if (($row != 0) && ($row != 1)) 
                    {
                            $file_list .= $error_det["file"]." ~ ";
                            $fn_list   .= $error_det["function"]." ~ ";
                    }
            }

            $file_content = "\n";
            $file_content .= date('h:i:s').'#';		
        //     $file_content .= $this->db_host.'#';
            $file_content .= $this->query.'#';
            $file_content .= $file_list.'#';
            $file_content .= $fn_list.'#';
            if($type == 1) { $file_content .= message; }
            if($type == 2) { $file_content .= "QryTime : ".($this->reqEnd - $this->reqStart); }

            if($type == 1)
                    $file_name = $_LOGFILEPATH.date('d-m-Y')."_".$_SERVER['SERVER_ADDR']."db_class_error_log.txt";
            if($type == 2)
                    $file_name = $_LOGFILEPATH.date('d-m-Y')."_".$_SERVER['SERVER_ADDR']."db_slow_query_log.txt";

        //     $fp = fopen($file_name,"a");
        //     @fwrite($fp, $file_content);
        //     fclose($fp);
        echo "error". $file_content;
    }

    // DESTRUCT //
    public function __destruct() {
            @mysqli_free_result($this->resource);
            @mysqli_close($this->db_link);
    }
    
}



?>
