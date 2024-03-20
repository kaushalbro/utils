#!/bin/bash
REMOTE_SSH_PASSWORD="kaushal@123";
REMOTE_SSH_HOST="10.10.10.10";
REMOTE_SSH_USER="kaushal"; 
LOCAL_SQL_USER="root";
LOCAL_SQL_PASSWORD="root";

isInstalled(){ 
    if [ ! "$(dpkg-query -W --showformat='${db:Status-Status}' "$1" 2>&1)" = installed ]; then
       echo -e $1 ' is not installed!!\n' $1' is required to run this programe!! '
       read -p "Enter Y|y to install:[Y/y] Key= " a
       if [[ ${a} = "Y" ||  ${a} = "y" ]]; then
          sudo apt install $1
          isInstalled $1
      else 
          echo "wrong input"
          exit 0
      fi
  fi
}
isInstalled "sshpass"
isInstalled "whiptail"

danger="\033[0;31m"
done="\033[0;32m"
warning="\033[0;33m"
prompt_input() {
    local prompt="$1"
    whiptail --inputbox "$prompt" 10 70 3>&1 1>&2 2>&3;
}
prompt_yesno() {
    local prompt="$1"
    whiptail --yesno "$prompt" 10 50 3>&1 1>&2 2>&3
    return $?
}

function drop_schema(){
    local mysql_user="$1"
    local mysql_password="$2"
    local schema_name="$3"
    mysql -u "$mysql_user" -p"$mysql_password" -e "DROP DATABASE IF EXISTS $schema_name;"
}
function create_schema(){
    local mysql_user="$1"
    local mysql_password="$2"
    local schema_name="$3"
    mysql -u "$mysql_user" -p"$mysql_password" -e "CREATE DATABASE IF NOT EXISTS $schema_name;"
}

function ask_schemaName_create_and_import(){
    local new_dbname="$1"
    schema_name=$(prompt_input "Enter new local schema/db name (Empty means not imported):")
    if [ $? -ne 0 ]; then
        echo " "
        echo " "       
        echo -e "${danger} $db_name import canceled."
        echo -e "${done}  Db "$db_name".sql backup successfully.."  ;       
        echo " "
        echo " " 
        echo "0"
        exit 0
    fi   
    is_schema_exist=$(check_schema_existence "$LOCAL_SQL_USER" "$LOCAL_SQL_PASSWORD" "$schema_name")
    if [ "$is_schema_exist" -eq 1 ]; then
        prompt_yesno "Schema $schema_name  already exist in local. \nDo you want to override it ?"
        can_override_db=$?
        if [ "$can_override_db" -eq 0 ]; then    
            drop_schema "$LOCAL_SQL_USER" "$LOCAL_SQL_PASSWORD" "$schema_name";
            create_schema "$LOCAL_SQL_USER" "$LOCAL_SQL_PASSWORD" "$schema_name";
            echo " "
            echo " "       
            echo -e "${warning}  Database is Importing from remote to local please wait...."  ;
            echo -e "${warning}  Time depends upon the size of remote database and performance of local server...."  ;              
            echo " "
            echo " " 
            import_database "$LOCAL_SQL_USER" "$LOCAL_SQL_PASSWORD" "$schema_name" "$new_dbname";
            exit 0;
        else 
            ask_schemaName_create_and_import
            exit 0
        fi
    else
       create_schema "$LOCAL_SQL_USER" "$LOCAL_SQL_PASSWORD" "$schema_name";
       echo " "
       echo " "       
       echo -e "${warning}  Database is Importing from remote to local please wait...."  ;
       echo " "
       echo -e "${warning}  Time depends upon the size of remote database and performance of local server...."  ;               
       echo " "
       echo " " 
       import_database "$LOCAL_SQL_USER" "$LOCAL_SQL_PASSWORD" "$schema_name" "$new_dbname";
   fi    
}

import_database(){
    local mysql_user="$1"
    local mysql_password="$2"
    local schema_name="$3"
    local file_path="$4"
    mysql -u "$mysql_user" -p"$mysql_password"  $schema_name < ./$file_path 
    echo " "
    echo " " 
    echo -e "${done} "$db_name".sql imported successfully from remote to local database with Schema name: $schema_name"  ;   
    echo " "
    echo " " 
}

check_schema_existence() {
    local mysql_user="$1"
    local mysql_password="$2"
    local schema_name="$3"
    db_exists=$(mysql -u "$mysql_user" -p"$mysql_password" -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$schema_name';" -sN)
    if [ -n "$db_exists" ]; then
        echo "1"
    else
        echo "0"
    fi
}

main(){
sshpass -p "$REMOTE_SSH_PASSWORD" ssh "$REMOTE_SSH_USER"@"$REMOTE_SSH_HOST" -t "./dbbackup.sh  && exit ; bash";
current_time=$(date +"%Y-%m-%d-%H:%M:%S");
echo " ";
echo " ";
echo " ";
echo -e "${warning}db is downloading from remote server please wait ..........";
echo " ";
echo " ";
echo " ";
sshpass -p "$REMOTE_SSH_PASSWORD" scp "$REMOTE_SSH_USER"@"$REMOTE_SSH_HOST":/home/$REMOTE_SSH_USER/backup_db.sql ./  ;
sshpass -p "$REMOTE_SSH_PASSWORD" ssh "$REMOTE_SSH_USER"@"$REMOTE_SSH_HOST" -t "rm /home/$REMOTE_SSH_USER/backup_db.sql  && exit ; bash";
echo " "
echo " "
userInput=$(prompt_input "Enter new database file Name (Empty means backup cancelled.):")
if [ $? -ne 0 ]; then
    echo -e "${danger}Backup canceled."
    exit 0
fi
if [ -z "$userInput" ]; then
    rm ./backup_db.sql
    echo -e "${danger}Backup is cancelled.."
    exit 0
else
    db_name="${userInput// /_}-$current_time"
    new_dbname="$db_name.sql"
    mv ./backup_db.sql "$new_dbname"
    
    prompt_yesno "Do you want to import to local database ?"
    is_import=$?
    if [ "$is_import" -eq 0 ]; then    
        ask_schemaName_create_and_import "$new_dbname";
        exit 0;
    else 
        echo -e "${done}Db $db_name.sql backup successfully.." ;   
        exit 0
    fi
fi
}


main #main function executes first

