//
//  CNumberToStringValueTransformer.m
//  TouchCode
//
//  Created by Jonathan Wight on 8/17/09.
//  Copyright 2009 Touchcode. All rights reserved.
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

#import "CNumberToStringValueTransformer.h"


@implementation CNumberToStringValueTransformer

+ (void)load
{
NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];
//
[self setValueTransformer:[[[self alloc] init] autorelease] forName:NSStringFromClass(self)];
//
[thePool release];
}

+ (Class)transformedValueClass
{
return([NSString class]);
}

+ (BOOL)allowsReverseTransformation
{
return(NO);
}

- (id)transformedValue:(id)value
{
if ([value isKindOfClass:[NSNumber class]])
	{
	CFNumberRef theNumber = (CFNumberRef)value;
	CFNumberType theType = CFNumberGetType(theNumber);
	switch (theType)
		{
		case kCFNumberFloat32Type:
		case kCFNumberFloat64Type:
		case kCFNumberFloatType:
		case kCFNumberDoubleType:
		case kCFNumberCGFloatType:
			{
			double theDouble = [value doubleValue];
			return([NSString stringWithFormat:@"%f", theDouble]);
			}
			break;
		default:
			{
			return([value stringValue]);
			}
			break;
		}
	}
else
	{
	return(NULL);
	}
}


@end
