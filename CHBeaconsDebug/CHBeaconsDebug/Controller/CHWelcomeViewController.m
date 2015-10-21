//
//  CHWelcomeViewController.m
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "CHWelcomeViewController.h"
#import "CHHttpRequest.h"
#import "JSONParser.h"
#import "CHBeaconsListTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CHBeaconAction.h"
#import "CHAlert.h"
#import "CHOptions.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CoreDataWrapper.h"
#import "Beacon.h"
#import "Beacon+CoreDataProperties.h"



#define kURL @"https://dl.dropboxusercontent.com/u/5819000/sample.json"

@interface CHWelcomeViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CHHTTPRequest *request;
@property (strong, nonatomic) NSDictionary *result;
@property (strong, nonatomic) NSArray <CHBeacon> *beacons;
@property (strong, nonatomic) NSString *error;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;

@property (strong, nonatomic) NSMutableDictionary *beaconsProximity;
@property (strong, nonatomic) NSMutableArray *beaconsNear;
@property (strong, nonatomic) NSMutableArray *beaconsImmediate;
@property (strong, nonatomic) NSMutableArray *beaconsDetected;

@property BOOL near;
@property BOOL immediate;

@property CLProximity previousProximity;


@end

@implementation CHWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    
    //this is a button to open the table with the information about each Beacon
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(showInfo:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Show Info" forState:UIControlStateNormal];
    CGFloat width = self.view.frame.size.width/2 - 200.0;
    CGFloat height = self.view.frame.size.height/2 - 40;
    button.frame = CGRectMake(width, height, 100.0, 40.0);
    [self.view addSubview:button];
    
    
    //App needs to ask for one of the permission types to access location data.
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    self.locationManager.delegate = self;
    
    //it will do the request and json parser of the information
    [self requestHTTP];
    
    //With always authorization, we can use region Monitoring when in the foreground and background. With when in use authorization, the app won't be able to start Monitoring, not even in the foreground. When denied access to Location Services, the app won't be able to range or monitor for beacons.
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
}

/**
 *  Button action
 *
 *  it will push the table view controller with all the information about the beacons
 *
 *  @param button UIButton
 */
-(void)showInfo:(UIButton *)button{

    CHBeaconsListTableViewController *beaconsTVC = [[CHBeaconsListTableViewController alloc] initWithNibName:@"CHBeaconsListTableViewController" bundle:nil];
    // This will push the new view controller to the top of the previous one
    beaconsTVC.beacons = self.beacons;
    [self.navigationController pushViewController:beaconsTVC animated:YES];

}

/**
 *  init region beacon
 *
 *  it will creates a CLBeaconRegion instance that will be used for region monitoring and ranging
 *
 *  @param uuid       NSString
 *  @param identifier NSString
 */
-(void)initRegionBeacon:(NSString *)uuid andIdentifier:(NSString*)identifier{
    
    
    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:uuid];//@"5AFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"];// for example
    NSString *regionIdentifier = identifier;//@"2F234454"; //for example
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:regionIdentifier];
    
    self.beaconRegion.notifyOnEntry=YES;
    self.beaconRegion.notifyOnExit=YES;
    self.beaconRegion.notifyEntryStateOnDisplay=YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Request HTTP with verification of success and no success
 *
 *  Includes JSONParser
 *
 *  If the request has success, it will init a region for each beacon
 *
 */

- (void)requestHTTP {
    
    RequestCompleteBlock callbackComplete = ^(BOOL wasSuccessful, NSDictionary *body) {
        if (wasSuccessful) {
            //with success - It means that it has returned an appropriate NSDictionary
            NSLog(@"Success");
            
            JSONParser * jp = [[JSONParser alloc] init];
            BOOL JSONWithError = [jp jsonWithError:body];
            
            if(!JSONWithError){
                @try {
                    //self.beacons will have all the CHBeacon objects returned from the request
                    self.beacons = [jp BeaconParser:body];
                    
                    for (int i = 0; i < [self.beacons count]; i++) {
                        //for each CHBeacon returned, a new region is initialized with the same uuid and identifier
                        CHBeacon *beacon = [self.beacons objectAtIndex:i];
                        [self initRegionBeacon:beacon.uuid andIdentifier:beacon.identifier];
                        
                    }
                    
                    //after the request has success, it will push the table view controller with all the information about the beacons
                    CHBeaconsListTableViewController *beaconsTVC = [[CHBeaconsListTableViewController alloc] initWithNibName:@"CHBeaconsListTableViewController" bundle:nil];
                    // This will push the new view controller to the top of the previous one
                    beaconsTVC.beacons = self.beacons;
                    [self.navigationController pushViewController:beaconsTVC animated:YES];
                }
                @catch (NSException *exception) {
                    // if something goes wrong with parsing the Beacons
                    NSLog(@"Error in parsing the Beacons");
                    // Send to a view to error message
                }
            }else{
                // if something goes wrong
                self.error = [jp getErrorJSON:body];
                NSLog(@"Erro %@", self.error);
            }
            
        } else {
            //without success - It means that it has not returned an appropriate NSDictionary
            NSLog(@"No Success");
            
        }
    };
    
    RequestErrorBlock callbackError = ^(NSError *error) {
        
        NSString *getError = error.localizedDescription;
        
        NSLog(@"Error %@", getError);
        
    };
    
    
    [self.request requestHTTP:kURL withCallback:callbackComplete andCallback:callbackError];
    
}

