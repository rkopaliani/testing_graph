//
//  BAFunctions.m
//  MSP Anywhere Viewer
//
//  Created by Ricardo Nascimento.
//  Copyright © 2016 BeAnywhere. All rights reserved.
//

#import "BALogger.h"
#import "BAFunctions.h"
#import "BABase64.h"
#import "NSString+MSPAUtils.h"

#import <CommonCrypto/CommonDigest.h>
#import <IOKit/graphics/IOGraphicsLib.h>

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <mach/host_info.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <mach/processor_info.h>
#import <mach/task.h>
#import <mach/task_info.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <netinet/in.h>
#import <stdlib.h>
#import <sys/ioctl.h>
#import <sys/mount.h>
#import <sys/param.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <sys/types.h>
#import <sys/utsname.h>
#import <unistd.h>

#define IFCONF_BUFFERSIZE    4000
#define max(a,b) ((a) > (b) ? (a) : (b))


@implementation BAFunctions

+ (int)longFromLowPart:(short)lowPart highPart:(short)highPart {
    return (int)(((ushort)lowPart) | (uint)(highPart << 16));
}

+ (NSString *)xmlPlistForProgramWithPath:(NSString *)programPath {
    NSString *result = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict>	<key>Label</key>	<string>BALaunchAgent</string>	<key>ProgramArguments</key>	<array>		<string>%@</string>	</array>	<key>RunAtLoad</key>	<true/></dict></plist>", programPath];
    return result;
}

+ (NSMutableData *) encodeXOREncryption: (NSString *) password
{
    NSMutableData* encrypedPass = [[NSMutableData alloc] init];
    @try {
        const char *c = [password UTF8String];
        char array[] = {0x7D, 0x89, 0x52, 0x23, 0xD2, 0xBC, 0xDD, 0xEA, 0xA3, 0xB9, 0x1F};
        for (int x = 0; x <= [password length]; x++)
        {
            int divisor = 0;
            char originalChar = c[x];
            double times = (double)(x) / (double)(11 - 1);
            if (times > (int) times)
                divisor = (int) times;
            
            char finalChar = originalChar ^ array[x - (11 * divisor)];
            [encrypedPass appendBytes:&finalChar length:1];
        }
        
        int caracteresAMais = [encrypedPass length] % 12;
        if (caracteresAMais > 0)
        {
            char charA = 0x41;
            int caracteresEmFalta = 12 - caracteresAMais;
            for (int x = 0; x < caracteresEmFalta; x++)
            {
                [encrypedPass appendBytes:&charA length:1];
            }
        }
    }
    @catch (NSException *Ex) {
        BAINFO(@"BAFunctions::encodeXOREncryption Exception - %@", Ex.reason);
    }
    return encrypedPass;
}


#pragma mark NETWORK

+(NSString*) getStringFromBase64:(NSString*) base64string{
    NSString* stringValue = @"";
    @try {
        BABase64 *base64Decoder = [[BABase64 alloc] init];
        [base64Decoder setEncoding:NSWindowsCP1252StringEncoding];
        stringValue = [base64Decoder decodeBase64String:base64string];
    }
    @catch (NSException *exception) {
        BAINFO(@"Error: %@",exception.reason);
    }
    
    return stringValue;
}

#pragma mark String Utils


+ (NSString *) IntToHex: (int) value
{
    return [NSString stringWithFormat:@"0x%08x",( unsigned int) value];
}

+ (BOOL) ConvertToUnsignedChar: (NSString *) string andOutBuffer: (unsigned char **) outBuffer andSize: (int*) bufferSize
{
    @try {
        if([string hasContent])
        {
            NSData * stringData = [string dataUsingEncoding:NSASCIIStringEncoding];
            *outBuffer = (unsigned char *) malloc(stringData.length+1);
            memset(*outBuffer, 0x00, stringData.length+1);
            memcpy(*outBuffer, [stringData bytes], stringData.length);
            
            *bufferSize = (int) stringData.length;
        }
        else
            BAINFO(@"String is empty...");
    } @catch (NSException *exception) {
        BAINFO(@"Error: %@", exception.reason);
    }
}

+ (CGFloat)widthOfString:(NSString *)string {
    return [self widthOfString:string withFont:[NSFont fontWithName:@"Helvetica Neue" size:13]];
}
//----------------------------------------------------------
+ (CGFloat)widthOfString:(NSString *)string withFont: (NSFont*) font{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

// Same as printHex, but in C (appending NSStrings causes a leak)
void printPointer (char *inPointer, int start, int length) {
    inPointer += start;
    for (int x = 0; x < length; x++) {
        printf("%X", (unsigned char) (*inPointer++));
    }
    printf("\n");
}

#pragma mark MICROTIME
+ (uint64_t)microtime {
    struct timeval tv;
    gettimeofday(&tv,NULL);
    return tv.tv_sec*(uint64_t)1000000+tv.tv_usec;
}

@end
