//
//  PulseViewController.m
//  Hekr
//
//  Created by Mario on 15/6/29.
//  Copyright (c) 2015年 Michael Hu. All rights reserved.
//

#import "PulseViewController.h"
#import "PulsingHaloLayer.h"
#import <QuartzCore/QuartzCore.h>
#import "SettingViewController.h"
#import "NetworkingManage.h"
#import "HekrConfigMgr.h"
#import "DeviceViewController.h"
#import "SomeViewController.h"
#import "MainViewController.h"
#import "Reachability.h"

@interface PulseViewController () <UITextFieldDelegate, UIAlertViewDelegate>
{
    CAShapeLayer *arcLayer;
}
@property (nonatomic, strong) PulsingHaloLayer *haloLayer;
@property (nonatomic, strong) UILabel *pulseTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *pulseButton;
@property (weak, nonatomic) IBOutlet UIButton *turnSettingViewController;
@property(weak)IBOutlet UILabel *ssidNameLabel;
@property(weak)IBOutlet UITextField *pswField;
@property (weak, nonatomic) IBOutlet UIButton *pulseShowPsd;
@property (weak, nonatomic) IBOutlet UITextField *enterUserPassword;
@property (weak, nonatomic) IBOutlet UIScrollView *pulse_ScrollView;
@property (weak, nonatomic) IBOutlet UIButton *howToEnterBtn;
@property (weak, nonatomic) IBOutlet UIButton *theSelected;

@property (nonatomic, strong) UIAlertView *nonePsdAlertViewShow;
@property (nonatomic, strong) UIAlertView *noneSsidAlertViewShow;
@property (nonatomic, strong) NSTimer *pulseMyTimer;
@property (nonatomic, strong) UIAlertView *determineNetwork;

@end

@implementation PulseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[HekrRuntime shareInstance] setBlock:^{

        if ([[NetworkingManage currentWifiSSID] hasPrefix:@"Hekr_"]) {
            self.ssidNameLabel.text=[NSString stringWithFormat:NSLocalizedString(@"您当前的网络是:%@", nil),[NetworkingManage currentWifiSSID]];
        }
        else if ([HekrRuntime shareInstance].hostReach.currentReachabilityStatus == ReachableViaWWAN)
        {
            self.ssidNameLabel.text = NSLocalizedString(@"当前正在使用手机流量配置设备", nil);
        } else if ([HekrRuntime shareInstance].hostReach.currentReachabilityStatus == NotReachable)
        {
            self.ssidNameLabel.text = NSLocalizedString(@"当前无WiFi或者手机流量配置设备", nil);
            self.determineNetwork = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"网络连接失败", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
                self.determineNetwork.tag = 101;
                [self.determineNetwork show];

        }
        if ([[NetworkingManage currentWifiSSID] hasPrefix:@"Hekr_"]) {
            self.ssidNameLabel.text=[NSString stringWithFormat:NSLocalizedString(@"你当前网络: %@", nil),[NetworkingManage currentWifiSSID]];
        } else {
            if ([[NetworkingManage currentWifiSSID] class] == NULL) {
                self.ssidNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"您当前未连接Wi-Fi", nil)];
            } else
            {
                self.ssidNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"你当前网络: %@", nil), [NetworkingManage currentWifiSSID]];
            }
            
        }
    }];
    
    [[HekrRuntime shareInstance] checkNetWork];
    
    self.pswField.keyboardType = UIKeyboardTypeASCIICapable;
    self.enterUserPassword.keyboardType = UIKeyboardTypeASCIICapable;
    
    self.pulseTitleLabel = [[UILabel alloc] init];
    self.pulseTitleLabel.text = NSLocalizedString(@"设置配置", nil);
    self.pulseTitleLabel.frame = CGRectMake(self.view.frame.size.width/ 2.3, 20, 30, 20);
    self.pulseTitleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = self.pulseTitleLabel;
    
    self.enterUserPassword.secureTextEntry = YES;
    self.enterUserPassword.delegate = self;
    
    // 隐藏上下滑动的条
    self.pulse_ScrollView.showsVerticalScrollIndicator = FALSE;
    
    self.pulse_ScrollView.alwaysBounceHorizontal = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connection) name:@"ADD_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notFindDevice) name:@"ADD_NOT_FIND" object:nil];
   
    
    // 给Label / Button添加下划线
    NSMutableAttributedString *howToEnterString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"如何进入?", nil)];
    NSRange strRange = {0,[howToEnterString length]};
    [howToEnterString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [self.howToEnterBtn setAttributedTitle:howToEnterString forState:UIControlStateNormal];
    
    // 禁止显示侧边栏
    UIPanGestureRecognizer *recognizer;
    recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom)];
    [self.view addGestureRecognizer:recognizer];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
     [[HekrConfigMgr sharedInstance] stopSend];
}
- (void)handleSwipeFrom
{
    return;
}

