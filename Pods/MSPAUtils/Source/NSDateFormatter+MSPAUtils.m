//
//  NSDateFormatter+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import "NSDateFormatter+MSPAUtils.h"

NSString *const BALocalTimeDateFormat = @"yyyyMMddHHmmss";

@implementation NSDateFormatter (MSPAUtils)

+ (NSString *)nowLocalTimeString {
    NSDateFormatter *dateFormatter = [self localTimeDateFormatter];
    return [dateFormatter stringFromDate:[NSDate date]];
}

static NSDateFormatter *baDateFormatter = nil;
+ (NSDateFormatter *)localTimeDateFormatter {
    if (baDateFormatter == nil) {
        baDateFormatter = [NSDateFormatter new];
        baDateFormatter.dateFormat = BALocalTimeDateFormat;
    }
    return baDateFormatter;
}

@end
