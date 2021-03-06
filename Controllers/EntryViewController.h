//
//  EntryViewController.h
//  MalaysiaNews
//
//  Created by Sumardi Shukor on 1/31/11.
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


@interface EntryViewController : UIViewController <UIWebViewDelegate> {
	UIWindow *window;
	UIWebView *webView;
	NSString *link;
	UIActivityIndicatorView *m_activity;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *m_activity;

@end
