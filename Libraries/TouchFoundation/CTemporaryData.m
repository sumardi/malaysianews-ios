//
//  CTemporaryData.m
//  TouchCode
//
//  Created by Jonathan Wight on 10/21/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "CTemporaryData.h"

#include <unistd.h>

#import "CTemporaryFile.h"

@interface CTemporaryData ()
@property (readwrite, nonatomic, assign) size_t memoryLimit;
@property (readwrite, nonatomic, retain) id storage;

@property (readonly, nonatomic, retain) NSMutableData *dataStorage;

- (BOOL)convertDataToFile:(NSError **)outError;
@end

#pragma mark -

@implementation CTemporaryData

@synthesize memoryLimit;
@synthesize storage;

- (id)initWithMemoryLimit:(size_t)inDataLimit;
    {
    if ((self = [self init]) != NULL)
        {
        memoryLimit = inDataLimit;
        }
    return(self);
    }

- (void)dealloc
    {
    [storage release];
    storage = NULL;

    [super dealloc];
    }
    
#pragma mark -

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (type: %@, length: %d)", [super description], NSStringFromClass([self.storage class]), self.length]);
    }

- (NSMutableData *)dataStorage
    {
    NSAssert([self.storage isKindOfClass:[NSMutableData class]], @"storage is not of type NSMutableData");
    return(self.storage);
    }
    
- (CTemporaryFile *)tempFileStorage
    {
    NSAssert([self.storage isKindOfClass:[CTemporaryFile class]], @"storage is not of type CTempFile");
    return(self.storage);
    }

- (NSFileHandle *)fileStorage
    {
    return([self.tempFileStorage fileHandle]);
    }

- (NSData *)data
    {
    NSData *theData = NULL;
    if ([self.storage isKindOfClass:[NSData class]])
        {
        theData = self.dataStorage;
        }
    else if ([self.storage isKindOfClass:[CTemporaryFile class]])
        {
        [self.fileStorage synchronizeFile];
        NSError *theError = NULL;

        theData = [NSData dataWithContentsOfURL:self.tempFileStorage.URL options:NSMappedRead error:&theError];
        if (theData == NULL || theError != NULL)
            {
            NSLog(@"ERROR: %@", theError);
            }
        }
    else
        {
        NSAssert(NO, @"self.storage is not an accepted type.");
        }

    return(theData);
    }

- (NSURL *)URL
    {
    if ([self.storage isKindOfClass:[CTemporaryFile class]])
        {
        return(self.tempFileStorage.URL);
        }
    else
        {
        return(NULL);
        }
    }

- (size_t)length
    {
    if ([self.storage isKindOfClass:[NSData class]])
        {
        return([self.dataStorage length]);
        }
    else if ([self.storage isKindOfClass:[CTemporaryFile class]])
        {
        [self.fileStorage synchronizeFile];
        return([self.fileStorage offsetInFile]);
        }
    else
        {
        NSAssert(NO, @"self.storage is not an accepted type.");
        }

    return(0);
    }

#pragma mark -

- (BOOL)appendData:(NSData *)inData error:(NSError **)outError
    {
    if (self.storage == NULL)
        {
        self.storage = [[inData mutableCopy] retain];
        }
    else if ([self.storage isKindOfClass:[CTemporaryFile class]])
        {
        [self.fileStorage writeData:inData];
        }
    else if ([self.dataStorage length] + [inData length] > self.memoryLimit)
        {
        if ([self convertDataToFile:outError] == NO)
            {
            return(NO);
            }
        return([self appendData:inData error:outError]);
        }
    else if ([self.storage isKindOfClass:[NSMutableData class]])
        {
        [self.dataStorage appendData:inData];
        }
    else
        {
        NSAssert(NO, @"self.storage is not an accepted type.");
        }

    return(YES);
    }
    
- (BOOL)appendBytes:(void *)inBytes length:(NSUInteger)inLength error:(NSError **)outError;
    {
    if (self.storage == NULL)
        {
        self.storage = [NSMutableData dataWithBytes:inBytes length:inLength];
        }
    if ([self.storage isKindOfClass:[CTemporaryFile class]])
        {
        NSData *theData = [NSData dataWithBytesNoCopy:inBytes length:inLength freeWhenDone:NO];
        [self.fileStorage writeData:theData];
        }
    else if ([self.storage length] + inLength > self.memoryLimit)
        {
        if ([self convertDataToFile:outError] == NO)
            {
            return(NO);
            }
        return([self appendBytes:inBytes length:inLength error:outError]);
        }
    else if ([self.storage isKindOfClass:[NSMutableData class]])
        {
        [self.dataStorage appendBytes:inBytes length:inLength];
        }
    else
        {
        NSAssert(NO, @"self.storage is not an accepted type.");
        }

    return(YES);
    }

// TODO We need an accompanying API for this. This requests N bytes, but we need to handle when we request more bytes than we use.
//- (void *)bytesForWritingLength:(NSUInteger)inLength error:(NSError **)outError;
//    {
//    if (self.storage == NULL)
//        {
//        self.storage = [NSMutableData dataWithLength:inLength];
//        return([self.storage mutableBytes]);
//        }
//    else if ([self.storage isKindOfClass:[NSMutableData class]])
//        {
//        NSUInteger theOldLength = [self.storage length];
//        [self.storage setLength:theOldLength + inLength];
//        return((UInt8 *)[self.storage mutableBytes] + theOldLength);
//        }
//    else
//        {
//        if (outError)
//            {
//            }
//        return(NULL);
//        }
//    }
   
#pragma mark -
    
- (BOOL)convertDataToFile:(NSError **)outError
    {
    NSAssert([self.storage isKindOfClass:[CTemporaryFile class]] == NO, @"Incorrectly trying to convert a data to file.");
    
    CTemporaryFile *theTempFile = [[[CTemporaryFile alloc] init] autorelease];
    theTempFile.prefix = @"DATA_";
    theTempFile.suffix = @"_DATA";
    if (self.dataStorage)
        {
        [theTempFile.fileHandle writeData:self.dataStorage];
        }
    self.storage = theTempFile;
    return(YES);
    
    
    
//    NSString *theTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"XXXXXXXXXXXXXXXX.tmp"];
//    char thePathBuffer[strlen([theTemplate UTF8String]) + 1];
//    strncpy(thePathBuffer, [theTemplate UTF8String], strlen([theTemplate UTF8String]));
//    mkstemps(thePathBuffer, 4);
//    NSString *thePath = [NSString stringWithUTF8String:thePathBuffer];
//    self.tempFileURL = [NSURL fileURLWithPath:thePath];
//    NSError *theError = NULL;
//
//    // Create an empty file.
//    BOOL theResult = [[NSData data] writeToURL:self.tempFileURL options:0 error:&theError];
//    if (theResult == NO || theError != NULL)
//        {
//        NSLog(@"ERROR: %@", theError);
//        if (outError)
//            *outError = theError;
//        return(NO);
//        }
//
//    NSFileHandle *theFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.tempFileURL.path];
//    if (theFileHandle == NULL || theError != NULL)
//        {
//        NSLog(@"ERROR: %@", theError);
//        if (outError)
//            *outError = theError;
//        return(NO);
//        }
//
//    if (self.dataStorage)
//        [theFileHandle writeData:self.dataStorage];
//
//    self.storage = theFileHandle;
//    
//    return(YES);
    }
    
@end
