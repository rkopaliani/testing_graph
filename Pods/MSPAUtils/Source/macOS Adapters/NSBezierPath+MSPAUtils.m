//
//  NSBezierPath+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

#import "NSBezierPath+MSPAUtils.h"

@implementation NSBezierPath (MSPAUtils)

- (CGPathRef)CGPath {
    CGMutablePathRef path = CGPathCreateMutable();
    NSPoint pointArray[3];
    NSInteger numElements = self.elementCount;
    for (int index = 0; index < numElements; ++index) {
        NSBezierPathElement pathType = [self elementAtIndex:index associatedPoints:pointArray];
        switch (pathType) {
            case NSBezierPathElementMoveTo:
                CGPathMoveToPoint(path, nil, pointArray[0].x, pointArray[0].y);
                break;
            case NSBezierPathElementLineTo:
                CGPathAddLineToPoint(path, nil, pointArray[0].x, pointArray[0].y);
                break;
            case NSBezierPathElementCurveTo:
                CGPathAddCurveToPoint(path, nil, pointArray[0].x, pointArray[0].y,
                                      pointArray[1].x, pointArray[1].y,
                                      pointArray[2].x, pointArray[2].y);
                break;
            case NSBezierPathElementClosePath:
                CGPathCloseSubpath(path);
                break;
        }
    }
    
    return path;
}

- (void)addLineToPoint:(CGPoint)point {
    [self lineToPoint:point];
}

@end
