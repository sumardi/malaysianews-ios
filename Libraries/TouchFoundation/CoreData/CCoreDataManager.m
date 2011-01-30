//
//  CCoreDataManager.m
//  TouchCode
//
//  Created by Jonathan Wight on 3/3/07.
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

#import "CCoreDataManager.h"

#if TARGET_OS_IPHONE == 1
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#define THREAD_PARANOIA 1

@interface CCoreDataManager ()
@property (readonly, retain) id threadStorageKey;

- (NSPersistentStoreCoordinator *)newPersistentStoreCoordinatorWithOptions:(NSDictionary *)inOptions error:(NSError **)outError;

+ (NSURL *)modelURLForName:(NSString *)inName;
+ (NSURL *)persistentStoreURLForName:(NSString *)inName storeType:(NSString *)inStoreType forceReplace:(BOOL)inForceReplace;
+ (NSString *)applicationSupportFolder;
- (id)threadStorageKey;
@end

#pragma mark -

@implementation CCoreDataManager

@synthesize name;
@synthesize storeType;
@synthesize forceReplace;
@synthesize storeOptions;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize threadStorageKey;
@synthesize delegate;

#if 0
+ (void)load
{
#warning Setting core data debugging

NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];

[[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"com.apple.CoreData.ThreadingDebug"];

[thePool release];
}
#endif

- (id)init
{
if ((self = [super init]) != NULL)
	{
	#if TARGET_OS_IPHONE == 1
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
	#else
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:[NSApplication sharedApplication]];
	#endif

	storeType = NSSQLiteStoreType;
	}
return(self);
}

- (void)dealloc
{
#if TARGET_OS_IPHONE == 1
[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
#else
[[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationWillTerminateNotification object:[NSApplication sharedApplication]];
#endif

[self save];

self.modelURL = NULL;
self.persistentStoreURL = NULL;
self.storeType = NULL;
self.storeOptions = NULL;

[name release];
name = NULL;
[persistentStoreCoordinator release];
persistentStoreCoordinator = NULL;
[managedObjectModel release];
managedObjectModel = NULL;
//
[super dealloc];
}

#pragma mark -

- (NSURL *)modelURL
{
if (modelURL == NULL && self.name != NULL)
	{
	modelURL = [[self class] modelURLForName:self.name];
	}
return(modelURL);
}

- (void)setModelURL:(NSURL *)inModelURL
{
if (modelURL != inModelURL)
	{
	[modelURL release];
	modelURL = [inModelURL retain];
	}
}

- (NSURL *)persistentStoreURL
{
if (persistentStoreURL == NULL && self.name != NULL)
	{
	persistentStoreURL = [[[self class] persistentStoreURLForName:self.name storeType:self.storeType forceReplace:self.forceReplace] retain];
	}
return(persistentStoreURL);
}

- (void)setPersistentStoreURL:(NSURL *)inPersistentStoreURL
{
if (persistentStoreURL != inPersistentStoreURL)
	{
	[persistentStoreURL release];
	persistentStoreURL = [inPersistentStoreURL retain];
	}
}

- (NSManagedObjectModel *)managedObjectModel
{
@synchronized(self)
	{
	if (managedObjectModel == NULL)
		{
//		NSLog(@"Creating MOM: %@", [self.modelURL.path lastPathComponent]);
		NSAssert([[NSFileManager defaultManager] fileExistsAtPath:self.modelURL.path], @"MOM file doesn't exist.");
		managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
		}
	}
return(managedObjectModel);
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
@synchronized(self)
	{
	if (persistentStoreCoordinator == NULL)
		{
		persistentStoreCoordinator = [[self newPersistentStoreCoordinatorWithOptions:self.storeOptions error:NULL] retain];

//		#if THREAD_PARANOIA == 1
//		NSAssert([NSThread isMainThread] == YES, @"Should not create persistentStoreCoordinate from non-main thread");
//		#endif /* THREAD_PARANOIA == 1 */

		}
	}

return(persistentStoreCoordinator);
}

- (NSPersistentStoreCoordinator *)newPersistentStoreCoordinatorWithOptions:(NSDictionary *)inOptions error:(NSError **)outError
{
NSPersistentStoreCoordinator *thePersistentStoreCoordinator = NULL;

NSError *theError = NULL;
NSManagedObjectModel *theManagedObjectModel = self.managedObjectModel;
if (theManagedObjectModel == NULL)
	return(NULL);
thePersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:theManagedObjectModel];
NSPersistentStore *thePersistentStore = [thePersistentStoreCoordinator addPersistentStoreWithType:self.storeType configuration:NULL URL:self.persistentStoreURL options:inOptions error:&theError];
if (thePersistentStore == NULL)
	{
	[self presentError:theError];
	}

if (outError)
	*outError = theError;
return(thePersistentStoreCoordinator);
}

- (NSManagedObjectContext *)managedObjectContext
{
NSManagedObjectContext *theManagedObjectContext = NULL;

NSString *theThreadStorageKey = [self threadStorageKey];

theManagedObjectContext = [[[NSThread currentThread] threadDictionary] objectForKey:theThreadStorageKey];
if (theManagedObjectContext == NULL)
	{
	theManagedObjectContext = [[self newManagedObjectContext] autorelease];
	if (theManagedObjectContext == NULL)
		return(NULL);
	[[[NSThread currentThread] threadDictionary] setObject:theManagedObjectContext forKey:theThreadStorageKey];
	}
return(theManagedObjectContext);
}

#pragma mark -

- (NSManagedObjectContext *)newManagedObjectContext
{
NSPersistentStoreCoordinator *thePersistentStoreCoordinator = self.persistentStoreCoordinator;
NSAssert(thePersistentStoreCoordinator != NULL, @"No persistent store coordinator!");
NSManagedObjectContext *theManagedObjectContext = [[NSManagedObjectContext alloc] init];
[theManagedObjectContext setPersistentStoreCoordinator:thePersistentStoreCoordinator];

if (self.delegate && [self.delegate respondsToSelector:@selector(coreDataManager:didCreateNewManagedObjectContext:)])
	[self.delegate coreDataManager:self didCreateNewManagedObjectContext:theManagedObjectContext];

return(theManagedObjectContext);
}

- (BOOL)migrate:(NSError **)outError;
{
BOOL theResult = NO;
@synchronized(self)
	{
	NSAssert(persistentStoreCoordinator == NULL, @"Cannot migrate persistent store with it already open.");

	NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];

	NSDictionary *theOptions = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
		NULL];

	NSError *theError = NULL;
	[[self newPersistentStoreCoordinatorWithOptions:theOptions error:&theError] autorelease];

	if (theError)
		[theError retain];

	[thePool release];

	if (theError)
		[theError autorelease];

	if (outError)
		*outError = theError;

	theResult = theError == NULL;
    }

