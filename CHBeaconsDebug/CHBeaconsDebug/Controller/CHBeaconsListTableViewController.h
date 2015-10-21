//
//  CHBeaconsListTableViewController.h
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHBeacon.h"


@interface CHBeaconsListTableViewController : UITableViewController

@property (strong, nonatomic) NSArray <CHBeacon >* beacons;

@end
