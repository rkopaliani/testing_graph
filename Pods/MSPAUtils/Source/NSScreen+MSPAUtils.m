//
//  NSScreen+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import "NSScreen+MSPAUtils.h"

@implementation NSScreen (MSPAUtils)

+ (NSUInteger)screensCount {
    return [NSScreen screens].count;
}

- (NSString *)screenName {
    NSDictionary *screenDictionary = [self deviceDescription];
    NSNumber *screenID = [screenDictionary objectForKey:@"NSScreenNumber"];
    return [NSScreen screenNameForDisplay:screenID];
}

+ (NSString *)screenNameForDisplay:(NSNumber *)screenId {
    CGDirectDisplayID displayID = [screenId unsignedIntValue];
    
    io_service_t serv = [self IOServicePortFromCGDisplayID:displayID];
    if (serv == 0) {
        return nil;
    }
    
    CFDictionaryRef info = IODisplayCreateInfoDictionary(serv, kIODisplayOnlyPreferredName);
    IOObjectRelease(serv);
    
    CFStringRef display_name;
    CFDictionaryRef names = CFDictionaryGetValue(info, CFSTR(kDisplayProductName));
    
    if (names == NO
        || CFDictionaryGetValueIfPresent(names, CFSTR("en_US"), (const void**) & display_name) == NO) {
        // This may happen if a desktop Mac is running headless
        CFRelease( info );
        return nil;
    }
    
    NSString * displayname = [NSString stringWithString: (__bridge NSString *) display_name];
    CFRelease(info);
    return displayname;
}

+ (io_service_t)IOServicePortFromCGDisplayID:(CGDirectDisplayID)displayID {
    io_iterator_t iter;
    io_service_t serv, servicePort = 0;
    
    CFMutableDictionaryRef matching = IOServiceMatching("IODisplayConnect");
    // releases matching for us
    kern_return_t err = IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &iter);
    if (err) {
        return 0;
    }
    
    while ((serv = IOIteratorNext(iter)) != 0) {
        CFDictionaryRef displayInfo;
        CFNumberRef vendorIDRef;
        CFNumberRef productIDRef;
        CFNumberRef serialNumberRef;
        
        displayInfo = IODisplayCreateInfoDictionary(serv, kIODisplayOnlyPreferredName);
        
        Boolean success;
        success =  CFDictionaryGetValueIfPresent(displayInfo, CFSTR(kDisplayVendorID), (const void**) &vendorIDRef);
        success &= CFDictionaryGetValueIfPresent(displayInfo, CFSTR(kDisplayProductID), (const void**) &productIDRef);
        
        if (success == NO) {
            CFRelease(displayInfo);
            continue;
        }
        
        SInt32 vendorID;
        CFNumberGetValue(vendorIDRef, kCFNumberSInt32Type, &vendorID);
        SInt32 productID;
        CFNumberGetValue(productIDRef, kCFNumberSInt32Type, &productID);
        
        // If a serial number is found, use it.
        // Otherwise serial number will be nil (= 0) which will match with the output of 'CGDisplaySerialNumber'
        SInt32 serialNumber = 0;
        if (CFDictionaryGetValueIfPresent(displayInfo, CFSTR(kDisplaySerialNumber), (const void**) &serialNumberRef)) {
            CFNumberGetValue( serialNumberRef, kCFNumberSInt32Type, &serialNumber );
        }
        
        // If the vendor and product id along with the serial don't match
        // then we are not looking at the correct monitor.
        // NOTE: The serial number is important in cases where two monitors
        //       are the exact same.
        if(CGDisplayVendorNumber(displayID) != vendorID ||
           CGDisplayModelNumber(displayID) != productID ||
           CGDisplaySerialNumber(displayID) != serialNumber) {
            CFRelease(displayInfo);
            continue;
        }
        
        servicePort = serv;
        CFRelease(displayInfo);
        break;
    }
    
    IOObjectRelease(iter);
    return servicePort;
}

@end
