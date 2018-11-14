//
//  MSPATimeSeriesChartView.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/7/18.
//

#import "MSPATimeSeriesChartView.h"
#import "MSPATimeSeriesDataProcessor.h"
#import "MSPATimeSeriesCanvasView.h"


@interface MSPATimeSeriesChartView() <MSPATimeSeriesCanvasViewDelegate, MSPATimeSeriesDataProcessorDelegate>

@property (nonatomic, assign) BOOL didUpdateConstraints;
@property (nonatomic, strong) MSPATimeSeriesDataProcessor *dataProcessor;
@property (nonatomic, weak) MSPScrollView *scrollView;
@property (nonatomic, weak) MSPATimeSeriesCanvasView *canvasView;

@end

@implementation MSPATimeSeriesChartView

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self configureView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

#pragma mark - Public

- (double)minimum {
    return self.dataProcessor.statistics.minimum;
}

- (double)maximum {
    return self.dataProcessor.statistics.maximum;
}

- (NSInteger)sampleSize {
    return self.dataProcessor.statistics.count;
}

- (MPSATimeSeriesChartBase)chartBase {
    return self.canvasView.columnBase;
}

- (void)setChartBase:(MPSATimeSeriesChartBase)chartBase {
    self.canvasView.columnBase = chartBase;
}

- (MSPColor *)columnColor {
    return self.canvasView.columnColor;
}

- (void)setColumnColor:(MSPColor *)columnColor {
    self.canvasView.columnColor = columnColor;
}

- (MSPAChartDataProcessorFunction)processingFunction {
    return self.dataProcessor.settings.processingFunction;
}

- (void)setProcessingFunction:(MSPAChartDataProcessorFunction)processingFunction {
    if (processingFunction == self.dataProcessor.settings.processingFunction) {
        return;
    }
    MSPATimeSeriesDataProcessorSettings *settings = [MSPATimeSeriesDataProcessorSettings defaultSettings];
    settings.processingFunction = processingFunction;
    self.dataProcessor.settings = settings;
}

- (void)appendSample:(NSArray<MSPATimeSeriesEntry *> *)sample {
    [self.dataProcessor addData:sample];
}

#pragma mark - Private

- (void)configureView {
    [self configureScrollView];
    [self configureCanvasView];
    [self configureDataProcessor];
    [self setNeedsUpdateConstraints];
}

- (void)configureScrollView {
    MSPScrollView *scrollView = [MSPScrollView new];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)configureCanvasView {
    MSPATimeSeriesCanvasView *canvasView = [[MSPATimeSeriesCanvasView alloc] initWithDelegate:self];
    canvasView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.documentView = canvasView;
    self.canvasView = canvasView;
}

- (void)configureDataProcessor {
    MSPATimeSeriesDataProcessorSettings *settings = [MSPATimeSeriesDataProcessorSettings defaultSettings];
    MSPATimeSeriesDataProcessor *dataProcessor = [[MSPATimeSeriesDataProcessor alloc] initWithSettings:settings];
    [dataProcessor addDelegate:self];
    [dataProcessor addDelegate:self.canvasView];
    self.dataProcessor = dataProcessor;
}

- (void)updateConstraints {
    if (self.didUpdateConstraints == NO) {
        NSArray<NSLayoutConstraint *> *constraints =
        @[
          [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
          [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
          [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0],
          [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
          
          [NSLayoutConstraint constraintWithItem:self.canvasView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
          [NSLayoutConstraint constraintWithItem:self.canvasView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
          [NSLayoutConstraint constraintWithItem:self.canvasView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
          [NSLayoutConstraint constraintWithItem:self.canvasView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        ];
        
        if (@available(macOS 10.10, *)) {
            [NSLayoutConstraint activateConstraints:constraints];
        } else {
            [self addConstraints:constraints];
        }
        self.didUpdateConstraints = YES;
    }

    [super updateConstraints];
}

#pragma mark - <MSPATimeSeriesCanvasViewDelegate>

- (CGSize)timeSeriesCanvasViewContentSize:(MSPATimeSeriesCanvasView *)canvasView {
    return self.bounds.size;
}

- (void)timeSeriesCanvasViewDidRedraw:(MSPATimeSeriesCanvasView *)canvasView {
    CGPoint offset = CGPointZero;
    switch (canvasView.columnBase) {
        case MPSATimeSeriesChartBaseTop:
        case MPSATimeSeriesChartBaseBottom:
            offset = CGPointMake(self.scrollView.contentSize.width - self.bounds.size.width + self.scrollView.contentInset.right, 0);
            break;
        case MPSATimeSeriesChartBaseLeft:
        case MPSATimeSeriesChartBaseRight:
            offset = CGPointMake(0, self.scrollView.contentSize.height - self.bounds.size.height + self.scrollView.contentInset.bottom);
    }
    [self.scrollView setContentOffset:offset animated:NO];
}

#pragma mark - <MSPATimeSeriesDataProcessorDelegate>

- (void)timeSeriesDataProcessorDidUpdate:(MSPATimeSeriesDataProcessor *)processor {
    [self.delegate timeSeriesChartViewDidUpdate:self];
}

@end
