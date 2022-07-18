node('linux') 
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'REPO', value: 'makeport'), string(name: 'DESCRIPTION', 'GNU Make is a tool which controls the generation of executables and other non-source files of a program from the program's source files.' )]
        }
}
