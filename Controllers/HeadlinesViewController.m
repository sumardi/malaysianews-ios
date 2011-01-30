//
//  HeadlinesViewController.m
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

#import "HeadlinesViewController.h"
#import "CFeed.h"
#import "CFeedStore.h"
#import "CFeedFetcher.h"
#import "CFeedEntry.h"
#import "EntryViewController.h"
#import "MalaysiaNewsAppDelegate.h"

@implementation HeadlinesViewController

@synthesize appDelegate, rss, entries, uiTableView;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (MalaysiaNewsAppDelegate *)[[UIApplication sharedApplication] delegate];
	CFeedFetcher *feedFetcher = [[CFeedFetcher alloc] initWithFeedStore:[CFeedStore instance]];
	[feedFetcher setDelegate:self];
	NSError *error = nil;
	[feedFetcher subscribeToURL:[NSURL URLWithString:rss] error:&error];
	[feedFetcher setFetchInterval:1];
	
	CFeed *feed = [[CFeedStore instance] feedForURL:[NSURL URLWithString:rss] fetch:YES];
	entries = [[NSArray alloc] initWithArray:[[feed entries] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fetchOrder" ascending:YES]]]];
	[uiTableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	CFeedFetcher *feedFetcher = [[CFeedFetcher alloc] initWithFeedStore:[CFeedStore instance]];
	[feedFetcher setDelegate:self];
	NSError *error = nil;
	[feedFetcher subscribeToURL:[NSURL URLWithString:rss] error:&error];
	[feedFetcher setFetchInterval:1];
}

- (void)feedFetcher:(CFeedFetcher *)inFeedFetcher didFetchFeed:(CFeed *)inFeed {
	entries = [[NSArray alloc] initWithArray:[[inFeed entries] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fetchOrder" ascending:YES]]]];
	[uiTableView reloadData];
}


/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [entries count];
}

- (NSString *)flattenHTML:(NSString *)html {
    NSScanner *thescanner;
    NSString *text = nil;
    thescanner = [NSScanner scannerWithString:html];
    while ([thescanner isAtEnd] == NO) {
        [thescanner scanUpToString:@"<" intoString:nil];
        [thescanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@" "];
	}
    return html;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
		cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.detailTextLabel.numberOfLines = 0;
		cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];

    }
    // Configure the cell...
	CFeedEntry *theEntry = [entries objectAtIndex:indexPath.row];
	cell.textLabel.text = theEntry.title;
	cell.detailTextLabel.text = [self flattenHTML:theEntry.content];
	NSLog(@"%@", [entries objectAtIndex:indexPath.row]);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CFeedEntry *theEntry = [entries objectAtIndex:indexPath.row];
    NSString *cellText = theEntry.title;
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
	UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    CGSize entrySize = [cellText sizeWithFont:textFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	
	NSString *cellDetail = [self flattenHTML:theEntry.content];
	UIFont *detailFont = [UIFont fontWithName:@"Helvetica" size:13.0];
	CGSize detailSize = [cellDetail sizeWithFont:detailFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	
    return entrySize.height + detailSize.height + 10;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	EntryViewController *entryViewController = [[EntryViewController alloc] initWithNibName:@"EntryView" bundle:nil];
	entryViewController.link = [[entries objectAtIndex:indexPath.row] link];
	[appDelegate.navigationController pushViewController:entryViewController animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[appDelegate release];
	[rss release];
	[entries release];
	[uiTableView release];
    [super dealloc];
}


@end

