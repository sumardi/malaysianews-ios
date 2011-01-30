//
//  NSOperationQueue_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 4/28/09.
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

#import "NSOperationQueue_Extensions.h"

#define USE_MAIN_QUEUE 0

@interface CRunloopHelper : NSObject {
	BOOL flag;
}
@property (readwrite, assign) BOOL flag;
- (void)runSynchronousOperation:(NSOperation *)inOperation onQueue:(NSOperationQueue *)inQueue;
@end

#pragma mark -

@implementation NSOperationQueue (NSOperationQueue_Extensions)

#if USE_MAIN_QUEUE == 0
static NSOperationQueue *gDefaultOperationQueue = NULL;
#endif

+ (NSOperationQueue *)defaultOperationQueue
{
#if USE_MAIN_QUEUE == 0
@synchronized(@"+[NSOperationQueue defaultOperationQueue]")
	{
	if (gDefaultOperationQueue == NULL)
		{
		gDefaultOperationQueue = [[self alloc] init];
		}
	}
return(gDefaultOperationQueue);
#else
NSOperationQueue *theQueue = [self currentQueue];
return(theQueue);
#endif
}

- (void)addOperationRecursively:(NSOperation *)inOperation
{
[self addOperation:inOperation];

for (NSOperation *theDependency in inOperation.dependencies)
	{
	[self addOperationRecursively:theDependency];
	}
}

- (void)addDependentOperations:(NSArray *)inOperations
{
NSOperation *thePreviousOperation = NULL;
for (NSOperation *theOperation in [inOperations reverseObjectEnumerator])
	{
	if (thePreviousOperation)
		{
		[thePreviousOperation addDependency:theOperation];
		}
	thePreviousOperation = theOperation;
	}

[self addOperationRecursively:[inOperations lastObject]];
}

- (void)runSynchronousOperation:(NSOperation *)inOperation
{
CRunloopHelper *theHelper = [[[CRunloopHelper alloc] init] autorelease];
[theHelper runSynchronousOperation:inOperation onQueue:self];
}

@end

#pragma mark -

@implementation CRunloopHelper

@synthesize flag;

- (void)runSynchronousOperation:(NSOperation *)inOperation onQueue:(NSOperationQueue *)inQueue
{
NSString *theContext = @"-[CRunloopHelper runSynchronousOperation:onQueue] context";

[inOperation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:theContext];
[inOperation addObserver:self forKeyPath:@"isCancelled" options:NSKeyValueObservingOptionNew context:theContext];

[inQueue addOperationRecursively:inOperation];

self.flag = YES;
while (self.flag == YES)
	{
	if ([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]] == NO)
		break;
	}

[inOperation removeObserver:self forKeyPath:@"isFinished"];
[inOperation removeObserver:self forKeyPath:@"isCancelled"];
}

- (void)stop
{
self.flag = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
[[NSRunLoop currentRunLoop] performSelector:@selector(stop) target:self argument:NULL order:0 modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
}

@end
