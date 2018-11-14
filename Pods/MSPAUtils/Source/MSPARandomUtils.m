//
//  MSPARandomUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import "MSPARandomUtils.h"
#import "BALogger.h"

@implementation MSPARandomUtils

+ (unsigned int) randomPositiveInt {
    int min = 0;
    int max = INT_MAX;
    int range = max - min;
    if (range == 0) return min;
    return (arc4random() % range) + min;
}

+ (NSString *)randomStringOfLength:(unsigned int)length {
    @try {
        NSString *ChTbl = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        
        NSMutableString *Value = [[NSMutableString alloc] initWithString:@""];
        unsigned int i;
        
        for (i=0 ; i < length ; i++) {
            
            NSString *rndChar = [ChTbl substringWithRange: NSMakeRange((arc4random() % [ChTbl length]), 1)];
            [Value appendString: rndChar];
            
        }
        
        return(Value);
        
    }
    @catch (NSException *exception) {
        BAINFO(@"BAAppDelegate::GenRandomString Exception - %@", exception.reason);
    }
    return @"";
}

+ (BOOL)generateRandomBuffer:(unsigned char*)buffer withLength:(unsigned int)length {
    BOOL bResult = NO;
    @try {
        if(buffer != NULL)
        {
            for(int i = 0; i < length; i++)
            {
                buffer[i] = arc4random_uniform(10000);
            }
            bResult = YES;
        }
    } @catch (NSException *exception) {
        BAINFO(@"Error: %@", exception.reason);
    }
    return bResult;
}

@end
