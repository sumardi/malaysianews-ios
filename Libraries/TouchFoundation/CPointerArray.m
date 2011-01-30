//
//  CPointerArray.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/10/08.
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

#import "CPointerArray.h"

// WithOptions:NSPointerFunctionsZeroingWeakMemory | NSPointerFunctionsObjectPersonality

@interface CPointerArray ()

@property (readwrite, nonatomic, assign) void **buffer;

@end

@implementation CPointerArray


- (id)init
{
if ((self = [super init]) != NULL)
	{
	count = 0;
	buffer = NULL;
	}
return(self);
}

- (void)dealloc
{
self.buffer = NULL;
//
[super dealloc];
}

#pragma mark -

- (NSUInteger)count
{
return(count);
}

- (void)setCount:(NSUInteger)inCount
{
if (count != inCount)
	{
	const NSUInteger theOldCount = count;
	const size_t theOldSize = sizeof(void *) * theOldCount;
	const size_t theNewSize = sizeof(void *) * inCount;
	void **theNewBuffer = NULL;
	if (theOldSize == 0)
		theNewBuffer = malloc(theNewSize);
	else
		theNewBuffer = realloc(self.buffer, theNewSize);

	if (theNewBuffer == NULL)
		[NSException raise:NSMallocException format:@"realloc failed trying to allocate %d bytes, (errno: %d)", theNewSize, errno];

	if (theNewSize > theOldSize)
		memset(theNewBuffer + theOldCount, 0, theNewSize - theOldSize);

	buffer = theNewBuffer;
	count = inCount;
	}
}

- (void **)buffer
{
if (buffer == NULL && self.count > 0)
	{
	const size_t theSize = sizeof(void *) * self.count;
	void **theNewBuffer = malloc(theSize);
	memset(theNewBuffer, 0, theSize);

	if (theNewBuffer == NULL)
		[NSException raise:NSMallocException format:@"-[CPointerArray buffer] malloc failed trying to allocate %d bytes, (errno: %d)", theSize, errno];

	buffer = theNewBuffer;
	}
return(buffer);
}

- (void)setBuffer:(void **)inBuffer
{
if (buffer != inBuffer)
	{
	buffer = inBuffer;
	//
	if (buffer == NULL)
		self.count = 0;
	}
}

#pragma mark -

- (void *)pointerAtIndex:(NSUInteger)inIndex;
{
if (inIndex > count - 1)
	[NSException raise:NSRangeException format:@"-[CPointerArray pointerAtIndex:] inIndex (%d) is greater than count (%d) - 1", inIndex, count];
return(buffer[inIndex]);
}

- (void)addPointer:(void *)inPointer
{
self.count += 1;
self.buffer[self.count - 1] = inPointer;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
const NSUInteger theStartIndex = state->state;
const NSUInteger theCount = MIN(self.count - theStartIndex, len);

if (theCount > 0)
	state->itemsPtr = (id *)&buffer[theStartIndex];
else
	state->itemsPtr = NULL;

state->state = theStartIndex + theCount;
state->mutationsPtr = (unsigned long *)&buffer;

return(theCount);
}

@end
