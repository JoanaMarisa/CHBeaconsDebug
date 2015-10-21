//
//  JSONParser.h
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHBeacon.h"

@interface JSONParser : NSObject

-(BOOL)jsonWithError:(NSDictionary *)data;
-(NSString *)getErrorJSON:(NSDictionary *)data;

-(NSMutableArray <CHBeacon> *)BeaconParser:(NSDictionary *)data;

@end
