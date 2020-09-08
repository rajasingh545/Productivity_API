<?php
include_once "lib/init.php";

if(isset($_GET["workrequestid"]))
{
    $workrequstid=$_GET["workrequestid"];
    if(empty($workrequstid))
    {
        $returnval["code"] = 2;
        $returnval["message"] = "Invalid Work Request";
        echo json_encode($returnval);
        exit;        
    }
}
else
{
    $returnval["code"] = 0;
    $returnval["message"] = "Invalid Work Request";
    echo json_encode($returnval);
    exit;    
}

// Include the main TCPDF library (search for installation path).
require_once('TCPDF-master/tcpdf_include.php');

// Extend the TCPDF class to create custom Header and Footer
class MYPDF extends TCPDF {

    //Page header
    public function Header() {
        // Logo
        if ($this->page != 2) {
            $image_file = 'TCPDF-master/img/VSS_LH_29062020.jpg';
            $this->Image($image_file, 0, 3, 160, '', 'JPG', '', 'T', false, 300, 'C', false, false, 0, false, false, false);
        }
    }
    
    // Page footer
    public function Footer() {
        // Position at 15 mm from bottom
        $this->SetY(-15);
        // Set font
        $this->SetFont('helvetica', 'N', 8);
        // Page number
        $this->Cell(0, 10, 'Page '.$this->getAliasNumPage().' of '.$this->getAliasNbPages(), 0, false, 'R', 0, '', 0, false, 'T', 'M');
    }
    function test(){
        return("inside function");
    }
    function getWorkRequestListDate($workrequstid){
		global $DBINFO,$TABLEINFO,$SERVERS,$DBNAME;
		$db = new DB;
		$dbcon = $db->connect('S',$DBNAME["NAME"],$DBINFO["USERNAME"],$DBINFO["PASSWORD"]);
		
		$whereClause = "workRequestId='".$workrequstid."'";
        $selectFileds=array("workRequestId","projectId","clientId","requestedBy","contractType","scaffoldRegister","remarks","description", "status","location","drawingAttach","createdOn","createdBy","drawingimage","completionImages");
        $res=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUEST"],$selectFileds,$whereClause);
		if($res[1] > 0){
		    $usersArr = $db->fetchArray($res[0], 1);
			$projectnewlist=array();
			foreach($usersArr as $key=>$value)
			{
			    $usersArr[$key]["workbasedon"]="";
                $usersArr[$key]["requestSizeList"]=[];
                $usersArr[$key]["requestmanpower"]=[];
                $usersArr[$key]["scaffoldtypelist"]=[];
                $usersArr[$key]["scaffoldworktypelist"]=[];
                $usersArr[$key]["sizeslist"]=[];
                
			    if($value['scaffoldRegister']==1)
			        $usersArr[$key]["scaffoldregister"]="Yes";
			    else
			        $usersArr[$key]["scaffoldregister"]="No";
			    $usersArr[$key]["remarks"]=$value['remarks'];
			    
			    $usersArr[$key]["createdOn"]=$value['createdOn'];
                $usersArr[$key]["drawingimage"]=$value['drawingimage'];
                $usersArr[$key]["completionImages"]=$value['completionImages'];
			    $createdBy=$value['createdBy'];
			    $selectFiledsitem=array("Name");
                $whereClauseitem = "userId=".$createdBy;
                $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["USERS"],$selectFiledsitem,$whereClauseitem);
                if($resitem[1] > 0){
                    $itemList = $db->fetchArray($resitem[0]);
                    $usersArr[$key]["createdBy"]=$itemList['Name'];
                }
                
			    $projectid=$value['projectId'];
			    $selectFiledsitem=array("projectName");
                $whereClauseitem = "projectId=".$projectid;
                $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["PROJECTS"],$selectFiledsitem,$whereClauseitem);
                if($resitem[1] > 0){
                    $itemList = $db->fetchArray($resitem[0]);
                    $usersArr[$key]["projectname"]=$itemList['projectName'];
                }
                $client_id=$value['clientId'];
			    $selectFiledsitem=array("clientName");
                $whereClauseitem = "clientId=".$client_id;
                $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["CLIENTS"],$selectFiledsitem,$whereClauseitem);
                if($resitem[1] > 0){
                    $itemList = $db->fetchArray($resitem[0]);
                    $usersArr[$key]["clientname"]=$itemList['clientName'];
                }
                $usersArr[$key]["location"]=$value['location'];
                if($value['contractType']==1)
                    $usersArr[$key]["contracttype"]="Original Contract";
                else
                    $usersArr[$key]["contracttype"]="Variation Works";
                $usersArr[$key]["description"]=$value['description'];
                
