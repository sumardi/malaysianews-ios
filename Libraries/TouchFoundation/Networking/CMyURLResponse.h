//
//  CMyURLResponse.h
//  HTTPClientOperation
//
//  Created by Jonathan Wight on 10/26/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMyURLResponse : NSHTTPURLResponse {
    CFHTTPMessageRef message;
}

- (id)initWithMessage:(CFHTTPMessageRef)inMessage;

@end
