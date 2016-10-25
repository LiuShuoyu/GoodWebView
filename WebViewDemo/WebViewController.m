//
//  WebViewController.m
//  WebViewDemo
//
//  Created by 刘小弟 on 16/10/11.
//  Copyright © 2016年 zhixun. All rights reserved.
//

#import "WebViewController.h"
#import "GoodWebView.h"

@implementation WebViewController

-(void)loadView
{
    self.view =[[GoodWebView alloc] init];
    self.view.backgroundColor =[UIColor whiteColor];
    [(GoodWebView *)self.view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.youtube.com"]]];

}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
}

@end
