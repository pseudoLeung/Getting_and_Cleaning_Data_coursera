## Define some variables should be used
unzipPath<- 'UCI HAR Dataset'
myResDir <- 'result'
fileName <- 'UCI_HAR_Dataset.zip'
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

## Some packages are needed
if(!('dplyr' %in% installed.packages()[,1])){
    print('dplyr is required')
    install.package('dplyr')
}

## Load package 'dplyr'
library('dplyr')
print('Load dplyr package')

## Maybe file has been downloaded.If not, it will be downloaded
if(!file.exists(fileName)){
    print(paste(fileName,' is required'))
    download.file('url',fileName)
}
print('Get zipped-data')

## Create folder to hold result
if(!file.exists(myResDir)){
    print('Create result folder')
    dir.create(myResDir)
}
print('Create result folder')

## Unzip the raw data&rename
unzip(fileName)
print('Unzip data file')

## Get features
features <- read.table(paste(unzipPath,'features.txt',sep='/'))
print('Load features')

## Get test data
xDat <- read.table(paste(unzipPath,'test/X_test.txt',sep='/')) ## capitalized X
colnames(xDat) <- features$V2
yDat <- read.table(paste(unzipPath,'test/y_test.txt',sep='/'))
colnames(yDat) <- 'activity'
subDat <- read.table(paste(unzipPath,'test/subject_test.txt',sep='/'))
colnames(subDat) <- 'ID'
testDat <- cbind(subDat,xDat,yDat)
print('Load test data')

## Get train data
xDat <- read.table(paste(unzipPath,'train/X_train.txt',sep='/')) ## capitalized X
colnames(xDat) <- features$V2
yDat <- read.table(paste(unzipPath,'train/y_train.txt',sep='/'))
colnames(yDat) <- 'activity'
subDat <- read.table(paste(unzipPath,'train/subject_train.txt',sep='/'))
colnames(subDat) <- 'ID'
trainDat <- cbind(subDat,xDat,yDat)
print('Load train data')

## Then, do as asked
## 1.Merges the training and the test sets to create one data set.
totalDat <- rbind(trainDat,testDat)

## 2.Extracts only the measurements on the mean and standard deviation for each measurement. 
totalColNames <- colnames(totalDat)
indices <- c(grep('std',totalColNames),grep('mean',totalColNames))
requiredDat <- totalDat[,c(1,indices,563)] ## 563 is a magic number

## 3.Uses descriptive activity names to name the activities in the data set
activity <- read.table(paste(unzipPath,'activity_labels.txt',sep='/'))
requiredDat$activity <- factor(requiredDat$activity, levels=activity$V1,labels=activity$V2)

## 4.Appropriately labels the data set with descriptive variable names. 
## done in step3

## 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
requiredDat2 <- requiredDat
myFun <- function(x){colMeans(x[,-c(1,dim(x)[2])])}  ## col[dim(x)[2]] is activity
requiredDat2 <- ddply(requiredDat2,.(ID,activity),myFun)

## save result
write.table(requiredDat,paste(myResDir,'result1.txt',sep = '/'),row.name=FALSE)
write.table(requiredDat2,paste(myResDir,'result2.txt',sep = '/'),row.name=FALSE)
print('Save result')
print('All done')
## Good luck!
