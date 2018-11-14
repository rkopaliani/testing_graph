//
//  MSPARandomUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSPARandomUtils : NSObject

//GenRandomString
+ (NSString *)randomStringOfLength:(unsigned int)length;

//+(BOOL) GenerateRandom: (unsigned char*) buffer andBufferLength: (unsigned int) length;
+ (BOOL)generateRandomBuffer:(unsigned char*)buffer withLength:(unsigned int)length;

//GenFileMagicID
+ (unsigned int)randomPositiveInt;

@end

NS_ASSUME_NONNULL_END

