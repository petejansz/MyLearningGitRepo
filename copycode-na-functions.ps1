param
(
    [string]$script
)

function envCntrlVar_dependencies([string]$filename) # @dependencies
{
    $EnvCtrlVarNamesFile = "$env:USERPROFILE\Documents\CMIPS\Env-ctrl-varnames.txt"
    $envCntrlVars = cat $EnvCtrlVarNamesFile

    $dependencies = @()

    foreach ($name in $envCntrlVars)
    {
        $name = $name.Trim()

        if (Select-String -CaseSensitive -Quiet -pattern $name $filename)
        {
            $dependencies += $name
        }
    }

    return $dependencies
}

function CopyCode_NotAdv_function_dependencies([string]$filename) # @dependencies
{
    $CopyCode_NotAdv_function_names = `
    ('SEND_EMAIL                                  '`
            , 'THRESHOLD_WARNING_ENCOUNTERED              '`
            , 'CHECK_FOR_ERROR                            '`
            , 'INITIALIZE_PARMS                           '`
            , 'ORACLE_QUERY_RESULT                        '`
            , 'ORACLE_QUERY_RESULT_ARRAY                  '`
            , 'ORACLE_EXECUTE                             '`
            , 'ORACLE_ETL_SCRIPT                          '`
            , 'COPY_RENAME_FILE_ADV_TO_ADV                '`
            , 'COPY_RENAME_FILE_TO_ADV                    '`
            , 'COPY_RENAME_FILES_TO_ADV                   '`
            , 'GET_TS                                     '`
            , 'COPY_RENAME_FILE_TO_PROCSERVER             '`
            , 'COPY_RENAME_FILE_TO_PROCSERVER_NO_WAIT     '`
            , 'REPORT_SCRIPT_STATUS                       ')

    $dependencies = @()

    foreach ($name in $CopyCode_NotAdv_function_names)
    {
        $name = $name.Trim()

        if (Select-String -CaseSensitive -Quiet -pattern $name $filename)
        {
            $dependencies += $name
        }
    }

    return $dependencies
}

##### Main

$filename = resolve-path $script
$dependencies = CopyCode_NotAdv_function_dependencies $filename
$dependencies += envCntrlVar_dependencies $filename

$report = $script + ': '
foreach ($name in $dependencies)
{
    $report += $name + ' '
}

$report