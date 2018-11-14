//
//  MSPDView.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

#import <Cocoa/Cocoa.h>
#import "NSView+MSPAUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSPDTBaseView: NSView

- (void)layoutSubviews;

@end


@interface MSPDTView: MSPDTBaseView

- (CALayer *)backingLayer;

@end


@interface MSPDTShapeView: MSPDTBaseView

@end

NS_ASSUME_NONNULL_END
