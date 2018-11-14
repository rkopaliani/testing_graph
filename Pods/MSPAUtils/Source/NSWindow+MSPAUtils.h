//
//  NSWindow+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 8/30/18.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSWindow (MSPAUtils)

+ (BOOL)alignCenterParentWindow:(NSWindow *)parentWindow withChild:(NSWindow *)childWindow;
- (BOOL)alignCenterWithChildWindow:(NSWindow *)childWindow;
- (BOOL)alignCenterWithParentWindow:(NSWindow *)parentWindow;
- (void)alignNextToWindow:(NSWindow *)mainWindow;

@end

NS_ASSUME_NONNULL_END
