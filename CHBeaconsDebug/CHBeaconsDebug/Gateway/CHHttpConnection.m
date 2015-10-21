//
//  CHHttpConnection.m
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "CHHttpConnection.h"

@implementation CHHTTPConnection

- (id)initWithRequest:(NSURLRequest *)urlRequest
{
    self = [super init];
    if (self) {
        self.request = urlRequest;
    }
    return self;
}


/**
 *  Returns JSON information in NSDictionary format
 *
 *  @return info from JSON
 */
- (NSDictionary *)body
{
    NSDictionary *info;
    
    if (self.data != nil) {
        info = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:NULL];
    }else{
        info = nil;
    }
    
    return info;
}

/**
 *  Execute Request
 *
 *  @param onSuccessBlock
 *  @param onFailureBlock
 *  @param onDidSendDataBlock
 *
 *  @return BOOL connection if not nil
 */
- (BOOL)executeRequestOnSuccess:(OnSuccess)onSuccessBlock
                        failure:(OnFailure)onFailureBlock
                    didSendData:(OnDidSendData)onDidSendDataBlock
{
    self.onSuccess = onSuccessBlock;
    self.onFailure = onFailureBlock;
    self.onDidSendData = onDidSendDataBlock;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    return connection != nil;
}

/**
 *  Any response objects we get back from the NSURLConnection class
 *  are instances of the NSHTTPURLResponse class
 *
 *  @param connection
 *  @param aResponse
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)aResponse;
    self.response = httpResponse;
    
    self.data = [NSMutableData data];
    [self.data setLength:0];
}

/**
 *  Associates the received data to the local data
 *
 *  @param connection
 *  @param bytes
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)bytes
{
    [self.data appendData:bytes];
}

/**
 *  If connection fails
 *
 *  @param connection
 *  @param error
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.onFailure)
        self.onFailure(self.response, error);
}

/**
 *  at the end of connection
 *  verify if request was with success
 *
 *  @param connection
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.onSuccess)
        self.onSuccess(self.response, self.body);
}



@end
