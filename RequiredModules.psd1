@{
    PSDependOptions              = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository      = 'PSGallery'
            AllowPreRelease = $true
        }
    }

    InvokeBuild                  = 'latest'
    PSScriptAnalyzer             = 'latest'
    Pester                       = 'latest'
    Plaster                      = 'latest'
    ModuleBuilder                = 'latest'
    ChangelogManagement          = 'latest'
    Sampler                      = 'latest'
    'Sampler.GitHubTasks'        = 'latest'
    Datum                        = 'latest'
    'Datum.ProtectedData'        = 'latest'
    DscBuildHelpers              = '0.3.0-preview0003'
    'DscResource.Test'           = 'latest'
    MarkdownLinkCheck            = 'latest'
    'DscResource.AnalyzerRules'  = 'latest'
    'DscResource.DocGenerator'   = 'latest'
    PSDesiredStateConfiguration  = 'latest'
    xDscResourceDesigner         = 'latest'

    #DSC Resources
    xPSDesiredStateConfiguration = 'latest'
    AADConnectDsc                = 'latest'

}
