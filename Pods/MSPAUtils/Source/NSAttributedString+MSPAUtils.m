//
//  NSAttributedString+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import "NSAttributedString+MSPAUtils.h"

@implementation NSAttributedString (MSPAUtils)

- (NSAttributedString *)stringWithForegroundColor:(NSColor *)color {
    NSMutableAttributedString *mutable = self.mutableCopy;
    [mutable addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, self.length)];
    return mutable.copy;
}

@end
