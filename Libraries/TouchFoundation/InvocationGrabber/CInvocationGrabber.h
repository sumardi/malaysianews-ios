//
//  CInvocationGrabber.h
//  TouchCode
//
//  Created by Jonathan Wight on 20090528.
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

#import <Foundation/Foundation.h>

/**
 * @class CInvocationGrabber
 * @discussion CInvocationGrabber is a helper object that makes it very easy to construct instances of NSInvocation. The object is inspired by NSUndoManager's prepareWithInvocationTarget method.

NSInvocation *theInvocation = NULL;
[[CInvocationGrabber grabWithTarget:someObject invocation:&theInvocation] doSomethingWithParameter:someParameter];

Note this version is all new and the syntax is a lot more compact. This version is not backwards compatible and the old version is therefore deprecated.

WARNING: Does not seem to work with methods that take vararg style arguments (...), e.g. -[NSMutableString appendFormat:] etc.
 */
@interface CInvocationGrabber : NSProxy {
	id target;
	NSInvocation **invocationDestination;
}

+ (id)grabInvocation:(NSInvocation **)outInvocation fromTarget:(id)inTarget;

- (void)didGrabInvocation:(NSInvocation *)inInvocation;

@end

#pragma mark -

@interface CThreadingInvocationGrabber : CInvocationGrabber {
	BOOL waitUntilDone;
}

+ (id)grabInvocationFromTarget:(id)inTarget andPeformOnMainThreadWaitUntilDone:(BOOL)inWaitUntilDone;

@end

