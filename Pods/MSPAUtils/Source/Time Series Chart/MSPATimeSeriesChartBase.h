//
//  MSPATimeSeriesChartBase.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/7/18.
//

#import <Foundation/Foundation.h>
#import "MSPAPlatform.h"
#import "MSPATimeSeriesEntry.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MPSATimeSeriesChartBase) {
    MPSATimeSeriesChartBaseBottom = 0,
    MPSATimeSeriesChartBaseTop,
    MPSATimeSeriesChartBaseLeft,
    MPSATimeSeriesChartBaseRight
};

@interface MSPATimeSeriesChartPathFactory: NSObject

+ (MSPBezierPath *)chartPathFromEntries:(NSArray<MSPATimeSeriesEntry *> *)entries
                               withBase:(MPSATimeSeriesChartBase)chartBase
                                 inRect:(MSPRect)rect
                            columnWidth:(CGFloat)columnWidth
                           columnsInset:(CGFloat)inset;
@end

NS_ASSUME_NONNULL_END
