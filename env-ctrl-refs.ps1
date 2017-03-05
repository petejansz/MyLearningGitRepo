<#
	From a directory of CMIPS MA KSH Scripts and Env-ctrl-varnames.txt of variable names,
	produce a CSV file of all KSH files and their reference counts to any Env-ctrl-varnames.txt of variable names and
	print the names of unused Env-ctrl-varnames
	
	Author: Pete Jansz
#>

param
(
    [string]$path,
	[string]$varNamesFile
)

$ErrorActionPreference = "stop"

$EnvCtrlVarNamesFile = resolve-path $varNamesFile
$EnvCntrlVarNames = cat $EnvCtrlVarNamesFile | sort

# A hashmap of VAR_NAME: count for $filename
function buildVarNameMap([string]$filename) # @map{VAR_NAME: count}
{
	$nameMap = @{}
	
	foreach ($name in $EnvCntrlVarNames)
	{
		$name = $name.Trim()
		$nameMap[$name] = 0
		
		if (sls -CaseSensitive -Quiet -pattern $name $filename)
		{
			$nameMap[$name]++
		}
	}
	
	return $nameMap
}

# CSV column headings in sorted order
function buildCsvColumnHeadings ($map)
{
	$csv = 'KSH_SCRIPT_FILENAME'
	
	foreach ($key in $map.Keys | sort)
	{
		$csv += ", $key"
	}
	
	return $csv
}

# Produce csv line of KSH_FILENAME, <ref-counts>
function reportAKshFile($filename, $map)
{
	$csv = split-path -leaf $filename
	
	foreach ($key in $map.Keys | sort)
	{
		[int]$value = $map[$key]
		$csv += ", $value"
	}
	
	return $csv
}

# A list if ksh files found in $path
function getKshFiles($path)
{
	$list = @()
	
	foreach ($file in (ls $path))
	{
		if (sls -CaseSensitive -Quiet -pattern "bin/ksh|^[A-Z_]* \(\)" $file)
		{
			$list += $file
		}
	}
	
	return $list
}

# Create CSV file ($csvFile) and return a CSV object
function createCsv($csvFile) # $csvObj
{
	try
	{
		rm $csvFile -ErrorAction SilentlyContinue
	}
	catch{}

	$count = 0
	foreach ($file in getKshFiles($path) )
	{
		$nameMap = buildVarNameMap $file.Fullname
		$count++
		
		if ($count -eq 1)
		{
			buildCsvColumnHeadings $nameMap | out-file -force -encoding utf8 $csvFile
		}
		
		reportAKshFile $file.Fullname $nameMap | out-file -append -encoding utf8 $csvFile
	}
	
	return Import-Csv $csvFile	
}

# The list of variable names not referenced by KSH scripts
function getUnusedNames($csvObject) # @names()
{
	$names = @()
		
	foreach ($name in $EnvCntrlVarNames)
	{
		$sum = ($csvObject.$name | Measure-Object -Sum).Sum
		if ($sum -eq 0)
		{
			$names += $name
		}
	}
	
	return $names
}

## Main ##
$whereAmI = (resolve-path .).ToString() 
$path = (resolve-path $path).Path
$csvFile = $whereAmI + "/refs.csv"
$csvObject = createCsv ($csvFile)
"UNUSED_NAMES"
getUnusedNames $csvObject
