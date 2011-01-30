//
//  CURLOperation2.h
//  HTTPClientOperation
//
//  Created by Jonathan Wight on 10/26/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CURLOperation2 : NSOperation {
    NSURLRequest *request;
}

@property (readonly, retain) NSURLRequest *request;
@property (readonly, retain) NSURLResponse *response;
@property (readonly, retain) NSError *error;

- (id)initWithRequest:(NSURLRequest *)inRequest;

- (void)didReceiveData:(NSData *)inData;

- (void)didFinish;
- (void)didFailWithError:(NSError *)inError;

@end
