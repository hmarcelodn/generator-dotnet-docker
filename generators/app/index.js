'use strict';
const util = require('util');
const Generator = require('yeoman-generator');
const chalk = require('chalk');
const yosay = require('yosay');
 
module.exports = class extends Generator {

    prompting() {
        this.log(yosay(
            'Welcome to ' + chalk.red('dotnet-docker') + ' generator for Dockerized .NET Core Microservices!'
        )); 

        const prompts = [{
            type: 'input',
            name: 'imageName',
            message: 'What is the image name ?'
        },
        {
            type: 'input',
            name: 'publicPort',
            message: 'Which is the port to expose your service ?'
        },
        {
            type: 'input',
            name: 'endPoint',
            message: 'Which is the endpoint to test service availability (use a relative path) ?',
            store: true
        },
        {
            type: 'input',
            name: 'projectName',
            message: 'What is the project name (dont add .csproj extensions) ?'
        },
        {
            type: 'input',
            name: 'serviceName',
            message: 'What is the service name ?'
        },
        {
            type: 'input',
            name: 'buildSdkImage',
            message: 'What is the SDK docker image for build ?',
            default: 'microsoft/dotnet:1.1.2-sdk'
        },
        {
            type: 'input',
            name: 'buildImage',
            message: 'What is the Optimized docker image for execution ?',
            default: 'microsoft/dotnet'
        }];          

        return this.prompt(prompts).then(props => {
            this.imageName = props.imageName;
            this.publicPort = props.publicPort;
            this.endPoint = props.endPoint;        
            this.projectName = props.projectName;
            this.serviceName = props.serviceName;
            this.buildSdkImage  = props.buildSdkImage;
            this.buildImage = props.buildImage;
        });              
    }

    writing(){
        var context = {
            port_number: this.publicPort,
            end_point: this.endPoint,
            image_name: this.imageName,
            project_name: this.projectName,
            service_name: this.serviceName,
            sdk_image: this.buildSdkImage,
            build_image: this.buildImage
        };

        this.fs.copyTpl(
            this.templatePath('_build.ci.ps1'),
            this.destinationPath('build.ci.ps1'),
            context);

        this.fs.copyTpl(
            this.templatePath('_build.ci.sh'),
            this.destinationPath('build.ci.sh'),
            context);

        this.fs.copyTpl(
            this.templatePath('_docker-compose.ci.build.yml'),
            this.destinationPath('docker-compose.ci.build.yml'),
            context);

        this.fs.copyTpl(
            this.templatePath('_docker-compose.yml'),
            this.destinationPath('docker-compose.yml'),
            context);  

        this.fs.copyTpl(
            this.templatePath('_Dockerfile'),
            this.destinationPath('Dockerfile'),
            context);                                                
    }    

    install() {
        console.log(chalk.grey('No extra dependencies are required.'));
    }

    end(){
        console.log(chalk.green('I have dockerized your .NET Microservice. Enjoy!'));
        console.log(''); 
        console.log(chalk.blue('Commandline Instructions:')); 
        console.log(chalk.blue('=========================')); 
        console.log(''); 
        console.log(chalk.blue('Windows:'));        
        console.log(chalk.blue('---------'));  
        console.log(chalk.blue('PowerShell Build: ./build.ci.ps1 -BuildAndCompose (This builds and run your container defined in Dockerfile)'));
        console.log(chalk.blue('PowerShell Cleanup: ./build.ci.ps1 -Clean (This clean up your container and images related)'));    
        console.log(''); 
        console.log(chalk.blue('Linux:'));        
        console.log(chalk.blue('---------'));          
        console.log(chalk.blue('Shell Cleanup: ./build.ci.ps1 -Clean (This clean up your container and images related)'));    
        console.log(chalk.blue('Shell Cleanup: ./build.ci.ps1 -Clean (This clean up your container and images related)'));        
        console.log(''); 
    }
};
