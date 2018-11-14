//
//  MSPAProgressIndicatorView.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

#import "MSPAProgressIndicatorView.h"

@import QuartzCore;


static CGFloat MSPAProgressIndicatorViewAnimationDuration = 1.5;
static CGFloat MSPAProgressIndicatorViewAnimationStrokeEnd = 0.8f;

static NSString *const MSPAProgressIndicatorViewAnimationKeyGroup = @"StrokeAnimation";
static NSString *const MSPAProgressIndicatorViewAnimationKeyStart = @"strokeStart";
static NSString *const MSPAProgressIndicatorViewAnimationKeyEnd = @"strokeEnd";


@interface MSPAProgressIndicatorView() <CAAnimationDelegate>

@property (nonatomic, assign, getter=isAnimating) BOOL animating;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) CAShapeLayer *strokeLayer;
@property (nonatomic, strong) CAAnimationGroup *strokeAnimationGroup;
@property (nonatomic, strong) CABasicAnimation *rotationAnimation;

- (void)setDefaultAnimationParameters;
- (void)configureAnimatedLayers;
- (void)resetAnimatedLayers;
- (void)didStopAnimation;

- (void)configureStrokeAnimationGroup:(CAAnimationGroup *)group;
- (CABasicAnimation *)strokeAnimationForKey:(NSString *)key;

@end


@implementation MSPAProgressIndicatorView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setDefaultAnimationParameters];
    }
    return self;
}

- (instancetype)initWithFrame:(MSPRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultAnimationParameters];
    }
    return self;
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    if (strokeWidth == _strokeWidth) {
        return;
    }
    _strokeWidth = strokeWidth;
    [self configureAnimatedLayers];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (cornerRadius == _cornerRadius) {
        return;
    }
    _cornerRadius = cornerRadius;
    [self configureAnimatedLayers];
}

- (void)setSpinnerColor:(MSPColor *)spinnerColor {
    if (spinnerColor == _spinnerColor) {
        return;
    }
    _spinnerColor = spinnerColor;
    [self configureAnimatedLayers];
}

- (void)setSpinnerBackgroundColor:(MSPColor *)spinnerBackgroundColor {
    if (spinnerBackgroundColor == _spinnerBackgroundColor) {
        return;
    }
    _spinnerBackgroundColor = spinnerBackgroundColor;
    [self configureAnimatedLayers];
}

- (void)startAnimation {
    if (self.isAnimating) {
        return;
    }
    [self.strokeLayer addAnimation:self.strokeAnimationGroup
                            forKey:MSPAProgressIndicatorViewAnimationKeyGroup];
    [self.backgroundLayer addAnimation:self.rotationAnimation
                                forKey:self.rotationAnimation.keyPath];
    self.animating = YES;
}

- (void)stopAnimation {
    if (self.isAnimating == NO) {
        return;
    }
    [self resetAnimatedLayers];
    self.animating = NO;
}

#pragma mark - Private

- (void)setDefaultAnimationParameters {
    _strokeWidth = - 1.f;
    _spinnerColor = [MSPColor orangeColor];
    _spinnerBackgroundColor = [MSPColor whiteColor];
    _cornerRadius = 5.f;
    
    self.backgroundLayer = [CAShapeLayer new];
}

- (void)resetAnimatedLayers {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.strokeLayer removeAllAnimations];
    [self.backgroundLayer removeAllAnimations];
    self.rotation = 0.f;
    self.strokeLayer.affineTransform = CGAffineTransformIdentity;
    [CATransaction commit];
}

