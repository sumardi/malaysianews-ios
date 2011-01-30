//
//  NSValue_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 04/29/08.
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

#import "NSValue_Extensions.h"


@implementation NSValue (NSValue_Extensions)

+ (NSValue *)valueWithCGPoint:(CGPoint)inPoint
{
return([NSValue valueWithBytes:&inPoint objCType:@encode(CGPoint)]);
}

- (CGPoint)CGPointValue
{
CGPoint theValue;
[self getValue:&theValue];
return(theValue);
}

+ (NSValue *)valueWithCGSize:(CGSize)inSize
{
return([NSValue valueWithBytes:&inSize objCType:@encode(CGSize)]);
}

- (CGSize)CGSizeValue
{
CGSize theValue;
[self getValue:&theValue];
return(theValue);
}

+ (NSValue *)valueWithCGRect:(CGRect)inRect
{
return([NSValue valueWithBytes:&inRect objCType:@encode(CGRect)]);
}

- (CGRect)CGRectValue
{
CGRect theValue;
[self getValue:&theValue];
return(theValue);
}

@end
