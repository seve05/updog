#!/bin/bash

#still need to add functionality to reconfigure the nfs client (without having to go into /etc/fstab manually
#wir behalten mntpoint.txt und nfsipaddr.txt, damit wir bei aenderung wieder den eintrag in etc/fstab finden koennen
#den wir entfernen wollen um durch neue IP und server  mountpoint zu ersetzen
#dir to execute scripts
if [[ $1 == "-r" ]]; then
	echo "Functionality not yet implemented, delete mount entry in '/etc/fstab' and '.mntpoint.txt' '.nfsipaddr.txt' and 'updog' in ~bin/ for now. "
	exit 1
fi

cd
echo "Please put in the IP-address NFS-Server"
read IP
echo "Please put in the mount point like this  /mnt/networkshare  to continue installing"
read Mnt
read -p "Inputs correct? (Y/N): " confirm && [[ $confirm == [yYj] || $confirm == [yY][eE][sS] ]] || exit 1
echo $Mnt > mntpoint.txt
echo $IP > nfsipaddr.txt
echo "You can update the IP adress and server-mountpoint the server by running installupdog.sh -r"


#checks if systemd is installed so we can automount it using x-systemd.automount
systemctl --version | grep systemd > systemdoutput 
systemdee=$(cat "$HOME/systemdoutput")
#-z is TRUE if the string is EMPTY
if [[ -z "$systemdee" ]]; then
	echo "Error, there is no systemd installed we cannot use automount to mount client-side"
	rm systemdoutput
	exit 1
fi
rm systemdoutput


pattern="networkfolder nfs x-systemd.automount"
if grep -q "$pattern" /etc/fstab; then
	echo "Already added mounting option in fstab, exiting"
	exit 1
fi
#adding the automount option into /etc/fstab
echo "$IP:$Mnt $HOME/networkfolder nfs x-systemd.automount  0  0" | sudo tee -a /etc/fstab


if ! [[ -f "$HOME/updog" ]]; then
cat > updog << 'EOF'
#!/bin/bash
dest="$HOME/networkfolder"
cp -f "$1" "$dest"
EOF
else
echo "updog already exists, exiting"
exit 1
fi
#if future me ever gets asked this question: no indents because EOF syntax "here document" wont allow for it.


if ! [[ -f "$HOME/networkfolder" ]]; then
	mkdir -p "$HOME/networkfolder"
else
	echo "cant create networkfolder, already exists, if intentional: please ignore"
fi

#need to find a better directory other than ~bin/ which is root dir
sudo chmod +x updog
sudo mv updog ~bin/
sudo mv mntpoint.txt ~bin/.mntpoint.txt
sudo mv nfsipaddr.txt ~bin/.nfsipaddr.txt

#now we need to install NFS Client if not present
sudo apt install nfs-common
echo "NFS will be mounted on next restart."
