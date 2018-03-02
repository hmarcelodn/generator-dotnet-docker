#!/bin/bash

# Project Mutable Variables
publicPort=<%= port_number %>
url="http://localhost:$publicPort/<%= end_point %>"
dockerComposeCiFile="docker-compose.ci.build.yml"
dockerComposeFile="docker-compose.yml"
sdkBuildImageName="<%= sdk_image %>"
BBlue="\033[1;36m"
imageName="<%= image_name %>"

# Utilize Linux Image to produce Release Build
buildCI () {
    printf "$BBlue Building Linux (Release Mode) dotnet-build"
    printf "$BBlue Creating ci-build Image for building"
    docker-compose -f $dockerComposeCiFile run ci-build
    printf "$BBlue (Release) Build Finished"
}

# Clean Build Image / Containers after producing build files
cleanBuildCI () {
    printf "$BBlue Cleaning Build Image and Containers"
    docker-compose -f $dockerComposeCiFile down
    printf "$BBlue Cleaned environment"
    printf "$BBlue Project ready to Compose"
}

# Compose Built Image
compose () {
    printf "$BBlue Creating Image and Container"
    docker-compose -f $dockerComposeFile build
    docker-compose -f $dockerComposeFile up -d  
    printf "$BBlue Container is ready"
}

# Kill Image and its containers
cleanBuild () {
    printf "$BBlue Cleaning Build Image and Containers"
    docker-compose -f $dockerComposeFile down
    docker rmi -f $imageName
    printf "$BBlue Cleaned environment"
}

# Pull SDK Image to save time
pullDockerImage() {
    docker pull $sdkBuildImageName
}

# Opens the remote site
openSite () {
  printf '$BBlue Opening site'
  until $(curl --output /dev/null --silent --head --fail $url); do
    printf '.'
    sleep 1
  done

  # Open the site.
  open $url
}

# Shows the usage for the script.
showUsage () {
  echo "Usage: dockerTask.sh [COMMAND] (ENVIRONMENT)"
  echo "    Runs build or compose using specific environment (if not provided, debug environment is used)"
  echo ""
  echo "Commands:"
  echo "    build: Builds a Docker image ('$imageName')."
  echo "    compose: Builds and Runs docker-compose."
  echo "    clean: Removes the image '$imageName' and kills all containers based on that image."
  echo ""
  echo "Example:"
  echo "    ./dockerTask.sh build"
  echo ""
  echo "    This will:"
  echo "        Build a Docker image named $imageName using debug environment."
}

# Initiate CI Workflow
if [ $# -eq 0 ]; then
  showUsage
else
  case "$1" in
    "compose")
            pullDockerImage
            buildCI
            cleanBuildCI
            compose
            openSite
            ;;
    "build")
            pullDockerImage
            buildCI
            cleanBuildCI
            ;;
    "clean")
            cleanBuild
            ;;
    *)
            showUsage
            ;;
  esac
fi