			    $wrequestid=$value['workRequestId'];
			    $selectFiledsitem=array("id","workRequestId","itemId","sizeType","previousWR","workBased","contractType");
                $whereClauseitem = "workRequestId='".$wrequestid."'";
                $resitem=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTITEMS"],$selectFiledsitem,$whereClauseitem);
                if($resitem[1] > 0){
                    $itemList = $db->fetchArray($resitem[0],1);
                    $k=0;
                    $a =0;
                    $b=0;
                    foreach($itemList as $item){
                        if($item["workBased"] == 1){
                            $usersArr[$key]["workbasedon"]="Size";
                            $selectFiledsSize=array("id","itemListId","scaffoldType","scaffoldWorkType","scaffoldSubCategory","length","height", "width","setcount");
                            $whereClauseSize = "workRequestId='".$wrequestid."' and itemListId=".$item["id"];
                            $resSize=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTSIZEBASED"],$selectFiledsSize,$whereClauseSize);
                            if($resSize[1] > 0){
                                $sizeList = $db->fetchArray($resSize[0],1);
                                $i=0;
                                $scaffold_name=array();
                                $scaffold_work_type=array();
                                foreach($sizeList as $sizeDet){
                                    $scaffoldworktype=$sizeDet['scaffoldWorkType'];
                    			    $selectFiledsitem=array("scaffoldName");
                                    $whereClauseitem = "id=".$scaffoldworktype;
                                    $resitem_in=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["SCAFFOLDWORKTYPE"],$selectFiledsitem,$whereClauseitem);
                                    if($resitem_in[1] > 0){
                                        $itemList_in = $db->fetchArray($resitem_in[0]);
                                        $usersArr[$key]["requestSizeList"][$a]["scaffoldworktype"]=$itemList_in['scaffoldName'];
                                        $scaffold_work_type[]=$itemList_in['scaffoldName'];
                                    }
                                    $scaffoldtype=$sizeDet['scaffoldType'];
                    			    $selectFiledsitem=array("scaffoldName");
                                    $whereClauseitem = "id=".$scaffoldtype;
                                    $resitem_in=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["SCAFFOLDTYPE"],$selectFiledsitem,$whereClauseitem);
                                    if($resitem_in[1] > 0){
                                        $itemList_in = $db->fetchArray($resitem_in[0]);
                                        $scaffoldtypename=$itemList_in['scaffoldName'];
                                        $usersArr[$key]["requestSizeList"][$a]["scaffoldtype"]=$itemList_in['scaffoldName'];
                                        $scaffold_name[]=$itemList_in['scaffoldName'];
                                    }
                                    $scaffoldsubcategory=$sizeDet['scaffoldSubCategory'];
                    			    $selectFiledsitem=array("scaffoldSubCatName");
                                    $whereClauseitem = "scaffoldSubCateId=".$scaffoldsubcategory;
                                    $resitem_in=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["SCAFFOLDSUBCATEGORY"],$selectFiledsitem,$whereClauseitem);
                                    if($resitem_in[1] > 0){
                                        $itemList_in = $db->fetchArray($resitem_in[0]);
                                        $usersArr[$key]["requestSizeList"][$a]["scaffoldsubcategory"]=$itemList_in['scaffoldSubCatName'];
                                    }
                                    $usersArr[$key]["requestSizeList"][$a]["size"]=$scaffoldtypename."-".$sizeDet['length']."mL x ".$sizeDet['width']."mW x ".$sizeDet['height']."mH";
                                    $sizeslist[]=$sizeDet['length']."mL x ".$sizeDet['width']."mW x ".$sizeDet['height']."mH x ".$sizeDet['setcount']." No's -".$scaffoldtypename;
                                    $a++;
                                }
                                $usersArr[$key]["scaffoldtypelist"]=$scaffold_name;
                                $usersArr[$key]["scaffoldworktypelist"]=$scaffold_work_type;
                                $usersArr[$key]["sizeslist"]=$sizeslist;
                            }
                        }
                        else if($item["workBased"] == 2){
                            $usersArr[$key]["workbasedon"]="ManPower";
                            $selectFiledsMan=array("id","itemListId","safety","supervisor","erectors","generalWorker","timeIn", "timeOut");
                            $whereClauseMan = "workRequestId='".$wrequestid."' and itemListId=".$item["id"];
                            $resMan=$db->select($dbcon, $DBNAME["NAME"],$TABLEINFO["WORKREQUESTMANPOWER"],$selectFiledsMan,$whereClauseMan);
                            if($resMan[1] > 0){
                                $manList = $db->fetchArray($resMan[0],1);
                                $j=0;
                                foreach($manList as $manDet){
                                    $safety=$manDet['safety'];
                                    $supervisor=$manDet['supervisor'];
                                    $erectors=$manDet['erectors'];
                                    $genworker=$manDet['generalWorker'];
                                    $timein=$manDet['timeIn'];
                                    $timeout=$manDet['timeOut'];
                                    $usersArr[$key]["requestmanpower"][$b]=array("safety"=>$safety,"supervisor"=>$supervisor,"erectors"=>$erectors,"generalworker"=>$genworker,"timein"=>$timein,"timeout"=>$timeout);
                                    $b++;
                                }
                            }
                        }
                        $k++;
                    }
                }
			}
		}
		return $usersArr;
    }
}

