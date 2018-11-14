//
//  NSAlert+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/3/18.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAlert (MSPAUtils)

+ (void)alertBox:(NSString *)message;
+ (void)alertBoxNonModal:(NSString *)message withWindow:(NSWindow *)window;

@end

NS_ASSUME_NONNULL_END
