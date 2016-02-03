//
//  MMError.h
//  mymailru-ios-sdk
//
//  Created by d.taraev on 29.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import "MMObject.h"

static int const MM_API_ERROR = -101;
static int const MM_API_CANCELED = -102;
static int const MM_API_REQUEST_NOT_PREPARED = -103;
static int const MM_RESPONSE_STRING_PARSING_ERROR = -104;
static int const MM_AUTHORIZE_CONTROLLER_CANCEL = -105;

/**
 Class for presenting MM SDK and MM API errors
 */
@interface MMError : MMObject

/// Contains system HTTP error
@property(nonatomic, strong) NSError *httpError;
/// Describes API error
@property(nonatomic, strong) MMError *apiError;

/// May contains such errors:\n <b>HTTP status code</b> if HTTP error occured;\n <b>MM_API_ERROR</b> if API error occured;\n <b>MM_API_CANCELED</b> if request was canceled;\n <b>MM_API_REQUEST_NOT_PREPARED</b> if error occured while preparing request;
@property(nonatomic, assign) NSInteger errorCode;
/// API error message
@property(nonatomic, strong) NSString *errorMessage;
/// Reason for authorization fail
@property(nonatomic, strong) NSString *errorReason;
// Localized error text from server if there is one
@property(nonatomic, strong) NSString *errorText;

/**
 Generate new error with code
 @param errorCode positive if it's an HTTP error. Negative if it's API or SDK error
 */
+ (instancetype)errorWithCode:(NSInteger)errorCode;

@end