-(void)notFindDevice
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        self.haloLayer.hidden = YES;
        arcLayer.hidden = YES;
        self.number = 0;
        [self.pulseButton setBackgroundImage:[UIImage imageNamed:@"PulseViewController_done"] forState:UIControlStateNormal];
        [KVNProgress showErrorWithStatus:NSLocalizedString(@"没找到设备", nil)
                                  onView:self.view];
    });
    
}
-(void)connection
{
    if ([[self.navigationController topViewController] isKindOfClass:[self class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"设备添加成功", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
        [alert show];
           [self.navigationController popViewControllerAnimated:YES];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ADD_SUCCESS" object:nil];

}
- (void)keyboardHide:(UITapGestureRecognizer *)tap
{
    [self.enterUserPassword resignFirstResponder];
}


-(void)intiUIOfView
{
    UIBezierPath *path=[UIBezierPath bezierPath];
    
    self.pulseButton.accessibilityPath = path;
    
    [path addArcWithCenter:CGPointMake(FULL_WIDTH/2, self.pulseButton.center.y) radius:self.pulseButton.frame.size.width /2  startAngle:1.5 *M_PI endAngle:3*M_PI+1.5*M_PI clockwise:YES];
    arcLayer=[CAShapeLayer layer];
    arcLayer.path=[self.pulseButton.accessibilityPath CGPath];//46,169,230
    arcLayer.fillColor = [[UIColor clearColor] CGColor];
    arcLayer.strokeColor=[UIColor colorWithRed:14/ 255.0 green:184 /255.0 blue:238 / 255.0 alpha:1].CGColor;
    arcLayer.lineWidth = 3;
    [self.pulse_ScrollView.layer addSublayer:arcLayer];
    [self drawLineAnimation:arcLayer];
    
/*
    self.haloLayer = [PulsingHaloLayer layer];
    self.haloLayer.position = self.pulseButton.center;
    [self.view.layer insertSublayer:self.haloLayer below:self.pulseButton.layer];
    //self.haloLayer.radius = kMaxRadius;
    UIColor *color = [UIColor colorWithRed:122 / 255.0 green:217 / 255.0 blue:244 /255.0 alpha:1];
    self.haloLayer.backgroundColor = color.CGColor;
*/
    
}

-(void)drawLineAnimation:(CALayer*)layer
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.duration=90;
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:bas forKey:@"key"];
}

- (IBAction)touchTurnSettingViewController:(id)sender {
    [self.navigationController pushViewController:[SettingViewController new] animated:YES];
}

- (IBAction)touchPulseButton:(id)sender withEvent:(UIEvent *)event
{
    if(self.number != 0)
    {
        self.number =0;
        [self.haloLayer removeAllAnimations];
        arcLayer.lineWidth=0;
        [arcLayer removeAllAnimations];
        [[HekrConfigMgr sharedInstance] stopSend];
        [self.pulseButton setBackgroundImage:[UIImage imageNamed:@"PulseViewController_done"] forState:UIControlStateNormal];
        return;
    }
    if (self.pswField.text.length >0 && [NetworkingManage currentWifiSSID].length>0 && self.number == 0) {
        
        self.haloLayer = [PulsingHaloLayer layer];
        self.haloLayer.position = CGPointMake(FULL_WIDTH / 2, self.pulseButton.center.y);
        [self.view.layer insertSublayer:self.haloLayer below:self.pulseButton.layer];
        self.haloLayer.radius = 100;
        UIColor *color = [UIColor colorWithRed:122 / 255.0 green:217 / 255.0 blue:244 /255.0 alpha:1];
        self.haloLayer.backgroundColor = color.CGColor;
        [self.pulse_ScrollView.layer addSublayer:self.haloLayer];
        [self intiUIOfView];
        
        [self.pulseButton setBackgroundImage:[UIImage imageNamed:@"PulseViewController_close"] forState:UIControlStateNormal];
        
        self.pulseMyTimer = [[NSTimer alloc] init];
        
        self.pulseMyTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerAdvanced) userInfo:nil repeats:NO];
        
        self.number++;

        [[HekrConfigMgr sharedInstance] sendPasswordToSSID:self.pswField.text ssidName:[NetworkingManage currentWifiSSID] Mtime:0.005];
    }else if (self.pswField.text.length == 0 || [NetworkingManage currentWifiSSID].length == 0 || self.number == 1){
        //提示用户没有输入密码，或没有连接WIFI
        [self.pulseButton setBackgroundImage:[UIImage imageNamed:@"PulseViewController_done"] forState:UIControlStateNormal];
        [[HekrConfigMgr sharedInstance] stopSend];
        
        [self.pulseMyTimer invalidate];
        self.haloLayer.hidden = YES;
        arcLayer.hidden = YES;
        self.number = 0;

        if (self.pswField.text.length == 0) {
            [self.pulseButton setBackgroundImage:[UIImage imageNamed:@"PulseViewController_done"] forState:UIControlStateNormal];
            self.nonePsdAlertViewShow = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"确认该Wi-Fi网络无密码?", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil)otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
            self.nonePsdAlertViewShow.tag = 10;
            [self.nonePsdAlertViewShow show];
            
        } else if ([NetworkingManage currentWifiSSID].length == 0)
        {
            [self.pulseButton setBackgroundImage:[UIImage imageNamed:@"PulseViewController_done"] forState:UIControlStateNormal];
            self.noneSsidAlertViewShow = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"请确认手机WiFi已连接", nil) message:NSLocalizedString(@"建议检查手机网络", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
            self.noneSsidAlertViewShow.tag = 20;
            [self.noneSsidAlertViewShow show];
        }
    }
}

