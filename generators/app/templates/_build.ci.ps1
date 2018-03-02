Param(
    [Parameter(Mandatory=$True,ParameterSetName="Compose")]
    [switch]$BuildAndCompose,
    [Parameter(Mandatory=$True,ParameterSetName="Build")]
    [switch]$Build,
    [Parameter(Mandatory=$True,ParameterSetName="Clean")]
    [switch]$Clean    
)

# Project Mutable Variables
$publicPort=<%= port_number %>;
$url="http://localhost:$publicPort/<%= end_point %>";
$dockerComposeCiFile="docker-compose.ci.build.yml";
$dockerComposeFile="docker-compose.yml";
$sdkBuildImageName="<%= sdk_image %>";
$imageName="<%= image_name %>";

# Utilize Linux Image to produce Release Build
function BuildCI(){
    Write-Host "Building Linux (Release Mode) dotnet-build" -foregroundcolor "blue"
    Write-Host "Creating ci-build Image for building" -foregroundcolor "blue"
    docker-compose -f ".\$dockerComposeCiFile" run ci-build
    Write-Host "(Release) Build Finished" -foregroundcolor "blue"
}

# Clean Build Image / Containers after producing build files
function CleanBuildCI(){
    Write-Host "Cleaning Build Image and Containers" -foregroundcolor "blue"
    docker-compose -f ".\$dockerComposeCiFile" down
    Write-Host "Cleaned environment" -foregroundcolor "blue"
    Write-Host "Project ready to Compose" -foregroundcolor "blue"
}

# Compose Built Image
function Compose(){
    Write-Host "Creating Image and Container" -foregroundcolor "blue"
    docker-compose -f ".\$dockerComposeFile" build
    docker-compose -f ".\$dockerComposeFile" up -d  
    Write-Host "Container is ready" -foregroundcolor "blue"
}

# Kill Image and its containers
function CleanBuild(){
    Write-Host "Cleaning Build Image and Containers" -foregroundcolor "blue"
    docker-compose -f ".\$dockerComposeFile" down
    docker rmi -f $imageName
    Write-Host "Cleaned environment" -foregroundcolor "blue"
}

# Pull SDK Image to save time
function PullDockerImage(){
    docker pull $sdkBuildImageName
}

# Opens the remote site
function OpenSite () {
    Write-Host "Opening site" -NoNewline -foregroundcolor "blue"
    $status = 0

    #Check if the site is available
    while($status -ne 200) {
        try {
            $response = Invoke-WebRequest -Uri $url -Headers @{"Cache-Control"="no-cache";"Pragma"="no-cache"} -UseBasicParsing
            $status = [int]$response.StatusCode
        }
        catch [System.Net.WebException] { }
        if($status -ne 200) {
            Write-Host "." -NoNewline
            Start-Sleep 1
        }
    }

    Write-Host
    # Open the site.
    Start-Process $url
}

# Initiate CI Workflow
if($Build){
    PullDockerImage
    BuildCI
    CleanBuildCI
}
elseif($BuildAndCompose){
    PullDockerImage
    BuildCI
    CleanBuildCI
    Compose
    OpenSite
}
elseif($Clean){
    CleanBuild
}