// create new PDF document
$pdf = new MYPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);
$vari=$pdf->getWorkRequestListDate($workrequstid);
if(empty($vari))
{
    $returnval["code"] = 1;
    $returnval["message"] = "Invalid Work Request";
    echo json_encode($returnval);
    exit;        
}
//print_r(json_encode($vari));exit;
$wrequestid="";
$projectname="";
$clientname="";
$location="";
$description="";
$drawingAttach="";
$scaffoldtypelist="";
$scaffoldworktypelist="";
$scaffoldworktypelistarray="";
$contracttype="";
$workbasedon="";
$requestedBy="";
$createdOn="";
$createdBy="";
$sizeslist="";
$sizeslistfinal="";
$imgdisp="";
if(!empty($vari))
{
    $createdOn=$vari[0]['createdOn'];
    $createdOn=date("Y-m-d h:i A",strtotime($createdOn));
    $createdBy=$vari[0]['createdBy'];
    $projectname=$vari[0]['projectname'];
    $clientname=$vari[0]['clientname'];
    $location=$vari[0]['location'];
    $description=$vari[0]['description'];
    $drawingAttach=$vari[0]['drawingAttach'];
    if ($vari[0]['drawingimage'] != '')
    {
    $drawingimage="http://".$_SERVER['HTTP_HOST']."/productivity-api/".$vari[0]['drawingimage'];
    }
    else{
        $drawingimage="";
    }
    $completionimage = array();
    $completionimage=explode(",",$vari[0]['completionImages']);
    //$imgdisp=$completionimage;
    
    if(!empty($vari[0]['scaffoldtypelist']))
    {
        $scaffoldtypelist=array_unique($vari[0]['scaffoldtypelist']);
        $scaffoldtypelist=implode(", ",$scaffoldtypelist);
    }
    if(!empty($vari[0]['scaffoldworktypelist']))
    {
        $scaffoldworktypelistarray=array_unique($vari[0]['scaffoldworktypelist']);
        $scaffoldworktypelist=implode(", ",$scaffoldworktypelist);
    }
    $sizeslist=$vari[0]['sizeslist'];
    $contracttype=$vari[0]['contracttype'];
    $workbasedon=$vari[0]['workbasedon'];
    $requestedBy=$vari[0]['requestedBy'];
    $wrrequestname="vss-".trim(substr($clientname,0,3)).'-'.trim(substr($projectname,0,3))."-wr-".str_pad($vari[0]['workRequestId'], 4, '0', STR_PAD_LEFT);
    $wrequestid=strtoupper($wrrequestname);
}
if(!$wrequestid)
{
    $wrequestid="____________________________________________<br />";
}

if(!$location)
{
    $location="_____________________________________________";
}

