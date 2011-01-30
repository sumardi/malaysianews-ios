//
//  NSURL_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 04/05/08.
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

#import "NSURL_Extensions.h"

@implementation NSURL (NSURL_Extensions)

+ (NSURL *)URLWithRoot:(NSURL *)inRoot query:(NSString *)inQuery
{
if (inQuery == NULL || [inQuery length] == 0)
	return(inRoot);
NSString *theURLString = [NSString stringWithFormat:@"%@?%@", inRoot, inQuery];
return([self URLWithString:theURLString]);
}

+ (NSURL *)URLWithRoot:(NSURL *)inRoot queryDictionary:(NSDictionary *)inQueryDictionary
{
NSURL *theURL = NULL;

if ([inRoot query] != NULL)
	{
	NSMutableDictionary *theExistingQuery = [[[inRoot queryDictionary] mutableCopy] autorelease];
	
	[theExistingQuery addEntriesFromDictionary:inQueryDictionary];
	
	theURL = [self URLWithRoot:[inRoot querylessURL] query:[self queryStringForDictionary:theExistingQuery]];
	}
else
	{
	theURL = [self URLWithRoot:inRoot query:[self queryStringForDictionary:inQueryDictionary]];
	}

return(theURL);
}

+ (NSString *)queryStringForDictionary:(NSDictionary *)inQueryDictionary
{
NSMutableArray *theQueryComponents = [NSMutableArray array];
for (NSString *theKey in inQueryDictionary)
	{
	id theValue = [inQueryDictionary objectForKey:theKey];
	// this fixes the issue of spaces in values. %@ = [value description]
	NSString *tempValue = [theValue description];
	[theQueryComponents addObject:[NSString stringWithFormat:@"%@=%@", theKey, [tempValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
return([theQueryComponents componentsJoinedByString:@"&"]);
}

- (NSDictionary *)queryDictionary
{
NSString *theQuery = [self query];

NSMutableDictionary *theQueryDictionary = [NSMutableDictionary dictionary];

for (NSString *theComponent in [theQuery componentsSeparatedByString:@"&"])
	{
	if ([theComponent rangeOfString:@"="].location != NSNotFound)
		{
		NSArray *theComponents = [theComponent componentsSeparatedByString:@"="];
		if ([theComponents count] != 2)
			return(NULL);
		[theQueryDictionary setObject:[theComponents objectAtIndex:1] forKey:[theComponents objectAtIndex:0]];
		}
	else
		{
		[theQueryDictionary setObject:[NSNull null] forKey:theComponent];
		}
	}
return(theQueryDictionary);
}

- (NSURL *)querylessURL
{
NSMutableString *theURLString = [NSMutableString stringWithString:@""];

if ([self scheme])
	[theURLString appendFormat:@"%@://", [self scheme]];
if ([self user])
	[theURLString appendFormat:@"%@", [self user]];
if ([self host])
	[theURLString appendFormat:@"%@", [self host]];
if ([self path])
	[theURLString appendFormat:@"%@", [self path]];

NSURL *theURL = [NSURL URLWithString:theURLString];
return(theURL);
}

@end
