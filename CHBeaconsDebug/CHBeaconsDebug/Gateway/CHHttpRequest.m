//
//  CHHttpRequest.m
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHHttpRequest.h"

@implementation CHHTTPRequest


/**
 *  Method that takes a callback that is defined as typedef
 *  Makes a simple GET request to the API
 *  When the request is completed - check if it was succesful
 *  and execute the callback block with the data returned
 *
 *
 *  @param urlString
 *  @param callback
 */
- (void)requestHTTP:(NSString *)urlString withCallback:(RequestCompleteBlock)callbackComplete andCallback:(RequestErrorBlock)callbackError
{
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    CHHTTPConnection *connection = [[CHHTTPConnection alloc] initWithRequest:request];
    
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSDictionary *body) {
         if (response.statusCode == 200) {

             callbackComplete(YES, body);
         } else {
             callbackComplete(NO, nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSError *error) {
         callbackError(error);
     } didSendData:nil];
}

@end

