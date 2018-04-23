function Install-TervisTrellOps {
    Install-Module -Name TrellOps
}

function New-TervisTrelloAuthTokens {
    param (
        $APIKey
    )

    $AuthRead = New-TrelloToken -Key $APIKey -AppName "TrellOpsRead" -Expiration "never" -Scope 'read'
    $AuthWrite = New-TrelloToken -Key $APIKey -AppName "TrellOpsWrite" -Expiration "never" -Scope 'read,write'
}

function New-TervisTrelloCardForVMsNotAccountedFor {

    $AuthReadCredential = Get-PasswordstateCredential -PasswordID 5391

    $AuthRead = @{
        Token = $AuthReadCredential.GetNetworkCredential().password
        AccessKey = $AuthReadCredential.UserName
    }

    $AuthWriteCredential = Get-PasswordstateCredential -PasswordID 5392

    $AuthWrite = @{
        Token = $AuthWriteCredential.GetNetworkCredential().password
        AccessKey = $AuthWriteCredential.UserName
    }

    Get-TrelloBoard -Token $AuthRead -All


    Get-TrelloBoard -Token $AuthRead -Name "Hyper-V Virtual Machines"
    $Board = Get-TrelloBoard -Token $AuthRead -Name "Hyper-V Virtual Machines"
    $cards = Get-TrelloCard -Token $AuthRead -All
    $cards = Get-TrelloCard -Token $AuthRead -All -Id $Board.Id
    $Lists = Get-TrelloList -Token $AuthRead -All -Id $Board.Id
    $UnownedList = $Lists | where Name -match Unowned


    $cards | Add-Member -MemberType ScriptProperty -Name VMName -Force -Value {
        ($This.Name -split " " | Select-Object -SkipLast 1) -join " "
    }

    $VMSAlreadyOnTrelloBoard = $cards.VMName

    $VMs = Find-TervisVM -Name *

    $VMs | where Name -NotIn $VMSAlreadyOnTrelloBoard | select -ExpandProperty Name | % {
        New-TrelloCard -Token $AuthWrite -Id $UnownedList.Id -Name $_ -Description ""
    }
}