- (void)timerAdvanced
{
    [self.pulseButton setBackgroundImage:[UIImage imageNamed:@"PulseViewController_done"] forState:UIControlStateNormal];
    self.number=0;
    arcLayer.hidden = YES;
}


- (IBAction)showPasswordButtonClicked:(id)sender
{
    if (self.enterUserPassword.secureTextEntry == YES)
    {
        [self.pulseShowPsd setImage:[UIImage imageNamed:@"settingViewController_showPsd"] forState:UIControlStateNormal];
        self.enterUserPassword.keyboardType = UIKeyboardTypeASCIICapable;
        self.enterUserPassword.secureTextEntry = NO;
        
    } else if (self.enterUserPassword.secureTextEntry == NO)
    {
        [self.pulseShowPsd setImage:[UIImage imageNamed:@"settingViewController_showPassword"] forState:UIControlStateNormal];
        self.enterUserPassword.keyboardType = UIKeyboardTypeASCIICapable;
        self.enterUserPassword.secureTextEntry = YES;
    }
}

- (IBAction)howToEnterButtonClicked:(id)sender {
    NSLog(@"当前点击了如何进入Button");
    
    DeviceViewController *device = [DeviceViewController new];
    device.urlString = @"https://hekr.daikeapp.com/";
    device.isShowNav=YES;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    view.backgroundColor = [UIColor colorWithRed:94/255.0 green:95/255.0 blue:160/255.0 alpha:1];
    [device.view addSubview:view];
    
    [self.navigationController pushViewController:device animated:YES];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.enterUserPassword resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.pulseButton setBackgroundImage:[UIImage imageNamed:@"PulseViewController_done"] forState:UIControlStateNormal];
    self.number = 0;
    arcLayer.hidden = YES;
    self.haloLayer.hidden = YES;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MainViewController *mainVC = [[MainViewController alloc] init];
    
    if (alertView.tag == 10) {
        if (buttonIndex == 1) {
            // 跳出键盘
            //[self.pswField becomeFirstResponder];
            self.number = 0;
            self.haloLayer = [PulsingHaloLayer layer];
            self.haloLayer.position = CGPointMake(FULL_WIDTH / 2, self.pulseButton.center.y);
            [self.view.layer insertSublayer:self.haloLayer below:self.pulseButton.layer];
            self.haloLayer.radius = 100;
            UIColor *color = [UIColor colorWithRed:122 / 255.0 green:217 / 255.0 blue:244 /255.0 alpha:1];
            self.haloLayer.backgroundColor = color.CGColor;
            [self.pulse_ScrollView.layer addSublayer:self.haloLayer];
            [self intiUIOfView];
            
            [self.pulseButton setBackgroundImage:[UIImage imageNamed:@"PulseViewController_close"] forState:UIControlStateNormal];
            
            self.pulseMyTimer = [[NSTimer alloc] init];
            
            self.pulseMyTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerAdvanced) userInfo:nil repeats:NO];
            
            self.number++;
            [[HekrConfigMgr sharedInstance] sendPasswordToSSID:@"" ssidName:[NetworkingManage currentWifiSSID] Mtime:0.05];
        } else if (self.noneSsidAlertViewShow) {
            if (buttonIndex == 0) {
                [self.navigationController popToViewController:mainVC animated:YES];
            } else if (buttonIndex == 1)
            {
                [self.pswField becomeFirstResponder];
                self.number = 0;
            }
        } else if (alertView.tag == 101) {
            if (buttonIndex == 1) {
                [self.navigationController popToViewController:mainVC animated:YES];
            }
        }
    }
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
