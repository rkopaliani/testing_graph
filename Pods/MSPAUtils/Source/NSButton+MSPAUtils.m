//
//  NSButton+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/13/18.
//

#import "NSButton+MSPAUtils.h"

@implementation NSButton (MSPAUtils)

- (void)applyAttributedTitleForegroundColor:(NSColor *)color {
    NSMutableAttributedString *colorTitle = self.attributedTitle.mutableCopy;
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    self.attributedTitle = colorTitle;
}

@end
