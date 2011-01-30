//
//  NSData_DigestExtensions.m
//  AnythingBucket
//
//  Created by Jonathan Wight on 10/22/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "NSData_DigestExtensions.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSData (NSData_DigestExtensions)

- (NSData *)MD5Digest
    {
    unsigned char theDigest[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self bytes], [self length], theDigest);
    return([NSData dataWithBytes:theDigest length:sizeof(theDigest)]);
    }

- (NSData *)SHA1Digest
    {
    unsigned char theDigest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([self bytes], [self length], theDigest);
    return([NSData dataWithBytes:theDigest length:sizeof(theDigest)]);
    }

@end
