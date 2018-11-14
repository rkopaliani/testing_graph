//
//  MSPATimeSeriesCanvasView.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/7/18.
//

#import "MSPAPlatform.h"
#import "MSPATimeSeriesChartBase.h"
#import "MSPATimeSeriesDataProcessor.h"


NS_ASSUME_NONNULL_BEGIN
@class MSPATimeSeriesCanvasView;
@protocol MSPATimeSeriesCanvasViewDelegate <NSObject>

- (CGSize)timeSeriesCanvasViewContentSize:(MSPATimeSeriesCanvasView *)canvasView;
- (void)timeSeriesCanvasViewDidRedraw:(MSPATimeSeriesCanvasView *)canvasView;

@end


@interface MSPATimeSeriesCanvasView : MSPView <MSPATimeSeriesDataProcessorDelegate>

@property (nonatomic, weak, readonly) id<MSPATimeSeriesCanvasViewDelegate> delegate;

- (instancetype)initWithDelegate:(id<MSPATimeSeriesCanvasViewDelegate>)delegate NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(MSPRect)frameRect NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;

@property (nonatomic, assign) CGFloat columnWidth;
@property (nonatomic, strong) MSPColor *columnColor;
@property (nonatomic, assign) MPSATimeSeriesChartBase columnBase;

@end

NS_ASSUME_NONNULL_END
