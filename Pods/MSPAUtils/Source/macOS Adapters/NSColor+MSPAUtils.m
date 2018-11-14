//
//  NSColor+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

#import "NSColor+MSPAUtils.h"

@implementation NSColor (MSPAUtils)

+ (NSColor *)colorWithHex:(NSUInteger)hex {
    CGFloat red, green, blue, alpha;
    red = ((CGFloat)((hex >> 16) & 0xFF)) / ((CGFloat)0xFF);
    green = ((CGFloat)((hex >> 8) & 0xFF)) / ((CGFloat)0xFF);
    blue = ((CGFloat)((hex >> 0) & 0xFF)) / ((CGFloat)0xFF);
    alpha = hex > 0xFFFFFF ? ((CGFloat)((hex >> 24) & 0xFF)) / ((CGFloat)0xFF) : 1;
    return [NSColor colorWithRed: red green:green blue:blue alpha:alpha];
}

- (uint)hex {
    CGFloat red, green, blue, alpha;
    
    @try {
        [self getRed:&red green:&green blue:&blue alpha:&alpha];
    }
    @catch (NSException *exception) {
        [self getWhite:&red alpha:&alpha];
        green = red;
        blue = red;
    }
    
    red = roundf(red * 255.f);
    green = roundf(green * 255.f);
    blue = roundf(blue * 255.f);
    alpha = roundf(alpha * 255.f);
    
    return ((uint)alpha << 24) | ((uint)red << 16) | ((uint)green << 8) | ((uint)blue);
}

- (NSString *)hexString {
    return [NSString stringWithFormat:@"0x%08x", [self hex]];
}

@end
