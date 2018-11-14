//
//  NSFileManager+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/3/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (MSPAUtils)

//PathToFileExists
- (BOOL)isFileExistsAtPath:(NSString *)path;

//MySetFileAttributes
- (BOOL)setAttributesAtPath:(NSString *)path withCommand:(int)cmd;

//CreateFolderAtPath
- (BOOL)createDirectoryAtPath:(NSString *)path;

//RenameFile
- (BOOL)moveFileFromPath:(NSString *)oldPathName toPath:(NSString *)newPathName;

//Delete File
- (BOOL)deleteFileAtPath:(NSString *)path;

//FreeDiskSpaceFromPath
- (int64_t)freeDiskSpaceAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
