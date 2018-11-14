//
//  NSImage+MSPAUtils.m
//  MSPAUtils
//
//  Created by Roman Kopaliani on 9/3/18.
//

#import "NSImage+MSPAUtils.h"

@implementation NSImage (MSPAUtils)

- (NSImage *)imageTintedWithColor:(NSColor *)color {
    NSImage *copiedImage = self.copy;
    if (copiedImage == nil) {
        return nil;
    }
    [copiedImage lockFocus];
    [color set];
    NSRect imageRect = NSMakeRect(0.f, 0.f, copiedImage.size.width, copiedImage.size.height);
    NSRectFillUsingOperation(imageRect, NSCompositingOperationSourceAtop);
    [copiedImage unlockFocus];
    return copiedImage;
}

+ (NSImage *)flipImageVertically:(NSImage *)image {
    NSAffineTransform *flipper = [NSAffineTransform transform];
    [flipper scaleXBy:1.0 yBy:-1.0];
    [flipper set];
    [image drawAtPoint:NSMakePoint(0,-image.size.height)
              fromRect:NSMakeRect(0,0, image.size.width, image.size.height)
             operation:NSCompositingOperationCopy fraction:1.0];
    return image;
}

+ (NSImage *)flipImageHorizontally:(NSImage *)image {
    NSAffineTransform *flipper = [NSAffineTransform transform];
    [flipper scaleXBy:-1.0 yBy:1.0];
    [flipper set];
    [image drawAtPoint:NSMakePoint(-image.size.width,0)
              fromRect:NSMakeRect(0,0, image.size.width, image.size.height)
             operation:NSCompositingOperationCopy fraction:1.0];
    return image;
}

@end
