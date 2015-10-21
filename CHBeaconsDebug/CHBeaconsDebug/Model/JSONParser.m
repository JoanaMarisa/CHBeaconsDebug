//
//  JSONParser.m
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONParser.h"
#import "CHBeacon.h"


@implementation JSONParser

/**
 *  verify if JSON has errors
 *
 *  @param data NSDictionary
 *
 *  @return BOOL error(YES) no error(NO)
 */
-(BOOL)jsonWithError:(NSDictionary *)data{
    
    NSNumber * success = [data objectForKey:@"success"];
    BOOL error;
    
    if ([success isEqualToNumber:@0]) {
        error = YES;
    }else{
        error = NO;
    }
    
    return error;
}

/**
 *  gets error message
 *
 *  @param data NSDictionary
 *
 *  @return messageError NSString
 */
-(NSString *)getErrorJSON:(NSDictionary *)data{
    
    NSArray *error = [data objectForKey:@"messages"];
    NSDictionary *message= [error firstObject];
    NSString * messageError = [message objectForKey:@"message"];
    
    return messageError;
}

/**
 *  Makes the parser of the Country and Language
 *
 *  @param data with JSON
 *
 *  @return array of objects from type Country
 */
-(NSArray <CHBeacon> *)BeaconParser:(NSDictionary *)data{
    
    NSMutableArray *arrCountriesObj = [[NSMutableArray alloc] init];
    
    NSArray *dataArray = [data objectForKey:@"data"];
    //NSArray *countries = [dataDic objectForKey:@"countries"];
    
    for (int i=0; i<[dataArray count]; i++) {
        CHBeacon *beacon = [[CHBeacon alloc] init]; // Creat obj for each countries
      //  NSDictionary *beacons = [dataArray objectAtIndex:i];
        @try {
            for (NSString *key in dataArray[i]) {
                [beacon setValue:[dataArray[i] valueForKey:key] forKey:key]; //try to find a match between key from obj beacons and the key from dictionary
            }
        } @catch (NSException *exception) {
            NSLog(@"Error in parsing");
            NSLog(@"%@",[dataArray[i] objectForKey:@"name"]);
            @throw exception;
        }
        [arrCountriesObj addObject:beacon];
    }
    
    return arrCountriesObj;
}


@end