return(theResult);
}

- (BOOL)save:(NSError **)outError;
{
BOOL theResult = NO;

[self.managedObjectContext lock];

#if TARGET_OS_IPHONE == 0
[self.managedObjectContext commitEditing];
#endif

if ([self.managedObjectContext hasChanges] == NO)
	theResult = YES;
else
	{
	[self.managedObjectContext processPendingChanges];
	theResult = [self.managedObjectContext save:outError];
	}

[self.managedObjectContext unlock];

return(theResult);
}

- (void)save
{
NSError *theError = NULL;
if ([self save:&theError] == NO)
	{
	[self presentError:theError];
	}
}

#pragma mark -

- (void)presentError:(NSError *)inError
{
if (self.delegate && [self.delegate respondsToSelector:@selector(coreDataManager:presentError:)])
	{
	[self.delegate coreDataManager:self presentError:inError];
	}
else
	{
	#if TARGET_OS_IPHONE == 1
	fprintf(stderr, "ERROR: %s (%s)\n", [[inError description] UTF8String], [[inError.userInfo description] UTF8String]);
	#else
	[[NSApplication sharedApplication] presentError:inError];
	#endif
	}
}

- (void)applicationWillTerminate:(NSNotification *)inNotification
{
#pragma unused (inNotification)

[self save];
}

#pragma mark -

+ (NSURL *)modelURLForName:(NSString *)inName
{
NSString *theModelPath = [[NSBundle mainBundle] pathForResource:inName ofType:@"mom"];
if (theModelPath == NULL)
	theModelPath = [[NSBundle mainBundle] pathForResource:inName ofType:@"momd"];
NSURL *theModelURL = [NSURL fileURLWithPath:theModelPath];
return(theModelURL);
}

+ (NSURL *)persistentStoreURLForName:(NSString *)inName storeType:(NSString *)inStoreType forceReplace:(BOOL)inForceReplace
{
inStoreType = inStoreType ? inStoreType : NSSQLiteStoreType;

NSString *thePathExtension = NULL;
if ([inStoreType isEqualToString:NSSQLiteStoreType])
	thePathExtension = @"sqlite";
else if ([inStoreType isEqualToString:NSBinaryStoreType])
	thePathExtension = @"db";

NSString *theStorePath = [[self applicationSupportFolder] stringByAppendingPathComponent:[inName stringByAppendingPathExtension:thePathExtension]];

if (inForceReplace == YES)
	{
	NSError *theError = NULL;
	if ([[NSFileManager defaultManager] fileExistsAtPath:theStorePath] == YES)
		{
		[[NSFileManager defaultManager] removeItemAtPath:theStorePath error:&theError];
		}
	}

if ([[NSFileManager defaultManager] fileExistsAtPath:theStorePath] == NO)
	{
	NSError *theError = NULL;
	NSString *theSourceFile = [[NSBundle mainBundle] pathForResource:inName ofType:thePathExtension];
	if ([[NSFileManager defaultManager] fileExistsAtPath:theSourceFile] == YES)
		{
		BOOL theResult = [[NSFileManager defaultManager] copyItemAtPath:theSourceFile toPath:theStorePath error:&theError];
		if (theResult == NO)
			{
			return(NULL);
			}
		}
	}

NSURL *thePersistentStoreURL = [NSURL fileURLWithPath:theStorePath];

return(thePersistentStoreURL);
}

+ (NSString *)applicationSupportFolder
{
NSArray *thePaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
NSString *theBasePath = ([thePaths count] > 0) ? [thePaths objectAtIndex:0] : NSTemporaryDirectory();

NSString *theBundleName = [[[[NSBundle mainBundle] bundlePath] lastPathComponent] stringByDeletingPathExtension];
NSString *theApplicationSupportFolder = [theBasePath stringByAppendingPathComponent:theBundleName];

if ([[NSFileManager defaultManager] fileExistsAtPath:theApplicationSupportFolder] == NO)
	{
	NSError *theError = NULL;
	if ([[NSFileManager defaultManager] createDirectoryAtPath:theApplicationSupportFolder withIntermediateDirectories:YES attributes:NULL error:&theError] == NO)
		return(NULL);
	}

return(theApplicationSupportFolder);
}

- (id)threadStorageKey
{
@synchronized(self)
	{
	if (threadStorageKey == NULL)
		{
		threadStorageKey = [[NSString alloc] initWithFormat:@"%@:%p", NSStringFromClass([self class]), self];
		}
	}
return(threadStorageKey);
}

@end
