#!/bin/bash


# ========================================
# Files backup
# https://github.com/natedillon/server-scripts
#
# Nate Dillon
# https://natedillon.com
# ========================================


# Settings
# --------------------

# Backup storage directories
backup_directory=$HOME/backups/files
daily_directory=$backup_directory/daily
weekly_directory=$backup_directory/weekly
monthly_directory=$backup_directory/monthly

# Define backup target(s)


# Functions
# --------------------

# Checks for the existence of a directory and creates it if needed
check_directory () {
  local directory=$1
  if [ ! -z $directory ] && [ ! -d $directory ]; then
    mkdir -p $directory
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


# Weekly

# Monthly
