#!/bin/bash
# functino to check 
isInstalled(){ #this function will check if the required pacakage is installed or not
if [ ! "$(dpkg-query -W --showformat='${db:Status-Status}' "$1" 2>&1)" = installed ]; then
     echo -e $1 'is not installed!!\n' $1'is required to run this programe!! '
     read -p "Enter Y|y to install:[Y/y] Key= " a #read from user and store in a variable
    if [[ ${a} = "Y" ||  ${a} = "y" ]]; then #if the input is equall to y or Y then
      sudo apt install $1 #install whiptail
      isInstalled $1
    else #else exit
      echo "wrong input"
    exit 0
fi
fi
}
isInstalled "whiptail"

MYSQL_USER="root"
MYSQL_PASSWORD="root"
SCHEMA=$(sudo mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --skip-column-names -e "SELECT GROUP_CONCAT(schema_name) FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys');")
#convert string to array:
# Set the delimiter
delimiter=","
# Split the string into an array
IFS="$delimiter" read -r -a schema_array <<< "$SCHEMA"	
options=""
schema_array=("All" "${schema_array[@]}")
for element in "${schema_array[@]}"; do
if [ ${schema_array[0]} ]; then
    options+="$element \"Backup-$element-db\" "
else
    options+="$element \"Backup-$element\" "
fi
done
options+="\"End\" \"End\""
# Display the whiptail menu and store the selected option
menu_width=70
DATABASE=$(whiptail --title "Backup/Export Database" --menu "Choose a Database to backup" $((menu_width - 50)) $menu_width 10 \ $options 3>&1 1>&2 2>&3)
# Check if whiptail command succeeded
# Check if TO_RUN is empty or "End" was selected
current_datetime=$(date +"%Y-%m-%d-%H:%M:%S")
# eval to execute command on terminal--all-databases
if [ "$DATABASE" = " All" ]; then
  eval "mysqldump" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --all-databases ">" "$DATABASE"-database-backup-"$current_datetime".sql
else
   declare -i n=10
    db_size=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -s -N -e "SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS size_mb FROM information_schema.tables WHERE table_schema = '$DATABASE';")
    echo "Backupping $DATABASE ..........";
    eval "mysqldump" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$DATABASE" ">" "$DATABASE"-database-backup-"$current_datetime".sql
    n=$n+1;
    if [ $n = 11 ]; then
         echo "Backup Completed.    ";
    fi

fi

