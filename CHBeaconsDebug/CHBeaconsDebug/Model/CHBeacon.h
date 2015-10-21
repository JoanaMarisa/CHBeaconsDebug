//
//  CHBeacon.h
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHBeaconAction.h"

@protocol CHBeacon <NSObject>


@end

@interface CHBeacon : NSObject

@property (strong, nonatomic) NSString *beaconId;
@property (strong, nonatomic) NSNumber *version;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) CHBeaconAction *onEnter;
@property (strong, nonatomic) CHBeaconAction *onExit;

@end