/**
 *  init request
 *
 *  @return request
 */
- (CHHTTPRequest *)request
{
    if (!_request) {
        self.request = [[CHHTTPRequest alloc] init];
    }
    
    return _request;
}

/*
 A user can transition in or out of a region while the application is not running. When this happens CoreLocation will launch the application momentarily, call this delegate method and we will let the user know via a local notification.
 */
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    
    
    if(state == CLRegionStateInside)
    {
        
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];//colocar ou nao?
        [self didEnterRegion:region];
        
    }
    else if(state == CLRegionStateOutside)
    {
        [self didExitRegion:region];
        
    }
    else
    {
        return;
    }
    
}


- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //requestStateForRegion it will determinateState for region
    [self.locationManager requestStateForRegion:self.beaconRegion];
    
  
}


/**
 *  this method will be called once the device cross the thresold of the region
 *
 *  this method does not detail which matching beacons are nearby, so the ranging starts
 *
 *  @param manager CLLocationManager
 *  @param region  CLRegion
 */
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    
    [self didEnterRegion:region];
    [self.locationManager startUpdatingLocation];
    //[self.locationManager startRangingBeaconsInRegion:beaconRegion];  //the beaconRegion has to be the same as @param region and has to be the same as one of the regions already initialized
    //if we start ranging beacons the method -(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region;
    //will be called
    
}

/**
 *  this method will be called once the device exit the region
 *
 *  @param manager CLLocationManager
 *  @param region  CLRegion
 */
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self didExitRegion:region];
    [self.locationManager startUpdatingLocation];
    
}

/**
 *  this method is called repeatedly while BLE connection is available even if there are no beacons visible
 *
 *  this method is used when in a region we want to verify wich beacon is the closest
 *
 *  in this case this method will not be used beacause each region has only one beacon and we want them to do an action when the device enter ou exit a beacon region
 *
 *  @param manager CLLocationManager
 *  @param beacons NSArray
 *  @param region  CLBeaconRegion
 */
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
   
    //if beacons are not being detected
    if ([beacons count] == 0){
        
        return;
    }else{
        
        CLBeacon * beacon;
       
        for (NSInteger i = 0; i < beacons.count; i++) {
            beacon = [beacons objectAtIndex:i];
            
            //it's important to verify if the app is detecting the right beacons, they need to belong to the app
            BOOL belongs = [self belongsToApp:beacon];
            
            if(belongs){
                // all beacons detected that belongs to the app will be classified by their proximity
                [self proximityState:manager beacon:beacon];
            }
            
        }
        
        //after all beacons are classified, we need to verify wich one is the closest and this beacon will be returned
        beacon = [self nearestBeacon];
        
        // Since the method is called repeatedly, the app can be detetecting the same beacon so we need to check if the closest beacon has already been detected
        if([self beaconAlreadyDetected:beacon] == NO){
            [self doSomethingWith:beacon];
        }
    }
    
    NSLog(@"Ranged beacons count: %lu", (unsigned long)[beacons count]);
}


/**
 *  this method will verify if the beacon has a respective one from the NSArray <CHBeacon> *
 *
 *  @param beacon CLBeacon
 *
 *  @return BOOL
 */
-(BOOL)belongsToApp:(CLBeacon*)beacon{
    
    BOOL belongs = NO;
    for(int i = 0; i < self.beacons.count; i++){
        CHBeacon *chBeacon = [self.beacons objectAtIndex:i];
        if (beacon.proximityUUID.description == chBeacon.uuid){
            belongs = YES;
        }
    }
    
    return belongs;
}

