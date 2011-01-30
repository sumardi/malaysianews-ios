//
//  CTrivialTemplate.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/19/08.
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

#import "CTrivialTemplate.h"

@implementation CTrivialTemplate

@synthesize template;

- (id)initWithTemplate:(NSString *)inTemplate
{
if ((self = [super init]) != NULL)
	{
	self.template = inTemplate;
	}
return(self);
}

- (id)initWithPath:(NSString *)inPath;
{
//NSString *theTemplate = [NSString stringWithContentsOfFile:inPath];
NSStringEncoding encoding;
NSString *theTemplate = [NSString stringWithContentsOfFile:inPath usedEncoding:&encoding error:NULL];
return([self initWithTemplate:theTemplate]);
}

- (id)initWithTemplateName:(NSString *)inTemplateName
{
NSString *theName = [inTemplateName stringByDeletingPathExtension];
NSString *theExtension = [inTemplateName pathExtension];

NSString *thePath = [[NSBundle mainBundle] pathForResource:theName ofType:theExtension];
return([self initWithPath:thePath]);
}

- (void)dealloc
{
self.template = NULL;
//
[super dealloc];
}

#pragma mark -

- (NSString *)transform:(id)inParameters error:(NSError **)outError
{
return [self transform:inParameters error:outError usedKeys:NULL];
}

- (NSString *)transform:(id)inParameters error:(NSError **)outError usedKeys:(NSArray **)outKeys
{
NSMutableString *theOutputString = [NSMutableString stringWithCapacity:self.template.length];
NSMutableArray *theUsedKeyArray = [NSMutableArray array];
NSAssert(self.template != NULL, @"template is null");
NSScanner *theScanner = [NSScanner scannerWithString:self.template];
[theScanner setCharactersToBeSkipped:NULL];

NSUInteger theLastScanLocation = [theScanner scanLocation];

NSString *theString = NULL;
while ([theScanner isAtEnd] == NO)
	{
	if ([theScanner scanUpToString:@"${" intoString:&theString] == YES)
		{
		[theOutputString appendString:theString];
		}

	if ([theScanner scanString:@"${" intoString:&theString] == YES)
		{
		if ([theScanner scanUpToString:@"}" intoString:&theString] == NO)
			{
			return(NULL);
			}

		NSArray *theComponents = [theString componentsSeparatedByString:@":"];
		NSString *theKeyValuePath = [theComponents objectAtIndex:0];
		NSString *theTransformerName = NULL;
		if (theComponents.count == 2)
			theTransformerName = [theComponents objectAtIndex:1];

		id theValue = [inParameters valueForKeyPath:theKeyValuePath];
		[theUsedKeyArray addObject:theKeyValuePath];

		if (theTransformerName)
			{
			NSValueTransformer *theTransformer = [NSValueTransformer valueTransformerForName:theTransformerName];
			if (theTransformer == NULL)
				{
				[NSException raise:NSGenericException format:@"Cannot find a value transform named: %@", theTransformerName];
				}
			theValue = [theTransformer transformedValue:theValue];
			}

		if (theValue)
			{
			NSString *theReplacementString = [theValue description];
			[theOutputString appendString:theReplacementString];
			}

		if ([theScanner scanString:@"}" intoString:&theString] == NO)
			{
			return(NULL);
			}
		}

	if ([theScanner scanLocation] == theLastScanLocation)
		{
		NSAssert(NO, @"NSScanner infinite loop detected!");
		}

	theLastScanLocation = [theScanner scanLocation];
	}

if (outKeys) *outKeys = [NSArray arrayWithArray:theUsedKeyArray]; 
return(theOutputString);
}

@end

#pragma mark -

@implementation CTrivialTemplate (CTrivialTemplate_Conveniences)

+ (NSString *)transformTemplateNamed:(NSString *)inName replacementDictionary:(NSDictionary *)inDictionary error:(NSError **)outError
{
CTrivialTemplate *theTemplate = [[[self alloc] initWithTemplateName:inName] autorelease];
return([theTemplate transform:inDictionary error:outError]);
}

@end
