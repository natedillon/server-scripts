# server-scripts

Shell scripts used for tasks on my web server. The scripts were written and tested in macOS for use on an Ubuntu server.

## Instructions

### Backup MySQL

1. Put the `backup-mysql` directory somewhere on the web server (e.g. `/home/user/scripts/`).
2. Modify the settings near the top of the `backup-mysql.sh` file. Specifically, it requires adding your MySQL username and password.

### Backup files

1. Put the `backup-files` directory somewhere on the web server (e.g. `/home/user/scripts/`).
2. Make a duplicate of the `config.sh.example` file, naming it `config.sh`.
3. Modify the settings in the `config.sh` file. Specifically, it will require setting up the name and path for the desired files to backup.

### Make executable

If needed, make the scripts executable by running `chmod +x` on the main files (e.g. `chmod +x /home/user/scripts/backup-mysql.sh`).

### Cron jobs

[Set up a cron job](https://www.digitalocean.com/community/tutorials/how-to-use-cron-to-automate-tasks-ubuntu-1804) to automatically run the scripts on a schedule.

## Resources

- [How to Automate MySQL Database Backups in Linux](https://sqlbak.com/blog/how-to-automate-mysql-database-backups-in-linux) — The code in this article was the starting point for the MySQL backup script
- [How To Use Cron to Automate Tasks on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-use-cron-to-automate-tasks-ubuntu-1804)
