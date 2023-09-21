
node('linux')
{
  stage ('Poll') {
               // Poll from upstream:
               checkout([
                                               $class: 'GitSCM',: 'GitSCM',
                       branches: [[name: '*/4.4.1']],
                       doGenerateSubmoduleConfigurations: false,
                       extensions: [],
                       userRemoteConfigs: [[url: 'https://git.savannah.gnu.org/git/make.git']]])

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

  string(name: 'BUILD_LINE', value: 'DEV')]
  }
}

