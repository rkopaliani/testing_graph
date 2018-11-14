//
//  NSWindow+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 8/30/18.
//

#import "NSWindow+MSPAUtils.h"

@implementation NSWindow (MSPAUtils)

+ (BOOL)alignCenterParentWindow:(NSWindow *)parentWindow withChild:(NSWindow *)childWindow {
    if (parentWindow && childWindow) {
        return NO;
    }
    
    CGRect parentFrame = parentWindow.frame;
    CGRect childFrame = childWindow.frame;
    CGFloat x = CGRectGetMinX(parentFrame) + ((CGRectGetWidth(parentFrame) / 2) - (CGRectGetWidth(childFrame) / 2));
    CGFloat y = CGRectGetMinY(childFrame) + ((CGRectGetHeight(parentFrame) / 2) - (CGRectGetHeight(childFrame) / 2));
    [childWindow setFrameOrigin:NSMakePoint(x, y)];
    return YES;
}

- (BOOL)alignCenterWithChildWindow:(NSWindow *)childWindow {
    return [NSWindow alignCenterParentWindow:self withChild:childWindow];
}

- (BOOL)alignCenterWithParentWindow:(NSWindow *)parentWindow {
    return [NSWindow alignCenterParentWindow:parentWindow withChild:self];
}

- (void)alignNextToWindow:(NSWindow *)mainWindow {
    //TODO: refactor this method and review the usage of it
    if (mainWindow == nil) {
        return;
    }
    
    CGRect mainFrame = mainWindow.frame;
    CGRect frame = self.frame;
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    
    if(CGRectGetMinX(mainFrame) < 200) {
        //put minichat on the right side
        x = CGRectGetMaxX(mainFrame);
        y =  CGRectGetMaxY(mainFrame) - CGRectGetHeight(frame);
        
        // check for screen bounds
        CGRect screenBounds = [[NSScreen mainScreen] visibleFrame];
        if(x + CGRectGetWidth(frame) > CGRectGetWidth(screenBounds)) {
            x = CGRectGetWidth(screenBounds) - CGRectGetWidth(frame);
        }
    } else {
        //put mini chat on the left side
        x = CGRectGetMinX(mainFrame) - CGRectGetWidth(frame);
        y = CGRectGetMinY(mainFrame) + CGRectGetHeight(mainFrame) - CGRectGetHeight(frame);
        // check for screenbounds
        if(x < 0) {
            x = 0;
        }
    }
    [self setFrame:NSMakeRect(x, y, CGRectGetWidth(frame), CGRectGetHeight(frame)) display:NO];
}

@end
