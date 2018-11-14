//
//  NSMutableString+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/21/18.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (MSPAUtils)

- (void)safeAppendCSVString:(NSString *)string;
- (void)appendNewline;

@end
