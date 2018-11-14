//
//  BAFunctions.h
//  MSP Anywhere Viewer
//
//  Created by Ricardo Nascimento.
//  Copyright © 2016 BeAnywhere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BAFunctions : NSObject

//GetTickCount – [NSDate timeIntervalSinceReferenceDate]

//MakeLong
+ (int)longFromLowPart:(short)lowPart highPart:(short)highPart;


//getXmlPlistFileWithProgramPath
+ (NSString *)xmlPlistForProgramWithPath:(NSString *)programPath;

+ (NSMutableData *) encodeXOREncryption: (NSString *) password;

//Use: NSAlert+MSPAUtils
//+ (void) AlertBox: (NSString *) message;
//+ (void) AlertBoxNonModal: (NSString *) message withWindow: (NSWindow *) window;

//Use: NSString+MSPAUtils: ASCIIVersion
//+ (NSString *) convertToASCIIString: (NSString *) nonASCIIString;

//+ (NSArray *)getProcessInfo:(int)pid;
//+ (NSArray *)runningProcessesWithAllInfo;
//+ (NSArray *)runningProcessesWithProcessIDAndProcessNameAndProcessUserName;
//+ (NSArray *)runningProcessesWithProcessIDAndProcessName;

// NSString+MSPAUtils: stringByRemovingSubstring:withOptions:
//+ (NSString *) removeStringAtBegin: (NSString *) stringToDelete fromString: (NSString *) string;
//+ (NSString *) removeStringAtEnd: (NSString *) stringToDelete fromString: (NSString *) string;


// NSScreen+MSPAUtils:
//+ (NSString*) displayNameWithId: (CGDirectDisplayID) displayID;

//+ (NSString*) bytesStringFormat: (int64_t) bytes;
// NSImage+MSPAUtils
//+ (NSImage *) flipImageVertically:(NSImage *)image;
//+ (NSImage *) flipImageHorizontally:(NSImage *)image;
//+ (float) cpuUsageByPID: (int) pid;
//+ (bool) processIsRunning: (int) pid;

//Use NSAttributedString+MSPAUtils
//+ (NSMutableAttributedString *) getAttributedString:(NSAttributedString *) attributedString andColor:(NSColor *) color;

+(NSString*) getStringFromBase64:(NSString*) base64string;


//Use NSString+MSPAUtils: hasContent
//+ (BOOL) StringIsEmptyOrNull: (NSString *) string;

//+ (unsigned char*) ConvertNSStringToUnsignedChar: (NSString *) string;
// removed
//+ (NSString *) ConvertUnsignedCharToNSString: (unsigned char *) pChar;
//
//Use NSString+MSPAUtils: containsSubstring
//+(BOOL) ContainsString:(NSString*) MainString andSearchString:(NSString*) searchValue ;

+ (NSString *) IntToHex: (int) value;



+ (BOOL) ConvertToUnsignedChar: (NSString *) string andOutBuffer: (unsigned char **) outBuffer andSize: (int*) bufferSize;

//Use: NSBundle+MSPAUtils
//+ (NSString *) GetApplicationVersion;

//Use: NSString+MSPAUtils
//+(NSString*) md5HexDigest: (NSString *) input;

//Use: NSDateFormatter+MSPAUtils
//+(NSString*)GetNow;


+ (uint64_t)microtime;

void printPointer (char *inPointer, int start, int length);

+ (CGFloat)widthOfString:(NSString *)string;
+ (CGFloat)widthOfString:(NSString *)string withFont: (NSFont*) font;

// NSString+MSPAUtils
//+ (NSMutableString *)xmlSimpleUnescape:(NSMutableString *) string;
//+ (NSMutableString *)xmlSimpleEscape:(NSMutableString *) string;

// Use: NSWindow+MSPAUtils: alignNextToWindow
//+ (BOOL) CenterWindow: (NSWindow *) parentWindow withChild: (NSWindow *) childWindow;

@end

NS_ASSUME_NONNULL_END
