//
//  MSPANetworkUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/3/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSPANetworkUtils : NSObject

+ (NSString *)macAddress;
+ (NSString *)IPAddress;
+ (NSDictionary *)IPAddressesMap;

//getBroadcastAddress
+ (NSString *)broadcastAddress;

//SessionCipherToString
+ (NSString *)cipherString:(unsigned int)cipher;

@end

NS_ASSUME_NONNULL_END
