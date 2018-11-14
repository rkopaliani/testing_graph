//
//  MSPACredentialUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/3/18.
//

#import "MSPACredentialsUtils.h"
#import "BALogger.h"


@implementation MSPACredentialsUtils

+ (NSString *)loggedUserName {
    NSString *command = [NSString stringWithFormat:@"stat -f '%%Su' /dev/console"];
    
    NSArray *args = [NSArray arrayWithObjects:@"-c", command,nil];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:@"/"];
    [task setArguments:args];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    [task setStandardError: pipe];
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    if ([string length] > 0)
        string = [string substringToIndex:[string length] - 1];
    
    return string;
}

+ (BOOL)checkRootPassword:(NSString * )password {
    BOOL bresult = NO;
    
    @try {
        NSString* command;
        NSArray *args = [[NSArray alloc] init];
        
        command = [NSString stringWithFormat:@"dscl . -authonly root \"%@\"", password];
        args = [NSArray arrayWithObjects:@"-c", command, nil];
        
        NSTask *task01 = [[NSTask alloc] init];
        [task01 setLaunchPath:@"/bin/bash"];
        [task01 setArguments:args];
        
        NSPipe *pipe01 = [NSPipe pipe];
        [task01 setStandardOutput: pipe01];
        [task01 setStandardError: pipe01];
        NSFileHandle *file;
        file = [pipe01 fileHandleForReading];
        [task01 launch];
        NSData *data;
        data = [file readDataToEndOfFile];
        if ([data length] == 0)
            bresult = YES;
    }
    @catch (NSException *Ex) {
        BAINFO(@"BAFunctions::checkRootPassword Exception - %@", Ex.reason);
    }
    return bresult;
}

+ (BOOL)checkUserCredentialsWithUsernameInTerminal:(NSString *)username andPassword:(NSString *)password
{
    BOOL bresult = false;
    
    @try {
        
        NSString* command;
        NSArray *args = [[NSArray alloc] init];
        
        command = [NSString stringWithFormat:@"dscl . -authonly \"%@\" \"%@\"", username, password];
        args = [NSArray arrayWithObjects:@"-c", command, nil];
        
        NSTask *task01 = [[NSTask alloc] init];
        [task01 setLaunchPath:@"/bin/bash"];
        [task01 setArguments:args];
        
        NSPipe *pipe01 = [NSPipe pipe];
        [task01 setStandardOutput: pipe01];
        [task01 setStandardError: pipe01];
        NSFileHandle *file;
        file = [pipe01 fileHandleForReading];
        [task01 launch];
        NSData *data;
        data = [file readDataToEndOfFile];
        if ([data length] == 0)
            bresult = true;
    }
    @catch (NSException *Ex) {
        BAINFO(@"BAFunctions::checkUserCredentialsWithUsernameInTerminal Exception - %@", Ex.reason);
    }
    return bresult;
}


+ (BOOL)checkUserCredentialsWithUsername:(NSString *)username andPassword:(NSString *)password {
    
    BOOL bresult = false;
    
    @try {
        
        const char kAuthorizationRightName[] = "system.login.tty";
        
        AuthorizationItem right;
        right.name = kAuthorizationRightName;
        right.valueLength = 0;
        right.value = NULL;
        right.flags = 0;
        AuthorizationRights rights;
        rights.count = 1;
        rights.items = &right;
        
        AuthorizationItem environment_items[2];
        environment_items[0].name = kAuthorizationEnvironmentUsername;
        environment_items[0].valueLength = [username length];
        environment_items[0].value = (char *) [username cStringUsingEncoding:NSUTF8StringEncoding];
        environment_items[0].flags = 0;
        environment_items[1].name = kAuthorizationEnvironmentPassword;
        environment_items[1].valueLength = [password length];
        environment_items[1].value = (char *) [password cStringUsingEncoding:NSUTF8StringEncoding];
        environment_items[1].flags = 0;
        AuthorizationEnvironment environment;
        environment.count = 2;
        environment.items = environment_items;
        
        OSStatus status = AuthorizationCreate(&rights, &environment,
                                              kAuthorizationFlagExtendRights,
                                              NULL);
        
        if (status == 0)
            bresult = true;
        
    }
    @catch (NSException *Ex) {
        BAINFO(@"BAFunctions::checkUserCredentialsWithUsername Exception - %@", Ex.reason);
    }
    return bresult;
}

+ (BOOL)checkUserHasAdminPrivilegesWithUsername:(NSString *)username andPassword:(NSString *)password {
    BOOL bresult = NO;
    AuthorizationRef authorization;
    OSStatus status,status1;
    AuthorizationFlags flag;
    AuthorizationItem items[2];
    
    items[0].name = kAuthorizationEnvironmentPassword;
    items[0].value = (char *)[password cStringUsingEncoding:NSISOLatin1StringEncoding];
    items[0].valueLength = strlen([password cStringUsingEncoding:NSISOLatin1StringEncoding]);
    items[0].flags = 0;
    items[1].name = kAuthorizationEnvironmentUsername;
    items[1].value = (char *)[username cStringUsingEncoding:NSISOLatin1StringEncoding];
    items[1].valueLength = strlen([username cStringUsingEncoding:NSISOLatin1StringEncoding]);
    items[1].flags = 0;
    
    AuthorizationItemSet itemSet = {2,items};
    status = AuthorizationCreate(NULL, &itemSet, kAuthorizationFlagDefaults, &authorization);
    if(status == errAuthorizationSuccess) {
        AuthorizationRights rights = {2,items};
        AuthorizationEnvironment kEnviroment = {2, items};
        flag = kAuthorizationFlagDefaults | kAuthorizationFlagExtendRights ;
        status1 = AuthorizationCopyRights(authorization, &rights, &kEnviroment, flag, NULL);
        if(status1 == errAuthorizationSuccess)
            bresult = YES;
    }
    return bresult;
}

@end
