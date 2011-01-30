//
//  NSDate_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 4/1/09.
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

#import "NSDate_Extensions.h"

@implementation NSDate (NSDate_Extensions)

+ (NSDate *)dateWithString:(NSString *)inString format:(NSString *)inFormat
{
NSDateFormatter *theFormatter = [[[NSDateFormatter alloc] init] autorelease];
theFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
theFormatter.dateFormat = inFormat;
return([theFormatter dateFromString:inString]);
}

- (NSString *)stringWithFormat:(NSString *)inFormat;
{
NSDateFormatter *theFormatter = [[[NSDateFormatter alloc] init] autorelease];
theFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
theFormatter.dateFormat = inFormat;
return([theFormatter stringFromDate:self]);
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)inDateStyle timeStyle:(NSDateFormatterStyle)inTimeStyle
{
NSDateFormatter *theFormatter = [[[NSDateFormatter alloc] init] autorelease];
theFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
theFormatter.dateStyle = inDateStyle;
theFormatter.timeStyle = inTimeStyle;
return([theFormatter stringFromDate:self]);
}

- (NSString *)stringWithShortDateStyleFormat
{
return([self stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]);
}

- (NSString *)stringWithMediumDateStyleFormat
{
return([self stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]);
}

- (NSString *)stringWithLongDateStyleFormat
{
return([self stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle]);
}

- (NSString *)stringWithFullDateStyleFormat
{
return([self stringWithDateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle]);
}

- (NSString *)stringWithShortTimeStyleFormat
{
return([self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]);
}

- (NSString *)stringWithMediumTimeStyleFormat
{
return([self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle]);
}

- (NSString *)stringWithLongTimeStyleFormat
{
return([self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterLongStyle]);
}

- (NSString *)stringWithFullTimeStyleFormat
{
return([self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterFullStyle]);
}

- (BOOL)isSameCalendarDayAsDate:(NSDate *)inDate
{
NSDateComponents *theComponents = [[NSCalendar currentCalendar] components:NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self toDate:inDate options:0];

return(theComponents.era == 0 && theComponents.year == 0 && theComponents.month == 0 && theComponents.day == 0);
}

@end
