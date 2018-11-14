//
//  MSPAPlatform.h
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/4/18.
//

#import <Foundation/Foundation.h>


#if TARGET_OS_IOS
@import UIKit;

#import "MSPMView.h"
#import "UIBezierPath+MSPAUtils.h"
#import "MSPMScrollView.h"

typedef UIBezierPath MSPBezierPath;
typedef MSPMScrollView MSPScrollView;
typedef MSPMView MSPView;
typedef MSPMShapeView MSPShapeView;
typedef UIFont MSPFont;
typedef UIColor MSPColor;
typedef CGRect MSPRect;
typedef CGPoint MSPPoint;
typedef CGSize MSPSize;
typedef NSLayoutConstraint MSPALayoutConstraint;

#else
@import AppKit;

#import "NSScrollView+MSPAUtils.h"
#import "NSBezierPath+MSPAUtils.h"
#import "MSPDView.h"

typedef NSBezierPath MSPBezierPath;
typedef NSScrollView MSPScrollView;
typedef MSPDTView MSPView;
typedef MSPDTShapeView MSPShapeView;
typedef NSFont MSPFont;
typedef NSColor MSPColor;
typedef NSRect MSPRect;
typedef NSPoint MSPPoint;
typedef NSSize MSPSize;
typedef NSLayoutConstraint MSPALayoutConstraint;

#if defined(AVAILABLE_MAC_OS_X_VERSION_10_10_AND_LATER)
typedef NS_ENUM(NSUInteger, MSPADateComponent) {
    MSPADateComponentYear = NSCalendarUnitYear,
    MSPADateComponentMonth = NSCalendarUnitMonth,
    MSPADateComponentDay = NSCalendarUnitDay,
};
#else
typedef NS_ENUM(NSUInteger, MSPADateComponent) {
    MSPADateComponentYear = NSYearCalendarUnit,
    MSPADateComponentMonth = NSMonthCalendarUnit,
    MSPADateComponentDay = NSDayCalendarUnit,
};
#endif


#endif