if($drawingAttach)
{
    $drawingAttach='checked="checked"';
}
else
{
    $drawingAttach='checked=""';
}
if(!empty($scaffoldworktypelistarray))
{
    if(in_array("Erection",$scaffoldworktypelistarray))
    {
        $tswchecked1='checked="checked"';
    }
    if(in_array("Dismandle",$scaffoldworktypelistarray))
    {
        $tswchecked2='checked="checked"';
    }
    if(in_array("Modification",$scaffoldworktypelistarray))
    {
        $tswchecked3='checked="checked"';
    }
    if(in_array("Erection & Dismandle",$scaffoldworktypelistarray))
    {
        $tswchecked4='checked="checked"';
    }
    if(in_array("Re-Erection",$scaffoldworktypelistarray))
    {
        $tswchecked5='checked="checked"';
    }
    if(in_array("Modification & Dismandle",$scaffoldworktypelistarray))
    {
        $tswchecked6='checked="checked"';
    }
    if(in_array("Top-Up",$scaffoldworktypelistarray))
    {
        $tswchecked7='checked="checked"';
    }
    if(in_array("Dismandle & Re-Erection",$scaffoldworktypelistarray))
    {
        $tswchecked8='checked="checked"';
    }
    /*
    <tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Type of Scaffold Work</b></td>
		<td colspan="3">'.$scaffoldworktypelist.'</td>
	</tr>
    */
}
else
{
    $tswchecked1='checked=""';
    $tswchecked2='checked=""';
    $tswchecked3='checked=""';
}
if(!empty($contracttype))
{
    if($contracttype=="Original Contract")
    {
        $nwchecked1='checked="checked"';
    }
    else if($contracttype=="Variation Works")
    {
        $nwchecked2='checked="checked"';
    }
}
else
{
    $nwchecked1='checked=""';
    $nwchecked2='checked=""';
}
if(!empty($workbasedon))
{
    if($workbasedon=="Size")
    {
        $wbchecked1='checked="checked"';
        foreach($sizeslist as $sizekey=>$sizevalue){
            $sizeslistfinal.=($sizekey+1).") ".$sizevalue."<br/>";
        }
    }
    else if($workbasedon=="ManPower")
    {
        $wbchecked2='checked="checked"';
    }
    else
    {
        $wbchecked3='checked="checked"';
    }
}
else
{
    $wbchecked1='checked=""';
    $wbchecked2='checked=""';
}

// set document information
//$pdf->SetCreator(PDF_CREATOR);
//$pdf->SetAuthor('Nicola Asuni');
$pdf->SetTitle('WORK REQUEST FORM');
//$pdf->SetSubject('TCPDF Tutorial');
//$pdf->SetKeywords('TCPDF, PDF, example, test, guide');

// set default header data
//$pdf->SetHeaderData(PDF_HEADER_LOGO, PDF_HEADER_LOGO_WIDTH, PDF_HEADER_TITLE.' 006', PDF_HEADER_STRING);

// set header and footer fonts
$pdf->setHeaderFont(Array(PDF_FONT_NAME_MAIN, '', PDF_FONT_SIZE_MAIN));
$pdf->setFooterFont(Array(PDF_FONT_NAME_DATA, '', PDF_FONT_SIZE_DATA));

// set default monospaced font
$pdf->SetDefaultMonospacedFont(PDF_FONT_MONOSPACED);

// set margins
$pdf->SetMargins(PDF_MARGIN_LEFT, PDF_MARGIN_TOP, PDF_MARGIN_RIGHT);
$pdf->SetHeaderMargin(PDF_MARGIN_HEADER);
$pdf->SetFooterMargin(PDF_MARGIN_FOOTER);

// set auto page breaks
$pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);

// set image scale factor
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// set some language-dependent strings (optional)
if (@file_exists(dirname(__FILE__).'/lang/eng.php')) {
	require_once(dirname(__FILE__).'/lang/eng.php');
	$pdf->setLanguageArray($l);
}

// ---------------------------------------------------------

// set font
$pdf->SetFont('dejavusans', '', 10);

// add a page
$pdf->AddPage();

$html = '<br /><br />
<table bgcolor="#bfbfbf" style="text-align:center;font-size:17px;color:#a01603;font-weight: bold;">
	<tr><td><b>WORK REQUEST FORM</b></td></tr>
