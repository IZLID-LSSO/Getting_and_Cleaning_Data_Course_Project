# 0. Script created on R version 3.6.0 (2019-04-26)

        #  Load requried Library, script was created with library(dplyr) version 0.8.1
        library(dplyr)

# 0. Download assignment dataset

        # First line creates ./data directory if not already present
        # Second line provides a path for R to download the file
        # Third line is an execution command to download the file, to the newly created directory, with the second line specified url
        # Fourth line unpacks the .zip file to the /data directory
        if(!file.exists("./data")){dir.create("./data")}
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl,destfile="./data/Dataset.zip")
        unzip(zipfile="./data/Dataset.zip",exdir="./data")
# 1. Merges the training and the test sets to create one data set
        # Reading training tables, and storing the data as variables.
        x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
        y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
        subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")


        # Reading test tables, and storing the data as variables.
        x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
        y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
        subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

        #  Reading device features as a features vector
        features <- read.table('./data/UCI HAR Dataset/features.txt')

        # Reading activity label designators and storing as activitylabels
        activityLabels = read.table('./data/UCI HAR Dataset/activity_labels.txt')

        #Putting names to the columns, first bank is for training
        colnames(x_train) <- features[,2] 
        colnames(y_train) <-"activityId"
        colnames(subject_train) <- "subjectId"
        # second bank is for testing
        colnames(x_test) <- features[,2] 
        colnames(y_test) <- "activityId"
        colnames(subject_test) <- "subjectId"
        
        colnames(activityLabels) <- c('activityId','activityType')
        
        # Joining the data using cbind, and storing as merged training and test, then combining again as one dataset
        mrg_train <- cbind(y_train, subject_train, x_train)
        mrg_test <- cbind(y_test, subject_test, x_test)
        setAllInOne <- rbind(mrg_train, mrg_test)

# 2. Extracting only the measurements on the mean and standard deviation for each measurement

        # Reading column names, and storing into a vector diffrent from the R command colnames, by captalizing "N"
        colNames <- colnames(setAllInOne)
        #Creating a vector for defining ID, mean and standard deviation using grepl to find elements of each character vector
        mean_and_std <- (grepl("activityId" , colNames) | 
                         grepl("subjectId" , colNames) | 
                         grepl("mean.." , colNames) | 
                         grepl("std.." , colNames) 
        )
        # Subsettingfrom setAllInOne:
        setForMeanAndStd <- setAllInOne[ , mean_and_std == TRUE]

# 3. Using descriptive activity names to name the activities in the data set:

        # Providing descriptive activity names to the data set, derived from activityLabels
        setWithActivityNames <- merge(setForMeanAndStd, activityLabels,
                                      by='activityId',
                                      all.x=TRUE)
# 4. Appropriately labeling the data set with descriptive variable names.
        # Performed early in the script with "colnames" command
        
# 5. Creating a second, independent tidy data set with the average of each variable for each activity and each subject:
        
        # 5.1 Creating the second tidy data set, all inclusive, generating the mean for every measurement, 
        # for each subject, in each activity
        secTidySet <- aggregate(. ~subjectId + activityId, setWithActivityNames, mean)
        secTidySet <- secTidySet[order(secTidySet$subjectId, secTidySet$activityId),]
        # 5.2 Writing the second tidy data set to a text file from the 5.1 variables
        write.table(secTidySet, "secTidySet.txt", row.name=FALSE)        

