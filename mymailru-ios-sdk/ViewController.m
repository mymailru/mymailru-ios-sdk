//
//  ViewController.m
//  mymailru-ios-sdk
//
//  Created by d.taraev on 20.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import "ViewController.h"
#import "MMSdk.h"
#import "MMAuthorizeController.h"

@interface ViewController () <MMSdkDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MMSdk initializeWithAppId:@"740836"];
    [MMSdk instance].sdkDelegate = self;
}



#pragma mark - Actions

- (IBAction)getTokenClicked:(UIButton *)sender
{
    //Not using scope (permissions) parameter
    [MMSdk authorize:nil];
}

- (void)showAlertViewWithText:(NSString *)alertText title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}



#pragma mark - MMSdkDelegate

- (void)mmSdkAccessAuthorizationFinishedWithResult:(MMAuthorizationResult *)result
{
    [self showAlertViewWithText:[NSString stringWithFormat:@"accessToken=%@", result.token.accessToken] title:@"Успешная авторизация"];
}

- (void)mmSdkUserAuthorizationFailed:(MMError *)error
{
    [self showAlertViewWithText:[NSString stringWithFormat:@"error=%ld", (long)error.errorCode] title:@"Ошибка"];
}

- (void)mmSdkTokenHasExpired:(MMAccessToken *)expiredToken
{
    [MMSdk authorize:nil];
}

@end
