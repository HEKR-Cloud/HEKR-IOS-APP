//
//  PromptViewController.m
//  Hekr
//
//  Created by Mario on 15/6/30.
//  Copyright (c) 2015年 Michael Hu. All rights reserved.
//

#import "PromptViewController.h"
#import "NetworkingManage.h"
#import "DeviceNameForSSID.h"
@interface PromptViewController ()
@property (weak, nonatomic) IBOutlet UIButton *ShowSsidButton;
@property (weak, nonatomic) IBOutlet UIButton *turnCancalButton;

@end

@implementation PromptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[HekrRuntime shareInstance] setBlock:^{
        if ([[NetworkingManage currentWifiSSID] hasPrefix:@"Hekr_"]) {
            [self.ShowSsidButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"已连接 ", @"%@"),[NetworkingManage currentWifiSSID]] forState:UIControlStateNormal];
        }else{
            [self.ShowSsidButton setTitle:NSLocalizedString(@"等待连接", nil) forState:UIControlStateNormal];
        }
    }];
    [[HekrRuntime shareInstance] checkNetWork];
    // Do any additional setup after loading the view from its nib.
    
    UIPanGestureRecognizer *recognizer;
    recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom)];
    [self.view addGestureRecognizer:recognizer];
    
}

- (void)handleSwipeFrom
{
    return;
}

- (IBAction)touchShowSsidButton:(id)sender {
    if ([[NetworkingManage currentWifiSSID] hasPrefix:@"Hekr_"])
    {
        [DeviceNameForSSID shareInstace].ssidName = [NetworkingManage currentWifiSSID];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)touchTurnCancalButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
