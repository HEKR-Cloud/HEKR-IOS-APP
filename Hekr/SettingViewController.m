//
//  SettingViewController.m
//  Hekr
//
//  Created by Michael Scofield on 2015-06-25.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import "SettingViewController.h"
#import "NetworkingManage.h"
#import "PromptViewController.h"
#import "NetworkingManage.h"
#import "MainViewController.h"
#import "DeviceNameForSSID.h"
@interface SettingViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *selectEquipment;
@property (weak, nonatomic) IBOutlet UIButton *chooseHot;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *enterPassword;
@property (weak)IBOutlet UITableView *tableView;
@property(weak)IBOutlet UILabel *chooseHotLabel;
@property(strong)NSTimer *countTimer;
@property(strong)NSDictionary *selectDic;
@property(strong)NSMutableArray *array;
@property(assign)NSInteger time;
@property (weak, nonatomic) IBOutlet UIButton *settingShowPsd;
@property(weak)IBOutlet UITextField *field1;
@property (weak, nonatomic) IBOutlet UIButton *theSelected;
@property (weak, nonatomic) IBOutlet UIScrollView *setting_ScorllView;

@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) NSInteger chooseNumbers;

@end

@implementation SettingViewController


- (IBAction)selectEquipment:(id)sender {
    
    [self.navigationController pushViewController:[PromptViewController new] animated:YES];
    
    self.enterPassword.delegate = self;
}


- (IBAction)doneButton:(id)sender {
    self.chooseNumbers = 0;
    if (self.chooseNumbers == 0) {
        [self.doneButton setTitle:NSLocalizedString(@"请稍后", nil) forState:UIControlStateNormal];
        self.chooseNumbers++;
    } else if (self.chooseNumbers != 0)
    {
        [self.doneButton setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
        self.chooseNumbers = 0;
    }
    if (self.selectDic && self.enterPassword.text.length > 0) {
        
        [NetworkingManage checkSSIDInfo:self.selectDic Password:self.enterPassword.text Block:^(bool isok, NSError *error) {
            if (!isok) {
                NSLog(@"连接成功");
                [NetworkingManage closeDevice];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"设备添加成功", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
                [alert show];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }else{
                //提示用户
                 SCLAlertView *alert = [SCLAlertView new];
                [alert showError:self title:NSLocalizedString(@"错误", nil) subTitle:NSLocalizedString(@"无法连接设备", nil) closeButtonTitle:NSLocalizedString(@"确定", nil) duration:0];
            }
        }];
    } else if (self.selectDic == nil || self.enterPassword.text == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示, 请查看设备是否选中或密码是否输入", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
        alertView.tag = 10;
        [alertView show];
    }
}
- (IBAction)settingPsdButtonClicked:(id)sender {
    if (self.enterPassword.secureTextEntry == YES)
    {
        [self.settingShowPsd setImage:[UIImage imageNamed:@"settingViewController_showPsd"] forState:UIControlStateNormal];
        self.enterPassword.keyboardType = UIKeyboardTypeASCIICapable;
        self.enterPassword.secureTextEntry = NO;
        
    } else
    {
        [self.settingShowPsd setImage:[UIImage imageNamed:@"settingViewController_showPassword"] forState:UIControlStateNormal];
        self.enterPassword.keyboardType = UIKeyboardTypeASCIICapable;
        self.enterPassword.secureTextEntry = YES;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    self.array = [NSMutableArray new];
    // Do any additional setup after loading the view from its nib.
    
    self.enterPassword.secureTextEntry = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHides:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    if ([[NetworkingManage currentWifiSSID] hasPrefix:@"Hekr_"]) {
        [self.selectEquipment setTitle:[NetworkingManage currentWifiSSID] forState:UIControlStateNormal];
    }
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [[HekrRuntime shareInstance] setBlock:^{
        if ([[NetworkingManage currentWifiSSID] hasPrefix:@"Hekr_"]) {
            [self.chooseHotLabel setText:[NSString stringWithFormat:NSLocalizedString(@"正在为%@设置连接", nil),[NetworkingManage currentWifiSSID]]];
            NSString *selectEquipmentLabel = [NetworkingManage currentWifiSSID];
            NSLog(@"selectEquipmentLabel %@", selectEquipmentLabel);
            [self.selectEquipment setTitle:selectEquipmentLabel forState:UIControlStateNormal];
        }else{
            self.chooseHotLabel.text = NSLocalizedString(@"未找到设备", nil);
        }
    }];
    [[HekrRuntime shareInstance] checkNetWork];
    
    UIPanGestureRecognizer *recognizer;
    recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom)];
    [self.view addGestureRecognizer:recognizer];
    
    [self.view addSubview:self.setting_ScorllView];
    
    // 键盘上移
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

// 键盘打开是出发的事件
- (void)keyboardShow:(NSNotification *)notif
{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y - 120);
    }];
    
}



