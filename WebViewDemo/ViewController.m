//
//  ViewController.m
//  WebViewDemo
//
//  Created by d.x.c on 16/10/9.
//  Copyright © 2016年 zhixun. All rights reserved.
//

#import "ViewController.h"
#import "GoodWebView.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GoodWebView *webView =[[GoodWebView alloc] initWithFrame:CGRectMake(20, 20, 300, 300)];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc  ]initWithTarget:self action:@selector(tapViewMoreBig:)];
    [self.view addSubview:webView];
    [webView addGestureRecognizer:tap];
    webView.center=self.view.center;
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)tapViewMoreBig:(UITapGestureRecognizer*)tap
{
    UIView *view= tap.view;
    view.frame =CGRectMake(0, 0, CGRectGetWidth(view.frame)*1.5, CGRectGetWidth(view.frame)*1.5);
    view.center=self.view.center;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
