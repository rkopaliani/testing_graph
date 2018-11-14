//
//  NSArray+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/13/18.
//

#import <Foundation/Foundation.h>

@interface NSArray<__covariant ObjectType> (MSPAUtils)

- (nullable ObjectType)safeObjectAtIndex:(NSUInteger)index;

@end
