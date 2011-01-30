//
//  CHumanDateFormatter.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/12/08.
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

#import "CHumanDateFormatter.h"

static NSDateFormatter *gSubDateFormatter1 = NULL;
static NSDateFormatter *gSubDateFormatter2 = NULL;
static NSDateFormatter *gSubDateFormatter3 = NULL;
static NSDateFormatter *gSubDateFormatter4 = NULL;

@implementation CHumanDateFormatter

@synthesize singleLine;
@synthesize relative;

// TODO one way to speed this up is to pre-init all the subDateFormatter objects (as statics).

+ (id)humanDateFormatter:(BOOL)inSingleLine
{
static CHumanDateFormatter *theSingleLineFormatter = NULL;
static CHumanDateFormatter *theMultiLineFormatter = NULL;
if (inSingleLine == YES)
	{
	if (theSingleLineFormatter == NULL)
		{
		theSingleLineFormatter = [[self alloc] init];
		theSingleLineFormatter.singleLine = inSingleLine;
		}
	return(theSingleLineFormatter);
	}
else
	{
	if (theMultiLineFormatter == NULL)
		{
		theMultiLineFormatter = [[self alloc] init];
		theMultiLineFormatter.singleLine = inSingleLine;
		}
	return(theMultiLineFormatter);
	}
}

+ (NSString *)formatDate:(NSDate *)inDate singleLine:(BOOL)inSingleLine;
{
CHumanDateFormatter *theDateFormatter = [self humanDateFormatter:inSingleLine];
return([theDateFormatter stringFromDate:inDate]);
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
	@synchronized([self class])
		{
		if (gSubDateFormatter1 == NULL)
			{
			NSDateFormatter *theSubDateFormatter = NULL;
			
			// ############################################

			theSubDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[theSubDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			[theSubDateFormatter setDateStyle:NSDateFormatterNoStyle];
			[theSubDateFormatter setTimeStyle:NSDateFormatterShortStyle];
			
			gSubDateFormatter1 = [theSubDateFormatter retain];

			// ############################################
			
			theSubDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[theSubDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			[theSubDateFormatter setDateStyle:NSDateFormatterNoStyle];
			[theSubDateFormatter setTimeStyle:NSDateFormatterShortStyle];

			gSubDateFormatter2 = [theSubDateFormatter retain];

			// ############################################

			theSubDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[theSubDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			[theSubDateFormatter setDateStyle:NSDateFormatterNoStyle];
			[theSubDateFormatter setTimeStyle:NSDateFormatterShortStyle];

			gSubDateFormatter3 = [theSubDateFormatter retain];

			// ############################################

			theSubDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[theSubDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			[theSubDateFormatter setDateStyle:NSDateFormatterShortStyle];
			[theSubDateFormatter setTimeStyle:NSDateFormatterNoStyle];

			gSubDateFormatter4 = [theSubDateFormatter retain];

			// ############################################
			}
		}
	}
return(self);
}

- (NSString *)stringFromDate:(NSDate *)inDate
{
NSDateComponents *theDateComponents = [[NSCalendar currentCalendar] components:NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit fromDate:inDate];
//
NSDate *theNow = [NSDate date];

// #############################################################################

NSDateComponents *theTodayComponents = [[NSCalendar currentCalendar] components:NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit fromDate:theNow];

if ([theDateComponents isEqual:theTodayComponents])
	{
	if (self.singleLine == YES)
		return(@"Today");
	else
		return([NSString stringWithFormat:@"Today\n%@", [gSubDateFormatter1 stringFromDate:inDate]]);
	}

// #############################################################################

NSDateComponents *theDelta = [[[NSDateComponents alloc] init] autorelease];
[theDelta setDay:+1];
NSDate *theTomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:theDelta toDate:theNow options:NSWrapCalendarComponents];
NSDateComponents *theTomorrowComponents = [[NSCalendar currentCalendar] components:NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit fromDate:theTomorrow];

if ([theDateComponents isEqual:theTomorrowComponents])
	{
	if (self.singleLine == YES)
		return(@"Tomorrow");
	else
		return([NSString stringWithFormat:@"Tomorrow\n%@", [gSubDateFormatter2 stringFromDate:inDate]]);
	}

// #############################################################################

[theDelta setDay:-1];
NSDate *theYesterday = [[NSCalendar currentCalendar] dateByAddingComponents:theDelta toDate:theNow options:NSWrapCalendarComponents];
NSDateComponents *theYesterdayComponents = [[NSCalendar currentCalendar] components:NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit fromDate:theYesterday];

if ([theDateComponents isEqual:theYesterdayComponents])
	{
	if (self.singleLine == YES)
		return(@"Yesterday");
	else
		return([NSString stringWithFormat:@"Yesterday\n%@", [gSubDateFormatter3 stringFromDate:inDate]]);
	}

if (self.relative == YES) {
	int days = (int) ceil([theNow timeIntervalSinceDate:inDate] / (60 * 60 * 24));
	return [NSString stringWithFormat:@"%d days ago",days];
}
	
if ([theNow timeIntervalSinceDate:inDate] < 7 * 24 * 60 * 60)
	{
	NSDateFormatter *theSubDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[theSubDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	if (self.singleLine == YES)
		[theSubDateFormatter setDateStyle:NSDateFormatterShortStyle];
	else
		[theSubDateFormatter setDateFormat:@"EEEE\nh:mm a"];
	//
	return([NSString stringWithFormat:@"%@", [theSubDateFormatter stringFromDate:inDate]]);
	}

// #############################################################################
//
return([gSubDateFormatter4 stringFromDate:inDate]);
}

@end
