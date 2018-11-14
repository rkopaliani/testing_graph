//
//  NSView+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

#import "NSView+MSPAUtils.h"

@implementation NSView (MSPAUtils)

- (void)setNeedsLayout {
    self.needsLayout = YES;
}

- (void)setNeedsUpdateConstraints {
    self.needsUpdateConstraints = YES;
}

@end
