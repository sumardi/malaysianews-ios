//
//  CBundleResourceURLProtocol.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/15/08.
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

#import "CBundleResourceURLProtocol.h"

#if !defined(XBUNDLE_NEVER_CHECK_WHITELIST)
#define XBUNDLE_NEVER_CHECK_WHITELIST 1
#endif /* !defined(XBUNDLE_NEVER_CHECK_WHITELIST) */

@implementation CBundleResourceURLProtocol

+ (void)load
{
[self registerClass:self];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
NSURL *theURL = request.URL;

if ([theURL.scheme isEqualToString:@"x-resource"] == NO)
	return(NO);

NSString *thePath = theURL.resourceSpecifier;
thePath = [thePath stringByStandardizingPath];
if ([self isPathWhitelisted:thePath] == NO)
	{
	return(NO);
	}

thePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:thePath];
BOOL theFileExists = [[NSFileManager defaultManager] fileExistsAtPath:thePath];

return(theFileExists);
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
return(request);
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
return([a.URL isEqual:b.URL]);
}

- (void)startLoading
{
NSAssert(self.client, @"Should never get a startLoading message.");
NSAssert([self.client conformsToProtocol:@protocol(NSURLProtocolClient)], @"Should never have a client that does not conform to NSURLProtocolClient protocol.");

NSURL *theURL = self.request.URL;
NSAssert([theURL.scheme isEqualToString:@"x-resource"], @"The requesting URL scheme is not x-resource.");

NSString *thePath = theURL.resourceSpecifier;

thePath = [thePath stringByStandardizingPath];

if ([[self class] isPathWhitelisted:thePath] == NO)
	{
	NSError *theError = [NSError errorWithDomain:@"TODO_DOMAIN" code:-1 userInfo:NULL];
	[self.client URLProtocol:self didFailWithError:theError];
	return;
	}

thePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:thePath];

NSString *theMimeType = [[self class] MIMETypeForPath:thePath];

NSData *theData = [NSData dataWithContentsOfFile:thePath];

NSURLResponse *theResponse = [[[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:theMimeType expectedContentLength:theData.length textEncodingName:NULL] autorelease];

[self.client URLProtocol:self didReceiveResponse:theResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];

[self.client URLProtocol:self didLoadData:theData];

[self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
}

+ (NSString *)MIMETypeForPath:(NSString *)inPath
{
NSString *theExtension = [inPath pathExtension];
if ([theExtension isEqualToString:@"js"])
	return(@"text/javascript");
else if ([theExtension isEqualToString:@"css"])
	return(@"text/css");
else if ([theExtension isEqualToString:@"html"])
	return(@"text/html");
else if ([theExtension isEqualToString:@"png"])
	return(@"image/png");
else
	return(@"application/data");
}

+ (BOOL)isPathWhitelisted:(NSString *)inPath
{
if (inPath == NULL || inPath.length == 0)
	return(NO);

#if XBUNDLE_NEVER_CHECK_WHITELIST == 1
return(YES);
#endif /* XBUNDLE_NEVER_CHECK_WHITELIST */

NSSet *theWhitelistedPaths = [NSSet setWithArray:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"XBundleResourceWhitelistedPaths"]];

if ([theWhitelistedPaths containsObject:inPath])
	return(YES);
else
	{
	return(NO);
	}
}


//+ (id)propertyForKey:(NSString *)key inRequest:(NSURLRequest *)request;
//+ (void)setProperty:(id)value forKey:(NSString *)key inRequest:(NSMutableURLRequest *)request;
//+ (void)removePropertyForKey:(NSString *)key inRequest:(NSMutableURLRequest *)request;


@end
