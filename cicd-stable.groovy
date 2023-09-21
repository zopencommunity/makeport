
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

  string(name: 'BUILD_LINE', value: 'STABLE')]
  }
}

