//
//  MSPAChartDataProcessor.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

#import "MSPATimeSeriesDataProcessor.h"


@interface MSPATimeSeriesDataStatistics()

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) double maximum;
@property (nonatomic, assign) double minimum;

@end

@implementation MSPATimeSeriesDataStatistics

- (instancetype)initWithRawData:(NSArray<NSNumber *> *)rawData {
    self = [super init];
    if (self) {
        self.count = rawData.count;
        self.maximum = [[rawData valueForKeyPath:@"@max.self"] doubleValue];
        self.minimum = [[rawData valueForKeyPath:@"@min.self"] doubleValue];
    }
    return self;
}

- (void)mergeWithStatistics:(MSPATimeSeriesDataStatistics *)statistics {
    self.count += statistics.count;
    self.maximum = MAX(self.maximum, statistics.maximum);
    self.minimum = MAX(self.minimum, statistics.minimum);
}

- (double)absMaximum {
    return self.maximum > round(self.minimum) ? self.maximum : round(self.minimum);
 }

@end


@implementation MSPATimeSeriesDataProcessorSettings

+ (instancetype)defaultSettings {
    return [[MSPATimeSeriesDataProcessorSettings alloc] initWithAccumulationInteval:1
                                                                 processingFunction:MSPAChartDataProcessorFunctionSum];
}

- (instancetype)initWithAccumulationInteval:(NSTimeInterval)interval
                         processingFunction:(MSPAChartDataProcessorFunction)processingFunction {
    self = [super init];
    if (self) {
        self.accumulationInterval = interval;
        self.processingFunction = processingFunction;
    }
    return self;
}

@end


@interface MSPATimeSeriesDataProcessor()

@property (nonatomic, strong) dispatch_queue_t processingQueue;
@property (nonatomic, strong) NSHashTable<id<MSPATimeSeriesDataProcessorDelegate>> *delegates;
@property (nonatomic, strong) NSMutableArray<MSPATimeSeriesEntry *> *timeSeries;
@property (nonatomic, strong) NSMutableArray<MSPATimeSeriesEntry *> *processingTimeSeries;
@property (nonatomic, strong) MSPATimeSeriesDataStatistics *statistics;
@property (nonatomic, weak) NSTimer *processingTimer;


- (void)accumulateData:(NSArray<MSPATimeSeriesEntry *> *)data;
- (void)triggerAccumulatedDataProcession;
- (void)processData:(NSArray<MSPATimeSeriesEntry *> *)data;

- (void)normalizeTimeSeries:(NSArray<MSPATimeSeriesEntry *> *)timeSeries withBase:(double)base;
- (NSArray<MSPATimeSeriesEntry *> *)interpolatedTimeSeries:(NSArray<MSPATimeSeriesEntry *> *)timeSeries;

- (void)rescheduleTimer;

- (void)dispatchDidUpdateEvent;

@end

@implementation MSPATimeSeriesDataProcessor

- (instancetype)init {
    return [self initWithSettings:nil];
}

- (instancetype)initWithSettings:(MSPATimeSeriesDataProcessorSettings *)settings {
    self = [super init];
    if (self) {
        _timeSeries = [NSMutableArray array];
        _processingTimeSeries = [NSMutableArray array];
        _processingQueue = dispatch_queue_create("com.beanywhere.chart.data-controller", DISPATCH_QUEUE_SERIAL);
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        _settings = settings ?: [MSPATimeSeriesDataProcessorSettings defaultSettings];
        [self reset];
    }
    return self;
}

- (void)dealloc {
    [self.processingTimer invalidate];
}

- (void)addDelegate:(id<MSPATimeSeriesDataProcessorDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<MSPATimeSeriesDataProcessorDelegate>)delegate {
    [self.delegates removeObject:delegate];
}

- (void)addData:(NSArray<MSPATimeSeriesEntry *> *)data {
    if (data.count == 0) {
        return;
    }
    [self accumulateData:data];
    dispatch_sync(self.processingQueue, ^{
        [self rescheduleTimer];
    });
}

- (void)reset {
    [self.timeSeries removeAllObjects];
    self.statistics = [MSPATimeSeriesDataStatistics new];
}

- (NSArray<MSPATimeSeriesEntry *> *)processedData {
    return self.timeSeries.copy;
}

#pragma mark - Private

- (void)accumulateData:(NSArray<MSPATimeSeriesEntry *> *)data {
    dispatch_sync(self.processingQueue, ^{
        [self.processingTimeSeries addObjectsFromArray:data];
        if (self.timeSeries.count == 0) {
            [self triggerAccumulatedDataProcession];
        }
    });
}

- (void)triggerAccumulatedDataProcession {
    NSArray<MSPATimeSeriesEntry *> *pendingData = self.processingTimeSeries.count > 0
        ? self.processingTimeSeries : @[[MSPATimeSeriesEntry new]];
    [self processData:pendingData];
    [self.processingTimeSeries removeAllObjects];
    [self rescheduleTimer];
}

