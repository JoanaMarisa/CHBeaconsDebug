//
//  CHBeaconsListTableViewController.m
//  CHBeaconDebug
//
//  Created by joanahenriques on 19/10/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "CHBeaconsListTableViewController.h"



#define kNumberDetectionsTableViewCellIdentifier @"CellIdentifier"

@interface CHBeaconsListTableViewController ()

@end

@implementation CHBeaconsListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.beacons count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNumberDetectionsTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kNumberDetectionsTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
   NSMutableDictionary *regionEntriesAndExits = [[[NSUserDefaults standardUserDefaults] objectForKey:[[self.beacons objectAtIndex:indexPath.row] identifier]] mutableCopy];
    
    NSNumber *entries = [regionEntriesAndExits objectForKey:@"entries"];
    if (entries == nil) {
        entries = @0;
    }

    NSNumber *exits = [regionEntriesAndExits objectForKey:@"exits"];
    if (exits == nil) {
        exits = @0;
    }
    
    cell.textLabel.text = [[self.beacons objectAtIndex:indexPath.row] beaconId];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Entrou: %d vezes Saiu: %d vezes", [entries intValue], [exits intValue]];
    
    
    return cell;

}


/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/


@end
