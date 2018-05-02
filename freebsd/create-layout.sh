#!/bin/sh
# freebsd/create-layout.sh
# ------------------------
# This script is meant to build the "perfect" zfs dataset layout for FreeBSD
# and FreeBSD-based operating systems.
# However, i do not claim it's perfect yet - i mostly copied another person's
# layout and may tweak it in the future, but it basically just recreates that
# person's layout as of now, with some parameters applied to it.
# Source of the initial layout:
# https://ericmccorkleblog.wordpress.com/2016/11/15/cohabiting-freebsd-and-gentoo-linux-on-a-common-zfs-volume/
usage_and_exit()
{
	echo "Usage:";
	echo "`basename $0` <root>";
	echo "Parameters:";
	echo "	<root>:	The parent dataset under which the layout should be created.";
	echo "		It will be created by the script if it doesn't exist yet.";
	exit 1
}

[ -z "$1" ] && usage_and_exit

echo "Dataset name provided: $1";

# Confirm the user wants to do this
echo "This script will now create an amount of zfs datasets.";
echo "Please make sure your dataset path is correct first.";
echo "Are you sure you want to continue?";
read -p "Press enter to continue or Ctrl-C to cancel now..." var;

echo "Alright, let's do it!";

DATASET=$1
if ! zfs list $DATASET; then
    zfs create -o compression=lz4 $DATASET || exit 1
fi

zfs create -o exec=on -o setuid=on -o compression=lz4 $DATASET/usr || exit 1
zfs create -o exec=off -o setuid=off -o compression=gzip $DATASET/usr/include || exit 1
zfs create -o exec=on -o setuid=off -o compression=lz4 $DATASET/usr/lib || exit 1
zfs create -o exec=on -o setuid=off -o compression=lz4 $DATASET/usr/lib32 || exit 1
zfs create -o exec=on -o setuid=off -o compression=gzip $DATASET/usr/libdata || exit 1
zfs create -o exec=on -o setuid=on -o compression=lz4 $DATASET/usr/local || exit 1
zfs create -o exec=on -o setuid=off -o compression=gzip $DATASET/usr/local/etc || exit 1
zfs create -o exec=off -o setuid=off -o compression=gzip $DATASET/usr/local/include || exit 1
zfs create -o exec=on -o setuid=off -o compression=lz4 $DATASET/usr/local/lib || exit 1
zfs create -o exec=on -o setuid=off -o compression=lz4 $DATASET/usr/local/lib32 || exit 1
zfs create -o exec=on -o setuid=off -o compression=gzip $DATASET/usr/local/libdata || exit 1
zfs create -o exec=on -o setuid=off -o compression=gzip $DATASET/usr/local/share || exit 1
zfs create -o exec=off -o setuid=off -o compression=off $DATASET/usr/local/share/info || exit 1
zfs create -o exec=off -o setuid=off -o compression=off $DATASET/usr/local/share/man || exit 1
zfs create -o exec=on setuid=on -o compression=lz4 $DATASET/obj || exit 1
zfs create -o exec=on -o setuid=on -o compression=lz4 $DATASET/usr/ports || exit 1
zfs create -o exec=on -o setuid=off -o compression=gzip $DATASET/usr/share || exit 1
zfs create -o exec=off -o setuid=off -o compression=off $DATASET/usr/share/info || exit 1
zfs create -o exec=off -o setuid=off -o compression=off $DATASET/usr/share/man || exit 1
zfs create -o exec=off -o setuid=off -o compression=gzip $DATASET/usr/src || exit 1
zfs create -o exec=off -o setuid=off -o compression=lz4 $DATASET/var || exit 1
zfs create -o exec=off -o setuid=off -o compression=off $DATASET/var/db || exit 1
zfs create -o exec=off -o setuid=off -o compression=lz4 $DATASET/var/db/pkg || exit 1
zfs create -o exec=off -o setuid=off -o compression=gzip $DATASET/var/log || exit 1
zfs create -o exec=off -o setuid=off -o compression=off $DATASET/var/empty || exit 1
zfs create -o exec=off -o setuid=off -o compression=gzip $DATASET/var/mail || exit 1
zfs create -o exec=on -o setuid=off -o compression=off $DATASET/var/tmp || exit 1

echo "datasets have been created under $DATASET!";

echo "The datasets will now be mounted under /mnt to create the folder structure.";
echo "You can unmount them by running umount -R /mnt afterwards.";
read -p "Press enter to continue or Ctrl-C to cancel..." var;

echo "Mounting $DATASET to /mnt...";
mount -t zfs $DATASET /mnt || exit 1
mkdir -v /mnt/tmp;

for dir in `cat filesystem-list`; do
    mkdir -v /mnt/$dir || exit 1
    echo "Mounting $DATASET/$dir to /mnt/$dir...";
    mount -t zfs $DATASET/$dir /mnt/$dir || exit 1
done
