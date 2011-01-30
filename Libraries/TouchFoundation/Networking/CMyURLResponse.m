//
//  CMyURLResponse.m
//  HTTPClientOperation
//
//  Created by Jonathan Wight on 10/26/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CMyURLResponse.h"

@implementation CMyURLResponse

- (id)initWithMessage:(CFHTTPMessageRef)inMessage
    {
    if ((self = [super initWithURL:NULL MIMEType:NULL expectedContentLength:-1 textEncodingName:NULL]) != NULL)
        {
        CFRetain(inMessage);
        message = inMessage;
        }
    return(self);
    }

- (NSInteger)statusCode
    {
    return(CFHTTPMessageGetResponseStatusCode(message));
    }
    
- (NSDictionary *)allHeaderFields
    {
    return([(id)CFHTTPMessageCopyAllHeaderFields(message) autorelease]);
    }


@end
