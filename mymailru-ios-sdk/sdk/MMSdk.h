//
//  MMSdk.h
//  mymailru-ios-sdk
//
//  Created by d.taraev on 19.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMObject.h"
#import "MMUtil.h"
#import "MMAuthorizationResult.h"
#import "MMSdkVersion.h"

typedef NS_ENUM(NSUInteger, MMAuthorizationState) {
    MMAuthorizationUnknown, // Authorization state unknown, probably something went wrong
    MMAuthorizationInitialized, // SDK initialized and ready to authorize
    MMAuthorizationPending, // Authorization state pending, probably we're trying to load auth information
    MMAuthorizationExternal, // Started external authorization process
    MMAuthorizationSafariInApp, // Started in app authorization process, using SafariViewController
    MMAuthorizationWebview, // Started in app authorization process, using WebView
    MMAuthorizationAuthorized, // User authorized
    MMAuthorizationError, // An error occured, try to wake up session later
};

/**
 SDK events delegate protocol.
 You should implement it, typically as main view controller or as application delegate.
 */
@protocol MMSdkDelegate <NSObject>
@required

/**
 Notifies delegate about authorization was completed, and returns authorization result which presents new token or error.
 @param result contains new token or error, retrieved after MM authorization
 */
- (void)mmSdkAccessAuthorizationFinishedWithResult:(MMAuthorizationResult *)result;

/**
 Notifies delegate about access error, mostly connected with user deauthorized application
 */
- (void)mmSdkUserAuthorizationFailed:(MMError *)error;

/**
 Notifies delegate about existing token has expired
 @param expiredToken old token that has expired
 */
- (void)mmSdkTokenHasExpired:(MMAccessToken *)expiredToken;

@end

@interface MMSdk : MMObject

/// Returns a last app_id used for initializing the SDK
@property(nonatomic, readonly, copy) NSString *currentAppId;

/// API version for making requests
@property(nonatomic, readonly, copy) NSString *apiVersion;

/// A weak object reference to an object implementing the MMSdkDelegate protocol
@property(nonatomic, weak) id <MMSdkDelegate> sdkDelegate;
///-------------------------------
/// @name Initialization
///-------------------------------

/**
 Returns instance of MM SDK. You should never use that directly
 */
+ (instancetype)instance;

/**
 Initialize SDK with responder for global SDK events with default api version from MM_SDK_API_VERSION
 @param appId your application id (if you haven't, you can create standalone application here http://api.mail.ru/apps/my/add )
 */
+ (instancetype)initializeWithAppId:(NSString *)appId;

///-------------------------------
/// @name Authentication in MM
///-------------------------------

/**
 Starts authorization process to retrieve unlimited token. If MMapp is available in system, it will opens and requests access from user.
 Otherwise Mobile Safari will be opened for access request.
 @param permissions array of permissions for your applications. All permissions you can
 */
+ (void)authorize:(NSArray *)permissions;

+ (BOOL)processOpenURL:(NSURL *)passedUrl fromApplication:(NSString *)sourceApplication;

@end

@interface MMAccessToken (Expiration)
- (void)notifyTokenExpired;
@end
