# server-scripts

Shell scripts used for tasks on my web server. The scripts were written and tested in macOS for use on an Ubuntu server.

## Instructions

### MySQL backup

1. Put the `mysql-backup.sh` file somewhere on the web server (e.g. `/home/user/scripts/`).
2. Modify the settings near the top of the file. Specifically, it requires adding your MySQL username and password.
3. Make sure the file is executable, running `chmod +x` on the file if needed (e.g. `chmod +x /home/user/scripts/mysql-backup.sh`).
4. [Set up a cron job](https://www.digitalocean.com/community/tutorials/how-to-use-cron-to-automate-tasks-ubuntu-1804) to run the script on a schedule.

## Resources

- [How to Automate MySQL Database Backups in Linux](https://sqlbak.com/blog/how-to-automate-mysql-database-backups-in-linux) — I started with the example in this article for my MySQL backup script and then over-engineered from there
- [How To Use Cron to Automate Tasks on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-use-cron-to-automate-tasks-ubuntu-1804)