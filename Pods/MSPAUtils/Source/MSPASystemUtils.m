//
//  MSPASystemUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import "MSPASystemUtils.h"
#import "BALogger.h"

#import <sys/sysctl.h>

@implementation MSPASystemUtils

+ (NSArray *)getProcessInfo:(int)pid {
    @try {
        NSString *command = [NSString stringWithFormat:@"ps -p %d -o pid,rss,pcpu,ruser", pid];
        NSArray *args = [NSArray arrayWithObjects:@"-c", command,nil];
        
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/bash"];
        [task setCurrentDirectoryPath:@"/"];
        [task setArguments:args];
        
        NSPipe *pipe = [[NSPipe alloc] init];
        [task setStandardOutput: pipe];
        [task setStandardError: pipe];
        NSFileHandle *file;
        file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData *data;
        data = [file readDataToEndOfFile];
        
        NSString *string;
        string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        
        bool twoLines = false;
        
        for (unsigned int x= 0; x < [string length] - 1; x++)
        {
            if ([[string substringWithRange:NSMakeRange(x, 1)] isEqualToString:@"\n"])
            {
                string = [string substringWithRange:NSMakeRange(x + 1, [string length] - x - 2)];
                twoLines = true;
                break;
            }
        }
        
        if (twoLines)
        {
            char *line = (char *)[string UTF8String];
            
            char dummy[256];
            char cpu[256];
            char mem[256];
            char user[256];
            
            sscanf(line, "%s %s %s %s", dummy, mem, cpu, user);
            NSString *cpuStr = [NSString stringWithFormat:@"%s", cpu];
            if ([cpuStr floatValue] > 100)
                cpuStr = @"100";
            
            cpuStr = [NSString stringWithFormat:@"%.0f",  [cpuStr floatValue]];
            NSString *memStr = [NSString stringWithFormat:@"%s", mem];
            NSString *userStr = [NSString stringWithFormat:@"%s", user];
            
            if (cpuStr == nil)
                cpuStr = @"0.0";
            if (memStr == nil)
                memStr = @"0";
            if (userStr == nil)
                userStr = @"";
            
            NSArray *object = [NSArray arrayWithObjects:cpuStr, memStr, userStr, nil];
            return object;
        }
        else
            return nil;
    }
    @catch (NSException *exception) {
        BAINFO(@"BAFunctions::getProcessInfo Exception - %@", exception.reason);
    }
}

+ (NSArray *)runningProcessesWithAllInfo {
    @try {
        int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
        size_t miblen = 4;
        
        size_t size;
        int st = sysctl(mib, (unsigned int) miblen, NULL, &size, NULL, 0);
        
        struct kinfo_proc * process = NULL;
        struct kinfo_proc * newprocess = NULL;
        
        do {
            
            size += size / 10;
            newprocess = realloc(process, size);
            
            if (!newprocess){
                
                if (process){
                    free(process);
                }
                
                return nil;
            }
            process = newprocess;
            st = sysctl(mib, (unsigned int) miblen, process, &size, NULL, 0);
            
        } while (st == -1 && errno == ENOMEM);
        
        if (st == 0){
            
            if (size % sizeof(struct kinfo_proc) == 0){
                long nprocess = size / sizeof(struct kinfo_proc);
                
                if (nprocess){
                    
                    NSMutableArray * array = [[NSMutableArray alloc] init];
                    
                    for (long i = nprocess - 1; i >= 0; i--){
                        
                        NSString *processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                        NSString *processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                        NSString *processPriority = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_priority];
                        int pp = [processPriority intValue];
                        if (pp <= 0)
                            pp = 0;
                        if (pp >= 39)
                            pp = 39;
                        
                        pp = (39 - pp) * 31 / 39;
                        processPriority = [NSString stringWithFormat:@"%d", pp];
                        
                        NSArray *processProps = [MSPASystemUtils getProcessInfo:[processID intValue]];
                        if (processProps != nil)
                        {
                            NSString *processPercentCPU = processProps[0];
                            NSString *processMemoryKB = processProps[1];
                            NSString *processUsername = processProps[2];
                            
                            long totalRAM = [[NSProcessInfo processInfo] physicalMemory];
                            totalRAM = totalRAM / 1024;
                            NSString* memory_PhysicalSize = [NSString stringWithFormat:@"%ld", totalRAM];
                            
                            long long ProcessMemoryUsageKB = [processMemoryKB longLongValue];
                            long long TotalMemory = [memory_PhysicalSize longLongValue];
                            long MemoryPercent = 0;
                            if (TotalMemory != 0)
                                MemoryPercent = ProcessMemoryUsageKB * 100 / TotalMemory;
                            
                            NSString *processMemoryPercentage = [NSString stringWithFormat:@"%ld", MemoryPercent];
                            NSArray *object = [NSArray arrayWithObjects:processID, processName, processPercentCPU, processMemoryKB, processUsername, processPriority, processMemoryPercentage, nil];
                            
                            [array addObject:object];
                        }
                    }
                    
                    free(process);
                    return array;
                    
                }
            }
        }
        
        return nil;
    }
    @catch (NSException *exception) {
        BAINFO(@"BAFunctions::runningProcessesWithAllInfo Exception - %@", exception.reason);
    }
}

