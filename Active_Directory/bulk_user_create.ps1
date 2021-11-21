Import-Module activedirectory
$users = Import-Csv './data.csv'

foreach ($user in $users) {
    $password = (ConvertTo-SecureString -AsPlainText $user.password -Force)
    $display_name = $user.firstname + "." + $user.lastname
    
    $params = @{
        'Name' = $display_name
        'EmailAddress' = $user.email
        'GivenName' = $user.firstname
        'Surname' = $user.lastname
        'AccountPassword' = $password
        'Enabled' = $true
    }

    $exist_user = (Get-ADUser $display_name)
    if ($null -eq $exist_user) {
        try {
            New-ADUser @params
            Write-Output("User With Display Name: $display_name Created!")
        }
        catch {
            Write-Output("Cannot Create User With Display Name: $display_name  Check Your Data (Password Complexity and ...)!")
        }
    }
    else {
        Write-Output("User With Display Name: $display_name Exist!")
    }
    
    if ($null -eq $user.groupname -or "" -eq $user.groupname) {
        Write-Output("Group Name For User: $display_name Is Null!")
    }
    else {
        $user_exist_in_group = (Get-ADGroup -Identity $user.groupname)
        if($null -eq $user_exist_in_group){
            $exist_group = Get-ADGroup -Identity $user.groupname
            if ($null -eq $exist_group) {
                New-ADGroup -Name $user.groupname -GroupScope DomainLocal
            }
            Add-ADGroupMember -Identity $user.groupname -Members $display_name
            Write-Output("User With Display Name: $display_name Added to Group!")
        }
        else{
            Write-Output("User With Display Name: $display_name Exist in Group!")
        }
    }
}
