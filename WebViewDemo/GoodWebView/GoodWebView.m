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
@property (strong, nonatomic) UIProgressView *progressView;

@end


@implementation GoodWebView

@synthesize showWebView =_showWebView;
@synthesize isShowWKWebViewClass =_isShowWKWebViewClass;
@synthesize scalesPageToFit = _scalesPageToFit;

#pragma mark dealloc
-(void)dealloc
{
    [self stopLoading];
    if (_isShowWKWebViewClass)
    {
        [self.showWebView removeObserver:self forKeyPath:@"title" context:nil];
        [self.showWebView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
        ((WKWebView *)self.showWebView).UIDelegate =nil;
        ((WKWebView *)self.showWebView).navigationDelegate =nil;
    }
    else
    {
        ((UIWebView *)self.showWebView).delegate =nil;
    }
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
}


#pragma mark   重写layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.showWebView.frame =CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.progressView.frame =CGRectMake(0, 64, CGRectGetWidth(self.frame), 5);

}

#pragma mark 赖加载 执行 初始化

- (UIProgressView *)progressView
{
    if (!_progressView)
    {
        _progressView =[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor =[UIColor blueColor];
        _progressView.trackTintColor =[UIColor groupTableViewBackgroundColor];

//        [self addSubview:_progressView];
    }
    _progressView.hidden =_progressView.progress<1 ?NO:YES;
    return _progressView;
}

- (UIView *)showWebView
{
    if (!_showWebView)
    {
        Class wkWebView = NSClassFromString(@"WKWebView");
        if (wkWebView)
        {
            _showWebView =[self instancetypeWKWebView];
            _isShowWKWebViewClass =YES;
            
        }
        else
        {
            _showWebView =[self instancetypeUIWebView];
            _isShowWKWebViewClass =NO;
        }
        [self addSubview:_showWebView];
        self.scalesPageToFit = YES;
    }
    return _showWebView;
}

#pragma mark WKWebView annd UIWebView  初始化
- (WKWebView *)instancetypeWKWebView
{
    WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences = [WKPreferences  new];
    configuration.preferences.javaScriptCanOpenWindowsAutomatically =false;
    configuration.userContentController = [WKUserContentController new];
    
    NSLog(@"self.bounds.wheight=%@",NSStringFromCGRect(self.bounds));
    WKWebView* webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    webView.allowsBackForwardNavigationGestures =YES;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    return webView;
}
- (UIWebView*)instancetypeUIWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.bounds];
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
#pragma mark WKNavigationDelegate

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) //当网页目标处触发目标为nil的时候，避免重新开辟网页， 直接强制打开连接，
    {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark WKNavigationDelegate

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
    [self.progressView setProgress:self.estimatedProgress  animated:YES];

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


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString*,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        self.estimatedProgress = [change[NSKeyValueChangeNewKey] doubleValue];
        [self.progressView setProgress:self.estimatedProgress  animated:YES];
        
        NSLog(@"self.progress =%f",self.progressView.progress);
    }
    else if ([keyPath isEqualToString:@"title"])
    {
        self.title = change[NSKeyValueChangeNewKey];
    }
}

#pragma mark  自定义的GoodWeb基础方法

-(UIScrollView *)scrollView
{
    if (_isShowWKWebViewClass)
    {
        return  [(WKWebView*)self.showWebView scrollView];
    }
    else
    {
        return [(UIWebView*)self.showWebView scrollView];
    }
}

- (NSURL *)URL
{
    if(_isShowWKWebViewClass)
    {
        return [(WKWebView*)self.showWebView URL];

    }
    else
    {
        return [(UIWebView*)self.showWebView request].URL;;
    }
}

- (NSURLRequest *)request
{
    if(_isShowWKWebViewClass)
    {
        return self.request;
        
    }
    else
    {
        return [(UIWebView*)self.showWebView request];;
    }
}

