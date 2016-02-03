//
//  MMSdk.m
//  mymailru-ios-sdk
//
//  Created by d.taraev on 19.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import "MMSdk.h"
#import "MMAuthorizeController.h"
#import "MMApiConst.h"
#import "MMError.h"

static NSString *MM_ACCESS_TOKEN_DEFAULTS_KEY = @"MM_ACCESS_TOKEN_DEFAULTS_KEY";

@interface MMSdk () <MMAuthorizeControllerDelegate>

@property(nonatomic, assign) MMAuthorizationState authState;

@property(nonatomic, readwrite, copy) NSString *currentAppId;
@property(nonatomic, readwrite, copy) NSString *apiVersion;
@property(nonatomic, readwrite, strong) MMAccessToken *accessToken;
@property(nonatomic, weak) UIViewController *presentedWebViewController;

@property(nonatomic, strong) NSSet *permissions;

@end

@implementation MMSdk
@synthesize sdkDelegate = _sdkDelegate;

static MMSdk *mmSdkInstance = nil;

+ (instancetype)initializeWithAppId:(NSString *)appId {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mmSdkInstance = [(MMSdk *) [super alloc] initUniqueInstance];
    });
    
    mmSdkInstance.currentAppId = appId;
    return mmSdkInstance;
}

+ (instancetype)instance {
    NSAssert(mmSdkInstance, @"MMSdk should be initialized. Use [MMSdk initializeWithAppId:] method");
    return mmSdkInstance;
}

#pragma mark - Instance

- (instancetype)initUniqueInstance {
    self = [super init];
    [self resetSdkState];
    return self;
}

- (void)resetSdkState {
    self.permissions = nil;
    self.authState = MMAuthorizationInitialized;
    self.accessToken = nil;
}


+ (void)authorize:(NSArray *)permissions
{
    
    MMSdk *instance = [MMSdk instance];
    
    BOOL mmAppInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"x-mailrumyworld://"]];
    NSString *appId = instance.currentAppId;
    
    MMAuthorizationContext *authContext = [MMAuthorizationContext contextWithAuthType:mmAppInstalled ? MMAuthorizationTypeApp : MMAuthorizationTypeSafari
                                                                                appId:appId
                                                                                scope:nil
                                                                               revoke:YES];
    NSURL *url = [MMAuthorizeController buildAuthorizationURLWithContext:authContext];
    
    if (mmAppInstalled)
    {
        instance.authState = MMAuthorizationExternal;
        [[UIApplication sharedApplication] openURL:url];
    } else {
        instance.authState = MMAuthorizationWebview;
        
        UINavigationController *nc = [MMAuthorizeController factoryModal:url];
        MMAuthorizeController *modalBrowser = (MMAuthorizeController *)nc.topViewController;
        modalBrowser.delegate = [self instance];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nc animated:YES completion:nil];
    }
}



#pragma mark - MMAuthorizeControllerDelegate

- (void)didGetToken:(MMAccessToken *)token
{
    MMAuthorizationResult *res = [MMAuthorizationResult new];
    res.token = token;
    res.userID = [token.userId copy];
    if (token) {
        [self notifyDelegate:@selector(mmSdkAccessAuthorizationFinishedWithResult:) obj:res];
    } else {
        MMError *error = [MMError errorWithCode:MM_API_ERROR];
        [self notifyDelegate:@selector(mmSdkUserAuthorizationFailed:) obj:error];
    }
}

- (void)didFailToGetToken:(MMError *)error
{
    [self notifyDelegate:@selector(mmSdkUserAuthorizationFailed:) obj:error];
}



#pragma mark - Access token

+ (MMAccessToken *)accessToken {
    return mmSdkInstance.accessToken;
}

