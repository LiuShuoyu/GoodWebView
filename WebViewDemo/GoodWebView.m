//
//  GoodWebView.m
//  WebViewDemo
//
//  Created by d.x.c on 16/10/9.
//  Copyright © 2016年 zhixun. All rights reserved.
//

#import "GoodWebView.h"
#import <WebKit/WebKit.h>
#import "IMY_NJKWebViewProgress.h"


@interface GoodWebView ()<UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate,IMY_NJKWebViewProgressDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIView *webView;
@property (nonatomic, assign) double estimatedProgress;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) IMY_NJKWebViewProgress* webViewProgress;

@end


@implementation GoodWebView

- (id)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame: frame];
    if (self)
    {
        Class wkWebView = NSClassFromString(@"WKWebView");
        if (wkWebView)
        {
            self.webView =[self instancetypeWKWebView];
        }
        else
        {
            self.webView =[self instancetypeUIWebView];
        }

        [self addSubview:self.webView];
        self.scalesPageToFit = YES;

    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self =[super initWithCoder:aDecoder];
    if (self)
    {
        
    }
    return self;
}
- (id)init
{
    self=[super init];
    if (self)
    {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.webView.frame =CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame));
}


#pragma mark WKWebView
- (WKWebView *)instancetypeWKWebView
{
    WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences = [WKPreferences  new];
    configuration.preferences.javaScriptCanOpenWindowsAutomatically =false;
    configuration.userContentController = [WKUserContentController new];
    
    NSLog(@"self.bounds.wheight=%f",self.bounds.size.height);
    WKWebView* webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    webView.allowsBackForwardNavigationGestures =YES;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    return webView;
}

#pragma mark WKWebViewDelegate


#pragma mark UIWebView and UIWebViewDelegate
- (UIWebView*)instancetypeUIWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.bounds];
    //防止留在，
    webView.backgroundColor =[UIColor clearColor];
    webView.opaque =NO;
    for (UIView *subview in [webView.scrollView subviews])
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            ((UIImageView *) subview).image = nil;
            subview.backgroundColor = [UIColor clearColor];
        }
    }
    self.webViewProgress =[[IMY_NJKWebViewProgress alloc] init];
    webView.delegate =_webViewProgress;
    self.webViewProgress.webViewProxyDelegate = self;
    self.webViewProgress.progressDelegate = self;
    return webView;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    if(self.originRequest == nil)
//    {
//        self.originRequest = webView.request;
//    }
//    
//    [self callback_webViewDidFinishLoad];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [self callback_webViewDidStartLoad];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    [self callback_webViewDidFailLoadWithError:error];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    BOOL resultBOOL = [self callback_webViewShouldStartLoadWithRequest:request navigationType:navigationType];
//    return resultBOOL;
    return YES;
}
- (void)webViewProgress:(IMY_NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    self.estimatedProgress = progress;
}


-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}




#pragma mark KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        self.estimatedProgress = [change[NSKeyValueChangeNewKey] doubleValue];
    }
    else if ([keyPath isEqualToString:@"title"])
    {
        self.title = change[NSKeyValueChangeNewKey];
    }
}
@end
