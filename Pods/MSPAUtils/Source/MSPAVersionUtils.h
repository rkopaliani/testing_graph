//
//  MSPAVersionUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import <Foundation/Foundation.h>

@import AppKit;

NS_ASSUME_NONNULL_BEGIN

@interface MSPAVersionUtils : NSObject

+ (NSString *)OSVersion;
+ (NSString *)mspxVersion;

@end

NS_ASSUME_NONNULL_END
