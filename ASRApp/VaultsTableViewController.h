//
//  VaultsTableViewController.h
//  ASRApp
//
//  Created by Akshay Hegde on 5/26/15.
//  Copyright (c) 2015 Akshay Hegde. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VaultsTableViewController : UITableViewController <NSURLConnectionDelegate>

@property NSArray* VaultNames;
@property NSArray* VaultLocations;
@property NSIndexPath* SelectedIndexPath;
@property (strong,nonatomic) UIActivityIndicatorView *VaultSpinner;

@property NSString* SavedAzureUserName;
@property NSString* SavedAzurePassword;
@property NSString* SavedSubscriptionId;
@property NSMutableData* VaultsResponseData;
@property NSMutableData* ProtectedItemsResponseData;
@property NSMutableData* RecoveryPlansResponseData;
@property NSInteger ActiveConnections;
@property BOOL IsSelfRefresh;

@end
