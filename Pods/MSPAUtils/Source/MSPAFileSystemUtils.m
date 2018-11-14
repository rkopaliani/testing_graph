//
//  MSPAFileUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import "MSPAFileSystemUtils.h"
#import "NSString+MSPAUtils.h"
#import "BALogger.h"


@implementation MSPAFileSystemUtils

+ (NSString *)libraryPath {
    NSArray *libraryDirs = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return libraryDirs.firstObject;
}

+ (NSString *)macPathFromPath:(NSString *)path {
    path = [path stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    path = [NSString stringWithFormat:@"/Volumes/%@", path];
    return path;
}

+ (BOOL)copyFolderFromPath:(NSString *)originPath toPath:(NSString *)destPath {
    BOOL bResult = NO;
    @try {
        NSString *command = [NSString stringWithFormat:@"cp -r \"%@\" \"%@\"", originPath, destPath];
        NSArray *args = [[NSArray alloc] initWithObjects:@"-c", command, nil];
        
        NSTask *task01 = [[NSTask alloc] init];
        [task01 setLaunchPath:@"/bin/bash"];
        [task01 setArguments:args];
        
        NSPipe *pipe01 = [NSPipe pipe];
        [task01 setStandardOutput: pipe01];
        [task01 setStandardError: pipe01];
        [task01 launch];
        
        NSFileHandle *file;
        file = [pipe01 fileHandleForReading];
        
        [task01 waitUntilExit];
        
        NSData *data;
        data = [file readDataToEndOfFile];
        if ([data length] == 0) {
            bResult = YES;
        } else {
            BAINFO(@"Failed: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }
    @catch(NSException * exception) {
        BAINFO(@"Exception: %@", exception.reason);
    }
    return bResult;
}

+ (BOOL)decompressFileOnPath:(NSString *)zipPath toPath:(NSString *)destinationPath {
    @try {
        if([zipPath hasContent] && [destinationPath hasContent])
        {
            NSString* command = [NSString stringWithFormat:@"unzip -o \"%@\" -d \"%@\"", zipPath, destinationPath];
            NSArray *args = [NSArray arrayWithObjects:@"-c", command, nil];
            
            BAINFO(@"UnzipCommand: %@", command);
            
            NSTask *unzip = [[NSTask alloc] init];
            [unzip setLaunchPath:@"/bin/bash"];
            [unzip setArguments:args];
            [unzip launch];
            [unzip waitUntilExit];
            
            return YES;
        }
        else
            BAINFO(@"Path is empty...");
    } @catch (NSException *exception) {
        BAINFO(@"Error: %@", exception.reason);
    }
    
    return NO;
}

+ (void)compressFileAtPath:(NSString *)originPath toPath:(NSString *)destPath {
    NSString *command = [NSString stringWithFormat:@"ditto -ck --rsrc --sequesterRsrc %@ %@", originPath, destPath];
    NSArray *args = [NSArray arrayWithObjects:@"-c", command, nil];
    
    NSTask *task01 = [[NSTask alloc] init];
    [task01 setLaunchPath:@"/bin/bash"];
    [task01 setArguments:args];
    
    [task01 launch];
    [task01 waitUntilExit];
}

@end
