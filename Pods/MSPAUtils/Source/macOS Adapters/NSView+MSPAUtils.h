//
//  NSView+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

@import AppKit;

NS_ASSUME_NONNULL_BEGIN

@interface NSView (MSPAUtils)

- (void)setNeedsLayout;
- (void)setNeedsUpdateConstraints;

@end

NS_ASSUME_NONNULL_END
