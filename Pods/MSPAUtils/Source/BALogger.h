//
//  BALogger.h
//  BALogger
//
//  Created by Ales Bublik on 6/23/16.
//  Copyright © 2016 Ales Bublik. All rights reserved.
//  Edited by Nuno Silva 8/24/16

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define DEBUGMODE YES
#else
#define DEBUGMODE NO
#endif


#define BACRITICAL(format, ...) BALogCritical([NSString stringWithFormat:@"%@", [NSString stringWithUTF8String:__FUNCTION__]], [NSString stringWithFormat:(format), ##__VA_ARGS__])

#define BAERROR(format, ...) BALogError([NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:__FUNCTION__]], [NSString stringWithFormat:(format), ##__VA_ARGS__])

#define BAWARN(format, ...) BALogWarning([NSString stringWithFormat:@"%@", [NSString stringWithUTF8String:__FUNCTION__]], [NSString stringWithFormat:(format), ##__VA_ARGS__])

#define BAINFO(format, ...) BALogInfo([NSString stringWithFormat:@"%@", [NSString stringWithUTF8String:__FUNCTION__]], [NSString stringWithFormat:(format), ##__VA_ARGS__])

#define BADEBUG(format, ...) DEBUGMODE ? BALogDebug([NSString stringWithFormat:@"%@", [NSString stringWithUTF8String:__FUNCTION__]], [NSString stringWithFormat:(format), ##__VA_ARGS__]): NULL



#define LoggerCriticalLogLevel 50
#define LoggerCriticalLogLevelName @"CRITICAL"

#define LoggerErrorLogLevel    40
#define LoggerErrorLogLevelName @"ERROR"

#define LoggerWarnLogLevel     30
#define LoggerWarnLogLevelName @"WARN"

#define LoggerInfoLogLevel     20
#define LoggerInfoLogLevelName @"INFO"

#define LoggerDebugLogLevel    10
#define LoggerDebugLogLevelName @"DEBUG"

#define LoggerUnsetLogLevel    1
#define LoggerUnsetLogLevelName @"UNSET"


void BALogCritical(NSString *location, NSString *msg);
void BALogError(NSString *location, NSString *msg);
void BALogWarning(NSString *location, NSString *msg);
void BALogInfo(NSString *location, NSString *msg);
void BALogDebug(NSString *location, NSString *msg);
NSString* getLevelName(unsigned int level);

unsigned int SetupCurrentLogLevel(unsigned int level);
void BALogger(unsigned int level, NSString *location, NSString *msg);
