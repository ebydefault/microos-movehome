########################################################################
#                                                                      #
# movehome.sh                                                          #
#                                                                      #
# Move /home under /var in openSUSE MicroOS provisioning stage         #
#                                                                      #
# Copyleft 🄯 2022 Ellam ByDefault. All rights reversed.                #
#                                                                      #
########################################################################

umount /var # mounted by default

# Create mount points
mkdir /mnt/{ROOT,VAR}
mount -o subvolid=0 /dev/disk/by-label/ROOT  /mnt/ROOT
mount -o subvolid=0 /dev/disk/by-label/SPARE /mnt/VAR

# Take an RO snapshot
btrfs subvolume snapshot -r /mnt/ROOT/@/home /mnt/ROOT/@/home_ro

# Crate parent subvolume
btrfs subvolume create /mnt/VAR/@

# Send the RO snapshot
btrfs send /mnt/ROOT/@/home_ro | btrfs receive /mnt/VAR/@

# Take an RW snapshot
btrfs subvolume snapshot /mnt/VAR/@/home_ro /mnt/VAR/@/home

# Remove RO snapshots
btrfs subvolume delete /mnt/ROOT/@/home_ro
btrfs subvolume delete /mnt/VAR/@/home_ro

# Clean up
umount /mnt/ROOT
umount /mnt/VAR
rmdir  /mnt/{ROOT,VAR}

# Modify /etc/fstab
UUID=$(blkid | grep SPARE | awk '{print $3}' | tr -d '"')

sed -nri 's,UUID=\S+( /home.+),'${UUID}'\1,;p' /etc/fstab

# Remount /var for any process ahead
mount /var