/**
 *  this method will classify all beacons according their proximity
 *
 * in this case we will ignore unknow and far proximity, but in case the beacon as a trigger distance, maybe it's importante to not ignore them
 *
 *  @param manager CLLocationManager
 *  @param beacon  CLBeacon
 */
-(void)proximityState:(CLLocationManager *)manager beacon:(CLBeacon *)beacon{
    
    self.beaconsProximity = [NSMutableDictionary dictionaryWithObjectsAndKeys: self.beaconsNear, @"near", self.beaconsImmediate, @"immediate", nil];
    
    switch (beacon.proximity) {
        case CLProximityNear:
            NSLog(@"Proximidade - Near");
            [self.beaconsNear addObject:beacon];
            [self.beaconsProximity setObject:self.beaconsNear forKey:@"near"];
            self.near = YES;
            break;
        case CLProximityImmediate:
            NSLog(@"Proximidade - Immediate");
            [self.beaconsImmediate addObject:beacon];
            [self.beaconsProximity setObject:self.beaconsImmediate forKey:@"immediate"];
            self.immediate = YES;
            break;
        default:
            break;
    }
    
    if (beacon.proximity != self.previousProximity) {
        self.previousProximity = beacon.proximity;
    }
}

/**
 *  this method will return the closest beacon
 *
 * if (BOOL) immediate is true we ignore the near beacons, in the other case if (BOOL)immediate is false and (BOOL)near is true
 *
 *  we will verify all near beacons
 *
 * independently of each proximity is true, we will verify if there is one or more beacons 
 *
 * if there is only one beacon, this will be the one that will be returned
 *
 * in the other case, if there is more that only one beacon we need to returned the closest one using rssi
 *
 *  @return CLBeacon
 */
-(CLBeacon *)nearestBeacon{
    
    CLBeacon *beacon;
    
    if(self.immediate){
        //there is more than one immediate beacon
        NSInteger bImmediate = self.beaconsImmediate.count;
        if(bImmediate > 1){
            //verify the closest, returnd the beacon with the biggest rssi
            return beacon = [self beaconBiggerRssi:self.beaconsImmediate];
            
        }else if (bImmediate == 1){
            //there is only one beacon
           return beacon = self.beaconsImmediate.firstObject;
           
        }else if (bImmediate == 0){
            NSLog(@"ERROR!");
        }
    }else if (self.immediate==NO  && self.near == YES){
        //there is more than one near beacon and none immediate beacon
        NSInteger bNear = self.beaconsNear.count;
        if(bNear > 1){
            //verify the closest, returnd the beacon with the biggest rssi
            return beacon = [self beaconBiggerRssi:self.beaconsNear];
        }else if (bNear == 1){
            //there is only one beacon
            beacon = self.beaconsNear.firstObject;
        }else if (bNear == 0){
            NSLog(@"ERROR!");
        }
    }
    
    self.immediate = NO;
    self.near = NO;

    
    return beacon;
    
}

/**
 *  this method will return the beacon that has the biggest rssi
 *
 *  @param beacons NSMutableArray
 *
 *  @return CLBeacon
 */
-(CLBeacon *)beaconBiggerRssi:(NSMutableArray *) beacons{
    
    CLBeacon *beacon = [[CLBeacon alloc]init];
    CLBeacon *auxBeacon;
    NSInteger maiorRssi = -10000;
    
    for (int i = 0; i< beacons.count; i++) {
        
        auxBeacon = beacons[i];
        
        NSInteger rssi = [auxBeacon rssi];
        
        if(rssi > maiorRssi){
            beacon = auxBeacon;
            maiorRssi = rssi;
        }
    }
    
    return beacon;
    
}

/**
 *  this method will verify if the closest beacon is been consecutively detected
 *
 *  so in this case we will not have action to be repeated consecutively
 *
 *  @param newBeacon CLBeacon
 *
 *  @return BOOL
 */
-(BOOL)beaconAlreadyDetected:(CLBeacon *)newBeacon{
    
    CLBeacon *beacon;
    BOOL alreadyDetected = NO;
    
        if(self.beaconsDetected.count == 1){
            beacon = self.beaconsDetected.firstObject;
            if(beacon.proximityUUID == newBeacon.proximityUUID){
                alreadyDetected = YES;
            }
            
            if(!alreadyDetected){
                [self.beaconsDetected removeAllObjects];
                [self.beaconsDetected addObject:newBeacon];
            }
        }else{
            [self.beaconsDetected addObject:newBeacon];
            return NO;
        }

    
    return alreadyDetected;
    
}

