//
//  ProtectedItemsViewController.m
//  ASRApp
//
//  Created by Akshay Hegde on 5/26/15.
//  Copyright (c) 2015 Akshay Hegde. All rights reserved.
//

#import "ProtectedItemsViewController.h"

@interface ProtectedItemsViewController ()

@end

@implementation ProtectedItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self.tabBar.items objectAtIndex:0] setTitle:@"Protected Items"];
    [[self.tabBar.items objectAtIndex:1] setTitle:@"Recovery Plans"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
