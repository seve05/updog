#!/bin/bash

# option -r to reconfigure the mount and ip, also edits etc/fstab to remove old entry+add new
# add functionality to back up files as well 
# maybe updog -b in the actual script
# how would we best back up our files ?
# rsync does this, by only copying the changed files, maybe use rsync instead of cp ?
# ToDo :
# - making it possible to have many nfs systems in /etc/fstab (by checking more specifically)
# - use rsync instead of cp because this only copies the diff. Also can be useful for backups
# - implement backups while im at it
# -> add another local dir mnt/backup add in etc/fstab/ and make command like updog -b that then has destination as that /mnt/backup
# -> needs to be configured on server beforehand
# - rsync -z for compression before sending when back up

if [[ $1 == "-r" ]]; then
#need to add .nfsipaddr_two.txt in /usr/local/bin/
	cd /usr/local/bin
	echo "New target IP: "
	read newip
	echo $newip > .nfsipaddr_two.txt
	
#need to add .mntpoint_two.txt	/usr/local/bin/
	echo "New mountpoint on the server: "
	read newmnt
	echo $newmnt > .mntpoint_two.txt

#need to make copy of /etc/fstab
	cd /etc/			
	sudo cp -f /etc/fstab /etc/fstab_recovery #can recover original state
	
#then we change the line in fstab itself
	oldip=$(cat /usr/local/bin/.nfsipaddr.txt)
	oldmnt=$(cat /usr/local/bin/.mntpoint.txt)	
#create old line
	oldline=$(echo "$oldip:$oldmnt") 
	echo "$oldline"	
#delete fstab entry with grep inverse matching
	grep -v "$oldline" fstab > /tmp/clearedfstab
	cp -f /tmp/clearedfstab fstab
	rm /tmp/clearedfstab
	
	echo "$newip:$newmnt /mnt/networkfolder nfs defaults,nofail  0  0" | sudo tee -a /etc/fstab
	cd /usr/local/bin
	# replace old with new or next time we run this we only add to last change
	cp -f .mntpoint_two.txt .mntpoint.txt	
	cp -f .nfsipaddr_two.txt .nfsipaddr.txt	
	sudo mount -a
	printf "Changed successfully."	
	exit 0
fi

cd
echo "Please put in the IP-address of the NFS-Server"
read IP
echo "Please put in the server mountpoint like this  /mnt/networkshare  to continue installing"
read Mnt
read -p "Inputs correct? (Y/N): " confirm && [[ $confirm == [yYj] || $confirm == [yY][eE][sS] ]] || exit 1
echo $Mnt > mntpoint.txt
echo $IP > nfsipaddr.txt
echo "You can update the IP adress and server mountpoint by running sudo installupdog.sh -r"
echo "On this machine the mountpoint is /mnt/networkfolder"
echo " "

#checks if systemd is installed so we can automount it using x-systemd.automount
systemctl --version | grep systemd > /tmp/systemdoutput 
systemdeez=$(cat "/tmp/systemdoutput")
#-z is TRUE if the string is EMPTY
if [[ -z "$systemdeez" ]]; then
	echo "Error, there is no systemd installed we cannot use automount to mount client-side in fstab"
	rm /tmp/systemdoutput
	exit 1
fi
rm /tmp/systemdoutput

#! this onesollte man noch konkreter machen, jetzt wird es wenn nfs schon irgendwo eingetragen ist failen
pattern="networkfolder nfs"
if grep -q "$pattern" /etc/fstab; then
	echo "Already added mounting option in fstab, exiting"
	exit 1
fi
#adding the automount option into /etc/fstab
cd /etc/
sudo cp /etc/fstab /etc/fstab_copy
echo " "
echo "$IP:$Mnt /mnt/networkfolder nfs defaults,nofail  0  0" | sudo tee -a /etc/fstab
echo "Copy of filesystem table in /etc/fstab_copy. "
cd 

#----------------------------------
if ! [[ -f "/mnt/updog" ]]; then
cat > updog << 'EOF'
#!/bin/bash
if [[ -d "/mnt/networkfolder" ]]; then
	if [[ -d "$1" ]]; then
		dest="/mnt/networkfolder"
		cp -rf "$1" "$dest"
	fi
	dest="/mnt/networkfolder"
	cp -f "$1" "$dest"
else
	echo "Error no networkfolder"
	exit 1
fi
EOF
else
echo "updog already exists, exiting"
exit 1
fi
#if future me ever gets asked this question: no indents because EOF syntax "here document" wont allow for it.
#---------------------------------

if ! [[ -d "/mnt/networkfolder" ]]; then
	sudo mkdir -p "/mnt/networkfolder"
	sudo chmod 777 "/mnt/networkfolder"
else
	echo "cant create networkfolder, already exists, if intentional: please ignore"
fi

sudo chmod +x updog
sudo mv updog /usr/local/bin
sudo mv mntpoint.txt /usr/local/bin/.mntpoint.txt
sudo mv nfsipaddr.txt /usr/local/bin/.nfsipaddr.txt

#now we need to install NFS Client if not present
sudo apt install -y nfs-common
echo "NFS will mount now."
sudo systemctl daemon-reload
sudo mount -a

