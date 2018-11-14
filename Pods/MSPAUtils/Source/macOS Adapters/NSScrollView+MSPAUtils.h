//
//  NSScrollView+MSPAUtils.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

@import AppKit;

NS_ASSUME_NONNULL_BEGIN

@interface NSScrollView (MSPAUtils)

- (NSEdgeInsets)contentInset;
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
