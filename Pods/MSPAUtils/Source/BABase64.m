//
//  BABase64.m
//  BeAnywhere Support Express
//
//  Created by Joao Gonçalves on 11/2/12.
//  Edited by Ricardo Nascimento on 16/12/15
//  Copyright (c) 2012 BeAnywhere. All rights reserved.
//

#import "BABase64.h"
#import "BALogger.h"

@implementation BABase64

#define BASE64_ENDTEXT        255
#define BASE64_IGNORE         254

const char encodingTable[64] = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'};


//---------------------------------------------------------------------------
+(NSUInteger) encodedBase64Size: (NSUInteger) unEncodedSize {
    
    return((((unEncodedSize + 3) - (unEncodedSize % 3)) / 3) * 4);
    
}

//---------------------------------------------------------------------------
-(id) init {
    
    self = [super init];
    decodingTableInitialized = false;
    strEncoding = NSASCIIStringEncoding;
    [self initDecodingTable];
    return self;
    
}

-(void) setEncoding: (int) newEncoding {
    
    strEncoding = newEncoding;
}

//---------------------------------------------------------------------------
-(void) initDecodingTable {
    
    unsigned char ch;
    
    if (!decodingTableInitialized) {
        
        for (ch = 0 ; ch < 255 ; ch++) {
            
            if ((ch >= 'A') && (ch <= 'Z'))
                decodingTable[ch] = ch - 'A';
            else if ((ch >= 'a') && (ch <= 'z'))
                decodingTable[ch] = ch - 'a' + 26;
            else if ((ch >= '0') && (ch <= '9'))
                decodingTable[ch] = ch - '0' + 52;
            else if (ch == '+')
                decodingTable[ch] = 62;
            else if (ch == '-' || ch == '=')
                decodingTable[ch] = BASE64_ENDTEXT;
            else if (ch == '/')
                decodingTable[ch] = 63;
            else
                decodingTable[ch] = BASE64_IGNORE;
        }
        
        decodingTableInitialized = true;
        
    }
    
}

#define min(a, b) ((a) < (b) ? (a) : (b))

//---------------------------------------------------------------------------
-(NSString *) encodeBase64: (char *) data dataLen:(NSUInteger) aDataLen {
    
    NSUInteger i;
    NSUInteger scopy;
    NSUInteger outcopy;
    NSUInteger pos;
    char inbuf[3];
    char outbuf[4];
    NSMutableString *OutStr = [NSMutableString stringWithString:@""];
    char *OutStrBuf;
    NSUInteger OutStrBufPos = 0;
    NSUInteger ExpectedEncodedSize;
    
    ExpectedEncodedSize = (((aDataLen + 3) - (aDataLen % 3)) / 3) * 4;
    OutStrBuf = (char *) calloc(ExpectedEncodedSize + 1, 1);
    
    if (OutStrBuf != NULL) {
        
        @try {
            
            if (aDataLen > 0) {
                
                scopy = min(3, aDataLen);
                pos = 0;
                
                while (pos < aDataLen) {
                    
                    // Delete
                    inbuf[0]=0;
                    inbuf[1]=0;
                    inbuf[2]=0;
                    
                    // Copy
                    for (i=0 ; i<scopy ; i++) {
                        inbuf[i] = data[pos+i];
                    }
                    
                    outbuf [0] = (inbuf [0] & 0xFC) >> 2;
                    outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
                    outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
                    outbuf [3] = inbuf [2] & 0x3F;
                    
                    outcopy = 4;
                    switch (scopy) {
                        case 1:
                            outcopy = 2;
                            break;
                        case 2:
                            outcopy = 3;
                            break;
                    }
                    
                    for (i = 0; i<outcopy ; i++) {
                        OutStrBuf[OutStrBufPos++] = encodingTable[outbuf[i]];
                    }
                    
                    /* Stuff */
                    for (i = outcopy ; i<4 ; i++) {
                        OutStrBuf[OutStrBufPos++] = '-';
                    }
                    
                    pos += scopy;
                    scopy = min(3, aDataLen - pos);
                    
                }
                
                OutStrBuf[OutStrBufPos++] = '\0';
                
                NSString *TempStr = [NSString stringWithCString: OutStrBuf encoding: strEncoding];
                [OutStr appendString:TempStr];
                
            } else {
                [OutStr appendString:@"---"];
            }
            
        }
        @finally {
            free(OutStrBuf);
        }
        
    } else {
        [OutStr appendString:@"---"];
    }
    
    if ((ExpectedEncodedSize - [OutStr length]) > 4) {
        BAINFO(@"Output size does not match expected encoded size...");
    }
    
    return OutStr;
    
}

