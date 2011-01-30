//
//  CInvocationGrabber.m
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

#import "CInvocationGrabber.h"

/*
CInvocationGrabber *theInvocationGrabber = [CInvocationGrabber invocationGrabber];
[[theInvocationGrabber prepareWithInvocationTarget:foo] doSomethingWithParameter:bar];
NSInvocation *theInvocation = [theInvocationGrabber invocation];
*/

@interface CInvocationGrabber ()
@property (readwrite, retain) id target;
@property (readwrite, assign) NSInvocation **invocationDestination;
@end

@implementation CInvocationGrabber

@synthesize target;
@synthesize invocationDestination;

+ (id)grabInvocation:(NSInvocation **)outInvocation fromTarget:(id)inTarget;
{
CInvocationGrabber *theGrabber = [[[self alloc] init] autorelease];
theGrabber.target = inTarget;
theGrabber.invocationDestination = outInvocation;
return(theGrabber);
}

- (id)init
{
return(self);
}

- (void)dealloc
{
self.target = NULL;
//
[super dealloc];
}

#pragma mark -

- (NSMethodSignature *)methodSignatureForSelector:(SEL)inSelector
{
NSMethodSignature *theMethodSignature = [[self target] methodSignatureForSelector:inSelector];
return(theMethodSignature);
}

- (void)forwardInvocation:(NSInvocation *)ioInvocation
{
[ioInvocation setTarget:self.target];

if (self.invocationDestination)
	*self.invocationDestination = ioInvocation;

[self didGrabInvocation:ioInvocation];
}

- (void)didGrabInvocation:(NSInvocation *)inInvocation
{
}

@end

#pragma mark  -

@interface CThreadingInvocationGrabber ()
@property (readwrite, nonatomic, assign) BOOL waitUntilDone;
@end

#pragma mark -

@implementation CThreadingInvocationGrabber

@synthesize waitUntilDone;

+ (id)grabInvocationFromTarget:(id)inTarget andPeformOnMainThreadWaitUntilDone:(BOOL)inWaitUntilDone
{
CThreadingInvocationGrabber *theGrabber = [[[self alloc] init] autorelease];
theGrabber.target = inTarget;
theGrabber.waitUntilDone = inWaitUntilDone;
return(theGrabber);
}

- (void)didGrabInvocation:(NSInvocation *)inInvocation
{
[inInvocation retainArguments];

[inInvocation performSelectorOnMainThread:@selector(invoke) withObject:NULL waitUntilDone:self.waitUntilDone];
}

@end

