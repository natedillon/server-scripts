#!/bin/bash

# ========================================
# MySQL database backup
#
# Nate Dillon
#   https://natedillon.com
#
# Requires:
# - zip
# - postfix (for e-mail notifications)
# - mailutils (for e-mail notifications)
# ========================================


# Settings
# --------------------

# Backup storage directories
backup_directory=$HOME/backups/mysql
daily_directory=$backup_directory/daily
weekly_directory=$backup_directory/weekly
monthly_directory=$backup_directory/monthly

# Backup style:
# - combined (all databases in one file)
# - separated (each database in separate files)
# - both
backup_style=both

# E-mail notifications
email_notifications=false
email=<username@mail.com>

# MySQL credentials
mysql_user=<user_name>
mysql_password=<password>

# Number of backups to keep for daily/weekly/monthly backups
# Set to 0 to disable
keep_days=30
keep_weeks=4
keep_months=12

# Day to run weekly backup
# An integer, 1 (Monday) through 7 (Sunday)
weekly_backup_day=1

# Day of the month to run monthly backup
# Single digit days require a leading zero (e.g. 01)
monthly_backup_day=07

# Backup filenames:
# - datetime is the time stamp added to the files
# - combined_filename is the name used for files created using the combined backup style
datetime=$(date +%Y-%m-%d-%H%M%S)
combined_filename=all-databases


# Functions
# --------------------

# Checks for the existence of a directory and creates it if needed
check_directory () {
  local directory=$1
  if [ ! -z $directory ] && [ ! -d $directory ]; then
    mkdir -p $directory
  fi
}

# Runs the appropriate backup style
run_backup () {
  local directory=$1
  if [ $backup_style = combined ]; then
    combined_backup $directory
  elif [ $backup_style = separated ]; then
    separated_backup $directory
  elif [ $backup_style = both ]; then
    combined_backup $directory
    separated_backup $directory
 fi
}

# Runs the combined backup style
combined_backup () {
  local directory=$1/$combined_filename
  local filename=$combined_filename-$datetime
  check_directory $directory

  # Create backup
  mysqldump -u $mysql_user -p$mysql_password --all-databases > $directory/$filename.sql
  check_backup

  # Compress backup
  zip -j $directory/$filename.zip $directory/$filename.sql
  check_compression
  rm $directory/$filename.sql
  
  #echo $filename.zip | mailx -s 'Backup was successfully created' $email
}

# Runs the separated backup style
separated_backup () {
  for db in $(mysql -e 'show databases' -s --skip-column-names); do
    
    if [ $db != information_schema ] && [ $db != mysql ] && [ $db != performance_schema ] && [ $db != sys ]; then
    
      local directory=$1/$db
      local filename=$db-$datetime
      check_directory $directory

      # Create backup
      mysqldump -u $mysql_user -p$mysql_password $db > $directory/$filename.sql
      check_backup

      # Compress backup
      zip -j $directory/$filename.zip $directory/$filename.sql
      check_compression
      rm $directory/$filename.sql
    fi
  done
}

# Checks for successful backup
check_backup () {
  if [ $? == 0 ]; then
    echo 'Sql dump created'
  else
    echo 'mysqldump return non-zero code'
    if [ $email_notifications = true ]; then
      mailx -s 'No backup was created!' $email
    fi
    exit
  fi
}

# Checks for successful compression
check_compression () {
  if [ $? == 0 ]; then
    echo 'The backup was successfully compressed'
    if [ $email_notifications = true ]; then
      mailx -s 'Backup was created!' $email
    fi
  else
    echo 'Error compressing backup'
    if [ $email_notifications = true ]; then
      mailx -s 'Backup was not created!' $email
    fi
    exit
  fi
}


# Setup directories
# --------------------

check_directory $backup_directory
check_directory $daily_directory
check_directory $weekly_directory
check_directory $monthly_directory


# Run new backups and delete old backups
# --------------------

# Daily
if [ $keep_days -gt 0 ]; then
  run_backup $daily_directory
  find $daily_directory -mtime +$keep_days -delete
fi

# Weekly
if [ $keep_weeks -gt 0 ] && [ $(date +%u) = $weekly_backup_day ]; then
  run_backup $weekly_directory
  keep_weeks_as_days=$(( keep_weeks * 7 ))
  find $weekly_directory -mtime +$keep_weeks_as_days -delete
fi

# Monthly
if [ $keep_months -gt 0 ] && [ $(date +%d) = $monthly_backup_day ]; then
  run_backup $monthly_directory
  keep_months_as_days=$(( keep_months * 30 ))
  find $monthly_directory -mtime +$keep_months_as_days -delete
fi
