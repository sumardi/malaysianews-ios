//
//  NSURLResponse_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 11/09/09.
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

#import "NSURLResponse_Extensions.h"

@implementation NSURLResponse (NSURLResponse_Extensions)

- (NSError *)asError
{
// TODO - we can make a minimal OH NOES error here and just use the URL in the error. No?
return(NULL);
}

- (NSString *)debuggingDescription
{
NSMutableArray *theComponents = [NSMutableArray array];

[theComponents addObject:[NSString stringWithFormat:@"URL: %@", [self URL]]];
[theComponents addObject:[NSString stringWithFormat:@"MIMEType: %@", [self MIMEType]]];

NSString *theDescription = [theComponents componentsJoinedByString:@"\n"];
return(theDescription);
}

- (void)dump
{
fprintf(stderr, "%s\n", [[self debuggingDescription] UTF8String]);
}

@end

#pragma mark -

@implementation NSHTTPURLResponse (NSURLResponse_Extensions)

- (NSError *)asError
{
NSString *theLocalizedDescription = NULL;
NSString *theRecoverySuggestion = NULL;

switch ([self statusCode])
	{
	case 401:
		theLocalizedDescription = @"Authorization failed.";
		theRecoverySuggestion = @"Try again later.";
		break;
	case 503:
		theLocalizedDescription = @"The service is currently unavailable.";
		theRecoverySuggestion = @"Try again later.";
		break;
	default:
		theLocalizedDescription = [NSHTTPURLResponse localizedStringForStatusCode:self.statusCode];
		break;
	}

NSMutableDictionary *theUserInfo = [NSMutableDictionary dictionary];

if (self.URL)
	[theUserInfo setObject:self.URL forKey:NSURLErrorKey];

if (theLocalizedDescription != NULL)
	[theUserInfo setObject:theLocalizedDescription forKey:NSLocalizedDescriptionKey];
if (theRecoverySuggestion != NULL)
	[theUserInfo setObject:theRecoverySuggestion forKey:NSLocalizedRecoverySuggestionErrorKey];

NSError *theError = [NSError errorWithDomain:@"HTTP" code:self.statusCode userInfo:theUserInfo];
return(theError);
}

- (NSString *)debuggingDescription
{
NSMutableArray *theComponents = [NSMutableArray array];

[theComponents addObject:[NSString stringWithFormat:@"URL: %@", [self URL]]];
[theComponents addObject:[NSString stringWithFormat:@"MIMEType: %@", [self MIMEType]]];
[theComponents addObject:[NSString stringWithFormat:@"statusCode: %d", [self statusCode]]];
[theComponents addObject:[NSString stringWithFormat:@"Headers: %@", [self allHeaderFields]]];


NSString *theDescription = [theComponents componentsJoinedByString:@"\n"];
return(theDescription);
}

@end
