#!/bin/bash
cd
echo "Please put in the IP of the NFS Server to install updog"
read IP
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yYj] || $confirm == [yYjJ][eEaA][sS] ]] || exit 1
#exit1 if error such that user can get the ip right
echo $IP > nfsipaddr.txt
echo "You can updog the IP adress of the server in case you want to change it in ~bin/nfsipaddr.txt"

#if future me ever gets asked this question: no indents because EOF syntax "here document" wont allow for it.
if ![ -e "$HOME/updog" ]; then
cat > updog << 'EOF'
#!/bin/bash
IPadrpath="./nfsipaddr.txt"
IPadr=$(cat "$IPadrpath")
sudo mount -t nfs "$IPadr":mnt/networkshare "$HOME/networkfolder"
dest="$HOME/networkfolder"
cp -f "$1" "$dest"
EOF
else
echo "updog already exists, exiting"
exit 1
fi

if ![ -e "$HOME/networkfolder" ]; then
	mkdir -p "$HOME/networkfolder"
else
	echo "cant create networkfolder, already exists, if intentional: please ignore"
fi

sudo chmod +x updog
sudo mv updog ~bin/
sudo mv nfsipaddr.txt ~bin/

#now we need to install NFS Client if not present, configure NFS IP on client
sudo apt install nfs-common
#sudo mount -t nfs "$IP":mnt/networkshare "$HOME/networkfolder"

