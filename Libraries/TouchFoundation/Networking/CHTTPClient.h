//
//  CHTTPClient.h
//  HTTPClientOperation
//
//  Created by Jonathan Wight on 10/23/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTemporaryData;

@protocol CHTTPClientDelegate;

@interface CHTTPClient : NSObject {
    NSURLRequest *request;
    CFReadStreamRef readStream;
    NSUInteger initialBufferLength;
    NSMutableData *initialBuffer;
    NSUInteger bufferLength;
    NSMutableData *buffer;
    CTemporaryData *data;
    CFHTTPMessageRef requestMessage;
    CFHTTPMessageRef responseMessage;
    id <CHTTPClientDelegate> delegate;  
}

@property (readwrite, nonatomic, assign) NSUInteger initialBufferLength;
@property (readwrite, nonatomic, assign) NSUInteger bufferLength;
@property (readwrite, nonatomic, assign) id <CHTTPClientDelegate> delegate;    

- (id)initWithRequest:(NSURLRequest *)inRequest;

- (void)main;

@end

#pragma mark -

@protocol CHTTPClientDelegate <NSObject>
@optional
- (void)httpClient:(CHTTPClient *)inClient didReceiveResponse:(NSURLResponse *)inResponse;
- (void)httpClientDidFinishLoading:(CHTTPClient *)inClient;
- (void)httpClient:(CHTTPClient *)inClient didFailWithError:(NSError *)inError;
- (void)httpClient:(CHTTPClient *)inClient didReceiveData:(NSData *)inData;
@end