//
//  CoreDataWrapper.h
//  CHBeaconsDebug
//
//  Created by joanahenriques on 20/10/15.
//  Copyright © 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataWrapper : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *childManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedInstance;

+ (NSArray*) fetchFrom:(NSString*)clss withBeaconId:(NSNumber*)beaconId;

+ (void) create:(NSManagedObject *) model;
+ (void) createOrUpdate:(NSManagedObject *) mObject;
+ (void) deleteAll;

- (void)saveContext;
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectContext *)childManagedObjectContext;

@end