//
//  CCoreDataManager.h
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

#import <CoreData/CoreData.h>

@protocol CCoreDataManagerDelegate;

@interface CCoreDataManager : NSObject {
	NSString *name;
	NSURL *modelURL;
	NSURL *persistentStoreURL;
	NSString *storeType;
	BOOL forceReplace;
	NSDictionary *storeOptions;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
	id threadStorageKey;
	id <CCoreDataManagerDelegate> delegate;
}

+ (NSURL *)modelURLForName:(NSString *)inName;

@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSURL *modelURL;
@property (readwrite, retain) NSURL *persistentStoreURL;
@property (readwrite, retain) NSString *storeType;
@property (readwrite, assign) BOOL forceReplace;
@property (readwrite, retain) NSDictionary *storeOptions;

@property (readwrite, nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readwrite, nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (readwrite, nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (readwrite, assign) id <CCoreDataManagerDelegate> delegate;

- (id)init;

/// You don't need to call this. Subclasses can override to change default behavior.
- (NSManagedObjectContext *)newManagedObjectContext;

- (BOOL)migrate:(NSError **)outError;

- (BOOL)save:(NSError **)outError;
- (void)save;

- (void)presentError:(NSError *)inError;

@end

#pragma mark -

@protocol CCoreDataManagerDelegate <NSObject>

@optional
- (void)coreDataManager:(CCoreDataManager *)inCoreDataManager didCreateNewManagedObjectContext:(NSManagedObjectContext *)inManagedObjectContext;
- (void)coreDataManager:(CCoreDataManager *)inCoreDataManager presentError:(NSError *)inError;

@end
