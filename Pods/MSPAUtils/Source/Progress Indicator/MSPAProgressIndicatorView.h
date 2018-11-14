//
//  MSPAProgressIndicatorView.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 11/6/18.
//

#import "MSPAPlatform.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSPAProgressIndicatorView : MSPView

@property (nonatomic, assign, readonly) BOOL isAnimating;

@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) MSPColor *spinnerColor;
@property (nonatomic, strong) MSPColor *spinnerBackgroundColor;

- (void)startAnimation;
- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
