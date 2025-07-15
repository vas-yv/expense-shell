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

dnf module disable nodejs -y
validate $? "disable nodejs"

dnf module enable nodejs:20 -y
validate $? "enable nodejs"

dnf install nodejs -y
validate $? "install nodejs"

useradd expense
validate $? "crate user"