- (void)configureAnimatedLayers {
    CGRect rect = self.bounds;
    if (CGRectIsEmpty(rect)) {
        return;
    }
    
    CALayer *layer = [self backingLayer];
    if (layer == nil) {
        return;
    }
    
    [self configureStrokeAnimationGroup:self.strokeAnimationGroup];
    
    layer.backgroundColor = self.spinnerBackgroundColor.CGColor;
    layer.cornerRadius = self.cornerRadius;
    
    [layer addSublayer:self.backgroundLayer];
    self.backgroundLayer.frame = rect;
    
    self.strokeLayer.frame = rect;
    self.strokeLayer.strokeColor = self.spinnerColor.CGColor;
    CGFloat strokeRadius = CGRectGetWidth(rect) / 2 * 0.75;
    self.strokeLayer.lineWidth = self.strokeWidth == -1 ? (strokeRadius / 5) : self.strokeWidth;
    
    MSPBezierPath *path = [MSPBezierPath bezierPath];
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    [path appendBezierPathWithArcWithCenter:center radius:strokeRadius startAngle:0 endAngle:360.f clockwise:false];
    self.strokeLayer.path = path.CGPath;
    [self.backgroundLayer addSublayer:self.strokeLayer];
}

- (void)configureStrokeAnimationGroup:(CAAnimationGroup *)group {
    CABasicAnimation *strokeEndAnimation = [self strokeAnimationForKey:MSPAProgressIndicatorViewAnimationKeyEnd];
    CABasicAnimation *strokeBeginAnimation = [self strokeAnimationForKey:MSPAProgressIndicatorViewAnimationKeyStart];
    strokeBeginAnimation.beginTime = MSPAProgressIndicatorViewAnimationDuration / 2;
    group.animations = @[strokeEndAnimation, strokeBeginAnimation];
    group.delegate = self;
}

- (CABasicAnimation *)strokeAnimationForKey:(NSString *)key {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
    animation.repeatCount = 1;
    animation.speed = 2.0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = @(0.f);
    animation.toValue = @(MSPAProgressIndicatorViewAnimationStrokeEnd);
    animation.duration = MSPAProgressIndicatorViewAnimationDuration;
    return animation;
}

- (void)didStopAnimation {
    if (self.isAnimating) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGFloat doublePI = M_PI * 2;
    self.rotation += MSPAProgressIndicatorViewAnimationStrokeEnd * doublePI;
    self.rotation = floorf(self.rotation/doublePI);
    self.strokeLayer.affineTransform = CGAffineTransformMakeRotation(self.rotation);
    [self.strokeLayer addAnimation:self.strokeAnimationGroup forKey:MSPAProgressIndicatorViewAnimationKeyGroup];
    [CATransaction commit];
}

#pragma mark Lazy Getters

- (CABasicAnimation *)rotationAnimation {
    if (_rotationAnimation) {
        return _rotationAnimation;
    }
    
    _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    _rotationAnimation.repeatCount = CGFLOAT_MAX;
    _rotationAnimation.fromValue = @(0);
    _rotationAnimation.toValue = @(1);
    _rotationAnimation.cumulative = YES;
    _rotationAnimation.removedOnCompletion = YES;
    _rotationAnimation.duration = MSPAProgressIndicatorViewAnimationDuration / 2;
    return _rotationAnimation;
}

- (CAShapeLayer *)strokeLayer {
    if (_strokeLayer) {
        return _strokeLayer;
    }
    
    _strokeLayer = [CAShapeLayer new];
    _strokeLayer.strokeEnd = MSPAProgressIndicatorViewAnimationStrokeEnd;
    _strokeLayer.lineCap = kCALineCapRound;
    _strokeLayer.fillColor = [MSPColor clearColor].CGColor;
    return _strokeLayer;
}

- (CAAnimationGroup *)strokeAnimationGroup {
    if (_strokeAnimationGroup) {
        return _strokeAnimationGroup;
    }
    
    _strokeAnimationGroup = [CAAnimationGroup new];
    _strokeAnimationGroup.repeatCount = 1;
    _strokeAnimationGroup.duration = MSPAProgressIndicatorViewAnimationDuration;
    _strokeAnimationGroup.removedOnCompletion = YES;
    return _strokeAnimationGroup;
}

#pragma mark - <CAAnimationDelegate>

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag == YES) {
        [self didStopAnimation];
    }
}

@end
