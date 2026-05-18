configuration AADSyncRuleCounts {
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
    )

    Import-DscResource -ModuleName AADConnectDsc
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    foreach ($item in $Items)
    {
        # ConnectorName is the key. Empty string or '*' means "all connectors".
        # Translate that to a safe, descriptive token for the execution name so
        # individual array items remain uniquely identifiable in compiled MOF.
        $scope = if ([string]::IsNullOrEmpty($item.ConnectorName) -or $item.ConnectorName -eq '*')
        {
            'AllConnectors'
        }
        else
        {
            $item.ConnectorName
        }

        $executionName = ("AADSyncRuleCount__$scope") -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName AADSyncRuleCount -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
