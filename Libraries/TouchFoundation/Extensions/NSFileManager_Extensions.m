//
//  NSFileManager_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 11/13/08.
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

#import "NSFileManager_Extensions.h"

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#endif /* TARGET_OS_IPHONE */

@implementation NSFileManager (NSFileManager_Extensions)

+ (NSFileManager *)fileManager;
    {
    // TODO One per thread!
    return([[[NSFileManager alloc] init] autorelease]);
    }

- (NSString *)mimeTypeForPath:(NSString *)inPath
{

NSString *thePathExtension = [inPath pathExtension];
if ([thePathExtension isEqualToString:@"html"])
	{
	return(@"text/html");
	}
else if ([thePathExtension isEqualToString:@"png"])
	{
	return(@"image/png");
	}
else if ([thePathExtension isEqualToString:@"css"])
	{
	return(@"text/css");
	}
else if ([thePathExtension isEqualToString:@"jpg"])
	{
	return(@"image/jpeg");
	}
else if ([thePathExtension isEqualToString:@"gif"])
	{
	return(@"image/gif");
	}
else if ([thePathExtension isEqualToString:@"js"])
	{
	return(@"text/javascript");
	}
else if ([thePathExtension isEqualToString:@"rtf"])
	{
	return(@"application/rtf");
	}
return(@"application/octet-stream");
}

- (NSString *)applicationSupportFolder
    {
    // TODO rewrite with URLForDirectory.
    NSArray *thePaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *theBasePath = ([thePaths count] > 0) ? [thePaths objectAtIndex:0] : NSTemporaryDirectory();

    NSString *theBundleName = [[[[NSBundle mainBundle] bundlePath] lastPathComponent] stringByDeletingPathExtension];
    NSString *theApplicationSupportFolder = [theBasePath stringByAppendingPathComponent:theBundleName];

    if ([self fileExistsAtPath:theApplicationSupportFolder] == NO)
        {
        NSError *theError = NULL;
        // TODO possible race condition
        if ([self createDirectoryAtPath:theApplicationSupportFolder withIntermediateDirectories:YES attributes:NULL error:&theError] == NO)
            return(NULL);
        }

    return(theApplicationSupportFolder);
    }


@end
