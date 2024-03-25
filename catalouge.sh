#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo "script started executing at $TIMESTAMP" &>> $LOGFILE
MONGODB_HOST=mongodb.yellaiahderangala.cloud

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e  "ERROR:: $2 .. $R failed $N"
    exit 1
        else echo -e "$2 .. $G sucess $N"
    fi
}

if [ $ID -ne 0 ]
then 
echo -e   $R "ERROR:: please run this script with root access $N"
exit 1 # you can give other than 0 (beacuse 0 means success so we need to give other than 0 to exit)
else 
echo -e  "  you are root user "
fi # fi means reverse of if , indicating condition end

dnf module disable nodejs -y
VALIDATE $? "Disabling current nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y
VALIDATE $? "Enabling nodejs 18" &>> $LOGFILE

dnf install nodejs -y
VALIDATE $? "Installing nodejs 18" &>> $LOGFILE

useradd roboshop
VALIDATE $? "creating roboshop user" &>> $LOGFILE

mkdir /app
VALIDATE $? "creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "downloading catalouge app" &>> $LOGFILE

cd /app

unzip /tmp/catalogue.zip
VALIDATE $? "unzipping catalouge " &>> $LOGFILE

npm install 
VALIDATE $? "installing dependencies " &>> $LOGFILE

#use absolute path because catalouge.service exists there
cp /home/centos/roboshop-shell/catalouge.service /etc/systemd/system/catalogue.service

VALIDATE $? "copying catalouge,service file" &>> $LOGFILE

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "catalouge daemon reload " &>> $LOGFILE

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "catalouge enabling " &>> $LOGFILE

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "staring catalouge " &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mangodb repo"

dnf install mongodb-org-shell -y

VALIDATE $? "installing  mangodb client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js

