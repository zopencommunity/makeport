
node('linux')
{
  stage ('Poll') {
                // Poll for local changes
                checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/main']],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        userRemoteConfigs: [[url: 'https://github.com/ZOSOpenTools/makeport.git']]])
  }

  stage('Build') {
    build job: 'Port-Pipeline', parameters: [
    string(name: 'PORT_GITHUB_REPO', value: 'https://github.com/ZOSOpenTools/makeport.git'),
    string(name: 'PORT_DESCRIPTION', value: 'GNU Make is a tool which controls the generation of executables and other non-source files of a program from program source files.'),
    string(name: 'BUILD_LINE', value: 'STABLE')]
  }
}

