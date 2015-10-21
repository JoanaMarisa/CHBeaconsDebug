//
//  CHHttpConnection.h
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"


typedef void (^OnSuccess) (NSHTTPURLResponse *response, NSDictionary *body);
typedef void (^OnFailure) (NSHTTPURLResponse *response, NSError *error);
typedef void (^OnDidSendData) (NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);


@interface CHHTTPConnection : NSObject

@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) NSHTTPURLResponse *response;
@property (strong, nonatomic) NSMutableData *data;

@property (copy, nonatomic) OnSuccess onSuccess;
@property (copy, nonatomic) OnFailure onFailure;
@property (copy, nonatomic) OnDidSendData onDidSendData;

- (id)initWithRequest:(NSURLRequest *)urlRequest;

- (BOOL)executeRequestOnSuccess:(OnSuccess)onSuccessBlock
                        failure:(OnFailure)onFailureBlock
                    didSendData:(OnDidSendData)onDidSendDataBlock;

@end
