//
//  LoginViewController.m
//  Hekr
//
//  Created by Michael Scofield on 2015-06-25.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import "LoginViewController.h"
#import "NetworkingManage.h"
#import "DeviceViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    UIPanGestureRecognizer *recognizer;
    recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom)];
    [self.view addGestureRecognizer:recognizer];
    // Do any additional setup after loading the view from its nib.
}

-(void)handleSwipeFrom
{
    return;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)localLogin:(id)sender
{
    [self.loaclLand setBackgroundImage:[UIImage imageNamed:@"login_l2"] forState:UIControlStateNormal];
    [NetworkingManage loginByLocal:^(BOOL finish) {
        if (finish) {
            //登陆成功
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGIN" object:nil];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}
-(IBAction)qqLogin:(id)sender
{
    [self goToWhichWebView:@"qq"];
    [self.qqland setBackgroundImage:[UIImage imageNamed:@"login_q2"] forState:UIControlStateNormal];
    
}
-(IBAction)sinaLogin:(id)sender
{
    [self goToWhichWebView:@"weibo"];
    [self.sinaLand setBackgroundImage:[UIImage imageNamed:@"login_w2"] forState:UIControlStateNormal];
}
-(IBAction)facebookLogin:(id)sender
{
    [self goToWhichWebView:@"g"];
    [self.googleLand setBackgroundImage:[UIImage imageNamed:@"login_g2"] forState:UIControlStateNormal];
}
-(IBAction)twitterLogin:(id)sender
{
    [self goToWhichWebView:@"tw"];
    [self.twitterLand setBackgroundImage:[UIImage imageNamed:@"login_t2"] forState:UIControlStateNormal];
}
-(void)goToWhichWebView:(NSString *)type
{
    NSString *url = @"";
    if ([type isEqualToString:@"tw"] || [type isEqualToString:@"g"]) {
        url = [NSString stringWithFormat:@"http://login.smartmatrix.mx/oauth.htm?type=%@",type];
    }else{
      url = [NSString stringWithFormat:@"http://login.hekr.me/oauth.htm?type=%@",type];
    }
    DeviceViewController *device = [DeviceViewController new];
    device.urlString=url;
    device.isShowNav=YES;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];

    view.backgroundColor = [UIColor colorWithRed:94/255.0 green:95/255.0 blue:160/255.0 alpha:1];
    [device.view addSubview:view];

    [self.navigationController pushViewController:device animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.loaclLand setBackgroundImage:[UIImage imageNamed:@"loginViewController_user"] forState:UIControlStateNormal];
    [self.qqland setBackgroundImage:[UIImage imageNamed:@"login_q"] forState:UIControlStateNormal];
    [self.sinaLand setBackgroundImage:[UIImage imageNamed:@"login_w"] forState:UIControlStateNormal];
    [self.twitterLand setBackgroundImage:[UIImage imageNamed:@"login_t"] forState:UIControlStateNormal];
    [self.googleLand setBackgroundImage:[UIImage imageNamed:@"login_g"] forState:UIControlStateNormal];
}

- (IBAction)touchGoogleDown:(id)sender {
    [self.googleLand setBackgroundImage:[UIImage imageNamed:@"login_g2"] forState:UIControlStateNormal];
}
- (IBAction)touchLocalDown:(id)sender {
    [self.loaclLand setBackgroundImage:[UIImage imageNamed:@"login_l2"] forState:UIControlStateNormal];
}
- (IBAction)touchQQDown:(id)sender {
    [self.qqland setBackgroundImage:[UIImage imageNamed:@"login_q2"] forState:UIControlStateNormal];
}
- (IBAction)touWeiboDown:(id)sender {
    [self.sinaLand setBackgroundImage:[UIImage imageNamed:@"login_w2"] forState:UIControlStateNormal];
}
- (IBAction)touchTwitterDonw:(id)sender {
    [self.twitterLand setBackgroundImage:[UIImage imageNamed:@"login_t2"] forState:UIControlStateNormal];
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