-(unsigned char *) encodeBase64Char: (char *) data dataLen:(NSUInteger) aDataLen {
    
    NSUInteger i;
    NSUInteger scopy;
    NSUInteger outcopy;
    NSUInteger pos;
    char inbuf[3];
    char outbuf[4];
    NSMutableString *OutStr = [NSMutableString stringWithString:@""];
    char *OutStrBuf;
    NSUInteger OutStrBufPos = 0;
    NSUInteger ExpectedEncodedSize;
    
    ExpectedEncodedSize = (((aDataLen + 3) - (aDataLen % 3)) / 3) * 4;
    OutStrBuf = (char *) calloc(ExpectedEncodedSize + 1, 1);
    
    if (OutStrBuf != NULL) {
        
        @try {
            
            if (aDataLen > 0) {
                
                scopy = min(3, aDataLen);
                pos = 0;
                
                while (pos < aDataLen) {
                    
                    // Delete
                    inbuf[0]=0;
                    inbuf[1]=0;
                    inbuf[2]=0;
                    
                    // Copy
                    for (i=0 ; i<scopy ; i++) {
                        inbuf[i] = data[pos+i];
                    }
                    
                    outbuf [0] = (inbuf [0] & 0xFC) >> 2;
                    outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
                    outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
                    outbuf [3] = inbuf [2] & 0x3F;
                    
                    outcopy = 4;
                    switch (scopy) {
                        case 1:
                            outcopy = 2;
                            break;
                        case 2:
                            outcopy = 3;
                            break;
                    }
                    
                    for (i = 0; i<outcopy ; i++) {
                        OutStrBuf[OutStrBufPos++] = encodingTable[outbuf[i]];
                    }
                    
                    /* Stuff */
                    for (i = outcopy ; i<4 ; i++) {
                        OutStrBuf[OutStrBufPos++] = '-';
                    }
                    
                    pos += scopy;
                    scopy = min(3, aDataLen - pos);
                    
                }
                
                OutStrBuf[OutStrBufPos++] = '\0';
                
//                NSString *TempStr = [NSString stringWithCString: OutStrBuf encoding: strEncoding];
//                [OutStr appendString:TempStr];
                
            } else {
                [OutStr appendString:@"---"];
            }
            
        }
        @finally {
            free(OutStrBuf);
        }
        
    } else {
        [OutStr appendString:@"---"];
    }
    
    if ((ExpectedEncodedSize - [OutStr length]) > 4) {
        BAINFO(@"Output size does not match expected encoded size...");
    }
    
    return ((unsigned char*)OutStrBuf);
    
}

//---------------------------------------------------------------------------
-(NSString *) encodeBase64: (NSData *) data {
    
    return([self encodeBase64: ((char *)[data bytes]) dataLen:[data length]]);
    
}

-(NSString *) encodeBase64_Ptr: (unsigned char *) data andSize: (int) size{
    
    return([self encodeBase64: ((char *)data) dataLen:size]);
    
}

//---------------------------------------------------------------------------
-(NSData *) decodeBase64: (NSString *) b64EncString {
    
    unsigned char *InB64Str;
    unsigned char *OutStr;
    unsigned char ch;
    NSUInteger i, j;
    unsigned char inbuf[4];
    unsigned char outbuf[3];
    NSUInteger pinbuf;
    NSUInteger poutbuf;
    bool endloop;
    NSUInteger outcopy;
    NSUInteger Len;
    NSData *OutNSData = nil;
    
    poutbuf = 0;
    pinbuf = 0;
    i = 1;
    endloop = false;
    
    InB64Str = (unsigned char *) malloc([b64EncString length] + 1);
    OutStr = (unsigned char *) malloc([b64EncString length] + 1);
    
    @try {
        
        if ((InB64Str != NULL) && (OutStr != NULL)) {
            
            
            NSMutableString *encString = [NSMutableString stringWithString:b64EncString];
            Len = [encString length];
            memcpy(InB64Str, [encString cStringUsingEncoding:strEncoding ], [encString length]);
            
            while ((i <= Len) && !endloop) {
                
                ch = decodingTable[InB64Str[i-1]];
                
                if (ch != BASE64_IGNORE) {
                    outcopy = 3;
                    if (ch == BASE64_ENDTEXT) {
                        if (pinbuf == 0)
                            break;
                        if ((pinbuf == 1) || (pinbuf == 2))
                            outcopy = 1;
                        else
                            outcopy = 2;
                        pinbuf = 3;
                        endloop = true;
                    }
                    
                    inbuf[pinbuf]=ch;
                    pinbuf++;
                    if (pinbuf == 4) {
                        pinbuf = 0;
                        
                        outbuf [0] = (inbuf [0] << 2) | ((inbuf [1] & 0x30) >> 4);
                        outbuf [1] = ((inbuf [1] & 0x0F) << 4) | ((inbuf [2] & 0x3C) >> 2);
                        outbuf [2] = ((inbuf [2] & 0x03) << 6) | (inbuf [3] & 0x3F);
                        
                        for (j=0;j<outcopy;j++) {
                            OutStr[poutbuf++]=outbuf[j];
                        }
                    }
                }
                i++;
            }
            
        }
        
        OutStr[poutbuf]=0;
        
        OutNSData = [[NSData alloc] initWithBytes:OutStr length: poutbuf];
        
    }
    @finally {
        if (InB64Str != NULL) {
            free(InB64Str);
        }
        if (OutStr != NULL) {
            free(OutStr);
        }
    }
    
    return(OutNSData);
    
}

//---------------------------------------------------------------------------
-(NSString *) decodeBase64String: (NSString *) b64EncString {
    
    NSData *decodedData = [self decodeBase64:b64EncString];
    
    NSString *str = [[NSString alloc] initWithBytes:[decodedData bytes] length:[decodedData length] encoding:strEncoding];
    
    return(str);
    
}

@end
