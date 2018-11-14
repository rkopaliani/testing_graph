//
//  BALogManager.m
//  BALogger
//
//  Created by Ales Bublik on 6/23/16.
//  Copyright © 2016 Ales Bublik. All rights reserved.
//

#import "BALogManager.h"
#import "BAFunctions.h"
#import "BALogger.h"
#import "NSString+MSPAUtils.h"
#import "NSFileManager+MSPAUtils.h"
#import "MSPAFileSystemUtils.h"
#import "MSPAPlatform.h"

@implementation BALogManager
static dispatch_queue_t serialQueue;
static NSFileHandle *fileHandle;
static NSString *logDirectory;
static NSString *projectRelativePath;
static NSString *filePath;
static NSDate *currentLogDate;

// added by Nuno Silva 17/11/2016
static dispatch_queue_t deleteOldLogsQueue;
static NSString *instanceName;
static int appType; //this will just indicate if app is viewer or agent
static NSString * appName;
// This class is meant as a global singleton for logging


+(void)initialize {
    @try {
        serialQueue = dispatch_queue_create("loggerQueue", DISPATCH_QUEUE_SERIAL);
        deleteOldLogsQueue = dispatch_queue_create("deleteOldLogs", DISPATCH_QUEUE_SERIAL);
        
        currentLogDate = [NSDate date];
    } @catch (NSException *exception) {
        
    }
}

+ (NSString *)logDirectory {
    NSString *directory;
    if ([NSUserName() isEqual: @"root"]) {
        directory = @"/Library/Logs";
    } else {
        NSString *libraryPath = [MSPAFileSystemUtils libraryPath];
        directory = [NSString stringWithFormat:@"%@/Logs", libraryPath];
    }
    return directory;
}

+(NSDate *)nextDay {
    NSCalendar *relevantCalendar = [NSCalendar currentCalendar];
    
    // decompose the current date to components; we'll
    // just ask for month, day and year here for brevity;
    // check out the other calendar units to decide whether
    // that's something you consider acceptable
    NSDateComponents *componentsForNow =
    [relevantCalendar components:
     MSPADateComponentYear|MSPADateComponentMonth|MSPADateComponentDay
                        fromDate:currentLogDate];
    
    // we could explicitly set the time to midnight now,
    // but since that's 00:00 it'll already be the value
    // in the date components per the standard Cocoa object
    // creation components, so...
    // get the midnight that last occurred
    NSDate *lastMidnight = [relevantCalendar dateFromComponents:componentsForNow];
    
    // can we just add 24 hours to that? No, because of DST. So...
    
    // create components that specify '1 day', however long that may be
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    oneDay.day = 1;
    
    // hence ask the calendar what the next midnight will be
    NSDate *nextMidnight = [relevantCalendar
                            dateByAddingComponents:oneDay
                            toDate:lastMidnight
                            options:0];
    currentLogDate = nextMidnight;
    return currentLogDate;
}

