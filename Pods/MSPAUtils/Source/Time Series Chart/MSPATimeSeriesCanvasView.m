//
//  MSPATimeSeriesCanvasView.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/7/18.
//

#import "MSPATimeSeriesCanvasView.h"

@import QuartzCore.CAShapeLayer;

@interface MSPATimeSeriesCanvasView()

@property (nonatomic, assign) BOOL needsRedraw;
@property (nonatomic, weak) id<MSPATimeSeriesCanvasViewDelegate> delegate;
@property (nonatomic, weak) MSPShapeView *chartView;
@property (nonatomic, strong) NSArray<MSPATimeSeriesEntry *> *data;

- (void)setNeedsRedraw;
- (void)redrawChart;

@end

@implementation MSPATimeSeriesCanvasView

- (instancetype)initWithDelegate:(id<MSPATimeSeriesCanvasViewDelegate>)delegate {
    MSPRect rect = (MSPRect){0.f, 0.f, 0.f, 0.f};
    self = [super initWithFrame:rect];
    if (self) {
        _delegate = delegate;
        _columnWidth = 5.f;
        _columnColor = [MSPColor whiteColor];
        _columnBase = MPSATimeSeriesChartBaseBottom;
        [self loadViewHierarchy];
    }
    return self;
}

- (void)setColumnWidth:(CGFloat)columnWidth {
    if (columnWidth == _columnWidth) {
        return;
    }
    _columnWidth = columnWidth;
    [self setNeedsRedraw];
}

- (void)setColumnBase:(MPSATimeSeriesChartBase)base {
    if (base == _columnBase) {
        return;
    }
    _columnBase = base;
    [self setNeedsRedraw];
}

- (void)setData:(NSArray<MSPATimeSeriesEntry *> *)data {
    _data = data;
    [self setNeedsRedraw];
}

- (MSPSize)intrinsicContentSize {
    if (self.delegate == nil) {
        return (MSPSize){-1, -1};
    }
    
    CGSize baseSize = [self.delegate timeSeriesCanvasViewContentSize:self];
    if (self.columnBase == MPSATimeSeriesChartBaseBottom || self.columnBase == MPSATimeSeriesChartBaseTop) {
        CGFloat width = MAX(baseSize.width, self.columnWidth * self.data.count);
        return (MSPSize){width, baseSize.height};
    } else {
        CGFloat height = MAX(baseSize.height, self.columnWidth * self.data.count);
        return (MSPSize){baseSize.width, height};
    }
}

#pragma mark - Private

- (void)loadViewHierarchy {
    MSPShapeView *chartView = [[MSPShapeView alloc] init];
    [self addSubview:chartView];
    self.chartView = chartView;
}

- (void)setNeedsRedraw {
    self.needsRedraw = YES;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.chartView.frame = self.bounds;
    if (self.needsRedraw) {
        [self redrawChart];
    }
}

- (void)redrawChart {
    if (self.data.count == 0) { return; }
    if (CGRectEqualToRect(self.bounds, CGRectZero)) { return ; }
    
    CALayer *drawingLayer = self.chartView.layer;
    if ([drawingLayer isKindOfClass:[CAShapeLayer class]] == NO) {
        return;
    }
    CAShapeLayer *castedLayer = (CAShapeLayer *)drawingLayer;
    MSPBezierPath *path = [MSPATimeSeriesChartPathFactory chartPathFromEntries:self.data
                                                                      withBase:self.columnBase
                                                                        inRect:self.bounds
                                                                   columnWidth:self.columnWidth
                                                                  columnsInset:0];
    castedLayer.frame = self.bounds;
    castedLayer.path = path.CGPath;
    castedLayer.fillColor = self.columnColor.CGColor;
    self.needsRedraw = NO;
}

#pragma mark - <MSPATimeSeriesDataProcessorDelegate>

- (void)timeSeriesDataProcessorDidUpdate:(MSPATimeSeriesDataProcessor *)processor {
    self.data = processor.processedData;
}

@end
