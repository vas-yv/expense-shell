#!/bin/bash
Userid=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$script_name-$timestamp.log
R="\e[31m"
G="\e[32m"
N="\e[33m"

echo "place enter db password"
read -s mysql_root_password

validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R $2..failed $N"
        exit 1
    else
        echo -e "$G $2..success $N"
    fi        

}

if [ $Userid -ne 0 ]
then
    echo " please run the user with root access"
    exit 1
else
     echo "your super user"
fi

dnf install mysql-server -y &>>$logfile
validate $? "installing mysql server"

systemctl enable mysqld &>>$logfile
validate $? "enabling mysql"

systemctl start mysqld &>>$logfile
validate $? "starting mysql"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$logfile
#validate $? "setting up root password"

#shell script is not idempotent in in nature

mysql -h 172.31.94.246 -u root -p${mysql_root_password} 'show databases;' &>>$loggfile
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password}
    validate $? "mysql root password"
else
     echo "Mysql root password is already setup.. $Y skipping $N"
fi    
