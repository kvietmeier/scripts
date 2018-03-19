Write-Host "Setting environment variables for Vagrant:";
Write-Host "    HTTPS_PROXY=http://proxy-chain.intel.com:911"
Write-Host "    HTTP_PROXY=http://proxy-chain.intel.com:911"
Write-Host "    NO_PROXY=127.0.0.1,172.16.0.0,172.10.0.0"

$env:HTTPS_PROXY="http://proxy-chain.intel.com:911"
$env:HTTP_PROXY="http://proxy-chain.intel.com:911"
$env:NO_PROXY="127.0.0.1,172.16.0.0,172.10.0.0"