/**
 *  this method will be called when there is a beacon action to do when a beacon is detected
 *
 *  @param beaconDetected CLBeacon
 */
-(void)doSomethingWith:(CLBeacon *)beaconDetected{

    for (int i = 0; i < [self.beacons count]; i++) {
        CHBeacon *beacon = [self.beacons objectAtIndex:i];
        if ([beacon.uuid isEqualToString:beaconDetected.proximityUUID.description]) {
            CHBeaconAction *notificationOnEnter = beacon.onEnter;
            if ([notificationOnEnter.type isEqualToNumber:@1]) {//alert
                CHAlert *alert = notificationOnEnter.alert;
                [self showAlert:alert];
            }else if ([notificationOnEnter.type isEqualToNumber:@2]){//url
                NSString *url = notificationOnEnter.url;
                [self showWebView:url];
            }
            
        }
        
    }
    
}

/**
 *  this method will be called when the device enters a region
 *
 *  @param region CLRegion
 */
-(void)didEnterRegion:(CLRegion *)region{


    for (int i = 0; i < [self.beacons count]; i++) {
        CHBeacon *beacon = [self.beacons objectAtIndex:i];
        if ([beacon.identifier isEqualToString:region.identifier]) {
            //vai ver qual é a ação a fazer
            CHBeaconAction *notificationOnEnter = beacon.onEnter;
            if ([notificationOnEnter.type isEqualToNumber:@1]) {//alert
                CHAlert *alert = notificationOnEnter.alert;
                [self showAlert:alert];
            }else if ([notificationOnEnter.type isEqualToNumber:@2]){//url
                NSString *url = notificationOnEnter.url;
                [self showWebView:url];
            }
            
        }
        
    }
    
    NSMutableDictionary *regionEntriesAndExits = [[[NSUserDefaults standardUserDefaults] objectForKey:region.identifier] mutableCopy];
    
    if (regionEntriesAndExits == nil) {
        regionEntriesAndExits = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@1, @"entries", @0, @"exits", nil];
    }else{
        NSNumber *entries = [regionEntriesAndExits objectForKey:@"entries"];
        int newExit = [entries intValue] + 1;
        [regionEntriesAndExits setObject:[NSNumber numberWithInt:newExit] forKey:@"entries"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:regionEntriesAndExits forKey:region.identifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    



}

/**
 *  this method will be called when the device exits a region
 *
 *  @param region CLRegion
 */
-(void)didExitRegion:(CLRegion *)region{
    
    
    for (int i = 0; i < [self.beacons count]; i++) {
        CHBeacon *beacon = [self.beacons objectAtIndex:i];
        if ([beacon.identifier isEqualToString:region.identifier]) {
            //vai ver qual é a ação a fazer
            CHBeaconAction *notificationOnExit = beacon.onExit;
            if ([notificationOnExit.type isEqualToNumber:@1]) {//alert
                CHAlert *alert = notificationOnExit.alert;
                [self showAlert:alert];
            }else if ([notificationOnExit.type isEqualToNumber:@2]){//url
                NSString *url = notificationOnExit.url;
                [self showWebView:url];
            }
            
        }
        
    }
    
    NSMutableDictionary *regionEntriesAndExits = [[[NSUserDefaults standardUserDefaults] objectForKey:region.identifier] mutableCopy];
    
    if (regionEntriesAndExits == nil) {
        regionEntriesAndExits = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@0, @"entries", @1,@"exits", nil];
    }else{
        NSNumber *exits = [regionEntriesAndExits objectForKey:@"exits"];
        int newExit = [exits intValue] + 1;
        [regionEntriesAndExits setObject:[NSNumber numberWithInt:newExit] forKey:@"exits"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:regionEntriesAndExits forKey:region.identifier];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    
}

/**
 *  this method will be called if the action type is alert
 *
 *  @param alert CHAlert
 */
-(void)showAlert:(CHAlert *) alert{

    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if([alert.sound isEqualToNumber:@1]){
           AudioServicesPlaySystemSound(1003);
    }else if ([alert.sound isEqualToNumber:@2]){
       AudioServicesPlaySystemSound(1001);
    }
        
    UIAlertController * alertController =   [UIAlertController
                                  alertControllerWithTitle:alert.title
                                  message:alert.message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
   
    
}

/**
 *  this method will be called if the action type is url
 *
 *  @param alert CHAlert
 */
-(void)showWebView:(NSString *)url{
    
    UIWebView *webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [webview loadRequest:nsrequest];
    [self.view addSubview:webview];

}




@end
