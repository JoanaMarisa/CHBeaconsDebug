//
//  CHAlert.h
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHAlert : NSObject

@property (strong, nonatomic) NSNumber *sound;
@property (strong, nonatomic) NSNumber *ledColor;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;

@end
