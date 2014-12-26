//
//  ViewController.m
//  SJHTTPRequestOperation
//
//  Created by fushijian on 14/12/25.
//  Copyright (c) 2014年 fushijian. All rights reserved.
//

#import "ViewController.h"
#import "SJHTTPRequestOperation.h"



#define STRURL @"http://www.baidu.com"

@interface ViewController () <SJHTTPRequestOperationDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    SJHTTPRequestOperation *oper = [[SJHTTPRequestOperation alloc] initWithUrl:[NSURL URLWithString:STRURL]];
    oper.delegate = self;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperation:oper];
    
}


-(void)requestDidStarted:(SJHTTPRequestOperation *)request
{
//    NSLog(@"sleep 10");
//    sleep(10);
    NSLog(@"started");
}

-(void)request:(SJHTTPRequestOperation *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"responseHeaders:%@",responseHeaders);
}

-(void)requestDidFinished:(SJHTTPRequestOperation *)request
{
    NSLog(@"response: %@",request.responseString);
}

-(void)requestDidFailed:(SJHTTPRequestOperation *)request
{
    NSLog(@"failed");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
