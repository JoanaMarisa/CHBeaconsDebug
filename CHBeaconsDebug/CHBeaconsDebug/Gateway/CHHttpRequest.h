//
//  CHHttpRequest.h
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHHttpConnection.h"

typedef void (^RequestCompleteBlock) (BOOL wasSuccessful, NSDictionary *body);
typedef void (^RequestErrorBlock) (NSError *error);

@interface CHHTTPRequest : NSObject

- (void)requestHTTP:(NSString *)urlString withCallback:(RequestCompleteBlock)callbackComplete andCallback:(RequestErrorBlock)callbackError;

@end
