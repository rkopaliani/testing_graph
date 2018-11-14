//
//  MSPACredentialUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/3/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSPACredentialsUtils : NSObject

+ (NSString *)loggedUserName;

+ (BOOL)checkRootPassword:(NSString *)pass;
+ (BOOL)checkUserCredentialsWithUsernameInTerminal:(NSString *)username andPassword:(NSString *)password;
+ (BOOL)checkUserCredentialsWithUsername:(NSString *)username andPassword:(NSString *)password;
+ (BOOL)checkUserHasAdminPrivilegesWithUsername:(NSString *)username andPassword:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
