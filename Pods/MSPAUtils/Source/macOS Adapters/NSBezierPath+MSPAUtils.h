//
//  NSBezierPath+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

@import AppKit;

NS_ASSUME_NONNULL_BEGIN

@interface NSBezierPath (MSPAUtils)

@property (nonatomic, readonly) CGPathRef CGPath;

- (void)addLineToPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
