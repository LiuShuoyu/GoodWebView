//
//  GoodWebView.h
//  WebViewDemo
//
//  Created by d.x.c on 16/10/9.
//  Copyright © 2016年 zhixun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GoodWebView;

__TVOS_PROHIBITED @protocol GoodWebViewDelegate <NSObject>

@optional
- (BOOL)webView:(GoodWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(GoodWebView *)webView;
- (void)webViewDidFinishLoad:(GoodWebView *)webView;
- (void)webView:(GoodWebView *)webView didFailLoadWithError:(NSError *)error;
@optional


@end

@interface GoodWebView : UIView


@property(nonatomic,readonly)UIView *showWebView;
@property (nonatomic, readonly) BOOL isShowWKWebViewClass;



@property (nonatomic) BOOL scalesPageToFit;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly, strong) NSURLRequest *request;
@property (nonatomic, readonly) double estimatedProgress;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly, strong) UIScrollView *scrollView NS_AVAILABLE_IOS(5_0);
@property (nonatomic, assign) id <GoodWebViewDelegate> delegate;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:( NSURL *)baseURL;

- (void)reload;
- (void)stopLoading;
- (void)goBack;
- (void)goForward;
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;


@end
