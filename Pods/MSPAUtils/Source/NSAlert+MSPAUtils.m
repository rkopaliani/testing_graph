//
//  NSAlert+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/3/18.
//

#import "NSAlert+MSPAUtils.h"

@implementation NSAlert (MSPAUtils)

+ (void)alertBox:(NSString *)message {
    NSAlert* msgBox = [[NSAlert alloc] init];
    [msgBox setMessageText: message];
    [msgBox addButtonWithTitle: @"OK"];
    [msgBox runModal];
}

+ (void)alertBoxNonModal: (NSString *) message withWindow:(NSWindow *)window {
    NSAlert* msgBox = [[NSAlert alloc] init];
    [msgBox setMessageText: message];
    [msgBox addButtonWithTitle: @"OK"];
    [msgBox beginSheetModalForWindow:window completionHandler:nil];
}

@end
