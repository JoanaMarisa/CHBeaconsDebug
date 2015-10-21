//
//  CHOnEnter.h
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHAlert.h"
#import "CHOptions.h"

@interface CHBeaconAction : NSObject

@property (strong, nonatomic) NSNumber *idOnEnter;
@property (strong, nonatomic) NSString *descriptionOnEnter;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSNumber *interval;
@property (strong, nonatomic) CHAlert *alert;
@property (strong, nonatomic) CHOptions *options;
@property (strong, nonatomic) NSString *url;

@end
