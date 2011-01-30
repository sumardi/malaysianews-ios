//
//  CHTTPClient.m
//  HTTPClientOperation
//
//  Created by Jonathan Wight on 10/23/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CHTTPClient.h"

#import "CTemporaryData.h"
#import "CMyURLResponse.h"

@interface CHTTPClient ()
@property (readwrite, nonatomic, retain) NSURLRequest *request;
@property (readwrite, nonatomic, assign) CFReadStreamRef readStream;
@property (readwrite, nonatomic, retain) NSMutableData *initialBuffer;
@property (readwrite, nonatomic, retain) NSMutableData *buffer;
@property (readwrite, nonatomic, retain) CTemporaryData *data;
@property (readwrite, nonatomic, assign) CFHTTPMessageRef requestMessage;
@property (readwrite, nonatomic, assign) CFHTTPMessageRef responseMessage;    

- (void)open;
- (void)process;
- (void)close;

- (void)readContent;
//- (void)readContent:(NSInteger)inContentLength;

@end

#pragma mark -

@implementation CHTTPClient

@synthesize request;
@synthesize readStream;
@synthesize initialBufferLength;
@synthesize initialBuffer;
@synthesize bufferLength;
@synthesize buffer;
@synthesize data;
@synthesize requestMessage;
@synthesize responseMessage;
@synthesize delegate;

- (id)initWithRequest:(NSURLRequest *)inRequest
    {
    if ((self = [super init]) != NULL)
        {
        request = [inRequest retain];
        initialBufferLength = 32 * 1024;
        bufferLength = 32 * 1024;
        }
    return(self);
    }

- (void)dealloc
    {
    [request release];
    request = NULL;
    
    if (readStream)
        {
        CFRelease(readStream);
        readStream = NULL;
        }
    
    [initialBuffer release];
    initialBuffer = NULL;

    [buffer release];
    buffer = NULL;
    
    [data release];
    data = NULL;
    
    if (requestMessage)
        {
        CFRelease(requestMessage);
        requestMessage = NULL;
        }
    
    if (responseMessage)
        {
        CFRelease(responseMessage);
        responseMessage = NULL;
        }
    //
    [super dealloc];
    }

#pragma mark -

- (CTemporaryData *)data
    {
    if (data == NULL)
        {
        data = [[CTemporaryData alloc] initWithMemoryLimit:8 * 1024 * 1024];
        }
    return(data);
    }

#pragma mark -

- (void)main
    {
    [self open];
    [self process];
    [self close];
    }

- (void)open
    {
    self.requestMessage = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("GET"), (CFURLRef)self.request.URL, kCFHTTPVersion1_1);
    CFHTTPMessageSetHeaderFieldValue(self.requestMessage, CFSTR("Host"), (CFStringRef)self.request.URL.host);

    self.initialBuffer = [NSMutableData dataWithLength:self.initialBufferLength];
    self.buffer = [NSMutableData dataWithLength:self.bufferLength];
    }

#pragma mark -

- (void)readContent
{
    self.data = [[[CTemporaryData alloc] initWithMemoryLimit:1 * 1024 * 1024] autorelease];
    [self.data appendData:(id)self.initialBuffer error:NULL];
	
    do
	{
        CFIndex theBytesRead = CFReadStreamRead(self.readStream, [self.buffer mutableBytes], self.buffer.length);
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(httpClient:didReceiveData:)])
		{
			// TODO bytes nocopy?
			NSData *theData = [NSData dataWithBytes:[self.buffer mutableBytes] length:theBytesRead];
			[self.delegate httpClient:self didReceiveData:theData];
		}
		
        [self.data appendBytes:[self.buffer mutableBytes] length:theBytesRead error:NULL];
	}
    while (CFReadStreamGetStatus(self.readStream) == kCFStreamStatusOpen);
}

- (void)process
    {
    self.readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, self.requestMessage);
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanTrue);

    CFReadStreamOpen(self.readStream);

    CFIndex theBytesRead = CFReadStreamRead(self.readStream, self.initialBuffer.mutableBytes, self.initialBuffer.length);
    self.initialBuffer.length = theBytesRead;
    
    self.responseMessage = (CFHTTPMessageRef)CFReadStreamCopyProperty(self.readStream, kCFStreamPropertyHTTPResponseHeader);
    
    if ([self.delegate respondsToSelector:@selector(httpClient:didReceiveResponse:)])
        {
        CMyURLResponse *theResponse = [[[CMyURLResponse alloc] initWithMessage:self.responseMessage] autorelease];
        [self.delegate httpClient:self didReceiveResponse:theResponse];
        }
    
    CFIndex theStatusCode = CFHTTPMessageGetResponseStatusCode(self.responseMessage);
    NSDictionary *theRequestHeaders = [(id)CFHTTPMessageCopyAllHeaderFields(self.requestMessage) autorelease];

    NSDictionary *theResponseHeaders = [(id)CFHTTPMessageCopyAllHeaderFields(self.responseMessage) autorelease];
    if (theStatusCode == 401)
        {
        if ([(id)theRequestHeaders objectForKey:@"Authorization"])
            {
            NSLog(@"Bad auth");
            return;
            }
        
        CFHTTPAuthenticationRef theAuthentication = CFHTTPAuthenticationCreateFromResponse(kCFAllocatorDefault, self.responseMessage);
        if (theAuthentication == NULL)
            {
            NSLog(@"Bad auth");
            return;
            }
        CFStreamError theError;
        BOOL theFlag = CFHTTPAuthenticationIsValid(theAuthentication, &theError);
        NSLog(@"AUTH? %d", theFlag);
        
//        NSDictionary *theCredentials = [NSDictionary dictionaryWithObjectsAndKeys:
//            @"schwa", (id)kCFHTTPAuthenticationUsername,
//            @"*****", (id)kCFHTTPAuthenticationPassword,
//            NULL];
//        
//        theFlag = CFHTTPMessageApplyCredentialDictionary(self.requestMessage, theAuthentication, theCredentials, &theError);
//        NSLog(@"CRED? %d", theFlag);
//        
//        [self process];

        CFRelease(theAuthentication);
        
        return;
        }
    

    if ([self.request.HTTPMethod isEqualToString:@"HEAD"] || (theStatusCode >= 100 && theStatusCode <= 199) || theStatusCode == 204 || theStatusCode == 304)
        {
        NSLog(@"No body");
        }
    else if ([(id)theResponseHeaders objectForKey:@"Transfer-Encoding"] && [[(id)theResponseHeaders objectForKey:@"Transfer-Encoding"] isEqualToString:@"identity"] == NO)
        {
        NSLog(@"CHUNKED?");
        [self readContent];
        }
    else
        {
        [self readContent];
        }
    }

- (void)close
    {
	NSLog(@"CLOSE");
	
    if (readStream)
        {
        CFReadStreamClose(readStream);
        }
        
	if (self.delegate && [self.delegate respondsToSelector:@selector(httpClientDidFinishLoading:)])
		{
		[self.delegate httpClientDidFinishLoading:self];
		}
    }

@end