+ (void) setAppInfo: (NSString *) name withPath:(NSString *) path withType:(int) type withInstanceName: (NSString *) instance
{
    appType = type;
    instanceName = instance;
    projectRelativePath = path;
    appName = name;
}
+(void)setLogDirectory: (NSString *)path {
    NSFileManager *fm = [[NSFileManager alloc] init];
    BOOL isDir;
    BOOL exists = [fm fileExistsAtPath:path isDirectory:&isDir];
    if (!exists) {
        if(![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", path);
    }
    logDirectory = path;
}

+(NSFileHandle *)getFileObject {
    // return file if already opened
    if (fileHandle != nil) return fileHandle;
    
    filePath = [self filenameWithTodayDate];
    if ([filePath hasContent] == NO) {
        return nil;
    }
    
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    if ([fileMngr fileExistsAtPath:filePath] == NO) {
        NSString *dirPath = [filePath stringByDeletingLastPathComponent];
        
        if(![fileMngr createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:NULL]) {
            NSLog(@"Error: Folder creation failed %@", dirPath);
            return nil;
        }
        
        if(![fileMngr createFileAtPath:filePath contents:nil attributes:nil]) {
            NSLog(@"Error code: %d - message: %s - path: %@", errno, strerror(errno), filePath);
        }
        // Create file
        if (![fileMngr isWritableFileAtPath:filePath]) {
            NSLog(@"Can't write to the log file: %@", filePath);
            return nil;
        }
    }
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [fileHandle seekToEndOfFile];
    
    return fileHandle;
}

+(NSString *)filenameWithTodayDate {
    NSString *fileName = [BALogManager filenameWithPathforDate:[NSDate date]];
    return fileName;
}

+(NSString *)filenameWithPathforDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(appType == AGENT)
        [formatter setDateFormat:@"yyyy_MM_dd"];
    else
        [formatter setDateFormat:@"yyyy_MM_dd_HHmmss"];
    
    NSString *timeStamp = [formatter stringFromDate:date];
    NSString *newFilePath = [NSString stringWithFormat:@"%@%@%@_%@.log", logDirectory, projectRelativePath, appName, timeStamp];
    //NSString * newFilePath = [NSString stringWithFormat:@"%@%@MSPA_VIEWER_DEBUG.log", logDirectory, projectRelativePath];
    currentLogDate = date;
    return newFilePath;
}


+(void)readConfigurationWithLogPath:(NSString *)newFilePath {
    static NSString *logFilePath = @"";
    if ([newFilePath length] > 0) {
        filePath = newFilePath;
        [fileHandle closeFile];
        fileHandle = nil;
    } else {
        filePath = logFilePath;
    }
}

+(NSData *)createDataFromMessage:(NSString *)msg {
    NSString *str = [NSString stringWithFormat:@"%@\n", msg];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

+(void)logAsyncWitMsg:(NSString *)msg {
    NSData *data = [BALogManager createDataFromMessage:msg];
    NSLog(@"%@", msg);
    
    if(serialQueue != nil){
        dispatch_async(serialQueue, ^{
            NSError *error = nil;
            [BALogManager writeData:data error:&error];
        });
    }
}

+(void)logOnMainThreadWithMsg:(NSString *)msg {
    NSData *data = [BALogManager createDataFromMessage:msg];
    NSLog(@"%@", msg);
    
    if ([NSThread isMainThread]) {
        // doing dispatch to main thread from main thread should be always asynchronouse
      //  dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            [BALogManager writeData:data error:&error];
      //  });
    } else {
        // otherwise use synchronouse dispatch
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            [BALogManager writeData:data error:&error];
        });
    }
}

+(BOOL)changeFileHandler {
    [BALogManager readConfigurationWithLogPath:[BALogManager filenameWithPathforDate:[BALogManager nextDay]]];
    [BALogManager getFileObject];
    return YES;
}

+(long int)getDayComponentFrom:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSCalendarUnit)MSPADateComponentDay fromDate:date];
    return comps.day;
}

+(BOOL)writeData:(NSData *)data error:(NSError **)error {
    long int nowDay = [BALogManager getDayComponentFrom:[NSDate date]];
    
    // change log file when midnight will occur
    if (nowDay > [BALogManager getDayComponentFrom:currentLogDate]) {
        [BALogManager changeFileHandler];
    }
    
    @try {
        [self getFileObject];
        [fileHandle writeData:data];
    }
    @catch (NSException *e) {
        if (error != NULL) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to write data",
                                       // Other stuff?
                                       };
            *error = [NSError errorWithDomain:@"Logger" code:1 userInfo:userInfo];
            
        }
        return NO;
    }
    return YES;
}

+(void)stopLogger {
    // To clean up queue before closing log file
    dispatch_sync(serialQueue, ^{});
    [fileHandle closeFile];
}

