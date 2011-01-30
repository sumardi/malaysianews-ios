//
//  CBetterCoreDataManager.m
//  TouchCode
//
//  Created by Jonathan Wight on 11/10/09.
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

#import "CBetterCoreDataManager.h"

#import "NSError_Extensions.h"

@interface CBetterCoreDataManager()
- (void)managedObjectContextDidSaveNotification:(NSNotification *)inNotification;
@end

@implementation CBetterCoreDataManager

@synthesize defaultMergePolicy;

- (void)dealloc
{
[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:NULL];

[defaultMergePolicy release];
defaultMergePolicy = NULL;
//
[super dealloc];
}


- (NSManagedObjectContext *)newManagedObjectContext
{
NSManagedObjectContext *theManagedObjectContext = [super newManagedObjectContext];
if (self.defaultMergePolicy != NULL)
	theManagedObjectContext.mergePolicy = self.defaultMergePolicy;

if ([NSThread isMainThread] == NO)
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:theManagedObjectContext];

return(theManagedObjectContext);
}

- (void)managedObjectContextDidSaveNotification:(NSNotification *)inNotification
{
if ([NSThread mainThread] != [NSThread currentThread])
	{
	[self performSelectorOnMainThread:@selector(managedObjectContextDidSaveNotification:) withObject:inNotification waitUntilDone:YES];
	return;
	}

@try
	{
	[self.managedObjectContext mergeChangesFromContextDidSaveNotification:inNotification];
	[self save];
	}
@catch (NSException * e)
	{
	[self presentError:[NSError errorWithException:e]];
	}
}


@end
