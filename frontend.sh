#!/bin/bash

Userid=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$script_name-$timestamp.log

R="\e[31m"
G="\e[32m"
N="\e[0m"

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

dnf install nginx -y &>>$logfile
validate $? "install nginx"

systemctl enable nginx &>>$logfile
validate $? "enable nginx"

systemctl start nginx &>>$logfile
validate $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$logfile
validate $? "remove existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfile
validate $? "downloading frontend code"

cd /usr/share/nginx/html &>>$logfile
unzip /tmp/frontend.zip  &>>$logfile
validate $? "extracting frontend"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$logfile
validate $? "copied expense conf"

systemctl restart nginx &>>$logfile
validate $? "restarting nginx"