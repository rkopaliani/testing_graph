//
//  BABase64.h
//  BeAnywhere Support Express
//
//  Created by Joao Gonçalves on 11/2/12.
//  Edited by Ricardo Nascimento on 16/12/15
//  Copyright (c) 2012 BeAnywhere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BABase64 : NSObject {
    
    
    int strEncoding;
    
    unsigned char decodingTable[256];
    bool decodingTableInitialized;
    
}

+(NSUInteger) encodedBase64Size: (NSUInteger) unEncodedSize;

-(id) init;
-(void) setEncoding: (int) newEncoding;
-(void) initDecodingTable;
-(NSString *) encodeBase64: (char *) data dataLen:(NSUInteger) aDataLen;
-(NSString *) encodeBase64: (NSData *) data;
-(NSData *) decodeBase64: (NSString *) b64EncString;
-(NSString *) decodeBase64String: (NSString *) b64EncString;
-(NSString *) encodeBase64_Ptr: (unsigned char *) data andSize: (int) size;

-(unsigned char *) encodeBase64Char: (char *) data dataLen:(NSUInteger) aDataLen;
@end
