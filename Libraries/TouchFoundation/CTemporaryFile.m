//
//  CTemporaryFile.m
//  TouchCode
//
//  Created by Jonathan Wight on 12/29/08.
//  Copyright 2008 toxicsoftware.com. All rights reserved.
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

#import "CTemporaryFile.h"

#include <unistd.h>

@interface CTemporaryFile ()
@property (readwrite, nonatomic, retain) NSURL *URL;
@property (readwrite, nonatomic, assign) int fileDescriptor;
@end

#pragma mark -

@implementation CTemporaryFile

@synthesize deleteOnDealloc;
@synthesize prefix;
@synthesize suffix;
@synthesize URL;
@synthesize fileDescriptor;
@synthesize fileHandle;

+ (NSString *)temporaryDirectory
    {
    return(NSTemporaryDirectory());
    }

+ (CTemporaryFile *)tempFile
    {
    return([[[self alloc] init] autorelease]);
    }

- (id)init
{
if ((self = [super init]) != NULL)
	{
	deleteOnDealloc = YES;
	fileDescriptor = -1;
	}
return(self);
}

- (void)dealloc
    {
    if (fileHandle)
        {
        [fileHandle synchronizeFile];
        [fileHandle closeFile];
        [fileHandle release];
        fileHandle = NULL;
        }

    fileDescriptor = -1;

    if (deleteOnDealloc == YES && URL != NULL)
        {
        // Try and delete the file. But dont stress if it fails. JIWTODO - maybe log this?
        [[NSFileManager defaultManager] removeItemAtURL:self.URL error:NULL];
        }

    [suffix release];
    suffix = NULL;

    [URL release];
    URL = NULL;
    //
    [super dealloc];
    }

#pragma mark -

- (NSURL *)URL
    {
    if (URL == NULL)
        {
        [self create];
        }
    return(URL);
    }

- (int)fileDescriptor
    {
    if (fileDescriptor == -1)
        {
        [self create];
        }
    return(fileDescriptor);
    }

- (NSFileHandle *)fileHandle
    {
    if (fileHandle == NULL)
        {
        fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:self.fileDescriptor closeOnDealloc:YES];
        }
    return(fileHandle);
    }

#pragma mark -

- (void)create
    {
    // JIWTODO use a better (user supplied?) template
    NSString *theTemplate = [[[self class] temporaryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", self.prefix ?: @"", @"XXXXXXXXXXXXXXXXXXXXXXXXXXX"]];
    if (self.suffix)
        theTemplate = [theTemplate stringByAppendingString:self.suffix];

    char theBuffer[theTemplate.length + 1];
    strncpy(theBuffer, [theTemplate UTF8String], theTemplate.length + 1);
    self.fileDescriptor = mkstemps(theBuffer, self.suffix.length);
    self.URL = [NSURL fileURLWithPath:[NSString stringWithUTF8String:theBuffer]];
    }

@end
