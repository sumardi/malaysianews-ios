//
//  CURLOperation2.m
//  HTTPClientOperation
//
//  Created by Jonathan Wight on 10/26/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CURLOperation2.h"

#import "CHTTPClient.h"

@interface CURLOperation2 () <CHTTPClientDelegate>
@property (readwrite, retain) NSURLResponse *response;
@property (readwrite, retain) NSError *error;
@end

#pragma mark -

@implementation CURLOperation2

@synthesize request;
@synthesize response;
@synthesize error;

- (id)initWithRequest:(NSURLRequest *)inRequest;
    {
    if ((self = [super init]) != NULL)
        {
        request = [inRequest copy];
        }
    return(self);
    }

- (void)dealloc
    {

    //
    [super dealloc];
    }

- (void)main
    {
    NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];
    
    CHTTPClient *theClient = [[[CHTTPClient alloc] initWithRequest:self.request] autorelease];
    theClient.delegate = self;
    [theClient main];
        
    [thePool release];
    }

#pragma mark -

- (void)didReceiveData:(NSData *)inData
    {
	NSLog(@"DID RECEIVE DATA");
    }

- (void)didFinish
    {
	NSLog(@"DID FINISH");
    }
    
- (void)didFailWithError:(NSError *)inError
    {
	self.error = inError;
    }

#pragma mark -

- (void)httpClient:(CHTTPClient *)inClient didReceiveResponse:(NSURLResponse *)inResponse;
    {
	self.response = inResponse;
    }
	
- (void)httpClientDidFinishLoading:(CHTTPClient *)inClient;
	{
	[self didFinish];
	}

- (void)httpClient:(CHTTPClient *)inClient didReceiveData:(NSData *)inData
	{
	[self didReceiveData:inData];
	}

@end
