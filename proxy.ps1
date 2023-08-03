# Load environment variables from the .env file
$envFile = Join-Path $PSScriptRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([^#][A-Za-z_]+)=(.*)$') {
            $envVarName = $matches[1]
            $envVarValue = $matches[2]
            Set-Variable -Name $envVarName -Value $envVarValue -Force
        }
    }
}


# Function to enable the proxy settings
function EnableProxy {
    # Set proxy settings for both HTTP and HTTPS and suppress the output
    [void](Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyServer -Value "${PROXY_ADDRESS}:${PROXY_PORT}" -ErrorAction SilentlyContinue)
    [void](Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1 -ErrorAction SilentlyContinue)


    # Refresh proxy settings for the current user
    $null = (New-Object -ComObject "InternetExplorer.Application").Navigate2("about:blank")
    Start-Sleep -Seconds 1
    (Get-Process iexplore | Where-Object { $_.MainWindowTitle -eq "" }).CloseMainWindow()

    Write-Host "Proxy is now enabled."
}

# Function to disable the proxy settings
function DisableProxy {
    # Disable proxy settings and suppress the output
    [void](Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 0 -ErrorAction SilentlyContinue)

    # Refresh proxy settings for the current user
    $null = (New-Object -ComObject "InternetExplorer.Application").Navigate2("about:blank")
    Start-Sleep -Seconds 1
    (Get-Process iexplore | Where-Object { $_.MainWindowTitle -eq "" }).CloseMainWindow()

    Write-Host "Proxy is now disabled."
}

# Check the current proxy status and toggle accordingly
$proxyStatus = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -ErrorAction SilentlyContinue

if ($proxyStatus -eq 1) {
    DisableProxy
} else {
    EnableProxy
}
