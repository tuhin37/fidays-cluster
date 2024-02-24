#! /bin/bash
# Call this script from cron in every 10 minues

# user configureables
NAS_MOUNT=/mnt/nas-media                        # Tis is the mount point of NAS on a remote system. 
CLOUD_DISK=/mnt/disk1-4TB                       # This is the cloud directory. This will be synced with NAS. Note: This should be created and should be mounted on a large disk (4TB Cold Start DIsk). Also add entry to fstab
NAS_ENDPOINT="10.0.0.11"                        # IP address of NAS on the local network. This is used to check if it is reachable
NAS_NFS_SHARE=$NAS_ENDPOINT:/nfs/drag-media     # This is the NFS share location from NAS
TEMP_FOLDER=/tmp/jellyfin

# Check if rsync is already running
if ps -A | grep -q "rsync"; then
    echo ""
    echo "ERROR | $(date +"%Y-%m-%d %H:%M:%S") | rsync is already running. exiting"
    echo "--------------------------------------------------------------"
    exit 1
fi


# Check if the remote endpoint is reachable
if ping -c 1 -W 2 "$NAS_ENDPOINT" >/dev/null 2>&1; then
    echo ""
    echo "INFO | $(date +"%Y-%m-%d %H:%M:%S") | nas is reachable"
    echo "---------------------------------------------"
else
    echo ""
    echo "ERROR | $(date +"%Y-%m-%d %H:%M:%S") | nas is not reachable, exiting"
    echo "-----------------------------------------------------------"
    exit 1
fi

# if not mounted and directory not created then it will be created frist 
if [ ! -d $NAS_MOUNT ]
then
    echo ""
    echo "WARN | $(date +"%Y-%m-%d %H:%M:%S") | mount directory not found. creating it"
    echo "-------------------------------------------------------------------"
    sudo mkdir -p $NAS_MOUNT
fi

# mount
echo ""
echo "INFO | $(date +"%Y-%m-%d %H:%M:%S") | mounting nas"
echo "-----------------------------------------"
sudo mount -t nfs -o rw,hard,intr 10.0.0.11:/nfs/drag-media $NAS_MOUNT


# if cloud disk is not present, exit showing error(on fresh installation) create sync up from nas to cloud completely. One time only
if [ ! -d $CLOUD_DISK ]
then
    echo ""
    echo "ERROR | $(date +"%Y-%m-%d %H:%M:%S") | cloud disk ($CLOUD_DISK) not found. attach a large 4TB volume, add an entry in fstab to auto mount it at $CLOUD_DISK"
    echo "--------------------------------------------------------------------------------------------------------------------------------------------------"
    exit 1
fi

# if this is on a fresh installation, that means $CLOUD_DISK is created but never synced up. In this case first sync up from nas to cloud completely.
if [ ! -d "$CLOUD_DISK/jellyfin-cache" ] || [ ! -d "$CLOUD_DISK/jellyfin-config" ]
then
    echo ""
    echo "WARN | $(date +"%Y-%m-%d %H:%M:%S") | cloud drive empty. It synced up from nas completely. It will take few days"
    echo "-------------------------------------------------------------------------------------------------------"
    sudo mkdir -p $CLOUD_DISK
    rsync \
    -avz \
    --update \
    --progress \
    --bwlimit=100000 \
    --exclude='*' \
    --include={media/, jellyfin-config/, jellyfin-cache/} \
    $NAS_MOUNT/ \
    $CLOUD_DISK/
fi

# sync down config from cloud to nas. 
# the problem is, that nas is mountead using nfs v3. In such a caase altering permissions and ownership is not possible.
# `jellyfin-config` and `jellyfin-cache` folders are owned by 501:1000
# as a solution, the code will copy the two folders folders into /tmp/jellyfin
# then change the owner of the two folders with 501:1000
# the do the rsync to nas 
echo ""
echo "INFO | $(date +"%Y-%m-%d %H:%M:%S") | syncing down jellyfin config and cache from cloud to nas"
echo "-------------------------------------------------------------------------------------"

    # create the tmp folder if not present
    if [ ! -d "$TEMP_FOLDER" ]; then
        mkdir -p "$TEMP_FOLDER"
        echo "Folder $TEMP_FOLDER created."
    fi


    # first sync config and cache from cloud disk to /tmp
    sudo rsync -avz  --no-perms --no-owner --no-group --delete --delete-excluded --include='jellyfin-config/***'  --include='jellyfin-cache/***' --exclude='*' $CLOUD_DISK/ $TEMP_FOLDER/
    
    # set appropiate permissions 
    sudo chown -R 501:1000 $TEMP_FOLDER/*

    # sync down from tmp to nas
    rsync -avz --delete --update --progress $TEMP_FOLDER/jellyfin-config/  $NAS_MOUNT/jellyfin-config/
    rsync -avz --delete --update --progress $TEMP_FOLDER/jellyfin-cache/  $NAS_MOUNT/jellyfin-cache/



# sync up nas to cloud. if deleted in nas than it will be deleted from cloud (use case: If I restructure the files locally in nas it should reflect in cloud)
echo ""
echo "INFO | $(date +"%Y-%m-%d %H:%M:%S") | syncing up media structure nas to cloud (excludes config and cache)"
echo "------------------------------------------------------------------------------------------------"
rsync \
-avz \
--delete \
--update \
--progress \
--bwlimit=100000 \
--fuzzy \
$NAS_MOUNT/media/ \
$CLOUD_DISK/media/


# unmount
echo ""
echo "INFO | $(date +"%Y-%m-%d %H:%M:%S") | unmounting nas"
echo "-------------------------------------------"
if [ -d $NAS_MOUNT ] 
then
    sudo umount $NAS_MOUNT
    # check if the unmount was successful
    IS_MOUNTED=$( df -h| grep $NAS_MOUNT )
    if [ "$IS_MOUNTED" == "" ]
    then
        sudo rm -r $NAS_MOUNT
    else
        echo ""
        echo "ERROR | $(date +"%Y-%m-%d %H:%M:%S") | unmounting nas"
        echo "--------------------------------------------"
    fi
fi


echo ""
echo "INFO | $(date +"%Y-%m-%d %H:%M:%S") | sync complete"
echo "------------------------------------------"



# Test cases
# ++++ 1. Delete a movie in nas if if that movie gets deleted from could
# ---- 2. Move a movie from one folder to another in nas and see if thats reflected || rsync does not support moving, it will delete and recopy
# ---- 3. Rename a movie in nas and see if that is reflected (rsync makes delete and reupload)
# ++++ 4. Delete a movie from cloud, see if it reapears in cloud. also see it should not get deleted from nas
# ++++ 6. Delete config files from nas, see if it reapears in nas, also it should not get deleted in cloud
# ++++ 7. Delete cache file from nas, see if it reapears in nas, aslo it should not be deleted from cloud
# ++++ 8. Delete/edit a cache file in cloud, it shoud be editied in nas also and not the other way round
# +++++ 9. Delete/edit a config file in cloud, it should be reflected in nas, and not the otherway round
# 10. Turn off nas in the middle of an operation see how it is handled 
# 11. Turn off the router in the middle of an operation and see how it is handled


# ++++ => test successful
# ---- => test failed 


# ubuntu@ip-192-168-36-166:/mnt/disk1-4TB$ cat longhorn-disk.cfg 
# {"diskUUID":"d233ee81-646f-4b61-ae5a-5393bc4d07e1"}