//
//  MMAuthorizationResult.h
//  mymailru-ios-sdk
//
//  Created by d.taraev on 20.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import "MMAccessToken.h"
#import "MMError.h"

@interface MMAuthorizationResult : MMObject

@property(nonatomic, strong) MMAccessToken *token;
@property(nonatomic, strong) NSString *userID;
@property(nonatomic, strong) MMError *error;

@end
