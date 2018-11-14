//
//  MSPAChartDataProcessor.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

#import <Foundation/Foundation.h>
#import "MSPATimeSeriesEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSPATimeSeriesDataStatistics: NSObject

- (instancetype)initWithRawData:(NSArray<NSNumber *> *)rawData;

@property (nonatomic, assign, readonly) NSInteger count;
@property (nonatomic, assign, readonly) double maximum;
@property (nonatomic, assign, readonly) double minimum;

- (void)mergeWithStatistics:(MSPATimeSeriesDataStatistics *)statistics;
- (double)absMaximum;

@end


@interface MSPATimeSeriesDataProcessorSettings: NSObject

@property (nonatomic, assign) NSTimeInterval accumulationInterval;
@property (nonatomic, assign) MSPAChartDataProcessorFunction processingFunction;

+ (instancetype)defaultSettings;

@end


@class MSPATimeSeriesDataProcessor;
@protocol MSPATimeSeriesDataProcessorDelegate <NSObject>

- (void)timeSeriesDataProcessorDidUpdate:(MSPATimeSeriesDataProcessor *)processor;

@end

@interface MSPATimeSeriesDataProcessor : NSObject

- (instancetype)initWithSettings:(MSPATimeSeriesDataProcessorSettings *_Nullable)settings;

@property (nonatomic, strong) MSPATimeSeriesDataProcessorSettings *settings;
@property (nonatomic, strong, readonly) NSArray<MSPATimeSeriesEntry *> *processedData;
@property (nonatomic, strong, readonly) MSPATimeSeriesDataStatistics *statistics;

- (void)addDelegate:(id<MSPATimeSeriesDataProcessorDelegate>)delegate;
- (void)removeDelegate:(id<MSPATimeSeriesDataProcessorDelegate>)delegate;

- (void)addData:(NSArray<MSPATimeSeriesEntry *> *)data;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
