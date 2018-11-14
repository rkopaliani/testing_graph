//
//  NSScrollView+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

#import "NSScrollView+MSPAUtils.h"

@implementation NSScrollView (MSPAUtils)

- (NSEdgeInsets)contentInset {
    if (@available(macOS 10.10, *)) {
        return [self contentInsets];
    } else {
        return NSEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    if (animated) {
        [self.animator scrollPoint:contentOffset];
    } else {
        [self scrollPoint:contentOffset];
    }
}

@end
