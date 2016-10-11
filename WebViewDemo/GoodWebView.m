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


@interface GoodWebView ()<UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate,IMY_NJKWebViewProgressDelegate>

@property (nonatomic, assign) double estimatedProgress;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) IMY_NJKWebViewProgress* webViewProgress;
@property (nonatomic, strong) NSURLRequest *request;

@end


@implementation GoodWebView

@synthesize showWebView =_showWebView;
@synthesize usingUIWebView =_usingUIWebView;

#pragma mark 赖加载
- (UIView *)showWebView
{
    if (!_showWebView)
    {
        Class wkWebView = NSClassFromString(@"WKWebView");
        if (wkWebView)
        {
            _showWebView =[self instancetypeWKWebView];
        }
        else
        {
            _showWebView =[self instancetypeUIWebView];
        }
        [self addSubview:_showWebView];
        self.scalesPageToFit = YES;
    }
    return _showWebView;
}

#define mark   重写layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.showWebView.frame =CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame));
}

#pragma mark WKWebView annd UIWebView  初始化
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
#pragma mark WKWebViewDelegate

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) //当网页目标处触发目标为nil的时候，避免重新开辟网页， 直接强制打开连接，
    {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL resultBOOL = [self handler_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    if(resultBOOL)
    {
        self.request =navigationAction.request;
        if(!navigationAction.targetFrame)
        {
            NSString *url = navigationAction.request.URL.absoluteString;
            NSString *uf8URL =[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:uf8URL]]];
        }
        decisionHandler(WKNavigationActionPolicyAllow); 
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self handler_webViewDidStartLoad];
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self handler_webViewDidFinishLoad];
}
- (void)webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self handler_webViewDidFailLoadWithError:error];
}
- (void)webView: (WKWebView *)webView didFailNavigation:(WKNavigation *) navigation withError: (NSError *) error
{
    [self handler_webViewDidFailLoadWithError:error];
}
#pragma mark   UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
   return  [self handler_webViewShouldStartLoadWithRequest:request navigationType:navigationType];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self handler_webViewDidStartLoad];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self handler_webViewDidFinishLoad];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self handler_webViewDidFailLoadWithError:error];
}
- (void)webViewProgress:(IMY_NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    self.estimatedProgress = progress;
}


#pragma mark mainCall_back  回调
- (BOOL)handler_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        
        if(navigationType == -1) //兼容 UIWebView 和WKWebView 的navigationType 的差距
        {
            navigationType = UIWebViewNavigationTypeOther;
        }
       return  [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return YES;
}
- (void)handler_webViewDidStartLoad
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [self.delegate webViewDidStartLoad:self];
    }
}
- (void)handler_webViewDidFinishLoad
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
}
- (void)handler_webViewDidFailLoadWithError:(NSError *)error
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [self.delegate webView:self didFailLoadWithError:error];
    }
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
