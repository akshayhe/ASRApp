//
//  ViewController.m
//  ASRApp
//
//  Created by Akshay Hegde on 5/5/15.
//  Copyright (c) 2015 Akshay Hegde. All rights reserved.
//

#import "ViewController.h"
#import "SubscriptionsTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _AzurePassword.secureTextEntry = YES;
    _AzureLoginSpinner.hidesWhenStopped = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)AuthenticateCredentials:(id)sender {
    NSString *PostData = [NSString stringWithFormat:@"command=getazuresubscriptions&azureusername=%@&azurepassword=%@", _AzureUsername.text, _AzurePassword.text];
    SavedAzureUserName = _AzureUsername.text;
    SavedAzurePassword = _AzurePassword.text;
    NSData *EncodedPostData = [PostData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *PostDataLength = [NSString stringWithFormat:@"%lu",(unsigned long)[EncodedPostData length]];
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] init];
    [Request setURL:[NSURL URLWithString:RequestHandlerUrl]];
    [Request setHTTPMethod:@"POST"];
    [Request setValue:PostDataLength forHTTPHeaderField:@"Content-Length"];
    [Request setHTTPBody:EncodedPostData];
    //NSURLResponse *Response;
    NSURLConnection *Connection = [[NSURLConnection alloc] initWithRequest:Request delegate:self];
    [Connection start];
    _AzureUsername.enabled = FALSE;
    _AzurePassword.enabled = FALSE;
    _AzureLogin.enabled = FALSE;
    [_AzureLoginSpinner startAnimating];

    
    //NSData* ResponseData = [NSURLConnection sendSynchronousRequest:Request returningResponse:&Response error:nil];
    //NSString* ResponseDataStr = [[NSString alloc] initWithBytes:[ResponseData bytes] length:[ResponseData length] encoding:NSUTF8StringEncoding];
    //NSLog(@"request reply: %@", ResponseDataStr);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _ResponseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_ResponseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    _AzureUsername.enabled = TRUE;
    _AzurePassword.enabled = TRUE;
    _AzureLogin.enabled = TRUE;
    [_AzureLoginSpinner stopAnimating];
    [self performSegueWithIdentifier:@"showSubscriptionsDetail" sender:self];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"could not retrieve data");
    _AzureUsername.enabled = TRUE;
    _AzurePassword.enabled = TRUE;
    _AzureLogin.enabled = TRUE;
    [_AzureLoginSpinner stopAnimating];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSubscriptionsDetail"])
    {
        SubscriptionsTableViewController *SubscriptionsVC = (SubscriptionsTableViewController *)[[segue destinationViewController] topViewController];
        SubscriptionsVC.ResponseData = _ResponseData;
        SubscriptionsVC.SavedAzureUserName = SavedAzureUserName;
        SubscriptionsVC.SavedAzurePassword = SavedAzurePassword;
    }
}

@end
