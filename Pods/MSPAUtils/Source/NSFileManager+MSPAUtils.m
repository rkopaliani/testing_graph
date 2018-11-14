//
//  NSFileManager+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/3/18.
//

#import "NSFileManager+MSPAUtils.h"
#import "BALogger.h"

@implementation NSFileManager (MSPAUtils)

- (BOOL)createDirectoryAtPath:(NSString *)path {
    BOOL bresult = NO;
    @try {
        NSError *error = nil;
        bresult = [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error != nil) {
            BAINFO(@"BAFunctions::CreateFolderAtPath Error - %@", error);
        }
    }
    @catch (NSException *Ex) {
        BAINFO(@"Exception - %@", Ex.reason);
    }
    return bresult;
}

- (BOOL)isFileExistsAtPath:(NSString *)path {
    BOOL isDir;
    if ([self fileExistsAtPath:path isDirectory:&isDir] == NO) {
        return NO;
    }
    return !isDir;
}

- (BOOL)setAttributesAtPath:(NSString *)path withCommand:(int)cmd {
    BOOL bresult = NO;
    @try {
        NSError* error = nil;
        NSURL *url = [NSURL fileURLWithPath:path];
        
        if (cmd == 0)
        {
            NSDictionary* attribs = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:NSFileImmutable];
            [self setAttributes: attribs ofItemAtPath:path error:&error];
            [url setResourceValue:[NSNumber numberWithBool:NO] forKey:NSURLIsHiddenKey error:&error];
        }
        else if (cmd == 1 || cmd == 5)
        {
            NSDictionary* attribs = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSFileImmutable];
            [self setAttributes: attribs ofItemAtPath:path error:&error];
            [url setResourceValue:[NSNumber numberWithBool:NO] forKey:NSURLIsHiddenKey error:&error];
        }
        else if (cmd == 2 || cmd == 6)
        {
            NSDictionary* attribs = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:NSFileImmutable];
            [self setAttributes: attribs ofItemAtPath:path error:&error];
            [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsHiddenKey error:&error];
        }
        else if (cmd == 3 || cmd == 7)
        {
            NSDictionary* attribs = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSFileImmutable];
            [self setAttributes: attribs ofItemAtPath:path error:&error];
            [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsHiddenKey error:&error];
        }
        
        if (error == nil) {
            bresult = YES;
        } else {
            BAINFO(@"BAFunctions::MySetFileAttributes Error - %@", error);
        }
    }
    @catch (NSException *Ex) {
        bresult = false;
        BAINFO(@"Exception - %@", Ex.reason);
    }
    
    return bresult;
}

- (BOOL)moveFileFromPath:(NSString *)oldPathName toPath:(NSString *)newPathName {
    BOOL bresult = false;
    @try {
        NSError *error = nil;
        bresult = [self moveItemAtPath:oldPathName toPath:newPathName error:&error];
        if(error != nil) {
            BAINFO(@"BAFunctions::Rename/Move File Error - %@", error);
        }
    }
    @catch (NSException *Ex) {
        bresult = false;
        BAINFO(@"BAFunctions::RenameFile Exception - %@", Ex.reason);
    }
    return bresult;
}

- (BOOL)deleteFileAtPath:(NSString *)path {
    BOOL bresult = NO;
    @try {
        NSError *error = nil;
        bresult = [self removeItemAtPath:path error:&error];
        if(error != nil) {
            BAINFO(@"BAFunctions::DeleteFile Error - %@", error);
        }
    }
    @catch (NSException *Ex) {
        bresult = false;
        BAINFO(@"BAFunctions::DeleteFile Exception - %@", Ex.reason);
    }
    return bresult;
}

- (int64_t)freeDiskSpaceAtPath:(NSString *)path {
    int64_t freeSpace = 0;
    @try {
        NSError *error = nil;
        NSDictionary *fileAttributes = [self attributesOfFileSystemForPath:path error:&error];
        if (error == nil) {
            freeSpace = (int64_t)[[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
        }
    }
    @catch (NSException *Ex) {
        BAINFO(@"BAFunctions::GenFileMagicID Exception - %@", Ex.reason);
    }
    return freeSpace;
}

@end
