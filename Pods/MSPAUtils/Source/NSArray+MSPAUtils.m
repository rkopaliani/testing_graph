//
//  NSArray+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/13/18.
//

#import "NSArray+MSPAUtils.h"

@implementation NSArray (MSPAUtils)

- (id)safeObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return nil;
    }
    
    return [self objectAtIndex:index];
}

@end