- (void)processData:(NSArray<MSPATimeSeriesEntry *> *)data {
    if (data.count == 0) { return; }
    NSArray<MSPATimeSeriesEntry *> *sortedData = [data sortedArrayUsingComparator:^NSComparisonResult(MSPATimeSeriesEntry *lhs, MSPATimeSeriesEntry *rhs) {
        return lhs.timestamp <= rhs.timestamp;
    }];
    
    NSArray<MSPATimeSeriesEntry *> *interpolatedEntries = [self interpolatedTimeSeries:sortedData];
    NSMutableArray<NSNumber *> *rawData = [NSMutableArray new];
    for (MSPATimeSeriesEntry *entryObject in interpolatedEntries) {
        [rawData addObject:@(entryObject.rawValue)];
    }
    
    MSPATimeSeriesDataStatistics *pendingStatistics = [[MSPATimeSeriesDataStatistics alloc] initWithRawData:rawData];
    if (pendingStatistics.absMaximum > self.statistics.absMaximum) {
        [self.timeSeries addObjectsFromArray:interpolatedEntries];
        [self normalizeTimeSeries:self.timeSeries withBase:pendingStatistics.absMaximum];
    } else {
        [self normalizeTimeSeries:interpolatedEntries withBase:self.statistics.absMaximum];
        [self.timeSeries addObjectsFromArray:interpolatedEntries];
    }
    [self.statistics mergeWithStatistics:pendingStatistics];
    
    [self dispatchDidUpdateEvent];
}

- (void)normalizeTimeSeries:(NSArray<MSPATimeSeriesEntry *> *)timeSeries withBase:(double)base {
    double safeBase = base == 0 ? 1 : base;
    for (MSPATimeSeriesEntry *entry in timeSeries) {
        entry.normalizedValue = entry.rawValue / safeBase;
    }
}

- (NSArray<MSPATimeSeriesEntry *> *)interpolatedTimeSeries:(NSArray<MSPATimeSeriesEntry *> *)timeSeries {
    MSPATimeSeriesEntry *firstEntry = timeSeries.firstObject;
    if (firstEntry == nil) { return @[]; }
    
    NSMutableArray<MSPATimeSeriesEntry *> *entries = [NSMutableArray new];
    NSMutableArray<MSPATimeSeriesEntry *> *entryGroup = [NSMutableArray arrayWithObject:firstEntry];
    
    NSMutableArray<MSPATimeSeriesEntry *> *remainedEntries = timeSeries.mutableCopy;
    [remainedEntries removeObject:firstEntry];
    for (MSPATimeSeriesEntry *entry in remainedEntries) {
        MSPATimeSeriesEntry *groupFirstEntry = remainedEntries.firstObject;
        if (groupFirstEntry == nil) { return timeSeries; };
        MSPATimeSeriesEntry *groupLastEntry = remainedEntries.lastObject;
        if (groupLastEntry == nil) { return timeSeries; };
        
        NSTimeInterval timeInterval = entry.timestamp - groupFirstEntry.timestamp;
        if (timeInterval <= self.settings.accumulationInterval) {
            [entryGroup addObject:entry];
            continue;
        }
        
        timeInterval += self.settings.accumulationInterval;
        while (timeInterval <= entry.timestamp) {
            [entries addObject:[[MSPATimeSeriesEntry alloc] initWithTimestamp:timeInterval]];
            timeInterval += self.settings.accumulationInterval;
        }
        
        MSPATimeSeriesEntry *processedEntry = [MSPATimeSeriesEntry processedEntryFromEntries:entryGroup
                                                                                withFunction:self.settings.processingFunction];
        if (processedEntry) {
            [entries addObject:processedEntry];
        }
        
        [entryGroup removeAllObjects];
        [entryGroup addObject:entry];
    }
    
    MSPATimeSeriesEntry *processedEntry = [MSPATimeSeriesEntry processedEntryFromEntries:entryGroup
                                                                            withFunction:self.settings.processingFunction];
    if (processedEntry) {
        [entries addObject:processedEntry];
    }

    return entries;
}

#pragma mark - Timers

- (void)rescheduleTimer {
    if (self.processingTimer != nil) {
        return;
    }
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.settings.accumulationInterval
                                                      target:self
                                                    selector:@selector(timerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
    self.processingTimer = timer;
}

- (void)timerFired:(NSTimer *)timer {
    dispatch_sync(self.processingQueue, ^{
        [self triggerAccumulatedDataProcession];
    });
}

#pragma mark - Dispatcher

- (void)dispatchDidUpdateEvent {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<MSPATimeSeriesDataProcessorDelegate>delegate in self.delegates) {
            [delegate timeSeriesDataProcessorDidUpdate:self];
        }
    });
}

@end
