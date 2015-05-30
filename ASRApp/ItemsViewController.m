//
//  ItemsViewController.m
//  ASRApp
//
//  Created by Akshay Hegde on 5/27/15.
//  Copyright (c) 2015 Akshay Hegde. All rights reserved.
//

#import "ItemsViewController.h"

@interface ItemsViewController ()

@end

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _ItemsTableView.delegate = self;
    _ItemsTableView.dataSource = self;
    _ItemsTabBar.delegate = self;
    
    [_ItemsTabBar setTintColor:self.view.tintColor];
    [_ItemsTabBar setSelectedItem:_ProtectedItemsTabBarItem];
    
    [_ProtectedItemsTabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} forState:UIControlStateNormal];
    [_RecoveryPlansTabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} forState:UIControlStateNormal];
    
    [self setTitle:@"Protected Servers"];
    NSError *errorJson=nil;
    NSDictionary* ResponseDictionary = [NSJSONSerialization JSONObjectWithData:_ProtectedItemsResponseData options:kNilOptions error:&errorJson];
    _ProtectedItemNames = [ResponseDictionary valueForKeyPath:@"Name"];
    _IsItemProtected = [ResponseDictionary valueForKey:@"Protected"];
    
    ResponseDictionary = [NSJSONSerialization JSONObjectWithData:_RecoveryPlansResponseData options:kNilOptions error:&errorJson];
    _RecoveryPlanNames = [ResponseDictionary valueForKey:@"Name"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if([item isEqual:[_ItemsTabBar.items objectAtIndex:0]]) {
        _TabBarSelection = @"ProtectedItems";
        [self setTitle:@"Protected Servers"];
    }
    else if([item isEqual:[_ItemsTabBar.items objectAtIndex:1]]) {
        _TabBarSelection = @"RecoveryPlans";
        [self setTitle:@"Recovery Plans"];
    }
    [_ItemsTableView setNeedsDisplay];
    [_ItemsTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // If You have only one(1) section, return 1, otherwise you must handle sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([_TabBarSelection isEqualToString:@"ProtectedItems"]) {
        return [_ProtectedItemNames count];
    }
    else {
        return [_RecoveryPlanNames count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell...
    if ([_TabBarSelection isEqualToString:@"ProtectedItems"]) {
        cell.textLabel.text = [_ProtectedItemNames objectAtIndex:indexPath.row];
        if ([[_IsItemProtected objectAtIndex:indexPath.row] boolValue]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else {
        cell.textLabel.text = [_RecoveryPlanNames objectAtIndex:indexPath.row];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
