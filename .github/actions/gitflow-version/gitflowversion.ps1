# Test if the tag version are valid. Valid examples are: v1 or v1.2 or v1.2.3
$branch_ref = "${env:GITHUB_REF}"
$branch_name = "${env:GITHUB_REF_NAME}".Split('/')[-1]
Write-Host "branch_ref: $branch_ref"
Write-Host "branch_name: $branch_name"
if ($branch_ref -match "^refs\/heads\/develop$") {
    Write-Host "Development"
    $prerelease = '-alpha'
    # Get the latest tag
    $latestTag = git describe --tags --abbrev=0 --always
    if($latestTag -notmatch "^v\d+\.?\d*\.?\d*($|\s.+$)") {
        $latestTag = "v0.0.0"
    }
    Write-Host "Current tag: $latestTag"
    if ($latestTag -match "^v\d+\.?\d*\.?\d*($|\s.+$)") {
        # Split the tag version
        $latestTagVersionNumberParts = $latestTag.Trim("v").Split('.')
        if ($latestTagVersionNumberParts.Length -eq 1){
            $tag = "v" + $latestTagVersionNumberParts[0] + ".1.0"
        } elseif($latestTagVersionNumberParts.Length -ge 2){
            $tag = "v" + $latestTagVersionNumberParts[0] + "." + ([int]$latestTagVersionNumberParts[1]+1) + ".0"
        }
    }
}
elseif ($branch_ref -match "^refs\/heads\/release\/v\d+\.?\d*\.?\d*($|\s.+$)"){
    Write-Host "Stage"
    $tag = $branch_name
    $prerelease = '-beta'
}
elseif ($branch_ref -match "^refs\/tags\/v\d+\.?\d*\.?\d*($|\s.+$)") {
    Write-Host "Production"
    $tag = $branch_name
}
else {
    throw "Invalid branch or invalid version number in tag/release branch name. Do not specify revision number. Should be e.g. v1 or v1.2 or v1.2.3"
}
Write-Host "Next tag: $tag"
if ($tag -match "^v\d+\.?\d*\.?\d*($|\s.+$)") {
    # Split the tag version
    $tagVersionNumberParts = $tag -split ' ',2
    $tagVersionNumberParts = $tagVersionNumberParts[0].Trim("v").Split('.')
    $majorVersion = '0'
    $minorVersion = '0'
    $patchVersion = '0'
    $buildVersion = "${env:GITHUB_RUN_NUMBER}"
    # Build the version number
    if ($tagVersionNumberParts.Length -ge 1) {
        $majorVersion = $tagVersionNumberParts[0]
    }
    if ($tagVersionNumberParts.Length -ge 2) {
        $minorVersion = $tagVersionNumberParts[1]
    }
    if ($tagVersionNumberParts.Length -ge 3) {
        $patchVersion = $tagVersionNumberParts[2]
    }
	
    $packageVersion = $majorVersion+"."+$minorVersion+"."+$patchVersion
    if($prerelease -ne '') {
        $packageVersion = $packageVersion+$prerelease+"."+$buildVersion
    }
    $assemblyVersion = $majorVersion+"."+$minorVersion+"."+$patchVersion+"."+$buildVersion
    Write-Host "PackageVersion: $packageVersion"
    Write-Host "AssemblyVersion: $assemblyVersion"
    
    Write-Host "::set-output name=packageVersion::$packageVersion"
    Write-Host "::set-output name=assemblyVersion::$assemblyVersion"
}
