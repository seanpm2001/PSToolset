# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Test if we did that override already, Toolset can be
# loaded multiple times to one Powershell session
if( $GLOBAL:ToolsetAutoCompleteOptions )
{
    return
}

# Hook into the tab complete function
$function:TabExpansion2 = $Function:TabExpansion2 -replace 'End\r\n{', (@'
End
{
    if ($options -ne $null)
    {
        $options += $GLOBAL:ToolsetAutoCompleteOptions
    }
    else
    {
        $options = $GLOBAL:ToolsetAutoCompleteOptions
    }
'@)

# Overrides
$GLOBAL:ToolsetAutoCompleteOptions = @{ CustomArgumentCompleters = @{}; NativeArgumentCompleters = @{} }

$GLOBAL:ToolsetAutoCompleteOptions['NativeArgumentCompleters']['git'] =
{
    param( $completed, $ast )

    if( -not $completed )
    {
        $completed = "."
    }

    $gitCommand = $ast.CommandElements[1].Value
    switch -regex ($gitCommand)
    {
        "^(co|checkout|br|branch|rebase|merge)$"
        {
            git branch | parse "^\*?\s+(.+)" | where{ $psitem -match $completed }
        }
        "^(fetch|pull)$"
        {
            git remote | where{ $psitem -match $completed }
        }
    }
}

<# Sample how to make similar tab expansion for Powershell commands

$GLOBAL:ToolsetAutoCompleteOptions['CustomArgumentCompleters']['Remove-Outgoing:Branch'] =
{
    param($commandName, $parameterName, $completed, $commandAst, $fakeBoundParameter)

    if( -not $completed )
    {
        $completed = "."
    }

    git branch | parse "^\*?\s+(.+)" | where{ $psitem -match $completed }
}

#>