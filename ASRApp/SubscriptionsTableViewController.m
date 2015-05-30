//
//  SubscriptionsTableViewController.m
//  ASRApp
//
//  Created by Akshay Hegde on 5/25/15.
//  Copyright (c) 2015 Akshay Hegde. All rights reserved.
//

#import "SubscriptionsTableViewController.h"
#import "VaultsTableViewController.h"

@interface SubscriptionsTableViewController ()

@end

@implementation SubscriptionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:@"Azure Subscriptions"];
    _IsSelfRefresh = FALSE;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(RefreshSubscriptions) forControlEvents:UIControlEventValueChanged];

    NSError *errorJson=nil;
    NSDictionary* ResponseDictionary = [NSJSONSerialization JSONObjectWithData:_ResponseData options:kNilOptions error:&errorJson];
    _SubscriptionNames = [ResponseDictionary valueForKeyPath:@"SubscriptionName"];
    _SubscriptionIds = [ResponseDictionary valueForKeyPath:@"SubscriptionId"];
 
}

- (void)RefreshSubscriptions {
    [self.tableView reloadData];
    self.tableView.userInteractionEnabled = NO;
    NSString * const RequestHandlerUrl = @"http://104.42.98.185:8081/asrrestapi/request-handler.py";
    
    if (self.refreshControl) {
        _IsSelfRefresh = TRUE;
        [_ResponseData setLength:0];
        NSString *PostData = [NSString stringWithFormat:@"command=getazuresubscriptions&azureusername=%@&azurepassword=%@", _SavedAzureUserName, _SavedAzurePassword];
        NSData *EncodedPostData = [PostData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *PostDataLength = [NSString stringWithFormat:@"%lu",(unsigned long)[EncodedPostData length]];
        NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] init];
        [Request setURL:[NSURL URLWithString:RequestHandlerUrl]];
        [Request setHTTPMethod:@"POST"];
        [Request setValue:PostDataLength forHTTPHeaderField:@"Content-Length"];
        [Request setHTTPBody:EncodedPostData];
        NSURLConnection *Connection = [[NSURLConnection alloc] initWithRequest:Request delegate:self];
        [Connection start];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.tableView.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_SubscriptionNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubscriptionsCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [_SubscriptionNames objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.userInteractionEnabled = NO;
    _SelectedIndexPath = indexPath;
    _SubscriptionSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _SubscriptionSpinner.frame = CGRectMake(0, 0, 24, 24);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = _SubscriptionSpinner;
    _SubscriptionSpinner.hidesWhenStopped = YES;
    [_SubscriptionSpinner startAnimating];
    
    NSString *SelectedSubscriptionId = [_SubscriptionIds objectAtIndex:indexPath.row];
    _SavedSubscriptionId = SelectedSubscriptionId;
    NSString * const RequestHandlerUrl = @"http://104.42.98.185:8081/asrrestapi/request-handler.py";
    NSString *PostData = [NSString stringWithFormat:@"command=getasrvaults&azureusername=%@&azurepassword=%@&azuresubscriptionid=%@", _SavedAzureUserName, _SavedAzurePassword, SelectedSubscriptionId];
    NSData *EncodedPostData = [PostData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *PostDataLength = [NSString stringWithFormat:@"%lu",(unsigned long)[EncodedPostData length]];
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] init];
    [Request setURL:[NSURL URLWithString:RequestHandlerUrl]];
    [Request setHTTPMethod:@"POST"];
    [Request setValue:PostDataLength forHTTPHeaderField:@"Content-Length"];
    [Request setHTTPBody:EncodedPostData];
    
    NSURLConnection *Connection = [[NSURLConnection alloc] initWithRequest:Request delegate:self];
    [Connection start];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (_IsSelfRefresh == TRUE) {
        _ResponseData = [[NSMutableData alloc] init];
    }
    else {
        _VaultsResponseData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (_IsSelfRefresh == TRUE) {
        [_ResponseData appendData:data];
    }
    else {
        [_VaultsResponseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (_IsSelfRefresh == TRUE) {
        _IsSelfRefresh = FALSE;
        [self.refreshControl endRefreshing];
        self.tableView.userInteractionEnabled = YES;
    }
    else {
        [_SubscriptionSpinner stopAnimating];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[_SelectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_SelectedIndexPath];
        cell.accessoryView = nil;
        [self.tableView endUpdates];
        /*NSString* ResponseDataStr = [[NSString alloc] initWithBytes:[_VaultsResponseData bytes] length:[_VaultsResponseData length] encoding:NSUTF8StringEncoding];
         NSLog(@"request reply: %@", ResponseDataStr);*/
        [self performSegueWithIdentifier:@"showVaultsDetail" sender:self];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_IsSelfRefresh == TRUE) {
        _IsSelfRefresh = FALSE;
        [self.refreshControl endRefreshing];
    }
    else {
        NSLog(@"could not retrieve data");
        [_SubscriptionSpinner stopAnimating];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showVaultsDetail"])
    {
        VaultsTableViewController *VaultsVC = (VaultsTableViewController *)[segue destinationViewController];
        VaultsVC.VaultsResponseData = _VaultsResponseData;
        VaultsVC.SavedAzureUserName = _SavedAzureUserName;
        VaultsVC.SavedAzurePassword = _SavedAzurePassword;
        VaultsVC.SavedSubscriptionId = _SavedSubscriptionId;
    }
}

@end
