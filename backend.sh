#!/bin/bash

Userid=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$script_name-$timestamp.log

R="\e[31m"
G="\e[32m"
N="\e[33m"

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

dnf module disable nodejs -y &>>$logfile
validate $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$logfile
validate $? "enable nodejs"

dnf install nodejs -y &>>$logfile
validate $? "install nodejs"

id expense &>>$logfile
if [ $? -ne 0 ]
then
    useradd expense &>>$logfile
    validate $? "creating expense user"
else
    echo -e "expense user already created"
fi

mkdir -p /app &>>$logfile
validate $? " creating app user"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "download code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$logfile
validate $? "extracted backend code"

npm install &>>$logfile
validate $? "installing nodejs dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$logfile
validate $? "copied backend service"

systemctl daemon-reload
systemctl start backend
systemctl enable backend
validate $? "start&enable backend"



