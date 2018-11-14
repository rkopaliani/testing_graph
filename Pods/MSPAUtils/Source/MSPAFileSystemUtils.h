//
//  MSPAFileUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSPAFileSystemUtils : NSObject

+ (NSString * __nullable)libraryPath;

//ConvertToMACPath
+ (NSString * __nullable)macPathFromPath:(NSString *)path;

+ (BOOL)copyFolderFromPath:(NSString *)originPath toPath:(NSString *)destinationPath;
+ (BOOL)decompressFileOnPath:(NSString *)zipPath toPath:(NSString *)destinationPath;
+ (void)compressFileAtPath:(NSString *)originPath toPath:(NSString *)destPath;

@end

NS_ASSUME_NONNULL_END
