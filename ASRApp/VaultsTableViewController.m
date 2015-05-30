//
//  VaultsTableViewController.m
//  ASRApp
//
//  Created by Akshay Hegde on 5/26/15.
//  Copyright (c) 2015 Akshay Hegde. All rights reserved.
//

#import "VaultsTableViewController.h"
#import "ItemsViewController.h"
#import "URLConnectionWithTag.h"

@interface VaultsTableViewController ()

@end

@implementation VaultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:@"Site Recovery Vaults"];
    _IsSelfRefresh = FALSE;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(RefreshVaults) forControlEvents:UIControlEventValueChanged];
    
    NSError *errorJson=nil;
    NSDictionary* ResponseDictionary = [NSJSONSerialization JSONObjectWithData:_VaultsResponseData options:kNilOptions error:&errorJson];
    _VaultNames = [ResponseDictionary valueForKeyPath:@"Name"];
    _VaultLocations = [ResponseDictionary valueForKeyPath:@"Location"];
    _ActiveConnections = 0;
}

- (void)RefreshVaults {
    [self.tableView reloadData];
    self.tableView.userInteractionEnabled = NO;
    NSString * const RequestHandlerUrl = @"http://104.42.98.185:8081/asrrestapi/request-handler.py";
    
    if (self.refreshControl) {
        _IsSelfRefresh = TRUE;
        [_VaultsResponseData setLength:0];
        NSString *PostData = [NSString stringWithFormat:@"command=getasrvaults&azureusername=%@&azurepassword=%@&azuresubscriptionid=%@", _SavedAzureUserName, _SavedAzurePassword, _SavedSubscriptionId];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.tableView.userInteractionEnabled = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [_VaultNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VaultsCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [_VaultNames objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [_VaultLocations objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.userInteractionEnabled = NO;
    _SelectedIndexPath = indexPath;
    _VaultSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _VaultSpinner.frame = CGRectMake(0, 0, 24, 24);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = _VaultSpinner;
    _VaultSpinner.hidesWhenStopped = YES;
    [_VaultSpinner startAnimating];
    
    NSString *SelectedVaultName = [_VaultNames objectAtIndex:indexPath.row];
    NSString * const RequestHandlerUrl = @"http://104.42.98.185:8081/asrrestapi/request-handler.py";
    NSString *PostData = [NSString stringWithFormat:@"command=getasrprotecteditems&azureusername=%@&azurepassword=%@&azuresubscriptionid=%@&asrvaultname=%@", _SavedAzureUserName, _SavedAzurePassword, _SavedSubscriptionId, SelectedVaultName];
    NSData *EncodedPostData = [PostData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *PostDataLength = [NSString stringWithFormat:@"%lu",(unsigned long)[EncodedPostData length]];
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] init];
    [Request setURL:[NSURL URLWithString:RequestHandlerUrl]];
    [Request setHTTPMethod:@"POST"];
    [Request setValue:PostDataLength forHTTPHeaderField:@"Content-Length"];
    [Request setHTTPBody:EncodedPostData];
    
    URLConnectionWithTag *Connection1 = [[URLConnectionWithTag alloc] initWithRequest:Request delegate:self];
    Connection1.ConnectionTag = @"ProtectedItems";
    [Connection1 start];
    _ActiveConnections++;
    
    PostData = [NSString stringWithFormat:@"command=getasrrecoveryplans&azureusername=%@&azurepassword=%@&azuresubscriptionid=%@&asrvaultname=%@", _SavedAzureUserName, _SavedAzurePassword, _SavedSubscriptionId, SelectedVaultName];
    EncodedPostData = [PostData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    PostDataLength = [NSString stringWithFormat:@"%lu",(unsigned long)[EncodedPostData length]];
    [Request setURL:[NSURL URLWithString:RequestHandlerUrl]];
    [Request setHTTPMethod:@"POST"];
    [Request setValue:PostDataLength forHTTPHeaderField:@"Content-Length"];
    [Request setHTTPBody:EncodedPostData];
    
    URLConnectionWithTag *Connection2 = [[URLConnectionWithTag alloc] initWithRequest:Request delegate:self];
    Connection2.ConnectionTag = @"RecoveryPlans";
    [Connection2 start];
    _ActiveConnections++;
}

- (void)connection:(URLConnectionWithTag *)connection didReceiveResponse:(NSURLResponse *)response {
    if (_IsSelfRefresh == TRUE) {
        _VaultsResponseData = [[NSMutableData alloc] init];
    }
    else {
        if([connection.ConnectionTag isEqualToString:@"ProtectedItems"]) {
            _ProtectedItemsResponseData = [[NSMutableData alloc] init];
        }
        else {
            _RecoveryPlansResponseData = [[NSMutableData alloc] init];
        }
    }
}

- (void)connection:(URLConnectionWithTag *)connection didReceiveData:(NSData *)data {
    if (_IsSelfRefresh == TRUE) {
        [_VaultsResponseData appendData:data];
    }
    else {
        if([connection.ConnectionTag isEqualToString:@"ProtectedItems"]) {
            [_ProtectedItemsResponseData appendData:data];
        }
        else {
            [_RecoveryPlansResponseData appendData:data];
        }
    }
}

- (void)connectionDidFinishLoading:(URLConnectionWithTag *)connection {
    
    if (_IsSelfRefresh == TRUE) {
        _IsSelfRefresh = FALSE;
        [self.refreshControl endRefreshing];
        self.tableView.userInteractionEnabled = YES;
    }
    else {
        _ActiveConnections--;
        if (_ActiveConnections == 0) {
            [_VaultSpinner stopAnimating];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[_SelectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_SelectedIndexPath];
            cell.accessoryView = nil;
            [self.tableView endUpdates];
            /*NSString* ResponseDataStr = [[NSString alloc] initWithBytes:[_VaultsResponseData bytes] length:[_VaultsResponseData length] encoding:NSUTF8StringEncoding];
             NSLog(@"request reply: %@", ResponseDataStr);*/
    
            [self performSegueWithIdentifier:@"showItemsDetail" sender:self];
        }
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
        [_VaultSpinner stopAnimating];
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
    if ([[segue identifier] isEqualToString:@"showItemsDetail"])
    {
        ItemsViewController *ItemsVC = (ItemsViewController *)[segue destinationViewController];
        ItemsVC.ProtectedItemsResponseData = _ProtectedItemsResponseData;
        ItemsVC.RecoveryPlansResponseData = _RecoveryPlansResponseData;
        ItemsVC.TabBarSelection = @"ProtectedItems";
    }
}

@end
