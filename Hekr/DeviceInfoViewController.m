//
//  DeviceInfoViewController.m
//  HEKR
//
//  Created by Michael Scofield on 2015-08-26.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import "DeviceInfoViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NetworkingManage.h"
#import "StorageManage.h"
#import "DeviceViewController.h"
#import "UUIDManager.h"
@interface DeviceInfoViewController ()<UIAlertViewDelegate,UITextFieldDelegate>
@property(strong)NSArray *titles;
@property (strong)NSArray *vaules;
@end

@implementation DeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"设置",nil);
    self.tableView.tableHeaderView=[self headView:self.device];
    [self update];
    // Do any additional setup after loading the view from its nib.
}
-(void) update{
    self.titles=@[NSLocalizedString(@"设备名称",nil),NSLocalizedString(@"设备品牌",nil),NSLocalizedString(@"设备型号",nil),NSLocalizedString(@"固件版本",nil)];
    NSString * name = self.device.name;
    if (name.length <= 0) {
        if ([[self determineTheLanguage] hasPrefix:@"zh-H"]) {
            name = self.device.cname;
        } else
        {
            name = self.device.ename;
        }
        NSString *tidName =@" ";
        if (self.device.TID.length >2) {
            tidName= [self.device.TID substringFromIndex:self.device.TID.length-2];
        }
        name = [NSString stringWithFormat:@"%@_%@",name,tidName];
    }
    self.vaules =@[name,self.device.mname,self.device.ename,self.device.dVersion];
}
-(UIView *)headView:(DeviceObject *)device
{
    UIView *headbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FULL_WIDTH-32, 100)];
    headbg.backgroundColor=[UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
    UIView *hole = [[UIView alloc] initWithFrame:CGRectMake(headbg.frame.size.width/2-16, 25, 70, 70)];
    hole.backgroundColor=[UIColor clearColor];
    [hole.layer setBorderWidth:1.0];
    [hole.layer setBorderColor:[UIColor whiteColor].CGColor];
    [hole.layer setCornerRadius:hole.frame.size.width/2];
    [imageView sd_setImageWithURL:[NSURL URLWithString:device.deviceLogo]];
    [imageView setHidden:NO];
    [headbg addSubview:hole];
    [hole addSubview:imageView];
    return headbg;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"UITableViewCell";
    UITableViewCell* cell =(UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:str];
    }
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
    [cell.detailTextLabel setText:self.vaules[indexPath.row]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    [cell.textLabel setText:self.titles[indexPath.row]];
    if (indexPath.row == 0 || indexPath.row == 1) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self changeDeviceName];
            break;
            
        default:
            break;
    }
}
-(void)changeDeviceName
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"输入新的名字",nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:NSLocalizedString(@"确定",nil), nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].text = self.vaules.firstObject;
    [alert show];
 
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString * name = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSUInteger location = [name rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location;
        if (location != NSNotFound) {
            name = [name substringFromIndex:location];
        }
        
        if (name.length>0 && name.length <= 15) {
            [NetworkingManage changeDeviceName:self.device.TID Name:name Block:^(bool isok, NSError *error) {
                if (isok) {
                    self.device.name = name;
                    [self update];
                    [self.tableView reloadData];
                }else{
                    [KVNProgress showErrorWithStatus:NSLocalizedString(@"改名失败",nil)];
                }
            }];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"名字应在15字以内，且不能为空格",nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:NSLocalizedString(@"确定",nil), nil];
            [alert show];
        }
    }
}
-(IBAction)deleteDevice:(id)sender{
    [NetworkingManage deleteDeviceFromCloud:self.device.TID Block:^(bool isok, NSError *error) {
        if (isok) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"删除失败",nil)];
        }
    }];
}
-(IBAction)goToDeviceControlView:(id)sender
{
    NSString *lang=@"zh-CN";
    if ([[self determineTheLanguage] hasPrefix:@"zh-H"]) {
        lang = @"zh-CN";
    } else
    {
        lang = @"en-US";
    }
    
    NSString *url = [NSString stringWithFormat:@"http://app.hekr.me/vendor/%@/index.html?access_key=%@&tid=%@&lang=%@&user=%@",self.device.MID,[[StorageManage sharedInstance] getUserToken],self.device.TID,lang,[UUIDManager shareInstance].getUUID];
    DeviceViewController *deviceView = [DeviceViewController new];
    deviceView.urlString=url;
    deviceView.isShowNav=NO;
    [self.navigationController pushViewController:deviceView animated:YES];
}
- (NSString *)determineTheLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *theCurrentLanguage = [languages objectAtIndex:0];
    return  theCurrentLanguage;
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
