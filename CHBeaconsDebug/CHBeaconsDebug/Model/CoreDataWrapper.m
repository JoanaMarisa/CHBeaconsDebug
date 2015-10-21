//
//  Beacon.m
//  CHBeaconsDebug
//
//  Created by joanahenriques on 20/10/15.
//  Copyright © 2015. All rights reserved.
//

#import "CoreDataWrapper.h"
#import "CHBeacon.h"

@implementation CoreDataWrapper


@synthesize managedObjectContext = _managedObjectContext;
@synthesize childManagedObjectContext = _childManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (instancetype)init{
    return self;
}

#pragma mark - CRUD operations

/**
 *  Static method to insert a model in core data, it is needed to retrieve the context
 *  insert it in the context and save it.
 *
 *  @param model An MSManagedObject defined in the model in CoreData. For example Target.
 */

+ (void) create:(NSManagedObject *) model{
    
    CoreDataWrapper * shared = [CoreDataWrapper sharedInstance];
    NSManagedObjectContext * context = [shared childManagedObjectContext];
    
    [context insertObject:model];
    
    [shared saveChildContext];
    
    [shared saveContext];
    
}

/**
 *  Static method to retrieve all the NSManagedObjects that matches with beaconId.
 *
 *  @return NSArray of NSManagedObject that matches the request
 */

+ (NSArray*) fetchFrom:(NSString*)clss withBeaconId:(NSNumber*)beaconId{
    
    NSManagedObjectContext * context = [[CoreDataWrapper sharedInstance] managedObjectContext];
    
    
    NSFetchRequest * fetchReq = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:clss
                                              inManagedObjectContext:context];
    
    [fetchReq setEntity:entity];
    
    
    //predicate
    NSPredicate * predicate = [NSPredicate predicateWithFormat:
                               @"(beaconId == %@)", beaconId];
    
    [fetchReq setPredicate:predicate];
    
    
    //in what order you want your data to be fetched
    NSSortDescriptor *idSort = nil;
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: idSort, nil];
    fetchReq.sortDescriptors = sortDescriptors;
    
    //initialize a fetched results controller to efficiently manage the results
    //returned from a Core Data fetch request
    NSFetchedResultsController *FRC = [[NSFetchedResultsController alloc]
                                       initWithFetchRequest:fetchReq
                                       managedObjectContext:context
                                       sectionNameKeyPath:nil
                                       cacheName:nil];
    
    
    NSError *fetchingError = nil;
    
    //perform the fetch request
    if ([FRC performFetch:&fetchingError]){
        NSLog(@"Successfully fetched data: %@", [FRC fetchedObjects]);
    }
    else {
        NSLog(@"Failed to fetch any data");
    }
    
    return [FRC fetchedObjects];
    
}


/**
 *  Static method to update a given Beacon
 *
 *  @param beacon Beacon to update
 *
 *  @return The Updated Beacon
 */
+ (NSManagedObject * ) update:(NSManagedObject *)mObject{
    
    
    //returns the object for the specified ID
    NSArray* arr = nil;
    
    if ( [NSStringFromClass([mObject class]) isEqualToString:@"Beacon"]) {
        
        arr = [CoreDataWrapper fetchFrom:NSStringFromClass([mObject class]) withBeaconId:[mObject valueForKey:@"beaconId"]];
    }
    
    if ([arr count] == 0) {
        return nil;
    } else {
        
        NSManagedObject * beacon = [arr firstObject];
        
        NSArray *keys = [[[mObject entity] attributesByName] allKeys];
        
        for (NSString* name in keys) {
            [beacon setValue:[mObject valueForKey:name] forKey:name];
        }
        
        [[CoreDataWrapper sharedInstance] saveContext];
        return beacon;
    }
}


/**
 *  Tries to create a new Beacon only if there isn't one already.
 *  If it already existe, updates it.
 *
 *  @param beacon Beacon to create/update
 */

+ (void) createOrUpdate:(NSManagedObject *)mObject{
    
    if ([CoreDataWrapper update:mObject] == nil)
        [CoreDataWrapper create:mObject];
    
    
}


/**
 *  Delete all entries in coredata.
 */
+ (void) deleteAll {
    
    CoreDataWrapper * shared = [CoreDataWrapper sharedInstance];
    
    NSManagedObjectContext * context = [shared managedObjectContext];
    NSManagedObjectModel * model = [shared managedObjectModel];
    
    for (NSEntityDescription * entity in model) {
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:entity];
        [fetch setIncludesSubentities:NO];
        
        NSArray * objs = [context executeFetchRequest:fetch error:nil];
        
        for (NSManagedObject * j in objs) {
            [context deleteObject:j];
        }
        
    }
    
    [shared saveContext];
    
    
}


#pragma mark - singleton Creation


/**
 *  Singleton Creation
 *
 *  @return Static CoreDataWrapper class
 */
+ (id)sharedInstance {
    static CoreDataWrapper * sharedInstance = nil;
    
    @synchronized(self){
        
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
        
    }
    
    return sharedInstance;
    
}

#pragma mark - Core Data

/**
 *  Path for Core Data Store Files
 *
 *  @return Path for Core Data Store Files
 */
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.aigptc.MSA" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 *  Create ManagedObjectModel if it doesn't exist already
 *
 *  @return ManagedObjectModel used with CoreData
 */
- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CHBeaconsDebug" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


/**
 *  Return the NSPersistenceStoreCoordinator used in CoreData if it does'nt exist
 *  with the options: dictionaryWithObjectsAndKeys and NSMigratePersistentStoresAutomaticallyOption set to YES
 *
 *  @return PersistanceStoreCoordinator used by CoreData
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CHBeaconsDebug.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

/**
 *  Creates NSManagedObjectContext for CoreData
 *
 *  @return NSManagedObjectContext for CoreData
 */

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

/**
 *  Creates NSManagedObjectContext for CoreData
 *
 *  @return NSManagedObjectContext for CoreData
 */

- (NSManagedObjectContext *)childManagedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_childManagedObjectContext != nil) {
        return _childManagedObjectContext;
    }
    
    _childManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    NSManagedObjectContext * cont = [self managedObjectContext];
    
    [_childManagedObjectContext setParentContext:cont];
    
    return _childManagedObjectContext;
}


#pragma mark - Core Data Saving support


/**
 *  Saves all changes to coredata.
 */
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

/**
 *  Push Changes to parent context
 */
- (void)saveChildContext {
    NSManagedObjectContext *managedObjectContext = self.childManagedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}




@end