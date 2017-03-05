##
## Author: Pete Jansz
##

<#

.DESCRIPTION
Convert CSV file to an Excel workbook, using the PSExcel PowerShell module.
http://ramblingcookiemonster.github.io/PSExcel-Intro/

USAGE:
	csv2xlsx -csvFilename <csvfile> -worksheetName <string> -xlsxWorkbook <path/filename>
	
.EXAMPLE
    csv2xlsx -csvFilename .\report.csv -worksheetName 'FOO BAH' -xlsxWorkbook .\abc
#>

param
(
	[string]$csvFilename,
	[string]$xlsxWorkbook, # = "$workbookDir\CMIPS_MA_Scripts-EnvCtrl-Report.xlsx"
	[string]$worksheetName
)

Import-Module PSExcel
$ErrorActionPreference = "stop"

<#
    Convert a CSV ojbect to Excel xlsx workbook, returning an Excel xlsx workbook object
#>
function convertCsv2Excel( $csvObj, [string]$xlsxWorkbook, [string]$worksheetName )
{
    Export-XLSX `
    -Path $xlsxWorkbook `
    -InputObject $csvObj `
    -WorksheetName $worksheetName `
    -Force -ClearSheet -AutoFit -Table `
    -ErrorAction Stop `
    -TableStyle Medium2
    $excelObj = New-Excel -Path $xlsxWorkbook
    return $excelObj
}

<#
    Update $excelObj row, column range with background color, returning an Excel xlsx workbook object
#>
function indicateException( $excelObj, [int]$rowNr, [int]$startColNr, [int]$endColNr, $bgColor ) # $Excel obj
{
    # Filename
    $excelObj | Get-WorkSheet | Format-Cell `
    -StartRow $rowNr `
    -EndRow $rowNr `
    -StartColumn 1 `
    -EndColumn 1 `
    -Bold $True `
    -BackgroundColor $bgColor

    # Count values
    $excelObj | Get-WorkSheet | Format-Cell `
    -StartRow $rowNr `
    -EndRow $rowNr `
    -StartColumn $startColNr `
    -EndColumn $endColNr `
    -Bold $True `
    -BackgroundColor $bgColor

    return $excelObj
}

<#
    For-each exception in $csvfilename Do set appropriate indication in $excelObj, then return $excelObj
#>
function setWorkbookIndications( $excelObj, [string]$csvFilename )
{
    $RED = "Red"
    $YELLOW = "Yellow"
    # Workbook columns:
    #Name,WMB Process Date,Archive File Record Count,WMB Process Count,Exception,Backout
    $nameColNr = 1
    $archFileRecordCntColNr = 3
    $wmbProcCntColNr = 4
    $exceptionCntColNr = 5
    $backoutCntColNr = 6

    foreach ($line in (cat $csvFilename))
    {
        $rowNr++

        if ($line -match "Name,") {continue}

        $values = $line.split(',')
        #0 Name,
        #1 WMB Process Date,
        #2 Archive File Record Count,
        #3 WMB Process Count,
        #4 Exception,
        #5 Backout
        $name =                $values[$nameColNr              - 1]
        [int]$archiveCount =   $values[$archFileRecordCntColNr - 1].trim()
        [int]$wmbCount =       $values[$wmbProcCntColNr        - 1].trim()
        [int]$exceptionCount = $values[$exceptionCntColNr      - 1].trim()
        [int]$backoutCount =   $values[$backoutCntColNr        - 1].trim()

        if ($wmbCount -ne $archiveCount)
        {
            $excelObj = indicateException $excelObj $rowNr $archFileRecordCntColNr $wmbProcCntColNr $RED
        }

        if ($exceptionCount -ne 0)
        {
            $excelObj = indicateException $excelObj $rowNr $exceptionCntColNr $exceptionCntColNr $YELLOW
        }

        if ($backoutCount -ne 0)
        {
            $excelObj = indicateException $excelObj $rowNr $backoutCntColNr $backoutCntColNr $YELLOW
        }
    }

    return $excelObj
}

$csvFilename = resolve-path $csvFilename
$xlsxWorkbook = $xlsxWorkbook + '.xlsx'

try
{
    rm $xlsxWorkbook -ErrorAction SilentlyContinue
}
catch{}

$csvObj = Import-Csv $csvFilename
$excelObj = convertCsv2Excel $csvObj $xlsxWorkbook $worksheetName
#setWorkbookIndications $excelObj $csvFilename | Save-Excel -Passthru | out-null
