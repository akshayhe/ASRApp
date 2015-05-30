//
//  SubscriptionsTableViewController.h
//  ASRApp
//
//  Created by Akshay Hegde on 5/25/15.
//  Copyright (c) 2015 Akshay Hegde. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscriptionsTableViewController : UITableViewController <NSURLConnectionDelegate>

@property NSMutableData* ResponseData;
@property NSArray* SubscriptionNames;
@property NSArray* SubscriptionIds;
@property (strong,nonatomic) UIActivityIndicatorView *SubscriptionSpinner;

@property NSIndexPath* SelectedIndexPath;
@property NSString* SavedAzureUserName;
@property NSString* SavedAzurePassword;
@property NSString* SavedSubscriptionId;
@property NSMutableData* VaultsResponseData;
@property BOOL IsSelfRefresh;

@end

