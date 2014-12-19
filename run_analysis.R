#Set your working directory (where your files will be stored)
setwd("/Users/shdurham/Documents/Getting and Cleaning Data/Course Project/")

# Download and unzip the files
if(!file.exists("./UCI HAR Dataset")){
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, "wearables.zip", method = "curl")
        unzip("wearables.zip")
}

#Read the data into R
features <- read.table("./UCI HAR Dataset/features.txt")

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")

y_test <- read.table("./UCI HAR Dataset/test/Y_test.txt")
y_train <- read.table("./UCI HAR Dataset/train/Y_train.txt")

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

#Merge the subject and training datasets
x_data <- rbind(x_test, x_train)
y_data <- rbind(y_test, y_train)
subject_data <- rbind(subject_test, subject_train)

names(x_data) <- features$V2
names(y_data) <- c("activity")
names(subject_data) <- c("subject")

prelim_data <- cbind(subject_data, y_data)
merged_data <- cbind(prelim_data, x_data)

#Extract measurements on mean and standard deviation
extracted_std_and_mean <- features$V2[grep("mean\\(\\)|std\\(\\)", features$V2)]
activity_and_subject <- c(as.character(extracted_std_and_mean), "activity", "subject" )
merged_data <- subset(merged_data, select = activity_and_subject)

#Use descriptive activity names to name the activities
activity_count = 1
for (activity_count_label in activity_labels$V2) {
        merged_data$activity <- gsub(activity_count, activity_count_label, merged_data$activity)
        activity_count <- activity_count + 1
}
merged_data$activity <- as.factor(merged_data$activity)
merged_data$subject <- as.factor(merged_data$subject)

#Label the data set with descriptive variable names
names(merged_data) <- gsub("^t", "Time", names(merged_data))
names(merged_data) <- gsub("^f", "Frequency", names(merged_data))
names(merged_data) <- gsub("acc", "Accelerometer", names(merged_data))
names(merged_data) <- gsub("gyro", "Gyroscope", names(merged_data))
names(merged_data) <- gsub("mag", "Magnitude", names(merged_data))
names(merged_data) <- gsub("bodybody", "Body", names(merged_data))

#Create a second, independent tidy data set with the average of each variable for each activity and each subject.
library(plyr)
tidy_data <- ddply(merged_data, .(subject, activity), function(x) colMeans(x[, 1:66]))
write.table(tidy_data, "tidy_data.txt", row.name=FALSE)