//
//  MSPAVersionUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import "MSPAVersionUtils.h"

@implementation MSPAVersionUtils

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

+ (NSString *)OSVersion{
    NSProcessInfo *info = [NSProcessInfo processInfo];
    if (@available(macOS 10.10, *)) {
        NSOperatingSystemVersion version = [info operatingSystemVersion];
        return [NSString stringWithFormat:@"%li.%li.%li", version.majorVersion, version.minorVersion, version.patchVersion];
    } else {
        SInt32 major, minor, bugfix;
        Gestalt(gestaltSystemVersionMajor, &major);
        Gestalt(gestaltSystemVersionMinor, &minor);
        Gestalt(gestaltSystemVersionBugFix, &bugfix);
        return [NSString stringWithFormat:@"%d.%d.%d B %d", major, minor, bugfix,bugfix];
    }
}

// win <nome do os> <major version>.<minor version> B <build number> SP <service pack major version>.<service pack minor version> | <role> | <edition>
+ (NSString *)mspxVersion {
    NSProcessInfo *info = [NSProcessInfo processInfo];
    if (@available(macOS 10.10, *)) {
        NSOperatingSystemVersion runningVersion = [info operatingSystemVersion];
        return [NSString stringWithFormat:@"mac MacOS %ld.%ld.%ld B %ld",runningVersion.majorVersion, runningVersion.minorVersion,runningVersion.patchVersion, runningVersion.patchVersion];
    } else {
        SInt32 major, minor, bugfix;
        Gestalt(gestaltSystemVersionMajor, &major);
        Gestalt(gestaltSystemVersionMinor, &minor);
        Gestalt(gestaltSystemVersionBugFix, &bugfix);
        return [NSString stringWithFormat:@"mac MacOS %d.%d.%d B %d", major, minor, bugfix,bugfix];
    }
    return @"";
}

#pragma GCC diagnostic pop

@end
