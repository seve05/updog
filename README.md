### version control for my local nfs network to keep parity between machines
### this script also sets up the nfs client and automounts it in /etc/fstab
Requires: a running NFS Server; the user to know the target dir + ip 

### Installation w install script:
sudo chmod +x installupdog.sh

./installupdog.sh

### Once installed:
updog myfile.filenameextension

###
sudo .installupdog.sh -r to reconfigure the target IP, mountpoint
