# proxmox-pve-backup

This repository contains a script to automate the backup of Proxmox PVE configurations and data. The script performs daily, weekly, and monthly backups of specified directories and the `/etc/pve` directory.

## Script Summary

The `backup_pve.sh` script performs the following tasks:
- Configures backup source directories including network configurations, host settings, SSH configurations, Proxmox cluster data, LXC container configurations, and the root user's home directory.
- Defines the destination directory for backups and the retention policy for daily, weekly, and monthly backups.
- Ensures the existence of backup directories.
- Performs incremental backups using `rsync` for normal directories and `tar` for `/etc/pve` to avoid FUSE issues.
- Cleans up old backups based on the retention policy.

## Configuration Variables

- `SOURCE_DIRS`: An array of directories to be backed up.
- `DEST_DIR`: The base directory where backups will be stored.
- `DAILY_BACKUPS`: Number of daily backups to retain.
- `WEEKLY_BACKUPS`: Number of weekly backups to retain.
- `MONTHLY_BACKUPS`: Number of monthly backups to retain.

## How to Run the Script

1. Ensure the script is executable:
   ```sh
   chmod +x scripts/backup_pve.sh
   ```

2. Run the script:
   ```sh
   ./scripts/backup_pve.sh
   ```

The script will automatically perform daily backups. It checks the current day of the week and the date to perform weekly and monthly backups respectively.

### Example Cron Jobs

To automate the script, you can set up cron jobs as follows:

- **Daily Backup**: Run the script every day at midnight:
  ```sh
  0 0 * * * /path/to/proxmox-pve-backup/scripts/backup_pve.sh
  ```

- **Weekly Backup**: Run the script every Sunday at midnight:
  ```sh
  0 0 * * 0 /path/to/proxmox-pve-backup/scripts/backup_pve.sh
  ```

- **Monthly Backup**: Run the script on the 1st of each month at midnight:
  ```sh
  0 0 1 * * /path/to/proxmox-pve-backup/scripts/backup_pve.sh
  ```

This will ensure that the script runs daily, weekly, and monthly, performing incremental backups as configured.

Feel free to adjust the paths and retention policies according to your needs.
