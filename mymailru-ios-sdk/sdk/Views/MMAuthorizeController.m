//
//  MMAuthorizeController.m
//  mymailru-ios-sdk
//
//  Created by d.taraev on 21.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import "MMAuthorizeController.h"

NSString *MM_AUTHORIZE_APP_URL_STRING = @"x-mailrumyworld://x-callback-url/authorize";
NSString *MM_AUTHORIZE_URL_STRING = @"https://connect.mail.ru/oauth/authorize";

@interface MMAuthorizationContext ()
@property (nonatomic, readwrite, strong) NSString *authPrefix;
@property (nonatomic, readwrite, strong) NSString *redirectUri;
@property (nonatomic, readwrite, strong) NSString *appId;
@property (nonatomic, readwrite, strong) NSString *displayType;
@property (nonatomic, readwrite, strong) NSString *responseType;
@property (nonatomic, readwrite, strong) NSArray<NSString*> *scope;
@property (nonatomic, readwrite) BOOL revoke;
@end

@interface MMAuthorizeController () <UIWebViewDelegate>
{
    NSURL *_url;
}
@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, weak) UINavigationController *internalNavigationController;
@property(nonatomic, assign) BOOL finished;
@end

@implementation MMAuthorizeController
@synthesize delegate = _delegate;

- (instancetype)initWithURL:(NSURL *)url
{
    if ((self = [self init])) {
        _url = url;
    }
    return self;
}

+ (UINavigationController *)factoryModal:(NSURL *)url {
    MMAuthorizeController *browser = [[[self class] alloc] initWithURL:url];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    return nc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    [self.webView loadRequest:request];
}

- (void)setupView
{
    [self setupNavigationBar];
    
    CGRect webViewFrame = self.view.bounds;
    self.webView = [[UIWebView alloc] initWithFrame:webViewFrame];
    self.webView.delegate = self;
    
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.webView];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
//                                                          attribute:NSLayoutAttributeTop
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.topLayoutGuide
//                                                          attribute:NSLayoutAttributeTop
//                                                         multiplier:1.0
//                                                           constant:0.0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
//                                                          attribute:NSLayoutAttributeBottom
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.topLayoutGuide
//                                                          attribute:NSLayoutAttributeTop
//                                                         multiplier:1.0
//                                                           constant:0.0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"webView": self.webView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[webView]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"webView": self.webView}]];
    
}

- (void)setupNavigationBar
{
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Закрыть"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(closeButtonPressed)];
    self.navigationItem.rightBarButtonItem = closeButton;
}



#pragma mark - Actions

- (void)closeButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *fragment = request.URL.fragment;
    NSString *query = request.URL.query;
    
    if (fragment && [fragment rangeOfString:@"access_token"].location != NSNotFound) {
        MMAccessToken *token = [MMAccessToken tokenFromUrlString:fragment];
        if (token) {
            [_delegate didGetToken:token];
            [self closeButtonPressed];
        } else {
            MMError *error = [MMError errorWithCode:MM_API_ERROR];
            [_delegate didFailToGetToken:error];
            [self closeButtonPressed];
        }
    } else if (query && [query rangeOfString:@"error"].location != NSNotFound) {
        MMError *error = [MMError errorWithCode:MM_API_CANCELED];
        [_delegate didFailToGetToken:error];
    } else if (fragment && [fragment rangeOfString:@"error"].location != NSNotFound) {
        MMError *error = [MMError errorWithCode:MM_API_ERROR];
        [_delegate didFailToGetToken:error];
        [self closeButtonPressed];
    }
    return YES;
}

+ (NSURL *)buildAuthorizationURLWithContext:(MMAuthorizationContext *)ctx
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
        @"revoke" : @(ctx.revoke),
        @"sdk_version" : MM_SDK_VERSION,
        }];
    if (ctx.appId) {
        params[@"client_id"] = ctx.appId;
    }
    if (ctx.scope) {
        params[@"scope"] = [ctx.scope componentsJoinedByString:@","];
    }
    if (ctx.redirectUri) {
        params[@"redirect_uri"] = ctx.redirectUri;
    }
    if (ctx.responseType) {
        params[@"response_type"] = ctx.responseType;
    }
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", ctx.authPrefix ?: @"https://connect.mail.ru/oauth/authorize", [MMUtil queryStringFromParams:params]]];
}

@end



@implementation MMAuthorizationContext

+ (instancetype)contextWithAuthType:(MMAuthorizationType)authType
                              appId:(NSString *)appId
                              scope:(NSArray<NSString *> *)scope
                             revoke:(BOOL)revoke
{
    MMAuthorizationContext *res = [self new];
    res.scope = scope;
    res.revoke = revoke;
    res.appId = appId;
    
    switch (authType) {
        case MMAuthorizationTypeApp:
            res.authPrefix = MM_AUTHORIZE_APP_URL_STRING;
            res.redirectUri = [NSString stringWithFormat:@"mm%@://authorize", appId];
            res.responseType = @"token";
            res.displayType = nil;
            break;
        case MMAuthorizationTypeSafari:
            res.redirectUri = MM_AUTHORIZE_URL_STRING;
            res.responseType = @"token";
            break;
        case MMAuthorizationTypeWebView:
            res.redirectUri = MM_AUTHORIZE_URL_STRING;
            res.responseType = @"token";
            break;
        default:
            res.responseType = @"token";
            break;
    }
    
    return res;
}

@end
