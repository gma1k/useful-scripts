function Test-JavaVersion {
  [cmdletbinding()]
  Param(
    [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('hostname','name')]
    [System.String[]]$ComputerName = 'localhost',
    [System.String[]]$Option = '1',
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [System.String]$LogFile = 'C:\Users\$env:USERNAME\Documents\Test-JavaVersion.log',
    [Switch]$DryRun = $False
  )
  Begin{
    # Initialize a hashtable to store the results
    $list = @{}
    Write-Verbose "Starting Test-JavaVersion function" -Verbose
    Write-Debug "Parameters: ComputerName = $($ComputerName -join ', '), LogFile = $LogFile, DryRun = $DryRun" -Debug
    Write-Verbose "Log file: $LogFile" -Verbose
  }
  Process{
    foreach ($Computer in $ComputerName) {
      try {
        # Test the connectivity of the computer
        if(Test-Connection -ComputerName $Computer -Quiet -Count 1) {
          # Write a verbose message to indicate the computer is reachable
          Write-Verbose "Checking Java version on $Computer" -Verbose
          # Invoke a script block on the remote computer to get the Java versions from processes and registry keys
          $list[$Computer] = Invoke-Command -ComputerName $Computer -ScriptBlock {
            # Get the hostname of the remote computer
            $HostName = $env:COMPUTERNAME
            # Get the Java versions from processes
            $JavaVersionsFromProcesses = Get-Process java | ForEach-Object {
              [PSCustomObject]@{
                HostName = $HostName
                Name = $_.Name
                Path = $_.Path
                Version = (Get-Command $_.Path | Select-Object -ExpandProperty Version).ToString()
              }
            }
            # Get the Java versions from registry keys under HKCU
            $JavaVersionsFromRegistry = Get-CimInstance -Class Win32_Product -Filter "Name like '%Java%' and not Name like '%Java Auto Updater%'" | ForEach-Object {
              [PSCustomObject]@{
                HostName = $HostName
                Name = $_.Name
                Path = $_.InstallLocation
                Version = $_.Version
              }
            }
            # Get the Java versions from registry keys under HKLM
            $JavaVersionsFromRegistryHKLM = Get-ChildItem -Path HKLM:\SOFTWARE\JavaSoft -Recurse -Name
            # Compare the two methods and display the differences in a compact table format
            Compare-Object $JavaVersionsFromProcesses $JavaVersionsFromRegistry -Property Version -PassThru | Format-Table -AutoSize -Wrap
            # Display the Java versions from registry keys under HKLM
            $JavaVersionsFromRegistryHKLM | Format-Table -AutoSize -Wrap
          }
          # Write a verbose message to indicate the result for the computer using the -f operator to format the string and insert the variable value
          Write-Verbose ("Result for {0}: {1}" -f $Computer, ($list[$Computer] | Out-String)) -Verbose
        }
        else {
          # Write a warning message to indicate the computer is not reachable
          Write-Warning "$Computer is not reachable"
        }
      }
      catch {
        # Write an error message to indicate the exception that occurred
        Write-Error $_.Exception.Message
      }
    }
  }
  End{
    # Write a verbose message to indicate the end of the function
    Write-Verbose "Ending Test-JavaVersion function" -Verbose
    # Return the results as a hashtable
    return $list
  }
}
<#
# Get the commands
$Commands = Get-Content $PSCommandPath | Where-Object {$_ -match '^\s*\w+'} | ForEach-Object {$_.Trim().Split()[0]} | Where-Object {Get-Command $_ -ErrorAction SilentlyContinue} | Select-Object -Unique
# Get the module name for each command
$Modules = $Commands | ForEach-Object {(Get-Command $_).Module.Name} | Select-Object -Unique
# Check if each module is installed
foreach ($Module in $Modules) {
  if (-not (Get-Module -ListAvailable -Name $Module)) {
    Write-Host "Installing $Module module..."
    Install-Module -Name $Module -Scope CurrentUser -Force -WhatIf:$DryRun
  }
  Import-Module $Module
}
#>

If($Option -eq $null){
  # Display a menu of options and ask for user input
  Write-Host "Please select an option to check Java version on computers using both methods:" -ForegroundColor Cyan
  Write-Host "1. Check Java version on local computer" -ForegroundColor Cyan
  Write-Host "2. Check Java version on a single remote computer" -ForegroundColor Cyan
  Write-Host "3. Check Java version on multiple remote computers" -ForegroundColor Cyan
  Write-Host "4. Check Java version on all computers in a text file" -ForegroundColor Cyan

  Write-Host "5. Exit" -ForegroundColor Cyan
  Write-Host "6. Check Java version on local computer in dry run mode" -ForegroundColor Cyan
  $Option = Read-Host "Enter your choice"
}

# Execute the corresponding code based on user input
switch ($Option) {
  "1" {
    # Check Java version on local computer
    Test-JavaVersion -Verbose -Debug 4>&1 | Out-File C:\Users\$env:USERNAME\Documents\Test-JavaVersion.log -Append
  }
  "2" {
    # Check Java version on a single remote computer
    $ComputerName = Read-Host "Enter the name or IP address of the remote computer"
    Test-JavaVersion -ComputerName $ComputerName -Verbose -Debug 4>&1 | Out-File C:\Users\$env:USERNAME\Documents\Test-JavaVersion.log -Append
  }
  "3" {
    # Check Java version on multiple remote computer
    $Computers = Read-Host "Enter the names or IP addresses of the remote computers separated by commas"
    Test-JavaVersion -ComputerName $Computers.Split(",") -Verbose -Debug 4>&1 | Out-File C:\Users\$env:USERNAME\Documents\Test-JavaVersion.log -Append
  }
  "4" {
    # Check Java version on all computers in a text file
    $FilePath = Read-Host "Enter the path to the text file that contains the names or IP addresses of the computers"
    $Computers = Get-Content $FilePath
    Test-JavaVersion -ComputerName $Computers -Verbose -Debug 4>&1 | Out-File C:\Users\$env:USERNAME\Documents\Test-JavaVersion.log -Append
  }

  "5" {
    # Exit the script
    Write-Host "Exiting..."
    break
  }
  "6" {
    # Check Java version on local computer in dry run mode
    Test-JavaVersion -Verbose -Debug -DryRun 4>&1 | Out-File C:\Users\$env:USERNAME\Documents\Test-JavaVersion.log -Append
  }
  default {
    # Invalid input
    Write-Warning "Invalid option. Please try again."
  }
}
