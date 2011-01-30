//
//  NSManagedObjectContext_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 5/27/09.
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

#import "NSManagedObjectContext_Extensions.h"

@implementation NSManagedObjectContext (NSManagedObjectContext_Extensions)

- (NSUInteger)countOfObjectsOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate error:(NSError **)outError
{
NSEntityDescription *theEntityDescription = [NSEntityDescription entityForName:inEntityName inManagedObjectContext:self];
NSFetchRequest *theFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
[theFetchRequest setEntity:theEntityDescription];
if (inPredicate)
	[theFetchRequest setPredicate:inPredicate];
NSUInteger theCount = [self countForFetchRequest:theFetchRequest error:outError];
return(theCount);
}

- (NSArray *)fetchObjectsOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate error:(NSError **)outError
{
NSEntityDescription *theEntityDescription = [NSEntityDescription entityForName:inEntityName inManagedObjectContext:self];
NSFetchRequest *theFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
[theFetchRequest setEntity:theEntityDescription];
if (inPredicate)
	[theFetchRequest setPredicate:inPredicate];
NSArray *theObjects = [self executeFetchRequest:theFetchRequest error:outError];
return(theObjects);
}

- (id)fetchObjectOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate error:(NSError **)outError;
{
id theObject = [self fetchObjectOfEntityForName:inEntityName predicate:inPredicate createIfNotFound:NO wasCreated:NULL error:outError];
return(theObject);
}

- (id)fetchObjectOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate createIfNotFound:(BOOL)inCreateIfNotFound wasCreated:(BOOL *)outWasCreated error:(NSError **)outError
{
id theObject = NULL;
NSArray *theObjects = [self fetchObjectsOfEntityForName:inEntityName predicate:inPredicate error:outError];
BOOL theWasCreatedFlag = NO;
if (theObjects)
	{
	const NSUInteger theCount = theObjects.count;
	if (theCount == 0)
		{
		if (inCreateIfNotFound == YES)
			{
			theObject = [NSEntityDescription insertNewObjectForEntityForName:inEntityName inManagedObjectContext:self];
			if (theObject)
				theWasCreatedFlag = YES;
			}
		}
	else if (theCount == 1)
		{
		theObject = [theObjects lastObject];
		}
	else
		{
		if (outError)
			{
			NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat:@"Expected 1 object (of type %@) but got %d instead (%@).", inEntityName, theObjects.count, inPredicate], NSLocalizedDescriptionKey,
				NULL];
			
			*outError = [NSError errorWithDomain:@"TODO_DOMAIN" code:-1 userInfo:theUserInfo];
			}
		}
	}
if (theObject && outWasCreated)
	*outWasCreated = theWasCreatedFlag;
	
return(theObject);
}

#pragma mark -

#if NS_BLOCKS_AVAILABLE
- (BOOL)performTransaction:(void (^)(void))block error:(NSError **)outError
    {
    BOOL theResult = NO;
    
    #if 1
    if ([self hasChanges])
        {
		NSLog(@"Managed object context has unsaved changes and probably shouldn't! (%@)", self);
		
		if ([self insertedObjects].count > 0)
			{
			NSLog(@"insertedObjects: %@", [self insertedObjects]);
			}

		if ([self updatedObjects].count > 0)
			{
			NSLog(@"updatedObjects: %@", [self updatedObjects]);
			}

		if ([self deletedObjects].count > 0)
			{
			NSLog(@"deletedObjects: %@", [self deletedObjects]);
			}
        }
    #endif
        
    @try
        {
        if (block)
            {
            block();
            }
        
        // We only save _if_ we have changes (to prevent notifications from firing).
        if ([self hasChanges])
            {
            theResult = [self save:outError];
            }
        }
    @catch (NSException * e)
        {
        if ([self hasChanges])
            {
            [self rollback];
            }
        
        if (outError)
            {
			NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat:@"Exception thrown while performing transaction: %@", e], NSLocalizedDescriptionKey,
				e, @"exception",
				NULL];
            *outError = [NSError errorWithDomain:@"TODO_DOMAIN" code:-1 userInfo:theUserInfo];
            }
        }
    @finally
        {
        }
    return(theResult);
    }
#endif /* NS_BLOCKS_AVAILABLE */

@end