#pragma mark - 
#pragma mark REMOVE OLD LOGS
+ (void) RemoveOldLogs
{
    @try {
        dispatch_async(deleteOldLogsQueue, ^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if(appType == VIEWER)
            {
                // user viewer directory
                NSString * logsFolder = [NSString stringWithFormat:@"%@%@", logDirectory, projectRelativePath];
                BAINFO(@"Called...Viewer - Going to remove old logs from directory: %@", logsFolder);
                [BALogManager DeleteOldLogsFromDirectory:logsFolder];
                
                //check on root folders if has pending logs from installation to remove
                logsFolder = [NSString stringWithFormat:@"/Library/Logs%@ Installer", projectRelativePath];
                [BALogManager DeleteOldLogsFromDirectory:logsFolder];
            }
            else if(appType == AGENT)
            {
                /* In this part we have to consider the instance name, and the user folder logs and the root folder logs*/
                // USER LOGS
                NSArray *users = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/users" error:nil];
                
                for(NSString * user in users)
                {
                    NSString * userLogFolderPath = [NSString stringWithFormat:@"/Users/%@/Library/Logs/", user];
                    
                    if ([fileManager fileExistsAtPath:userLogFolderPath])
                    {
                        //check for instance
                        // Agent
                        if([instanceName hasContent])
                        {
                            userLogFolderPath = [NSString stringWithFormat:@"%@MSP Anywhere Agent %@/", userLogFolderPath, instanceName];
                        }
                        else    //BASE
                        {
                            userLogFolderPath = [NSString stringWithFormat:@"%@MSP Anywhere Agent/", userLogFolderPath];
                            
                            //call tmp dirs remove
                            [BALogManager RemoveTmpDirectories];
                        }
                        BAINFO(@"Called...Agent - Going to remove old agent logs from directory: %@", userLogFolderPath);
                    }
                }
                
                //ROOT LOGS
                NSString *rootLogsFolderPath = [NSString stringWithFormat:@"/Library/Logs/"];
                if ([fileManager fileExistsAtPath:rootLogsFolderPath])
                {
                    //check for instance
                    if([instanceName hasContent])
                    {
                        rootLogsFolderPath = [NSString stringWithFormat:@"%@MSP Anywhere Agent %@/", rootLogsFolderPath, instanceName];
                    }
                    else    //BASE
                    {
                        rootLogsFolderPath = [NSString stringWithFormat:@"%@MSP Anywhere Agent/", rootLogsFolderPath];
                        
                        //call tmp dirs remove
                        [BALogManager RemoveTmpDirectories];
                    }
                    BAINFO(@"Called...Agent - Going to remove old logs from directory: %@", rootLogsFolderPath);
                }
            }
        });
    } @catch (NSException *exception) {
        BAINFO(@"Exception: %@", exception.reason);
    }
}

// This is specific for BASE
+ (void) RemoveTmpDirectories
{
    @try
    {
        // ################# DELETING TMP DIRS TOO #################
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:@"/Users/Shared/MSPA_auto_downloaded"]) {
            
            NSString *command = [NSString stringWithFormat:@"sudo rm -rf /Users/Shared/MSPA_auto_downloaded"];
            
            NSArray *args = [NSArray arrayWithObjects:@"-c", command,nil];
            
            NSTask *task = [[NSTask alloc] init];
            [task setLaunchPath:@"/bin/bash"];
            [task setCurrentDirectoryPath:@"/"];
            [task setArguments:args];
            
            NSPipe *pipe;
            pipe = [NSPipe pipe];
            [task setStandardOutput: pipe];
            [task setStandardError: pipe];
            NSFileHandle *file;
            file = [pipe fileHandleForReading];
            
            [task launch];
            
        }
        
        // ################# USS FILE #################
        
        if ([fileManager fileExistsAtPath:@"/Applications/MSP Anywhere Agent.app/Contents/USS"]) {
            [fileManager deleteFileAtPath:@"/Applications/MSP Anywhere Agent.app/Contents/USS"];
        }
    }
    @catch(NSException * exception)
    {
        BAINFO(@"Exception: %@", exception.reason);
    }
}


+ (void) DeleteOldLogsFromDirectory: (NSString *) directory
{
    @try {
        if([instanceName hasContent])
        {
            NSFileManager* fileManager = [NSFileManager defaultManager];
            if ([fileManager isFileExistsAtPath:directory]) {
                NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:directory error:nil];
                for (NSString *filename in dirContents) {
                    
                    NSDictionary* attrs = [fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, filename] error:nil];
                    
                    if (attrs != nil) {
                        
                        NSDate *date = (NSDate*)[attrs objectForKey: NSFileModificationDate];
                        NSTimeInterval diferenceInSeconds = [[NSDate date] timeIntervalSinceDate:date];
                        
                        int days = diferenceInSeconds / (60 * 60 *24);
                        
                        NSError *error;
                        
                        if (days >= 15)
                        {
                            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, filename] error:&error];
                            
                            if (error != nil) {
                                NSLog(@"BAAppDeletage::deleteOldLogs - Error Deleting Files");
                            }
                        }
                    }
                    else {
                        NSLog(@"BAAppDeletage::deleteOldLogs - Attributes Not found");
                    }
                }
            }
            else
                BAINFO(@"Error, path: %@ not found...", directory);
        }
        else
            BAINFO(@"Error, empty directory...");
    } @catch (NSException *exception) {
        BAINFO(@"Exception: %@", exception.reason);
    }
}

@end
