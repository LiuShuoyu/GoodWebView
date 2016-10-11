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
    
    GoodWebView *webView =[[GoodWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:webView];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
