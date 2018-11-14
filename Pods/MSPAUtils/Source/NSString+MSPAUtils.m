//
//  NSString+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 8/30/18.
//

#import "NSString+MSPAUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MSPAUtils)

- (BOOL)hasContent {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0;
}

- (BOOL)containsSubstring:(NSString *)substring {
    if (substring.length == 0) {
        return YES;
    }
    
    if (@available(macOS 10.10, *)) {
        return [self containsString:substring];
    } else {
        return [self rangeOfString:substring].location != NSNotFound;
    }
}

- (NSString *)ASCIIVersion {
    NSData *asciiEncoded = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    return [[[NSString alloc] initWithData:asciiEncoded encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"?" withString:@" "];
}

- (NSString *)stringByRemovingSubstring:(NSString *)substring withOptions:(MSPAStringEnd)endOptions {
    if (substring.length == 0) {
        return self;
    }
    
    NSMutableString *mutable = self.mutableCopy;
    NSUInteger substringLength = substring.length;
    if (endOptions | MSPAStringEndLeading) {
        BOOL hasPrefix = YES;
        while (hasPrefix) {
            if (mutable.length < substringLength) {
                hasPrefix = NO;
                break;
            }
            NSRange proposedRange = NSMakeRange(0, substringLength);
            NSString *rangedString = [mutable substringWithRange:proposedRange];
            if ([rangedString isEqualToString:substring]) {
                [mutable deleteCharactersInRange:proposedRange];
            } else {
                hasPrefix = NO;
            }
        }
    }
    
    if (endOptions | MSPAStringEndLeading) {
        BOOL hasSuffix = YES;
        while (hasSuffix) {
            if (mutable.length < substringLength) {
                hasSuffix = NO;
                break;
            }
            NSRange proposedRange = NSMakeRange(mutable.length - substringLength, substringLength);
            NSString *rangedString = [mutable substringWithRange:proposedRange];
            if ([rangedString isEqualToString:substring]) {
                [mutable deleteCharactersInRange:proposedRange];
            } else {
                hasSuffix = NO;
            }
        }
    }
    
    return mutable.copy;
}

- (unsigned char *)unsignedCharString {
    return (unsigned char *)self.UTF8String;
}

#pragma mark - XML Escape
- (NSString *)xmlSimpleUnescape {
    //refactor it: use NSScanner or ready-made solutions
    if (self.length == 0) {
        return self;
    }
    
    NSMutableString *string = self.mutableCopy;
    [string replaceOccurrencesOfString:@"&amp;"  withString:@"&"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#x27;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#x39;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#x92;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#x96;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&gt;"   withString:@">"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&lt;"   withString:@"<"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    
    return string;
}

- (NSString *)xmlSimpleEscape {
    //refactor it: use NSScanner or ready-made solutions
    if (self.length == 0) {
        return self;
    }
    
    NSMutableString *string = self.mutableCopy;
    [string replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"'"  withString:@"&#x27;" options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    return string;
}

- (NSString *)md5HexDigest {
    const char *str = [self cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (unsigned int) strlen(str), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity: CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0 ; i < CC_MD5_DIGEST_LENGTH ; i++) {
        [ret appendFormat:@"%02X", result[i]];
    }
    
    return ret;
}

@end
