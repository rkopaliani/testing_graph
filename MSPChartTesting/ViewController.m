//
//  ViewController.m
//  MSPChartTesting
//
//  Created by Roman Kopaliani on 11/14/18.
//  Copyright © 2018 Roman Kopaliani. All rights reserved.
//

#import "ViewController.h"
#import <MSPAUtils/MSPATimeSeriesChartView.h>
#import <PureLayout/PureLayout.h>"

@interface ViewController () <MSPATimeSeriesChartViewDelegate>

@property (nonatomic, weak) IBOutlet NSView *containerView;
@property (nonatomic, weak) MSPATimeSeriesChartView *chartView;
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MSPATimeSeriesChartView *chartView = [[MSPATimeSeriesChartView alloc] initForAutoLayout];
    chartView.delegate = self;
    chartView.columnColor = [NSColor redColor];
    chartView.columnWidth = 2.f;
    [self.containerView addSubview:chartView];
    [chartView autoPinEdgesToSuperviewEdges];
    self.chartView = chartView;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fire:) userInfo:nil repeats:YES];
}

- (void)fire:(NSTimer *)timer {
    MSPATimeSeriesEntry *entry = [[MSPATimeSeriesEntry alloc] initWithTimestamp:[NSDate timeIntervalSinceReferenceDate] rawValue:(double)arc4random_uniform(100)];
    NSArray *array = [NSArray arrayWithObject:entry];
    [self.chartView appendSample:array];
}

#pragma mark <MSPATimeSeriesChartViewDelegate>

- (void)timeSeriesChartViewDidUpdate:(MSPATimeSeriesChartView *)chartView {
}

@end
