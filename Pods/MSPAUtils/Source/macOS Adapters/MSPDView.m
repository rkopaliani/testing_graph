//
//  MSPDView.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

#import "MSPDView.h"

@import QuartzCore.CAShapeLayer;

@implementation MSPDTBaseView

- (void)layout {
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layout];
}

@end


@implementation MSPDTView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.wantsLayer = YES;
    }
    return self;
}

- (CALayer *)backingLayer {
    return self.layer;
}

@end


@implementation MSPDTShapeView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer = [CAShapeLayer new];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.layer = [CAShapeLayer new];
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

@end
