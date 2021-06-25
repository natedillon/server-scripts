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

# Load the configuration file
if [ -f "./config.sh" ]; then
  . ./config.sh
else
  echo "Config file not found."
  exit
fi

# Backup timestamp
datetime=$(date +%Y-%m-%d-%H%M%S)


# Functions
# --------------------

# Checks for the existence of a directory and creates it if needed
check_directory () {
  local directory=$1
  if [ ! -z $directory ] && [ ! -d $directory ]; then
    mkdir -p $directory
  fi
}

# Runs the appropriate backups
run_backup () {
  local name=$1
  local path=$2

  # Daily
  if [ $keep_days -gt 0 ]; then
    check_directory $daily_directory/$name
    if [ ! -f "$daily_directory/$name/$name-$datetime.tar.gz" ]; then
      create_backup_file $daily_directory/$name/$name-$datetime.tar.gz $path
    else
      echo "$name file already exists. Check the config file for duplicates."
      exit
    fi
    find $daily_directory -mtime +$keep_days -delete
  fi

  # Weekly
  if [ $keep_weeks -gt 0 ] && [ $(date +%u) = $weekly_backup_day ]; then
    check_directory $weekly_directory/$name
    if [ -f $daily_directory/$name/$name-$datetime.tar.gz ]; then
      copy_backup_file $daily_directory/$name/$name-$datetime.tar.gz $weekly_directory/$name
    else
      create_backup_file $weekly_directory/$name/$name-$datetime.tar.gz $path
    fi
    keep_weeks_as_days=$(( keep_weeks * 7 ))
    find $weekly_directory -mtime +$keep_weeks_as_days -delete
  fi

  # Monthly
  if [ $keep_months -gt 0 ] && [ $(date +%d) = $monthly_backup_day ]; then
    check_directory $monthly_directory/$name
    if [ -f $daily_directory/$name/$name-$datetime.tar.gz ]; then
      copy_backup_file $daily_directory/$name/$name-$datetime.tar.gz $monthly_directory/$name
    elif [ -f $weekly_directory/$name/$name-$datetime.tar.gz ]; then
      copy_backup_file $weekly_directory/$name/$name-$datetime.tar.gz $monthly_directory/$name
    else
      create_backup_file $monthly_directory/$name/$name-$datetime.tar.gz $path
    fi
    keep_months_as_days=$(( keep_months * 30 ))
    find $monthly_directory -mtime +$keep_months_as_days -delete
  fi
}

# Creates the backup file
create_backup_file () {
  local name=$1
  local path=$2
  tar -czvf $name -C $path .
}

# Copies an existing backup file
copy_backup_file () {
  local src=$1
  local dest=$2
  cp $src $dest
}


# Directories setup
# --------------------

check_directory $backup_directory
check_directory $daily_directory
check_directory $weekly_directory
check_directory $monthly_directory


# Run new backups and delete old backups
# --------------------

if [ ${#name[@]} -gt 0 ] && [ ${#path[@]} -gt 0 ]; then
  for i in ${!name[@]}; do
    if [ ! -z ${name[$i]} ]; then
      if [ ! -z ${path[$i]} ]; then
        run_backup ${name[$i]} ${path[$i]}
      else
        echo "path[$i] is empty. Please check your config file."
      fi
    else
      echo "name[$i] is empty. Please check your config file."
    fi
  done
else
  echo "No backups defined. Please check your config file."
fi
