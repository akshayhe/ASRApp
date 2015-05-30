//
//  ViewController.h
//  ASRApp
//
//  Created by Akshay Hegde on 5/5/15.
//  Copyright (c) 2015 Akshay Hegde. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *AzureUsername;
@property (weak, nonatomic) IBOutlet UITextField *AzurePassword;
@property (weak, nonatomic) IBOutlet UIButton *AzureLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *AzureLoginSpinner;
@property NSMutableData* ResponseData;

- (IBAction)AuthenticateCredentials:(id)sender;

@end

NSString* SavedAzureUserName;
NSString* SavedAzurePassword;
NSString * const RequestHandlerUrl = @"http://104.42.98.185:8081/asrrestapi/request-handler.py";