+ (void)setAccessToken:(MMAccessToken *)token {
    [token saveTokenToDefaults:MM_ACCESS_TOKEN_DEFAULTS_KEY];
    
    id oldToken = mmSdkInstance.accessToken;
    if (!token && oldToken) {
        [MMAccessToken delete:MM_ACCESS_TOKEN_DEFAULTS_KEY];
    }
    
    mmSdkInstance.authState = token ? MMAuthorizationAuthorized : MMAuthorizationInitialized;
    mmSdkInstance.accessToken = token;
}

+ (BOOL)processOpenURL:(NSURL *)passedUrl fromApplication:(NSString *)sourceApplication {
    if ([sourceApplication isEqualToString:MM_CLIENT_BUNDLE]
        && [passedUrl.scheme isEqualToString:[NSString stringWithFormat:@"mm%@", mmSdkInstance.currentAppId]]) {
        return [self processOpenURL:passedUrl validation:NO];
    }
    return NO;
}

+ (BOOL)processOpenURL:(NSURL *)passedUrl validation:(BOOL)validation {
    NSString *urlString = [passedUrl absoluteString];
    NSRange rangeOfHash = [urlString rangeOfString:@"?"];
    if (rangeOfHash.location == NSNotFound) {
        return NO;
    }
    
    NSMutableDictionary * newAccessData = [NSMutableDictionary dictionary];
    for (NSString * param in [passedUrl.query componentsSeparatedByString:@"&"]) {
        NSArray * elements = [param componentsSeparatedByString:@"="];
        if (elements.count != 2) continue;
        newAccessData[elements[0]] = elements[1];
    }
    
    MMSdk *instance = [self instance];
    void (^notifyAuthorization)(MMAccessToken *, MMError *) = ^(MMAccessToken *token, MMError *error) {
        MMAuthorizationResult *res = [MMAuthorizationResult new];
        res.error = error ? error : nil;
        res.token = token;
        res.userID = [token.userId copy];
        if (token) {
            [instance notifyDelegate:@selector(mmSdkAccessAuthorizationFinishedWithResult:) obj:res];
        } else {
            [instance notifyDelegate:@selector(mmSdkAccessAuthorizationFinishedWithResult:) obj:res];
        }
    };
    
    NSString *parametersString = [MMUtil paramsStringFromURLString:urlString];
    if (parametersString.length == 0) {
        MMError *error = [MMError errorWithCode:MM_API_CANCELED];
        if (!validation) {
            notifyAuthorization(nil, error);
            [instance resetSdkState];
        }
        return NO;
    }
    NSDictionary *parametersDict = [MMUtil explodeQueryString:parametersString];
    void (^throwError)() = ^{
        MMError *error = [MMError errorWithCode:MM_API_ERROR];
        if (!validation) {
            notifyAuthorization(nil, error);
            [instance resetSdkState];
        }
    };
    
    BOOL result = YES;
    if (([parametersDict[@"status"] isEqualToString:@"cancel"] || [parametersDict[@"status"] isEqualToString:@"error"])) {
        throwError();
        result = NO;
    } else if ([parametersDict[@"status"] isEqualToString:@"success"]) {
        if (parametersDict[@"access_token"]) {
            MMAccessToken *token = [MMAccessToken tokenFromUrlString:urlString];
            if (!validation) {
                notifyAuthorization(token, nil);
            } else {
                [self setAccessToken:token];
            }
        }
    } else {
        MMAccessToken *token = [MMAccessToken tokenFromUrlString:parametersString];
        if (!token.accessToken) {
            result = NO;
        } else {
            notifyAuthorization(token, nil);
        }
    }
    return YES;
    
}

- (void)notifyDelegate:(SEL)selector obj:(id)object {
    if ([self.sdkDelegate respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.sdkDelegate performSelector:selector withObject:object];
#pragma clang diagnostic pop
    }
}



@end

@implementation MMAccessToken (Expiration)

- (void)notifyTokenExpired {
    [[MMSdk instance] notifyDelegate:@selector(mmSdkTokenHasExpired:) obj:self];
}

@end
