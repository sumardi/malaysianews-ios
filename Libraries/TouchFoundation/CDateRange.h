//
//  CDateRange.h
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

#import <Foundation/Foundation.h>

@interface CDateRange : NSObject <NSCopying, NSMutableCopying> {
	NSDate *start;
	NSDate *end;
}

@property (readonly, nonatomic, retain) NSDate *start;
@property (readonly, nonatomic, retain) NSDate *end;
@property (readonly, nonatomic, assign) NSTimeInterval duration;

- (id)initWithStart:(NSDate *)inStart end:(NSDate *)inEnd; 

- (NSString *)formattedString;

@end

#pragma mark -

@interface CMutableDateRange : CDateRange {
	BOOL durationPinnedFlag;
}

@property (readwrite, nonatomic, retain) NSDate *start;
@property (readwrite, nonatomic, retain) NSDate *end;
@property (readwrite, nonatomic, assign) NSTimeInterval duration;
@property (readwrite, nonatomic, assign) BOOL durationPinnedFlag;

@end

#pragma mark -

@interface CDateRange (CDateRange_Extensions)

@property (readonly, nonatomic, assign) NSTimeInterval durationHours;

@end
