//
//  NSScanner_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 12/27/2004.
//  Copyright 2004 toxicsoftware.com. All rights reserved.
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

#import "NSScanner_Extensions.h"

@implementation NSScanner (NSScanner_MoreExtensions)

- (NSString *)remainingString
{
return([[self string] substringFromIndex:[self scanLocation]]);
}

- (BOOL)scanAtMost:(NSUInteger)inMaximum commaSeparatedDoubles:(NSArray **)outDoubles
{
NSMutableArray *theDoubles = [NSMutableArray array];


NSInteger theStartScanLocation, theScanLocation;
theStartScanLocation = theScanLocation = [self scanLocation];

while ([self isAtEnd] == NO)
	{
	double theDouble;
	if ([self scanDouble:&theDouble] == NO)
		{
		break;
		}
	
	[theDoubles addObject:[NSNumber numberWithDouble:theDouble]];
	if (inMaximum > 0 && [theDoubles count] >= inMaximum)
		break;
	
	[self scanString:@"," intoString:NULL];

	theScanLocation = [self scanLocation];
	}

if ([theDoubles count] > 0)
	{
	[self setScanLocation:theScanLocation];

	if (outDoubles)
		*outDoubles = theDoubles;
	return(YES);
	}

[self setScanLocation:theStartScanLocation];

return(NO);
}

- (BOOL)skipComma
{
[self scanString:@"," intoString:NULL];
return(YES);
}

- (BOOL)scanCGPoint:(CGPoint *)outCGPoint
{
NSInteger theOldScanLocation = [self scanLocation];

CGPoint thePoint;
if ([self scanCGFloat:&thePoint.x] == YES && [self skipComma] && [self scanCGFloat:&thePoint.y] == YES)
	{
	if (outCGPoint)
		*outCGPoint = thePoint;
	return(YES);
	}

[self setScanLocation:theOldScanLocation];
return(NO);
}

- (BOOL)scanCGFloat:(CGFloat *)outCGFloat;
{
// TODO handle 64-bit
double theDouble;
BOOL theResult = [self scanDouble:&theDouble];
if (outCGFloat)
	*outCGFloat = theDouble;
return(theResult);
}

- (BOOL)scanAtMost:(NSUInteger)N charactersFromSet:(NSCharacterSet *)set intoString:(NSString **)value;
{
unsigned theCurrentLocation = [self scanLocation];

NSString *theValue = NULL;
if ([self scanCharactersFromSet:set intoString:&theValue] == YES)
	{
	unsigned theScannedCharacters = [theValue length];
	if (theScannedCharacters > N)
		{
		theValue = [theValue substringToIndex:N];
		[self setScanLocation:theCurrentLocation + N];
		}
	if (value)
		{
		*value = theValue;
		}
	return(YES);
	}
else
	{
	return(NO);
	}
}

- (BOOL)scanStringWithinParentheses:(NSString **)outString;
{
unsigned theCurrentLocation = [self scanLocation];

if ([self scanString:@"(" intoString:NULL] == NO)
	{
	[self setScanLocation:theCurrentLocation];
	return(NO);
	}
if ([self scanUpToString:@")" intoString:outString] == NO)
	{
	[self setScanLocation:theCurrentLocation];
	return(NO);
	}

return(YES);	
}

- (BOOL)scanNumber:(NSNumber **)outNumber
{
BOOL theResult = NO;
NSString *theSign = @"";
[self scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"+-"] intoString:&theSign];
NSString *theInteger = @"";
theResult = [self scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&theInteger];

NSString *theFraction = @"";
if ([self scanString:@"." intoString:NULL])
	{
	theResult = YES;
	[self scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&theFraction];
	}

if (theResult == YES)
	{
	if (outNumber != NULL)
		*outNumber = [NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@%@.%@", theSign, theInteger, theFraction] floatValue]];
	}
return(theResult);
}

/*
- (BOOL)scanAtMost:(unsigned)N charactersFromSet:(NSCharacterSet *)set intoString:(NSString **)value;
{
unsigned theCurrentLocation = [self scanLocation];

NSString *theValue = NULL;
if ([self scanCharactersFromSet:set intoString:&theValue] == YES)
	{
	unsigned theScannedCharacters = [theValue length];
	if (theScannedCharacters > N)
		{
		theValue = [theValue substringToIndex:N];
		[self setScanLocation:theCurrentLocation + N];
		}
	if (value)
		{
		*value = theValue;
		}
	return(YES);
	}
else
	{
	return(NO);
	}
}

- (BOOL)scanStringWithinParentheses:(NSString **)outString;
{
unsigned theCurrentLocation = [self scanLocation];

if ([self scanString:@"(" intoString:NULL] == NO)
	{
	[self setScanLocation:theCurrentLocation];
	return(NO);
	}
if ([self scanUpToString:@")" intoString:outString] == NO)
	{
	[self setScanLocation:theCurrentLocation];
	return(NO);
	}

return(YES);	
}

- (BOOL)scanNumber:(NSNumber **)outNumber
{
BOOL theResult = NO;
NSString *theSign = @"";
[self scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"+-"] intoString:&theSign];
NSString *theInteger = @"";
theResult = [self scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&theInteger];

NSString *theFraction = @"";
if ([self scanString:@"." intoString:NULL])
	{
	theResult = YES;
	[self scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&theFraction];
	}

if (theResult == YES)
	{
//	if (outNumber != NULL)
//		outNumber = [NSNumber numberWithFloat:[[NSString stringWithFormat:@"%@%@.%@", theSign, theInteger, theFraction] floatValue]];
	}
return(theResult);
}
*/

@end
