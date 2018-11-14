//
//  MSPASystemUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSPASystemUtils : NSObject

+ (BOOL)processIsRunning:(int)pid;
+ (NSArray *__nullable)getProcessInfo:(int)pid;
+ (NSArray *__nullable)runningProcessesWithAllInfo;
+ (NSArray *__nullable)runningProcessesWithProcessIDAndProcessNameAndProcessUserName;
+ (NSArray *__nullable)runningProcessesWithProcessIDAndProcessName;

+ (float)cpuUsageByPID:(int)pid;

@end

NS_ASSUME_NONNULL_END
