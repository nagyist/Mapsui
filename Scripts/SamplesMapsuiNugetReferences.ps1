Param (
    [string]$Version
)

$Packages = (Get-Content -raw -path $PSScriptRoot\..\Directory.Packages.props -Encoding UTF8)

# for debubbing Version setting in Directory.Packages.props
# $Version = "4.0.0-beta.9"

if (-Not [string]::IsNullOrWhiteSpace($Version))
{
    [string] $currentVersion;
    $Packages | Select-Xml -XPath "//PackageVersion" | ForEach-Object {  
        if ($_.node.Include -eq "Mapsui") {                    
            $currentVersion = $_.node.Version
        }
    }

    $currentVersionString = "Version=`"$currentVersion`""
    $versionString = "Version=`"$Version`""

    $Packages = $Packages -replace $currentVersionString, $versionString

    # Normalize to no Cariage Return at the End
    $fileContent = $fileContent -replace "</Project>`r`n", "</Project>"

    Set-Content -Path $PSScriptRoot\..\Directory.Packages.props $Packages -Encoding UTF8
}

$fileNames = Get-ChildItem -Path $PSScriptRoot\..\Samples, $PSScriptRoot\..\Tests -Recurse -Include *.csproj

foreach ($file in $fileNames) {
    $fileContent = (Get-Content -raw -path $file -Encoding UTF8)
    # Set Version in files
    $Packages | Select-Xml -XPath "//PackageVersion" | ForEach-Object {  
        if ($_.node.Include.StartsWith("Mapsui")) {                    
            $include=$_.node.Include
            $project = $include + ".csproj"
            $includeui = $include -replace "Mapsui.", "Mapsui.UI."
            $projectui = $includeui + ".csproj"
        
            # <ProjectReference .... />     
            $fileContent = $fileContent -replace "<ProjectReference Include=`"`[\.\\a-zA-Z0-9]*$project`"` />", "<PackageReference Include=""$include"" />"
            $fileContent = $fileContent -replace "<ProjectReference Include=`"`[\.\\a-zA-Z0-9]*$projectui`"` />", "<PackageReference Include=""$include"" />"       

            # <ProjectReference .... >...</ProjectReference'
            $fileContent = $fileContent -replace "<ProjectReference Include=`"`[\.\\a-zA-Z0-9]*$project`"`>[`r`n <>{}/\.\-a-zA-Z0-9]*</ProjectReference>", "<PackageReference Include=""$include"" />"
            $fileContent = $fileContent -replace "<ProjectReference Include=`"`[\.\\a-zA-Z0-9]*$projectui`"`>[`r`n <>{}/\.\-a-zA-Z0-9]*</ProjectReference>", "<PackageReference Include=""$include"" />"       
        }
    }
       
    # Normalize to no Cariage Return at the End
    $fileContent = $fileContent -replace "</Project>`r`n", "</Project>"
    Set-Content -Path $file $fileContent -Encoding UTF8
}