+ (NSArray *)runningProcessesWithProcessIDAndProcessNameAndProcessUserName {
    @try {
        int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
        size_t miblen = 4;
        
        size_t size;
        int st = sysctl(mib, (unsigned int) miblen, NULL, &size, NULL, 0);
        
        struct kinfo_proc * process = NULL;
        struct kinfo_proc * newprocess = NULL;
        
        do {
            
            size += size / 10;
            newprocess = realloc(process, size);
            
            if (!newprocess){
                
                if (process){
                    free(process);
                }
                
                return nil;
            }
            process = newprocess;
            st = sysctl(mib, (unsigned int) miblen, process, &size, NULL, 0);
            
        } while (st == -1 && errno == ENOMEM);
        
        if (st == 0){
            
            if (size % sizeof(struct kinfo_proc) == 0){
                long nprocess = size / sizeof(struct kinfo_proc);
                
                if (nprocess){
                    
                    NSMutableArray * array = [[NSMutableArray alloc] init];
                    
                    for (long i = nprocess - 1; i >= 0; i--){
                        
                        NSString *processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                        NSString *processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                        
                        NSArray *processProps = [MSPASystemUtils getProcessInfo:[processID intValue]];
                        if (processProps != nil)
                        {
                            NSString *processUsername = processProps[2];
                            
                            NSArray* process = [[NSArray alloc] initWithObjects:processName, processID, processUsername, nil];
                            [array addObject:process];
                        }
                    }
                    
                    free(process);
                    return array;
                    
                }
            }
        }
        
        return nil;
    }
    @catch (NSException *exception) {
        BAINFO(@"BAFunctions::runningProcessesWithProcessIDAndProcessNameAndProcessUserName Exception - %@", exception.reason);
    }
}

+ (NSArray *)runningProcessesWithProcessIDAndProcessName {
    @try {
        int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
        size_t miblen = 4;
        
        size_t size;
        int st = sysctl(mib, (unsigned int) miblen, NULL, &size, NULL, 0);
        
        struct kinfo_proc * process = NULL;
        struct kinfo_proc * newprocess = NULL;
        
        do {
            
            size += size / 10;
            newprocess = realloc(process, size);
            
            if (!newprocess){
                
                if (process){
                    free(process);
                }
                
                return nil;
            }
            process = newprocess;
            st = sysctl(mib, (unsigned int) miblen, process, &size, NULL, 0);
            
        } while (st == -1 && errno == ENOMEM);
        
        if (st == 0){
            
            if (size % sizeof(struct kinfo_proc) == 0){
                long nprocess = size / sizeof(struct kinfo_proc);
                
                if (nprocess){
                    
                    NSMutableArray * array = [[NSMutableArray alloc] init];
                    
                    for (long i = nprocess - 1; i >= 0; i--){
                        
                        NSString *processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                        NSString *processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                        
                        if (process[i].kp_proc.p_xstat == 0) // Se nao foi parado
                        {
                            NSArray* process = [[NSArray alloc] initWithObjects:processName, processID, nil];
                            [array addObject:process];
                        }
                    }
                    
                    free(process);
                    return array;
                    
                }
            }
        }
        
        return nil;
    }
    @catch (NSException *exception) {
        BAINFO(@"BAFunctions::runningProcessesWithProcessIDAndProcessName Exception - %@", exception.reason);
    }
}

+ (BOOL)processIsRunning:(int)pid {
    BOOL isRunning = NO;
    NSString* command = [NSString stringWithFormat:@"\
                         ps -p %i | awk '{ print $1; }';\
                         ", pid];
    
    NSArray* args = [NSArray arrayWithObjects:@"-c", command, nil];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:args];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    [task setStandardError: pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    NSString *result = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([result hasSuffix:[NSString stringWithFormat:@"%i", pid]])
        isRunning = YES;
    
    return isRunning;
}

+ (float)cpuUsageByPID:(int)pid {
    NSString* command;
    NSArray *args = [[NSArray alloc] init];
    
    command = [NSString stringWithFormat:@"top -pid %i -l 2 -stats cpu", pid];
    args = [NSArray arrayWithObjects:@"-c", command, nil];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:args];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    [task setStandardError: pipe];
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    string = [string substringWithRange:NSMakeRange(0, [string length] -1 )];
    NSRange abc = [string rangeOfString:@"\n" options:NSBackwardsSearch];
    
    string = [string substringWithRange:NSMakeRange(abc.location + 1, [string length] - abc.location - 1)];
    return  [string floatValue];
}

@end
