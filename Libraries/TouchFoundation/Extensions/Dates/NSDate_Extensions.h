//
//  NSDate_Extensions.h
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

#import <Foundation/Foundation.h>

@interface NSDate (NSDate_Extensions)

+ (NSDate *)dateWithString:(NSString *)inString format:(NSString *)inFormat;

- (NSString *)stringWithFormat:(NSString *)inFormat;

/// Specifies a short style, typically numeric only, such as “11/23/37” or “3:30pm”.
- (NSString *)stringWithShortDateStyleFormat; 
/// Specifies a medium style, typically with abbreviated text, such as “Nov 23, 1937”.
- (NSString *)stringWithMediumDateStyleFormat;
///Specifies a long style, typically with full text, such as “November 23, 1937” or “3:30:32pm”.
- (NSString *)stringWithLongDateStyleFormat;
///Specifies a full style with complete details, such as “Tuesday, April 12, 1952 AD” or “3:30:42pm PST”.
- (NSString *)stringWithFullDateStyleFormat;

- (NSString *)stringWithShortTimeStyleFormat;
- (NSString *)stringWithMediumTimeStyleFormat;
- (NSString *)stringWithLongTimeStyleFormat;
- (NSString *)stringWithFullTimeStyleFormat;

- (BOOL)isSameCalendarDayAsDate:(NSDate *)inDate;

@end
