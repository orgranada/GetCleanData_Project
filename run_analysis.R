#LOAD PACKAGES
library(dplyr)


#DOWNLOAD DATA
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipOut <- "./"
zipName <- "projectData.zip"
download.file(zipUrl, destfile = paste(zipOut, zipName), method = "curl")
unzip(zipName)

#IMPORT DATA
importDir <- "./UCI HAR Dataset/"


features <- read.table(
  paste(importDir,"features.txt",sep = ""), 
  col.names = c("id", "funct")
  )
activities <- read.table(
  paste(importDir,"activity_labels.txt",sep = ""), 
  col.names = c("id", "activity")
  )


subject_test <- read.table(
  paste(importDir,"test/subject_test.txt",sep = ""), 
  col.names = "subject")
x_test <- read.table(
  paste(importDir,"test/X_test.txt",sep = ""), 
  col.names = features$funct
  )
y_test <- read.table(
  paste(importDir,"test/y_test.txt",sep = ""), 
  col.names = "id"
  )


subject_train <- read.table(
  paste(importDir,"train/subject_train.txt",sep = ""), 
  col.names = "subject"
  )
x_train <- read.table(
  paste(importDir,"train/X_train.txt",sep = ""), 
  col.names = features$funct
  )
y_train <- read.table(
  paste(importDir,"train/y_train.txt",sep = ""), 
  col.names = "id"
  )



#MERGES
X <- rbind(x_test, x_train)
Y <- rbind(y_test, y_train)
Subject <- rbind(subject_test, subject_train)
dataMerged <- cbind(Subject, X, Y)


#MEASUREMENTS EXTRACTION (Mean and std)
dataTidy <- dataMerged %>% select(subject, id, contains("mean"), contains("std"))


#DESCRIPTIVE ACTIVITY NAMES
dataTidy$id <- activities[dataTidy$id, 2]


#DESCRIPTIVE VARIABLE NAMES
names(dataTidy)[2] = "activity"
names(dataTidy)<-gsub("Acc", "Accelerometer", names(dataTidy))
names(dataTidy)<-gsub("Gyro", "Gyroscope", names(dataTidy))
names(dataTidy)<-gsub("BodyBody", "Body", names(dataTidy))
names(dataTidy)<-gsub("Mag", "Magnitude", names(dataTidy))
names(dataTidy)<-gsub("^t", "Time", names(dataTidy))
names(dataTidy)<-gsub("^f", "Frequency", names(dataTidy))
names(dataTidy)<-gsub("tBody", "TimeBody", names(dataTidy))
names(dataTidy)<-gsub("-mean()", "Mean", names(dataTidy), ignore.case = TRUE)
names(dataTidy)<-gsub("-std()", "STD", names(dataTidy), ignore.case = TRUE)
names(dataTidy)<-gsub("-freq()", "Frequency", names(dataTidy), ignore.case = TRUE)
names(dataTidy)<-gsub("angle", "Angle", names(dataTidy))
names(dataTidy)<-gsub("gravity", "Gravity", names(dataTidy))


#SUMMARISE DATA AND EXPORT AS TXT
dataFinal <- dataTidy %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean))
write.table(dataFinal, "FinalData.txt", row.names = F)

#CHECK
str(dataFinal)