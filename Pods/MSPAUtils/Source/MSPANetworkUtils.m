//
//  MSPANetworkUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/3/18.
//

#import "MSPANetworkUtils.h"
#import "BALogger.h"

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

@implementation MSPANetworkUtils

+ (NSString *)macAddress {
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    if (errorFlag != NULL)
    {
        BAINFO(@"BAAppDelegate::getMacAddress Exception - %@", errorFlag);
        return errorFlag;
    }
    
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    
    free(msgBuffer);
    
    return macAddressString;
}

+ (NSDictionary *)IPAddressesMap {
    
    NSMutableDictionary *ip_addrs = [NSMutableDictionary dictionary];
    
    char buffer[IFCONF_BUFFERSIZE];
    char *ptr = buffer;
    struct ifconf ifc = { IFCONF_BUFFERSIZE, { buffer } };
    
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd == -1) {
        return ip_addrs;
    }
    
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0) {
        return ip_addrs;
    }
    
    while (ptr < buffer + ifc.ifc_len) {
        
        struct ifreq *ifr = (struct ifreq *)ptr;
        struct sockaddr_in *sin = (struct sockaddr_in *)&ifr->ifr_addr;
        
        NSString *ipaddr = [NSString stringWithCString: inet_ntoa (sin->sin_addr) encoding: NSASCIIStringEncoding];
        char *cptr;
        
        ptr += sizeof(ifr->ifr_name) + max(sizeof(struct sockaddr),
                                           ifr->ifr_addr.sa_len);
        
        if (ifr->ifr_addr.sa_family != AF_INET) {
            continue;
        }
        
        if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL) {
            *cptr = 0;
        }
        
        ioctl(sockfd, SIOCGIFFLAGS, ifr);
        if ((ifr->ifr_flags & IFF_UP) == 0) {
            continue;
        }
        
        [ip_addrs setObject:ipaddr forKey: [NSString stringWithCString: ifr->ifr_name encoding: NSASCIIStringEncoding]];
        
    }
    
    close(sockfd);
    
    return ip_addrs;
    
}

+ (NSString *)IPAddress {
    
    @try{
        
        NSString *address = @"error";
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr = NULL;
        int success = 0;
        success = getifaddrs(&interfaces);
        if (success == 0) {
            temp_addr = interfaces;
            while(temp_addr != NULL) {
                if(temp_addr->ifa_addr->sa_family == AF_INET) {
                    if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                        address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                        
                    }
                }
                
                temp_addr = temp_addr->ifa_next;
            }
        }
        // Free memory
        freeifaddrs(interfaces);
        return address;
    }
    
    @catch (NSException *exception) {
        BAINFO(@"BAAppDelegate::getIPAddress Exception - %@", exception.reason);
    }
}

+ (long long) IpAddrToIPNumber: (NSString *) __ip {
    
    @try {
        NSArray * ipParts = [__ip componentsSeparatedByString:@"."];
        
        if(ipParts.count == 4) {
            
            return([[ipParts objectAtIndex:0] intValue] * 256 * 256 * 256 + [[ipParts objectAtIndex:1] intValue]  * 256 * 256 + [[ipParts objectAtIndex:2] intValue]  * 256 + [[ipParts objectAtIndex:3] intValue]);
            
        } else {
            return -2;
        }
    } @catch (NSException *exception) {
        
    }
    
    return -1;
}

+ (NSString *)broadcastAddress {
    NSString *broadcastAddress = @"";
    
    @try {
        struct ifaddrs *interfaces = NULL;
        int result = getifaddrs(&interfaces);
        if(result == 0) {
            // loop through interfaces
            struct ifaddrs * tempInterfaces = interfaces;
            while (tempInterfaces != NULL){
                if(tempInterfaces->ifa_addr->sa_family == AF_INET) {
                    //look for interface en0 (usually it's the one connected)
                    if([[NSString stringWithUTF8String:tempInterfaces->ifa_name] isEqualToString:@"en0"]) {
                        broadcastAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)tempInterfaces ->ifa_dstaddr)->sin_addr)];
                        break;
                    }
                }
                
                // move to next one
                tempInterfaces = tempInterfaces -> ifa_next;
            }
        } else {
            BAINFO(@"Unable to get interfaces info...");
        }
        
        // free pointer
        if(interfaces != NULL) {
            freeifaddrs(interfaces);
        }
        
    } @catch (NSException *exception) {
        BAINFO(@"Exception: %@", exception.reason);
    }
    return broadcastAddress;
}

#define AES128  1
#define AES192  2
#define AES256  3
#define RC4     4

+ (NSString *)cipherString:(unsigned int)cipher {
    if(cipher == AES256) {
        return @"AES-256";
    } else if(cipher == AES192) {
        return @"AES-192";
    } else if(cipher == AES128) {
        return @"AES-128";
    }
    return @"Secure";
}

@end
