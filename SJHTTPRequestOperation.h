//
//  SJHTTPRequestOperation.h
//  SJHTTPRequestOperation
//
//  Created by fushijian on 14/12/25.
//  Copyright (c) 2014年 fushijian. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SJHTTPRequestOperationDelegate;

@interface SJHTTPRequestOperation : NSOperation
{
    CFHTTPMessageRef request;
    CFReadStreamRef readStream;
    BOOL finished;
    BOOL executing;
}

@property(nonatomic,strong) NSURL *url;
@property(nonatomic,assign) id <SJHTTPRequestOperationDelegate>delegate;

@property(nonatomic,strong) NSMutableDictionary *requestHeaders;
@property(nonatomic,strong) NSString *requestMethod; //default GET (only support GET)


//response
@property(nonatomic,strong) NSMutableData *responseData;
@property(nonatomic,strong) NSString *responseString;
@property(nonatomic,strong) NSDictionary *responseHeaders;
@property(nonatomic,assign) NSInteger responseStatusCode;

-(instancetype)initWithUrl:(NSURL*)url;

-(void)handleEvent:(CFStreamEventType)eventType;

@end


@protocol SJHTTPRequestOperationDelegate <NSObject>

-(void)requestDidStarted:(SJHTTPRequestOperation*)request;
-(void)request:(SJHTTPRequestOperation*)request didReceiveResponseHeaders:(NSDictionary*)responseHeaders;
- (void)requestDidFinished:(SJHTTPRequestOperation *)request;
- (void)requestDidFailed:(SJHTTPRequestOperation *)request;

@end