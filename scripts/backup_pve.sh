#!/bin/bash

# Configuration variables
SOURCE_DIRS=(
    "/etc/network"          # Network configurations
    "/etc/hosts"            # Host settings
    "/etc/hostname"         # Hostname settings
    "/etc/ssh"              # SSH configuration
    "/var/lib/pve-cluster"  # Proxmox cluster data
    "/var/lib/lxc"          # LXC container configurations (if using)
    "/root"                 # Root user home directory (custom configs, scripts, etc.)
)

DEST_DIR="/mnt/proxmox-backup/pve-incremental"
DAILY_BACKUPS=7
WEEKLY_BACKUPS=4
MONTHLY_BACKUPS=3

DAILY_DIR="$DEST_DIR/daily"
WEEKLY_DIR="$DEST_DIR/weekly"
MONTHLY_DIR="$DEST_DIR/monthly"

# Ensure backup directories exist
mkdir -p "$DAILY_DIR" "$WEEKLY_DIR" "$MONTHLY_DIR"

# Date format for naming the backups
DATE=$(date +"%Y-%m-%d")

# Backup function for normal directories
backup() {
    local source=$1
    local dest=$2
    local backup_name="backup-$DATE"
    
    # Perform the incremental backup using rsync
    rsync -av --ignore-errors --link-dest="$dest/latest" "$source" "$dest/$backup_name"
    
    # Update latest symlink
    ln -nfs "$dest/$backup_name" "$dest/latest"
}

# Special backup for /etc/pve using tar (avoiding FUSE issues)
backup_pve() {
    local dest=$1
    local backup_name="backup-$DATE-pve.tar.gz"
    tar -czf "$dest/$backup_name" /etc/pve
}

# Clean up old backups
cleanup() {
    local dir=$1
    local max_backups=$2
    backups=$(ls -1 $dir | sort -r | tail -n +$((max_backups + 1)))
    for backup in $backups; do
        rm -rf "$dir/$backup"
    done
}

# Perform daily backups
for source in "${SOURCE_DIRS[@]}"; do
    backup "$source" "$DAILY_DIR"
done
backup_pve "$DAILY_DIR"
cleanup "$DAILY_DIR" $DAILY_BACKUPS

# Perform weekly backup every Sunday
if [ "$(date +%u)" -eq 7 ]; then
    for source in "${SOURCE_DIRS[@]}"; do
        backup "$source" "$WEEKLY_DIR"
    done
    backup_pve "$WEEKLY_DIR"
    cleanup "$WEEKLY_DIR" $WEEKLY_BACKUPS
fi

# Perform monthly backup on the 1st of each month
if [ "$(date +%d)" -eq 01 ]; then
    for source in "${SOURCE_DIRS[@]}"; do
        backup "$source" "$MONTHLY_DIR"
    done
    backup_pve "$MONTHLY_DIR"
    cleanup "$MONTHLY_DIR" $MONTHLY_BACKUPS
fi

echo "Backup process completed."
