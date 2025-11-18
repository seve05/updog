# simple version control cl command for my local nfs network to keep parity between machines.

Requires: a running NFS Server; the user to know the target dir + ip 

Usage:
sudo chmod +x installupdog.sh

./updog.sh

Once installed:

updog myfile.filenameextension

You can reconfigure the IP of the server in ~bin/nfsipaddr.txt. 
