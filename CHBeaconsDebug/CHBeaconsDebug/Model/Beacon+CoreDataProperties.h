//
//  Beacon+CoreDataProperties.h
//  CHBeaconsDebug
//
//  Created by joanahenriques on 20/10/15.
//  Copyright © 2015. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Beacon.h"

NS_ASSUME_NONNULL_BEGIN

@interface Beacon (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *beaconId;
@property (nullable, nonatomic, retain) NSDecimalNumber *nrEntries;
@property (nullable, nonatomic, retain) NSDecimalNumber *nrExits;

@end

NS_ASSUME_NONNULL_END
