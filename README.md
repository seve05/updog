## version control for my local nfs network to keep parity between machines
## this script also sets up the nfs client while installing
Requires: a running NFS Server; the user to know the target dir + ip 

### Installation w install script:
sudo chmod +x installupdog.sh

./updog.sh

### Once installed:

updog myfile.filenameextension

You can reconfigure the IP of the server in ~bin/nfsipaddr.txt.
Smae for the mountpoint in ~bin/mntpoint.txt
