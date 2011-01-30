//
//  CEntityDataSource.m
//  TouchCode
//
//  Created by Jonathan Wight on 5/5/09.
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

#import "CEntityDataSource.h"

@interface CEntityDataSource ()
@property (readwrite, nonatomic, retain) NSArray *items;
@end

@implementation CEntityDataSource

@synthesize managedObjectContext;
@synthesize entityDescription;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)inManagedObjectContext entityDescription:(NSEntityDescription *)inEntityDescription
{
if ((self = [self init]) != NULL)
	{
	self.managedObjectContext = inManagedObjectContext;
	self.entityDescription = inEntityDescription;
	}
return(self);
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)inManagedObjectContext entityName:(NSString *)inEntityName
{
NSEntityDescription *theEntityDescription = [NSEntityDescription entityForName:inEntityName inManagedObjectContext:inManagedObjectContext];
if ((self = [self initWithManagedObjectContext:inManagedObjectContext entityDescription:theEntityDescription]) != NULL)
	{
	}
return(self);
}

- (void)dealloc
{
self.managedObjectContext = NULL;
self.entityDescription = NULL;
self.predicate = NULL;
self.items = NULL;
//
[super dealloc];
}

#pragma mark -

- (NSPredicate *)predicate
{
return(predicate);
}

- (void)setPredicate:(NSPredicate *)inPredicate
{
if (predicate != inPredicate)
	{
	[predicate autorelease];
	predicate = [inPredicate retain];
	//
	self.items = NULL;
    }
}

- (NSArray *)sortDescriptors
{
return(sortDescriptors);
}

- (void)setSortDescriptors:(NSArray *)inSortDescriptors
{
if (sortDescriptors != inSortDescriptors)
	{
	[sortDescriptors autorelease];
	sortDescriptors = [inSortDescriptors retain];
	//
	self.items = NULL;
    }
}

- (NSArray *)items
{
if (items == NULL)
	{
	[self fetch:NULL];
	}
return(items);
}

- (void)setItems:(NSArray *)inItems
{
if (items != inItems)
	{
	[items autorelease];
	items = [inItems retain];
    }
}

- (BOOL)fetch:(NSError **)outError
{
NSFetchRequest *theRequest = [[[NSFetchRequest alloc] init] autorelease];
[theRequest setEntity:self.entityDescription];
if (self.sortDescriptors)
	[theRequest setSortDescriptors:self.sortDescriptors];
if (self.predicate)
	[theRequest setPredicate:self.predicate];

NSArray *theArray = [self.managedObjectContext executeFetchRequest:theRequest error:outError];

self.items = theArray;

return(theArray != NULL);
}

@end