-(BOOL)isLoading
{
    if (_isShowWKWebViewClass)
    {
        return  [(WKWebView*)self.showWebView isLoading];
    }
    else
    {
        return [(UIWebView*)self.showWebView isLoading];
    }
}

-(BOOL)canGoBack
{
    if (_isShowWKWebViewClass)
    {
        return  [(WKWebView*)self.showWebView canGoBack];
    }
    else
    {
        return [(UIWebView*)self.showWebView canGoBack];
    }
}

-(BOOL)canGoForward
{
    if (_isShowWKWebViewClass)
    {
        return  [(WKWebView*)self.showWebView canGoForward];
    }
    else
    {
        return [(UIWebView*)self.showWebView canGoForward];
    }
}

- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    _scalesPageToFit =scalesPageToFit;
    if (_isShowWKWebViewClass)
    {
        WKWebView* webView =(WKWebView *) _showWebView;
        
        NSString *jScript = @"var meta = document.createElement('meta'); \
        meta.name = 'viewport'; \
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
        var head = document.getElementsByTagName('head')[0];\
        head.appendChild(meta);";
        
        if(scalesPageToFit)
        {
            WKUserScript *wkUScript = [[NSClassFromString(@"WKUserScript") alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
            [webView.configuration.userContentController addUserScript:wkUScript];
        }
        else
        {
            NSMutableArray* array = [NSMutableArray arrayWithArray:webView.configuration.userContentController.userScripts];
            for (WKUserScript *wkUScript in array)
            {
                if([wkUScript.source isEqual:jScript])
                {
                    [array removeObject:wkUScript];
                    break;
                }
            }
            for (WKUserScript *wkUScript in array)
            {
                [webView.configuration.userContentController addUserScript:wkUScript];
            }
        }
    }
    else
    {
        ((UIWebView *)self.showWebView).scalesPageToFit =  scalesPageToFit;
    }
}

- (BOOL)scalesPageToFit
{
    if (_isShowWKWebViewClass)
    {
        return  _scalesPageToFit;
    }
    else
    {
       return  [(UIWebView*)self.showWebView scalesPageToFit];
    }
}

- (void)loadRequest:(NSURLRequest *)request
{
    self.request =request;
    if (_isShowWKWebViewClass)
    {
        [(WKWebView*)self.showWebView loadRequest:request];
    }
    else
    {
        [(UIWebView*)self.showWebView loadRequest:request];
    }
}
- (void)loadHTMLString:(NSString *)string baseURL:( NSURL *)baseURL
{
    if (_isShowWKWebViewClass)
    {
        [(WKWebView*)self.showWebView loadHTMLString:string baseURL:baseURL];
    }
    else
    {
        [(UIWebView*)self.showWebView loadHTMLString:string baseURL:baseURL];        
    }
    
}

- (void)reload
{
    if (_isShowWKWebViewClass)
    {
        [(WKWebView*)self.showWebView reload];
    }
    else
    {
        [(UIWebView*)self.showWebView reload];
    }
}
- (void)stopLoading
{
    if (_isShowWKWebViewClass)
    {
        [(WKWebView*)self.showWebView stopLoading];
    }
    else
    {
        [(UIWebView*)self.showWebView stopLoading];
    }
}
- (void)goBack
{
    if (_isShowWKWebViewClass)
    {
        [(WKWebView*)self.showWebView goBack];
    }
    else
    {
        [(UIWebView*)self.showWebView goBack];
    }
}
- (void)goForward
{
    if (_isShowWKWebViewClass)
    {
        [(WKWebView*)self.showWebView goForward];
    }
    else
    {
        [(UIWebView*)self.showWebView goForward];
    }
}


- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    if (_isShowWKWebViewClass)
    {
        return[((WKWebView *)self.showWebView) evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
    else
    {
        NSString  *jsResult =[((UIWebView *)self.showWebView) stringByEvaluatingJavaScriptFromString:javaScriptString] ;
        if (completionHandler)
        {
            completionHandler(jsResult,nil);
        }
    }
}


@end
