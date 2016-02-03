//
//  MMAuthorizeController.h
//  mymailru-ios-sdk
//
//  Created by d.taraev on 21.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSdk.h"

@protocol MMAuthorizeControllerDelegate <NSObject>

- (void)didGetToken:(MMAccessToken *)token;
- (void)didFailToGetToken:(MMError *)error;

@end

typedef NS_ENUM(NSInteger, MMAuthorizationType) {
    MMAuthorizationTypeWebView,
    MMAuthorizationTypeSafari,
    MMAuthorizationTypeApp
};

@interface MMAuthorizationContext : MMObject
@property (nonatomic, readonly, strong) NSString *appId;
@property (nonatomic, readonly, strong) NSArray<NSString*> *scope;
@property (nonatomic, readonly) BOOL revoke;

/**
 Prepare context for building oauth url
 @param authType type of authorization will be used
 @param appId id of the application
 @param displayType selected display type
 @param scope requested scope for application
 @param revoke If YES, user will see permissions list and allow to logout (if logged in already)
 @return Prepared context, which must be passed into buildAuthorizationURLWithContext: method
 */
+(instancetype) contextWithAuthType:(MMAuthorizationType) authType
                              appId:(NSString*)appId
                              scope:(NSArray<NSString*>*)scope
                             revoke:(BOOL) revoke;

@end

/**
 Controller for authorization through webview (if MM app not available)
 */

@interface MMAuthorizeController : UIViewController

@property (nonatomic, weak) id <MMAuthorizeControllerDelegate> delegate;

/**
 Factory method, that returns autoreleased UINavigationController instance,
 inited with internal browser as root controller
 */
+ (UINavigationController *)factoryModal:(NSURL *)url;

//+ (void)presentForAuthorizeWithAppId:(NSString *)appId
//                        revokeAccess:(BOOL)revoke;

+ (NSURL *)buildAuthorizationURLWithContext:(MMAuthorizationContext*) ctx;

@end
