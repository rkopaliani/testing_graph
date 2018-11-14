//
//  NSDateFormatter+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BALocalTimeDateFormat;

@interface NSDateFormatter (MSPAUtils)

+ (NSString *)nowLocalTimeString;
+ (NSDateFormatter *)localTimeDateFormatter;

@end

NS_ASSUME_NONNULL_END
