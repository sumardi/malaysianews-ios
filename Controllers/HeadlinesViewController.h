//
//  HeadlinesViewController.h
//  MalaysiaNews
//
//  Created by Sumardi Shukor on 1/30/11.
//  Copyright 2011 Software Machine Development. All rights reserved.
//	<support[at]smd.com.my>
//
//	Malaysia News is free software; you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation; either version 2 of the License, or
//	(at your option) any later version.
// 
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
// 
//	You should have received a copy of the GNU General Public License
//	along with Malaysia News. If not, see <http://www.gnu.org/licenses/>

#import <UIKit/UIKit.h>
#import "CFeedFetcher.h"
@class CFeedEntry;
@class MalaysiaNewsAppDelegate;

@interface HeadlinesViewController : UITableViewController <CFeedFetcherDelegate> {
	MalaysiaNewsAppDelegate *appDelegate;
	
	NSString *rss;
	NSArray *entries;
	
	UITableView *uiTableView;
}

@property (nonatomic, retain) MalaysiaNewsAppDelegate *appDelegate;

@property (nonatomic, retain) NSString *rss;
@property (nonatomic, retain) NSArray *entries;

@property (nonatomic, retain) IBOutlet UITableView *uiTableView;

@end
