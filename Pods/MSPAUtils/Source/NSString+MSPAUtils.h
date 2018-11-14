//
//  NSString+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 8/30/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, MSPAStringEnd) {
    MSPAStringEndLeading = 1 << 0,
    MSPAStringEndTrailing = 1 << 1,
};

@interface NSString (MSPAUtils)

- (BOOL)hasContent;
- (BOOL)containsSubstring:(NSString *)substring;
- (NSString *)ASCIIVersion;

- (NSString *)stringByRemovingSubstring:(NSString *)substring withOptions:(MSPAStringEnd)endOptions;

- (NSString *)xmlSimpleUnescape;
- (NSString *)xmlSimpleEscape;

- (unsigned char *)unsignedCharString;

- (NSString *)md5HexDigest;

@end

NS_ASSUME_NONNULL_END
