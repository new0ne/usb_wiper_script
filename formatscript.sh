#!/bin/bash
#
# USB-Stick Wiper v.1
# created by new0ne
#

clear
numberofdevices=0
startvalue=0

FancyBar() {
	delimiter="--------------------------"
	if [ $# -eq 0 ]
	then
		echo $delimiter
	else
		echo $delimiter
		echo $1
		echo $delimiter
	fi
}

displayWelcomeMessage() {
	FancyBar "-> USB-Stick Wiper <-"
	echo "!! CAUTION !! CAUTION !!"
	FancyBar "Using this Tool without proper understanding of what you are doing will result in data loss! Proceed at your own Risk!!!!!"
	echo "!! CAUTION !! CAUTION !!"
	FancyBar

}

askForNumberOfDevices() {
	read -p "How many USB-Sticks do you want to wipe? " userinput
	numberofdevices=${userinput//[^0-9]/}
}

askForStartDevice() {
	FancyBar "This are your devices:"
	lsblk
	FancyBar
	read -p "Which device should we start with? e.g. sda, sdb, sdN: " startdevice
	FancyBar
	startdevice=${startdevice//[^a-z]/}
	startchar=${startdevice:2}
	startvalue=$(printf "%d\n" \'$startchar)
}

listToDeletedDevices() {
	for ((i=0; i<$numberofdevices; ++i))
	do
		devicestring="/dev/sd"
		devicestring+=$( printf $(printf '\\x%02x' $(expr $startvalue + $i))) 
		number=$(expr $i + 1)
		echo -e "Device #$number: $devicestring"	
	done
}

deletePartitions() {
	for ((i=0; i < $numberofdevices; ++i))
	do
		devicestring="/dev/sd"
		devicestring+=$( printf $(printf '\\x%02x' $(expr $startvalue + $i))) 
		echo "Wiping Partition on $devicestring..."
		dd if=/dev/zero of=$devicestring bs=512 count=1 conv=notrunc
	done
	wait
	FancyBar "Phase 1: Partition wiping complete. Examine Status above!"
}

createPartitions() {
	for ((i=0; i < $numberofdevices; ++i))
	do
		devicestring="/dev/sd"
		devicestring+=$( printf $(printf '\\x%02x' $(expr $startvalue + $i)))
	        echo "Creating Partition Table on $devicestring..."
		parted $devicestring mklabel msdos
		echo "Creating Partition on $devicestring..."
		parted -a optimal $devicestring mkpart primary 0% 100% 
	done
	wait
	FancyBar "Phase 2: Partition creation completed. Examine Status above!"
}

formatPartitions() {
	for ((i=0; i < $numberofdevices; ++i))
	do

		devicestring="/dev/sd"
		devicestring+=$( printf $(printf '\\x%02x' $(expr $startvalue + $i)))1
		echo "Formatting Partition $devicestring..."
	        mkfs.ntfs $devicestring&	
	done
	wait
	FancyBar "Phase 3: Job is done. Partitions are formatted. Have Fun!"
}

displayWelcomeMessage
askForNumberOfDevices
askForStartDevice

FancyBar "We are going to process $numberofdevices Devices:"
listToDeletedDevices
FancyBar

read -p "Do you want to wipe and format those device(s): (y/N)?" yn
case $yn in
	[Yy]*)
		deletePartitions
		createPartitions
		formatPartitions 
		break;;
	[Nn]*)  exit;;
	*)	exit;;
esac