</table>
<br /><br />
<table border="1" cellspacing="2" cellpadding="10">
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Project</b></td>
		<td>'.$projectname.'</td>
		<td rowspan="2" colspan="2" align="center" >WR Reference Number<br />'.$wrequestid.'<br /><span style="color:#737574;"><i>(Erection WR Ref.#____________________)</i></span></td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Client</b></td>
		<td>'.$clientname.'</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Location</b><br />
			<small>(Block / Level & Grid Line)</small>
		</td>
		<td colspan="3">
			<table>
				<tr>
					<td colspan="2" align="center" >'.$location.'</td>
					<td align="center" ><input type="checkbox" name="drawingattached" value="Drawing Attached" '.$drawingAttach.' readonly="true" /> Drawing Attached</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Description</b><br />
			<small>(Purpose of scaffold)</small>
		</td>
		<td colspan="3">'.$description.'</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Scaffold Type</b><br />
			<small>(Eg: Tower / Perimeter / Cantilever / Mobile...)</small>
		</td>
		<td colspan="3">'.$scaffoldtypelist.'</td>
	</tr>
	<tr rowspan="2" >
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Type of Scaffold Work</b></td>
		<td colspan="3">
		    <table>
        		<tr>
        			<td>
        			    <span><input type="checkbox" name="scaffoldwork" value="Erection" '.$tswchecked1.' readonly="true" /> Erection</span>
        			</td>
        			<td>
        			    <span><input type="checkbox" name="scaffoldwork" value="Dismantle" '.$tswchecked2.' readonly="true" /> Dismantle</span>
        			</td>
        		</tr>
        		<tr>
        			<td>
        			    <span><input type="checkbox" name="scaffoldwork" value="Modification" '.$tswchecked3.' readonly="true" /> Modification</span>
        			</td>
        			<td>
        			    <span><input type="checkbox" name="scaffoldwork" value="Erection & Dismandle" '.$tswchecked4.' readonly="true" /> Erection & Dismandle</span>
        			</td>
        		</tr>
        		<tr>
        			<td>
        			    <span><input type="checkbox" name="scaffoldwork" value="Re-Erection" '.$tswchecked5.' readonly="true" /> Re-Erection</span>
        			</td>
        			<td>
        			    <span><input type="checkbox" name="scaffoldwork" value="Modification & Dismandle" '.$tswchecked6.' readonly="true" /> Modification & Dismandle</span>
        			</td>
        		</tr>
        		<tr>
        			<td>
        			    <span><input type="checkbox" name="scaffoldwork" value="Top-Up" '.$tswchecked7.' readonly="true" /> Top-Up</span>
        			</td>
        			<td>
        			    <span><input type="checkbox" name="scaffoldwork" value="Dismandle & Re-Erection" '.$tswchecked8.' readonly="true" /> Dismandle & Re-Erection</span>
        			</td>
        		</tr>
        	</table>
		</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Nature of Work</b></td>
		<td colspan="3">
			<table>
				<tr>
					<td><span><input type="checkbox" name="naturework" value="Original Contract" '.$nwchecked1.' readonly="true" /> Original Contract</span></td>
					<td colspan="2"><span><input type="checkbox" name="naturework" value="Variation Work" '.$nwchecked2.' readonly="true" /> Variation Work</span></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Work based on</b></td>
		<td colspan="3">
			<table>
				<tr>
					<td><span><input type="checkbox" name="workbased" value="Scaffold Size" '.$wbchecked1.' readonly="true" /> Scaffold Size</span></td>
					<td><span><input type="checkbox" name="workbased" value="Man Hour" '.$wbchecked2.' readonly="true" /> Man Hour</span></td>
					<td><span><input type="checkbox" name="workbased" value="Others" '.$wbchecked3.' readonly="true" /> Others__________</span></td>
				</tr>
				<tr>
				    <td colspan="3">'.$sizeslistfinal.'</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Work Request By</b></td>
		<td colspan="3">'.$requestedBy.'</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Position</b></td>
		<td colspan="3">
			<table>
				<tr>
					<td colspan="2"></td>
					<td>HP#</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Signature</b></td>
		<td colspan="3">
			<table>
				<tr>
					<td colspan="2"></td>
					<td>Date & Time:</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Comments</b> by Client<br /><br /></td>
		<td colspan="3"><br /><br /></td>
	</tr>
</table>
<br /><br />
<table border="1" cellpadding="10">
	<tr bgcolor="#e6b8b7">
		<td colspan="4"><b>Vinayak Scaffold : Person-in-Charge</b></td>
	</tr>
	<tr>
		<td colspan="4">
		    <table>
		        <tr>
		            <td>Name: '.$createdBy.'</td>
		            <td>Date: '.$createdOn.'</td>
		            <td>Signature:</td>
		        </tr>
		    </table>
	    </td>
	</tr>
	<tr>
		<td colspan="4">Remarks:</td>
	</tr>
	<tr bgcolor="#e6b8b7">
		<td colspan="4"><b>Additional Comments:</b></td>
	</tr>
	<tr>
		<td colspan="4"><br /><br /><br /></td>
	</tr>
</table>
<img src="'.$drawingimage.'" />';
/*$j=1;
foreach($completionimage as $imagepath)
    {
     if(j == 1)
     {
        $imgdisp=$imgdisp.'<table><tr>';   
     }
     $imgdisp=$imgdisp.'<td><img src="http://'.$_SERVER['HTTP_HOST'].'/productivity-api/'.$imagepath.'" width="300 px"/></td>';
     if (j/3 == 0)
     {
        $imgdisp=$imgdisp.'</tr><tr>';   
     }
     $j++;
    }
    $imgdisp=$imgdisp.'</tr></table>';
*/




// output the HTML content
//$pdf->writeHTML($html, true, false, true, false, '');

//Close and output PDF document
//$pdf->Output('workrequestform.pdf', 'I');
//$pdf->writeHTML($html, true, false, true, false, '');
//$pdf->Output('workrequestform.pdf', 'I');
//$pdf->AddPage();
//$pdf->AddPage('P', 'A4');

//$pdf->Cell(0, 0, 'A4 PORTRAIT', 1, 1, 'C');
//$pdf->AddPage();
//$pdf->Cell(0, 10, ''<div>'.$imgdisp.'</div>'', 0, 1, 'L');
$pdf->writeHTML($html, true, false, true, false, '');
//$pdf->writeHTML($html, true, false, true, false, '');
//$pdf->startPageGroup();
//$html='<div>'.$imgdisp.'</div>';
if(!empty(completionimage))
    {
$pdf->AddPage();
/** String */
//$pdf->SetXY(110, 200);
$x=15;
$y=35;
$i=0;
$w=90;
$h=90;
$k=0;
$horizontal_alignments = array('L', 'C', 'R');
$vertical_alignments = array('T', 'M', 'B');
/*foreach($completionimage as $imagepath)
    {*/
    //$fitbox = $horizontal_alignments[$i].' ';
    $divCount =sizeof($completionimage)/6;
	$modCount=sizeof($completionimage)%6;
	if(modCount > 0)
	{
		$divCount++;
	}
	
     $imgdisp='http://'.$_SERVER['HTTP_HOST'].'/productivity-api/'.$imagepath;
     $l=0;
     for ($i = 0; $i<$divCount; $i++) {
    //$html='<p>Print</p>';
	//$pdf->writeHTML($html, true, false, true, false, '');
		 $y=35;
		 $x = 15;
		 if($i > 0)
			$pdf->AddPage();	  
		 for($k=0;$k < 3;$k++)
		 {
			// $html='<p>Print1</p>';
	//$pdf->writeHTML($html, true, false, true, false, '');
       $fitbox = $horizontal_alignments[$k].' ';
        $x = 15;
        for ($j = 0; $j < 2; $j++) {
		//	$html='<p>Print2</p>';
	//$pdf->writeHTML($html, true, false, true, false, '');
            $fitbox[$k] = $vertical_alignments[$j];
            //$pdf->Rect($x, $y, $w, $h, 'F', array(), array(128,255,255));
            //$pdf->Image('http://'.$_SERVER['HTTP_HOST'].'/productivity-api/'.$completionimage[$k], $x, $y, 90, 90, 'JPG', '', '', true, 300, '', false, false, 1, '', false, false);
            $pdf->Image($completionimage[$l], $x, $y, 70, 70, 'JPG', 'http://'.$_SERVER['HTTP_HOST'].'/productivity-api/', '', true, 250, '', false, false, 1, false, false, false);
                                                              
            $x += 100; // new column
            $l++;
        }
        $y += 82;
    }
	 }
    }
	//$html='<p>'.$divCount.'</p><p>--'.$modCount.'</p>';
	//$pdf->writeHTML($html, true, false, true, false, '');
   // }
//$pdf->Image($drawingimage, '', '', 40, 40, '', '', '', false, 300, '', false, false, 1, false, false, false);


/** Ending */
// need $pdf->writeHTML($html, true, false, true, false, '');
//$pdf->Cell(0, 10, writeHTML($html, true, false, true, false, ''), 0, 1, 'L');
//$html=$html.$pdf->AddPage().'<div>'.$imgdisp.'</div>';
//$html=$html.$pdf->AddPage().$pdf->Cell(0, 10, '<div>'.$imgdisp.'</div>', 0, 1, 'L');;
//$pdf->writeHTML($html, true, false, true, false, '');

//Close and output PDF document
$pdf->Output('workrequestform.pdf', 'I');
//============================================================+
// END OF FILE
//============================================================+
?>
