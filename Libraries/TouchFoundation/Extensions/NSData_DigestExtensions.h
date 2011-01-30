//
//  NSData_DigestExtensions.h
//  AnythingBucket
//
//  Created by Jonathan Wight on 10/22/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSData_DigestExtensions)

- (NSData *)MD5Digest;
- (NSData *)SHA1Digest;

@end
