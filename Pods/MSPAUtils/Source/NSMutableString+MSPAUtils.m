//
//  NSMutableString+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/21/18.
//

#import "NSMutableString+MSPAUtils.h"
#import "NSString+MSPAUtils.h"

@implementation NSMutableString (MSPAUtils)

- (void)safeAppendCSVString:(NSString *)string {
    if ([string hasContent] == NO) {
        return;
    }
    [self appendString:string];
    [self appendString:@", "];
}

- (void)appendNewline {
    [self appendString:@"\n"];
}

@end
