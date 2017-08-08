# Install necessary packages
# install.packages("data.table");install.packages("reshape2")

# Load the libraries
library(data.table);library(reshape2)

# Set working directory, set url, download file to working directory, and unzipping.
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

# Load activities and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("classLabels", "activityName"))
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, "featureNames"])
measurements <- features[featuresWanted, "featureNames"]
measurements <- gsub('[()]', '', measurements)

# Load train dataset
train <- read.table("UCI HAR Dataset/train/X_train.txt")[, featuresWanted]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt", col.names = c("Activity"))
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

# Load test datasets
test <- read.table("UCI HAR Dataset/test/X_test.txt")[, featuresWanted]
data.table::setnames(test, colnames(test), measurements)
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt", col.names = c("Activity"))
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# merge datasets
combined <- rbind(train, test)

# Convert classlabels to activityname 
combined[["Activity"]] <- factor(combined[, "Activity"], levels = activityLabels[["classLabels"]], labels = activityLabels[["activityName"]])
combined[["SubjectNum"]] <- as.factor(combined[, "SubjectNum"])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

# output to tidydata.txt
data.table::fwrite(x = combined, file = "tidydata.txt")
