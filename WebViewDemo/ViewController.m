//
//  ViewController.m
//  WebViewDemo
//
//  Created by d.x.c on 16/10/9.
//  Copyright © 2016年 zhixun. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"

@interface ViewController ()

@property(nonatomic,strong)UIButton *webBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    
    
}

-(void)setUI
{
    self.view.backgroundColor =[UIColor whiteColor];
    self.title =@"demo";
    [self.view addSubview:self.webBtn];
}

-(UIButton *)webBtn
{
    if (!_webBtn)
    {
        _webBtn =[[UIButton alloc] initWithFrame:CGRectMake(200, 100, 150, 50)];
        _webBtn.center =self.view.center;
        _webBtn.backgroundColor =[UIColor redColor];
        [_webBtn setTitle:@"点击跳转" forState:UIControlStateNormal];
        [_webBtn addTarget:self action:@selector(clikWebBtnSkipWebVc:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _webBtn;
}

-(void)clikWebBtnSkipWebVc:(UIButton *)btn
{
    WebViewController *webVC =[[WebViewController alloc] init];
    [self.navigationController pushViewController:webVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
