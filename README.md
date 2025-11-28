### When switching between machines I want no friction
### This script also sets up the nfs client and adds automount in /etc/fstab

Requires: 
A running NFS Server; the user to know the target dir + ip 

### Installation w install script:
sudo chmod +x installupdog.sh

./installupdog.sh

### Once installed:
updog Myfile.filnameextension 

updog Mydirectory


This performs some checks and replaces the old file in the target dir with the current one 

###
sudo ./installupdog.sh -r 

To reconfigure the target IP, server mountpoint
