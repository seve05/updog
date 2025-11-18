#!/bin/bash
echo "Please put in the IP of the NFS Server"
read IP
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yYj] || $confirm == [yYjJ][eEaA][sS] ]] || exit 1
#exit1 if error such that user can get the ip right
echo $IP > nfsipaddr.txt
echo "You can change the IP in ~bin/nfsipaddr.txt"
cat > vcont << 'EOF'
#!/bin/bash
IPadrpath="./nfsipaddr.txt"
IPadr=$(cat "$IPadrpath")
sudo mount -t nfs "$IPadr":mnt/networkshare "$HOME/networkfolder"
dest="$HOME/networkfolder"
cp -f "$1" "$dest"
EOF
mkdir -p "$HOME/networkfolder"
sudo chmod +x vcont
sudo mv vcont ~bin/
sudo mv nfsipadr.txt ~bin/
#now we need to install NFS Client if not present, configure NFS IP on client
sudo apt install nfs-common
sudo mount -t nfs "$IP":mnt/networkshare "$HOME/networkfolder"
