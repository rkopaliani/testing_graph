//
//  MSPATimeSeriesChartBase.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/7/18.
//

#import "MSPATimeSeriesChartBase.h"
#import "MSPATimeSeriesDataProcessor.h"


@implementation MSPATimeSeriesChartPathFactory

+ (MSPBezierPath *)chartPathFromEntries:(NSArray<MSPATimeSeriesEntry *> *)entries
                               withBase:(MPSATimeSeriesChartBase)chartBase
                                 inRect:(MSPRect)rect
                            columnWidth:(CGFloat)columnWidth
                           columnsInset:(CGFloat)inset {
    MSPBezierPath *path = [MSPBezierPath new];
    switch (chartBase) {
        case MPSATimeSeriesChartBaseBottom: {
            [path moveToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
            CGPoint currentPoint = path.currentPoint;
            CGPoint basePoint = currentPoint;
            for (MSPATimeSeriesEntry *entry in entries.reverseObjectEnumerator) {
                CGFloat columnHeight = CGRectGetHeight(rect) * entry.normalizedValue;
                [path addLineToPoint:basePoint];
                [path addLineToPoint:CGPointMake(basePoint.x, basePoint.y - columnHeight)];
                [path addLineToPoint:CGPointMake(basePoint.x - columnWidth, basePoint.y - columnHeight)];
                [path addLineToPoint:CGPointMake(basePoint.x - columnWidth, basePoint.y)];
                currentPoint = path.currentPoint;
                basePoint = CGPointMake(currentPoint.x - inset, currentPoint.y);
            }
        } break;
        case MPSATimeSeriesChartBaseTop: {
            [path moveToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
            CGPoint currentPoint = path.currentPoint;
            CGPoint basePoint = currentPoint;
            for (MSPATimeSeriesEntry *entry in entries.reverseObjectEnumerator) {
                CGFloat columnHeight = CGRectGetHeight(rect) * entry.normalizedValue;
                [path addLineToPoint:basePoint];
                [path addLineToPoint:CGPointMake(basePoint.x, columnHeight)];
                [path addLineToPoint:CGPointMake(basePoint.x - columnWidth, columnHeight)];
                [path addLineToPoint:CGPointMake(basePoint.x - columnWidth, basePoint.y)];
                currentPoint = path.currentPoint;
                basePoint = CGPointMake(currentPoint.x - inset, currentPoint.y);
            }
        } break;
        case MPSATimeSeriesChartBaseLeft: {
            [path moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
            CGPoint currentPoint = path.currentPoint;
            CGPoint basePoint = currentPoint;
            for (MSPATimeSeriesEntry *entry in entries.reverseObjectEnumerator) {
                CGFloat columnHeight = CGRectGetWidth(rect) * entry.normalizedValue;
                [path addLineToPoint:basePoint];
                [path addLineToPoint:CGPointMake(basePoint.x + columnHeight, basePoint.y)];
                [path addLineToPoint:CGPointMake(basePoint.x + columnHeight, basePoint.y - columnWidth)];
                [path addLineToPoint:CGPointMake(basePoint.x, basePoint.y - columnWidth)];
                currentPoint = path.currentPoint;
                basePoint = CGPointMake(currentPoint.x, currentPoint.y - inset);
            }
        } break;
        case MPSATimeSeriesChartBaseRight: {
            [path moveToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
            CGPoint currentPoint = path.currentPoint;
            CGPoint basePoint = currentPoint;
            for (MSPATimeSeriesEntry *entry in entries.reverseObjectEnumerator) {
                CGFloat columnHeight = CGRectGetWidth(rect) * entry.normalizedValue;
                [path addLineToPoint:basePoint];
                [path addLineToPoint:CGPointMake(basePoint.x - columnHeight, basePoint.y)];
                [path addLineToPoint:CGPointMake(basePoint.x - columnHeight, basePoint.y - columnWidth)];
                [path addLineToPoint:CGPointMake(basePoint.x, basePoint.y - columnWidth)];
                currentPoint = path.currentPoint;
                basePoint = CGPointMake(currentPoint.x, currentPoint.y - inset);
            }
        } break;
    }
    [path closePath];
    return path;
}

@end
