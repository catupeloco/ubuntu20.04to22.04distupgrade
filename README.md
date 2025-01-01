# Introduction
The goal of this script is to securely upgrade Ubuntu 20.04 to Ubuntu 22.04 in stages.  
Each stage provides detailed information. The script will remove all Snap programs and Snapd itself.  
Afterward, it will install the standard version of Firefox directly from Mozilla and the Extended Support Release from Launchpad.

# Usage
`main.sh 1` # for the first stage  
`main.sh 2` # for the second stage  
and so on.
