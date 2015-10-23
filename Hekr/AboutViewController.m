//
//  AboutViewController.m
//  Hekr
//
//  Created by Mario on 15/6/29.
//  Copyright (c) 2015年 Michael Hu. All rights reserved.
//

#import "AboutViewController.h"
#import "DeviceViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UIView *accordingToContentView;
@property (weak, nonatomic) IBOutlet UIButton *turnBack;
@property (weak, nonatomic) IBOutlet UILabel *about_TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *scanLabel;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.accordingToContentView.layer setCornerRadius:10.0];
    
    
    self.versionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}
- (IBAction)touchBackButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)checkTheWebsite:(id)sender {

    NSString *link = @"www.hekr.me";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", link]]];
    
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
