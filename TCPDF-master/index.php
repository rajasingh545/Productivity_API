<?php
//============================================================+
// File name   : example_006.php
// Begin       : 2008-03-04
// Last Update : 2013-05-14
//
// Description : Example 006 for TCPDF class
//               WriteHTML and RTL support
//
// Author: Nicola Asuni
//
// (c) Copyright:
//               Nicola Asuni
//               Tecnick.com LTD
//               www.tecnick.com
//               info@tecnick.com
//============================================================+

/**
 * Creates an example PDF TEST document using TCPDF
 * @package com.tecnick.tcpdf
 * @abstract TCPDF - Example: WriteHTML and RTL support
 * @author Nicola Asuni
 * @since 2008-03-04
 */

// Include the main TCPDF library (search for installation path).
require_once('tcpdf_include.php');

// Extend the TCPDF class to create custom Header and Footer
class MYPDF extends TCPDF {

    // Page footer
    public function Footer() {
        // Position at 15 mm from bottom
        $this->SetY(-15);
        // Set font
        $this->SetFont('helvetica', 'N', 8);
        // Page number
        $this->Cell(0, 10, 'Page '.$this->getAliasNumPage().' of '.$this->getAliasNbPages(), 0, false, 'R', 0, '', 0, false, 'T', 'M');
    }
}

// create new PDF document
$pdf = new MYPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

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

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Print a table

// add a page
$pdf->AddPage();

$html = <<<EOD
<table bgcolor="#bfbfbf" style="text-align:center;font-size:17px;color:#a01603;font-weight: bold;">
	<tr><td><b>WORK REQUEST FORM</b></td></tr>
</table>
<br /><br />
<table border="1" cellspacing="2" cellpadding="10">
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Project</b></td>
		<td></td>
		<td rowspan="2" colspan="2" align="center" >WR Reference Number<br />____________________________________________<br /><br /><span style="color:#737574;"><i>(Erection WR Ref.#____________________)</i></span></td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Client</b></td>
		<td></td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Location</b><br />
			<small>(Block / Level & Grid Line)</small>
		</td>
		<td colspan="3">
			<table>
				<tr>
					<td colspan="2">_____________________________________________</td>
					<td><input type="checkbox" name="drawingattached" value="Drawing Attached" checked="" readonly="true" /> Drawing Attached</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Description</b><br />
			<small>(Purpose of scaffold)</small>
		</td>
		<td colspan="3"></td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Scaffold Type</b><br />
			<small>(Eg: Tower / Perimeter / Cantilever / Mobile...)</small>
		</td>
		<td colspan="3"></td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Type of Scaffold Work</b></td>
		<td colspan="3">
			<table>
				<tr>
					<td><span><input type="checkbox" name="scaffoldwork" value="Erection" checked="checked" readonly="true" /> Erection</span></td>
					<td><span><input type="checkbox" name="scaffoldwork" value="Dismantle" checked="" readonly="true" /> Dismantle</span></td>
					<td><span><input type="checkbox" name="scaffoldwork" value="Modification" checked="" readonly="true" /> Modification</span></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Nature of Work</b></td>
		<td colspan="3">
			<table>
				<tr>
					<td><span><input type="checkbox" name="naturework" value="Original Contract" checked="" readonly="true" /> Original Contract</span></td>
					<td colspan="2"><span><input type="checkbox" name="naturework" value="Variation Work" checked="checked" readonly="true" /> Variation Work</span></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr rowspan="2">
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Work based on</b><br /><br /><br /></td>
		<td colspan="3">
			<table>
				<tr>
					<td><span><input type="checkbox" name="workbased" value="Scaffold Size" checked="checked" readonly="true" /> Scaffold Size</span></td>
					<td><span><input type="checkbox" name="workbased" value="Man Hour" checked="" readonly="true" /> Man Hour</span></td>
					<td><span><input type="checkbox" name="workbased" value="Others" checked="" readonly="true" /> Others__________</span></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td bgcolor="#ebf1de" style="font-size:12px;"><b>Work Request By</b></td>
		<td colspan="3">
		</td>
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
		<td colspan="3"><b>Vinayak Scaffold : Person-in-Charge</b></td>
	</tr>
	<tr>
		<td colspan="3"><table><tr><td>Name:</td><td>Signature:</td></tr></table></td>
	</tr>
	<tr>
		<td colspan="3">Remarks:</td>
	</tr>
	<tr bgcolor="#e6b8b7">
		<td colspan="3"><b>Additional Comments:</b></td>
	</tr>
	<tr>
		<td colspan="3"><br /><br /><br /></td>
	</tr>
</table>
EOD;

// output the HTML content
$pdf->writeHTML($html, true, false, true, false, '');

//$pdf->Ln();


// reset pointer to the last page
//$pdf->lastPage();

// ---------------------------------------------------------

//Close and output PDF document
$pdf->Output('workrequestform.pdf', 'I');

//============================================================+
// END OF FILE
//============================================================+
