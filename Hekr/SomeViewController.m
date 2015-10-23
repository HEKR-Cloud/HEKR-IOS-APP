//
//  SomeViewController.m
//  Hekr
//
//  Created by Mario on 15/7/8.
//  Copyright (c) 2015年 Michael Hu. All rights reserved.
//

#import "SomeViewController.h"

@interface SomeViewController ()

@end

@implementation SomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    NSString *howToEnter = @"https://hekr.daikeapp.com/";
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString: self.urlString]];
    
    [self.web loadRequest:request];
    UIPanGestureRecognizer *recognizer;
    recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom)];
    [self.view addGestureRecognizer:recognizer];
//    [KVNProgress showWithStatus:@"Loading"];
}

- (void)handleSwipeFrom
{
    return;
}
- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