- (void)keyboardHide:(NSNotification *)notif
{
    [UIView animateWithDuration:0.2 animations:^{
        
        self.view.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height /2);
        
    }];
    
}


- (void)handleSwipeFrom
{
    return;
}

-(void)keyboardHides:(UITapGestureRecognizer*)tap{
    [self.enterPassword resignFirstResponder];
//    self.tableView.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)connectWithSoftAP:(id)sender
{
    if (self.number == 0) {
        self.number++;
        self.time=0;
        self.countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countScanTime) userInfo:nil repeats:YES];
        
        [NetworkingManage setAK:^(bool isok, NSError *error) {
            if (!isok) {
                [NetworkingManage getListFromSoftAP:^(NSArray *array, NSError *error) {
                    if (array&&[array isKindOfClass:[NSArray class]]) {
                        [self.array addObjectsFromArray:array];
                        
                        self.chooseHotLabel.text=NSLocalizedString(@"选择热点", nil);
                        NSLog(@"array === %@", array);
                        [self.countTimer invalidate];
                        self.countTimer=nil;
                        [self.tableView setHidden:NO];
                        [self.tableView reloadData];
                    }
                }];
            }
        }];
        } else if (self.number == 1)
    {
        self.tableView.hidden = YES;
        self.number = 0;
    }

/*
    self.time=0;
    self.countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countScanTime) userInfo:nil repeats:YES];
    
    [NetworkingManage setAK:^(bool isok, NSError *error) {
        if (!isok) {
            [NetworkingManage getListFromSoftAP:^(NSArray *array, NSError *error) {
                if (array&&[array isKindOfClass:[NSArray class]]) {
                    [self.array removeAllObjects];
                    [self.array addObjectsFromArray:array];
                     self.chooseHotLabel.text=@"选择热点";
                    [self.countTimer invalidate];
                    self.countTimer=nil;
                    [self.tableView setHidden:NO];
                    [self.tableView reloadData];
                }
            }];
        }
    }];
*/
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.array count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SSID_Identifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SSID_Identifier"];
    }
    NSDictionary *dic = [self.array objectAtIndex:indexPath.row];
    [cell.textLabel setText:[dic objectForKey:@"ssid"]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.array objectAtIndex:indexPath.row];
    self.selectDic =dic;
    NSString *chooseHotLabel = [dic objectForKey:@"ssid"];
    [self.theSelected setTitle:chooseHotLabel forState:UIControlStateNormal];
    [tableView setHidden:YES];
}

-(void)countScanTime
{
    self.time++;
    self.chooseHotLabel.text = NSLocalizedString(@"热点列表正在加载中...", nil);
    if (self.time == 30) {
        [self.countTimer invalidate];
        self.countTimer=nil;
        
        UIAlertView *timeAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示, 请先选择设备的Wi-Fi", nil) message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        timeAlertView.tag = 20;
        [timeAlertView show];
        
        [self.chooseHot setTitle:NSLocalizedString(@"选择热点", nil) forState:UIControlStateNormal];
    }
}

-(IBAction)hiddenKeyboard:(id)sender
{
    [self.enterPassword resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10) {
        
        [self.doneButton setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
        self.chooseNumbers = 0;
    }
    if (alertView.tag == 20) {
        if (buttonIndex == 0) {
            [self.countTimer invalidate];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([DeviceNameForSSID shareInstace].ssidName != nil) {
        [self.selectEquipment setTitle:[DeviceNameForSSID shareInstace].ssidName forState:UIControlStateNormal];
        NSString *ssidNameString = [DeviceNameForSSID shareInstace].ssidName;
        self.chooseHotLabel.text = [NSString stringWithFormat:NSLocalizedString(@"当前设备名称是: %@", nil),ssidNameString];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.selectEquipment setTitle:NSLocalizedString(@"选择设备", nil) forState:UIControlStateNormal];
    [DeviceNameForSSID shareInstace].ssidName = NSLocalizedString(@"选择设备", nil);
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
