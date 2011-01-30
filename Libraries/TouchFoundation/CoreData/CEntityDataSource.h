//
//  CEntityDataSource.h
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

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@protocol CEntityDataSource

@property (readwrite, nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (readwrite, nonatomic, retain) NSEntityDescription *entityDescription;
@property (readwrite, nonatomic, retain) NSArray *sortDescriptors;
@property (readwrite, nonatomic, retain) NSPredicate *predicate;
@property (readonly, nonatomic, retain) NSArray *items;

- (BOOL)fetch:(NSError **)outError;

@end

#pragma mark -

@interface CEntityDataSource : NSObject <CEntityDataSource> {
	NSManagedObjectContext *managedObjectContext;
	NSEntityDescription *entityDescription;
	NSArray *sortDescriptors;
	NSPredicate *predicate;
	NSArray *items;
}

@property (readwrite, nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (readwrite, nonatomic, retain) NSEntityDescription *entityDescription;
@property (readwrite, nonatomic, retain) NSPredicate *predicate;
@property (readonly, nonatomic, retain) NSArray *items;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)inManagedObjectContext entityDescription:(NSEntityDescription *)inEntityDescription;
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)inManagedObjectContext entityName:(NSString *)inEntityName;

- (BOOL)fetch:(NSError **)outError;

@end
