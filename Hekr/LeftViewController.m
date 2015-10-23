//
//  LeftViewController.m
//  HEKR
//
//  Created by Mario on 15/5/25.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "LeftViewController.h"
#import "AboutViewController.h"
#import "TCViewController.h"
#import "DBHandler.h"
#import "MainViewController.h"
#import <UIViewController+MMDrawerController.h>
#import "StorageManage.h"
@interface LeftViewController ()

@end

@implementation LeftViewController

-(id)init{
    self = [super init];
    if(self){
        [self setRestorationIdentifier:@"MMExampleLeftSideDrawerController"];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    // Do any additional setup after loading the view.
    
}

- (IBAction)touchUsButton:(id)sender {
    NSLog(@"当前点击了关于我们按钮");
    
    AboutViewController *aboutVC = [[AboutViewController alloc] init];
    
    aboutVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:aboutVC animated:YES completion:^{
        
    }];
}
- (IBAction)touchGagButton:(id)sender {
    NSLog(@"当前点击了吐槽按钮");
    
    TCViewController *GagVC = [[TCViewController alloc] init];
    
    GagVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:GagVC animated:YES completion:^{
        
    }];
}
- (IBAction)touchQuiteButton:(id)sender {
    
    NSLog(@"当前点击了退出按钮");
    [[StorageManage sharedInstance] clearUserData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QUIT" object:nil];
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
