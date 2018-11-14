//
//  BALogManager.h
//  BALogger
//
//  Created by Ales Bublik on 6/23/16.
//  Copyright © 2016 Ales Bublik. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VIEWER  1
#define AGENT  2


@interface BALogManager : NSObject

+(NSDate *)nextDay;
+(long)getDayComponentFrom:(NSDate *)date;
+(void)setLogDirectory: (NSString *)path;
+ (NSString *)logDirectory;
+(BOOL)changeFileHandler;
+(void)readConfigurationWithLogPath:(NSString *)filePath;
+(NSData *)createDataFromMessage:(NSString *)msg;
+(void)logAsyncWitMsg:(NSString *)msg;
+(void)logOnMainThreadWithMsg:(NSString *)msg;
+(NSFileHandle *)getFileObject;
+(void)stopLogger;
+(BOOL)writeData:(NSData *)data error:(NSError **)error;
+(NSString *)filenameWithTodayDate;
+(NSString *)filenameWithPathforDate:(NSDate *)date;

+ (void) setAppInfo: (NSString *) name withPath:(NSString *) path withType:(int) type withInstanceName: (NSString *) instance;
+ (void) RemoveOldLogs;

@end
