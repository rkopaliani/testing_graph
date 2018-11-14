//
//  MSPATimeSeriesChartView.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/7/18.
//

#import "MSPAPlatform.h"
#import "MSPATimeSeriesEntry.h"
#import "MSPATimeSeriesChartBase.h"

NS_ASSUME_NONNULL_BEGIN

@class MSPATimeSeriesChartView;
@protocol MSPATimeSeriesChartViewDelegate<NSObject>

- (void)timeSeriesChartViewDidUpdate:(MSPATimeSeriesChartView *)chartView;

@end

@interface MSPATimeSeriesChartView : MSPView

@property (nonatomic, weak) id<MSPATimeSeriesChartViewDelegate> delegate;
@property (nonatomic, assign) MPSATimeSeriesChartBase chartBase;
@property (nonatomic, assign) MSPAChartDataProcessorFunction processingFunction;
@property (nonatomic, assign) CGFloat columnWidth;
@property (nonatomic, strong) MSPColor *columnColor;

@property (nonatomic, assign, readonly) double minimum;
@property (nonatomic, assign, readonly) double maximum;
@property (nonatomic, assign, readonly) NSInteger sampleSize;

- (void)appendSample:(NSArray<MSPATimeSeriesEntry *> *)sample;

@end

NS_ASSUME_NONNULL_END
