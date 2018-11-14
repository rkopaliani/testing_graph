//
//  NSBundle+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 8/30/18.
//

#import "NSBundle+MSPAUtils.h"

@implementation NSBundle (MSPAUtils)

- (NSString *)applicationVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

@end
