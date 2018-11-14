//
//  BALogger.m
//  BALogger
//
//  Created by Ales Bublik on 6/23/16.
//  Copyright © 2016 Ales Bublik. All rights reserved.
//  Edited by Nuno Silva 24/08/16

#import "BALogger.h"
#import "BALogManager.h"


void BALogCritical(NSString *location, NSString *msg) {
    BALogger(LoggerCriticalLogLevel, location, msg);
}

void BALogError(NSString *location, NSString *msg) {
    BALogger(LoggerErrorLogLevel, location, msg);
}

void BALogWarning(NSString *location, NSString *msg) {
    BALogger(LoggerWarnLogLevel, location, msg);
}

void BALogInfo(NSString *location, NSString *msg) {
    BALogger(LoggerInfoLogLevel, location, msg);
}

void BALogDebug(NSString *location, NSString *msg) {
    BALogger(LoggerDebugLogLevel, location, msg);
}

NSString* getLevelName(unsigned int level) {
    NSString *result = @"UNKNOWN";
    switch (level) {
        case LoggerCriticalLogLevel:
            result = LoggerCriticalLogLevelName;
            break;
        case LoggerErrorLogLevel:
            result = LoggerErrorLogLevelName;
            break;
        case LoggerWarnLogLevel:
            result = LoggerWarnLogLevelName;
            break;
        case LoggerInfoLogLevel:
            result = LoggerInfoLogLevelName;
            break;
        case LoggerDebugLogLevel:
            result = LoggerDebugLogLevelName;
            break;
        case LoggerUnsetLogLevel:
            result = LoggerUnsetLogLevelName;
            break;
    }
    return result;
}


unsigned int SetupCurrentLogLevel(unsigned int level) {
    // calling SetupCurrentLogLevel with zero argument will get you log level from previous setup
    static unsigned int currentLogLevel = LoggerCriticalLogLevel;
    // Change level only when non zero value
    if (level) {
        currentLogLevel = level;
    }
    return currentLogLevel;
}

void BALogger(unsigned int level, NSString *location, NSString *msg) {
    if (level <= SetupCurrentLogLevel(0)) {
        
        //get time of log
        NSDate* now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
        NSString *currentDate = [formatter stringFromDate:now];
        
        NSString *logMsg = [NSString stringWithFormat:@"%@ %@ : %@",currentDate, location, msg];
        // When log level is higher than certain level do log on main thread
        if (level <= LoggerInfoLogLevel) {
            [BALogManager logAsyncWitMsg:logMsg];
        } else {
            [BALogManager logOnMainThreadWithMsg:logMsg];
        }
    } else {
        // TODO: for testing?
    }
}


