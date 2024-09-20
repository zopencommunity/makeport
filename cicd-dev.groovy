
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
                        userRemoteConfigs: [[url: 'https://github.com/zopencommunity/makeport.git']]])
  }

  stage('Build') {
    build job: 'Port-Pipeline', parameters: [
    string(name: 'PORT_GITHUB_REPO', value: 'https://github.com/zopencommunity/makeport.git'),
    string(name: 'PORT_DESCRIPTION', value: 'GNU Make is a tool which controls the generation of executables and other non-source files of a program from program source files.'),
    string(name: 'BUILD_LINE', value: 'DEV')]
  }
}

