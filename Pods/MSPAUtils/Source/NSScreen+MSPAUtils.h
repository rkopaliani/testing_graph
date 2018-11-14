//
//  NSScreen+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSScreen (MSPAUtils)

- (NSString *)screenName;
+ (NSString * __nullable)screenNameForDisplay:(NSNumber *)screenId;
+ (NSUInteger)screensCount;

@end

NS_ASSUME_NONNULL_END
