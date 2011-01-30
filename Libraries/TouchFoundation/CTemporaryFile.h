//
//  CTemporaryFile.h
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

#import <Foundation/Foundation.h>

@interface CTemporaryFile : NSObject {
	BOOL deleteOnDealloc;
	NSString *prefix;
	NSString *suffix;
	NSURL *URL;
	int fileDescriptor;
	NSFileHandle *fileHandle;
}

@property (readwrite, nonatomic, assign) BOOL deleteOnDealloc;
@property (readwrite, nonatomic, retain) NSString *prefix;
@property (readwrite, nonatomic, retain) NSString *suffix;
@property (readonly, nonatomic, retain) NSURL *URL;
@property (readonly, nonatomic, assign) int fileDescriptor;
@property (readonly, nonatomic, retain) NSFileHandle *fileHandle; // JIWTODO - THIS SHOULD NOT BE HERE. Strong binding bad.

+ (NSString *)temporaryDirectory;

+ (CTemporaryFile *)tempFile;

- (void)create;

@end
