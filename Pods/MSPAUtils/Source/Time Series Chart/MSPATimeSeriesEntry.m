//
//  MSPATimeSeriesEntry.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/7/18.
//

#import "MSPATimeSeriesEntry.h"


@interface MSPATimeSeriesEntry()

@property (nonatomic, assign) double rawValue;
@property (nonatomic, assign) NSTimeInterval timestamp;

@end

@implementation MSPATimeSeriesEntry

+ (MSPATimeSeriesEntry *)processedEntryFromEntries:(NSArray<MSPATimeSeriesEntry *> *)entries
                                            withFunction:(MSPAChartDataProcessorFunction)function {
    switch (function) {
        case MSPAChartDataProcessorFunctionSum: return [self sumEntryFromEntries:entries];
        case MSPAChartDataProcessorFunctionAverage: return [self averageEntryFromEntries:entries];
    }
}

+ (MSPATimeSeriesEntry *)sumEntryFromEntries:(NSArray<MSPATimeSeriesEntry *> *)entries {
    if (entries.count == 0) { return nil; };
    double sum = 0;
    for (MSPATimeSeriesEntry *entry in entries) {
        sum += entry.rawValue;
    }
    return [[MSPATimeSeriesEntry alloc] initWithTimestamp:entries.firstObject.timestamp rawValue:sum];
}

+ (MSPATimeSeriesEntry *)averageEntryFromEntries:(NSArray<MSPATimeSeriesEntry *> *)entries {
    if (entries.count == 0) { return nil; };
    double sum = 0;
    for (MSPATimeSeriesEntry *entry in entries) {
        sum += entry.rawValue;
    }
    double avgValue = sum/entries.count;
    return [[MSPATimeSeriesEntry alloc] initWithTimestamp:entries.firstObject.timestamp rawValue:avgValue];
}

- (instancetype)initWithTimestamp:(NSTimeInterval)timestamp rawValue:(double)raw {
    self = [super init];
    if (self) {
        self.timestamp = timestamp;
        self.rawValue = raw;
    }
    return self;
}

- (instancetype)initWithTimestamp:(NSTimeInterval)timestamp {
    return [self initWithTimestamp:timestamp rawValue:0];
}

@end
