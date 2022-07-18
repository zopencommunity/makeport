node('linux') 
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'REPO', value: 'makeport'), string(name: 'DESCRIPTION', 'makeport' )]
        }
}
