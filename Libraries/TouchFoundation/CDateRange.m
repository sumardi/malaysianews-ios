//
//  CDateRange.m
//  TouchCode
//
//  Created by Jonathan Wight on 5/15/09.
//  Copyright 2009 Small Society. All rights reserved.
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

#import "CDateRange.h"

#import "NSDate_Extensions.h"

@interface CDateRange ()
@property (readwrite, nonatomic, retain) NSDate *start;
@property (readwrite, nonatomic, retain) NSDate *end;
@end

#pragma mark -

@implementation CDateRange

@synthesize start;
@synthesize end;

- (id)initWithStart:(NSDate *)inStart end:(NSDate *)inEnd;
{
if ((self = [super init]) != NULL)
	{
	self.start = inStart;
	self.end = inEnd;
	}
return(self);
}

- (void)dealloc
{
self.start = NULL;
self.end = NULL;
//
[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
return([[CDateRange alloc] initWithStart:self.start end:self.end]);
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
return([[CMutableDateRange alloc] initWithStart:self.start end:self.end]);
}

#pragma mark -

- (NSTimeInterval)duration;
{
return([self.end timeIntervalSinceDate:self.start]);
}

- (NSString *)formattedString
{
if ([self.start isSameCalendarDayAsDate:self.end] == YES)
	{
	// Dec 25, 10:30 AM - 11:00 AM
	return([NSString stringWithFormat:@"%@, %@ - %@",
		[self.start stringWithFormat:@"MMM d"],
		[self.start stringWithShortTimeStyleFormat],
		[self.end stringWithShortTimeStyleFormat]
		]);
	}
else
	{
	// Dec 25, 10:30 AM - Dec 26, 11:00 AM
	return([NSString stringWithFormat:@"%@, %@ - %@, %@",
		[self.start stringWithFormat:@"MMM d"],
		[self.start stringWithShortTimeStyleFormat],
		[self.end stringWithFormat:@"MMM d"],
		[self.end stringWithShortTimeStyleFormat]
		]);
	}
}

@end

#pragma mark -

@implementation CMutableDateRange

@synthesize durationPinnedFlag;

- (id)initWithStart:(NSDate *)inStart end:(NSDate *)inEnd;
{
if ((self = [super initWithStart:inStart end:inEnd]) != NULL)
	{
	self.durationPinnedFlag = YES;
	}
return(self);
}

- (NSDate *)start
{
return(start);
}

- (void)setStart:(NSDate *)inStart
{
if (start != inStart)
	{
	if (self.durationPinnedFlag == NO)
		[super setStart:inStart];
	else
		{
		NSTimeInterval theDuration = self.duration;
		[super setStart:inStart];
		[super setEnd:[inStart dateByAddingTimeInterval:theDuration]];
		}

    }
}

- (NSDate *)end
{
return end;
}

- (void)setEnd:(NSDate *)inEnd
{
if (end != inEnd)
	{
	[super setEnd:inEnd];
    }
}

- (NSTimeInterval)duration
{
return([self.end timeIntervalSinceDate:self.start]);
}

- (void)setDuration:(NSTimeInterval)inDuration
{
self.end = [self.start dateByAddingTimeInterval:inDuration];
}

@end

#pragma mark -

@implementation CDateRange (CDateRange_Extensions)

- (NSTimeInterval)durationHours
{
return(round(self.duration / 3600.0));
}

@end
