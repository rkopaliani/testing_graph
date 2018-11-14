//
//  NSImage+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/3/18.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (MSPAUtils)

- (NSImage *)imageTintedWithColor:(NSColor *)color;

+ (NSImage *)flipImageVertically:(NSImage *)image;
+ (NSImage *)flipImageHorizontally:(NSImage *)image;

@end

NS_ASSUME_NONNULL_END
