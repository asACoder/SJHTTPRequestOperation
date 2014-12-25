//
//  ViewController.m
//  SJHTTPRequestOperation
//
//  Created by fushijian on 14/12/25.
//  Copyright (c) 2014年 fushijian. All rights reserved.
//

#import "ViewController.h"
#import "SJHTTPRequestOperation.h"



//#define STRURL @"http://118.194.57.122:8888/httpclient/agentservice.jsp?verifyCode=3F742948DA367004727397CE7261E624&Page=1&Pagesize=20&AgentId=163423162&messagename=GetPropertySurveyOrderInfoList&city=%E5%8C%97%E4%BA%AC&wirelesscode=FD694829C9B1173787C3FA3B650123C1"

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
    NSLog(@"started");
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
