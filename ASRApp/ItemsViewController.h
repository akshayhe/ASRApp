//
//  ItemsViewController.h
//  ASRApp
//
//  Created by Akshay Hegde on 5/27/15.
//  Copyright (c) 2015 Akshay Hegde. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITabBarDelegate>
@property (weak, nonatomic) IBOutlet UITabBar *ItemsTabBar;
@property (weak, nonatomic) IBOutlet UITableView *ItemsTableView;
@property (weak, nonatomic) IBOutlet UITabBarItem *ProtectedItemsTabBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *RecoveryPlansTabBarItem;

@property NSMutableData* ProtectedItemsResponseData;
@property NSMutableData* RecoveryPlansResponseData;

@property NSString* TabBarSelection;
@property NSArray* ProtectedItemNames;
@property NSArray* IsItemProtected;
@property NSArray* RecoveryPlanNames;

@end
