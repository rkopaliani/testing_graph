//
//  MSPATimeSeriesEntry.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/7/18.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, MSPAChartDataProcessorFunction) {
    MSPAChartDataProcessorFunctionSum,
    MSPAChartDataProcessorFunctionAverage
};

NS_ASSUME_NONNULL_BEGIN

@interface MSPATimeSeriesEntry : NSObject

@property (nonatomic, assign) double normalizedValue;
@property (nonatomic, assign, readonly) double rawValue;
@property (nonatomic, assign, readonly) NSTimeInterval timestamp;

+ (MSPATimeSeriesEntry *)processedEntryFromEntries:(NSArray<MSPATimeSeriesEntry *> *)entries
                                      withFunction:(MSPAChartDataProcessorFunction)function;

- (instancetype)initWithTimestamp:(NSTimeInterval)timestamp rawValue:(double)raw;
- (instancetype)initWithTimestamp:(NSTimeInterval)timestamp;

@end

NS_ASSUME_NONNULL_END
