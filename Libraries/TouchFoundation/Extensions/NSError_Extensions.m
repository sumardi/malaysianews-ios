//
//  NSError_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 8/27/07.
//  Copyright 2007 toxicsoftware.com. All rights reserved.
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

#import "NSError_Extensions.h"

@implementation NSError (NSError_Extensions)

+ (id)errorWithDomain:(NSString *)inDomain code:(int)inCode userInfo:(NSDictionary *)inUserInfo localizedDescription:(NSString *)inFormat, ...
{
NSMutableDictionary *theUserInfo = [NSMutableDictionary dictionaryWithDictionary:inUserInfo];

va_list theArgs;
va_start(theArgs, inFormat);
NSString *theLocalizedDescription = [[[NSString alloc] initWithFormat:inFormat arguments:theArgs] autorelease];
va_end(theArgs);
[theUserInfo setObject:theLocalizedDescription forKey:NSLocalizedDescriptionKey];

NSError *theError = [self errorWithDomain:inDomain code:inCode userInfo:theUserInfo];
return(theError);
}

+ (int)errnoForError:(NSError *)inError;
{
NSAssert(inError && [[inError domain] isEqualToString:NSPOSIXErrorDomain] == YES, @"Error domain is not NSPOSIXErrorDomain");
return([inError code]);
}

+ (id)errorWithException:(NSException *)inException
{
NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	inException, @"NSException",
	NULL];


NSError *theError = [NSError errorWithDomain:@"NSException" code:-1 userInfo:theUserInfo];
return(theError);
}

@end
