//
//  SJHTTPRequestOperation.m
//  SJHTTPRequestOperation
//
//  Created by fushijian on 14/12/25.
//  Copyright (c) 2014年 fushijian. All rights reserved.
//

#import "SJHTTPRequestOperation.h"
#import <CFNetwork/CFNetwork.h>

static NSThread *requestThread = nil;
CFOptionFlags registeredEvents =  kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred |kCFStreamEventEndEncountered;


void readStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    [((__bridge SJHTTPRequestOperation*)clientCallBackInfo)  handleEvent:type];
}


#define kBufSize 1024

@interface SJHTTPRequestOperation()

@end

@implementation SJHTTPRequestOperation


-(instancetype)initWithUrl:(NSURL *)url
{
    if (self = [super init]) {
        self.url = url;
        self.requestMethod = @"GET";
        self.responseData = [[NSMutableData alloc] init];
        
        executing = NO;
        finished = NO;
    }
    return self;
}

// http请求的线程-单例
+(NSThread*)threadForRequest
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        requestThread = [[NSThread alloc] initWithTarget:self selector:@selector(requestRun) object:nil];
        [requestThread start];
    });
    return requestThread;
}

+(void)requestRun
{
    @autoreleasepool {
        
        NSLog(@"runloop in thread run");
        [[NSThread currentThread] setName:@"HTTPRequestWithCFNetWork"];
        NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}


// must implement
-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting
{
    return executing;
}

-(BOOL)isFinished
{
    return finished;
}
#pragma mark -start
-(void)start
{
    if (self.cancelled) {
        
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self performSelector:@selector(main) onThread:[[self class] threadForRequest] withObject:nil waitUntilDone:NO];
}
#pragma mark -main
-(void)main
{
    NSLog(@"request run in %@ thread",[[NSThread currentThread] name]);

    
    // 1 CFHTTPMessage
    request = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (__bridge CFStringRef)(self.requestMethod), (__bridge CFURLRef)(self.url), kCFHTTPVersion1_1);
    // 2 配置RequestHeaders
    for (NSString *key in [self.requestHeaders allKeys]) {
        CFHTTPMessageSetHeaderFieldValue(request, (__bridge CFStringRef)(key), (__bridge CFStringRef)([self.requestHeaders objectForKey:key]));
    }
    // 3 ReadStream 与 CFHTTPMessage 关联
    readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, request);
    // 4 配置 CFStreamClientContext
    CFStreamClientContext readContext = {0,(__bridge void*)self,NULL,NULL,NULL};
    if (CFReadStreamSetClient(readStream, registeredEvents, readStreamClientCallBack, &readContext)) {
        CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFReadStreamOpen(readStream);
        
        NSLog(@"begin start");
        // request start
        if ([self.delegate respondsToSelector:@selector(requestDidStarted:)]) {
            [self.delegate  requestDidStarted:self];
        }
    }
    
}

-(void)handleEvent:(CFStreamEventType)eventType
{
    switch (eventType) {
        case kCFStreamEventHasBytesAvailable:{
            
            UInt8 buf[kBufSize];
            CFIndex numberBytesRead = CFReadStreamRead(readStream, buf, kBufSize);
            if (numberBytesRead) {
                [self processDataWithBuf:buf length:numberBytesRead];
            }
            break;
        }
        case kCFStreamEventEndEncountered:{
            
            [self completeOperation];
            self.responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];

            if ([self.delegate respondsToSelector:@selector(requestDidFinished:)]) {
                [self.delegate requestDidFinished:self];
            }

            break;
        }
        case kCFStreamEventErrorOccurred:{
            [self completeOperation];
            if ([self.delegate respondsToSelector:@selector(requestDidFailed:)]) {
                [self.delegate requestDidFailed:self];
            }
        }
            
        default:
            break;
    }
}

-(void)processDataWithBuf:(UInt8*)buf length:(CFIndex)length
{
    [self.responseData appendBytes:(const void*)buf length:length];
}

- (void)completeOperation {
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

-(void)dealloc
{
    CFRelease(request);
}
@end
