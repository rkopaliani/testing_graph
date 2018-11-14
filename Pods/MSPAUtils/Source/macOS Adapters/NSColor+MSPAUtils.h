//
//  NSColor+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

@import AppKit;

NS_ASSUME_NONNULL_BEGIN

@interface NSColor (MSPAUtils)

+ (NSColor *)colorWithHex:(NSUInteger)hex;

@property (nonatomic, assign, readonly) uint hex;
@property (nonatomic, strong, readonly) NSString *hexString;

@end

NS_ASSUME_NONNULL_END
