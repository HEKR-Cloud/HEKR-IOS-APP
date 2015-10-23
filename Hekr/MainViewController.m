//
//  ViewController.m
//  Hekr
//
//  Created by Michael Scofield on 2015-06-24.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import "MainViewController.h"
#import "StorageManage.h"
#import "LoginViewController.h"
#import "NetworkingManage.h"
#import "MainTableViewCell.h"
#import "DeviceObject.h"
#import <UIViewController+MMDrawerController.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "PulseViewController.h"
#import "UUIDManager.h"
#import "DeviceViewController.h"
#import "UIView+MaterialDesign.h"
#import <MJRefresh.h>
#import "SWTableViewCell.h"
#import "DeviceInfoViewController.h"
@interface MainViewController ()
@property(weak)IBOutlet UITableView *tableView;
@property(strong)NSMutableArray *datas;
@property (nonatomic, assign) BOOL flag;
@property (nonatomic, strong) NSString *currentLanguage;
@property (nonatomic, strong) NSString *cellTitleName;
@property (weak, nonatomic) IBOutlet UILabel *addDeviceLabel;
@end

@implementation MainViewController
- (id)init
{
    self = [super init];
    if (self) {
        [self setRestorationIdentifier:@"MMExampleCenterNavigationControllerRestorationKey"];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:@"LOGIN" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOut) name:@"QUIT" object:nil];
    
    self.datas = [NSMutableArray new];
    if ([[StorageManage sharedInstance] getCSRF]) {
        
        [self fetchData];
        
    }else{
        [self showLoginPageFunc];
    }
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableFooterView=[UIView new];
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    // 隐藏时间
    self.tableView.header.updatedTimeHidden = YES;
    self.tableView.header.textColor = [UIColor whiteColor];
    // 马上进入刷新状态
    [self.tableView.header beginRefreshing];
    
    UIImageView *imageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_logo"]];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.9, 25, 72, 18)];
    imageView.frame=view.bounds;
    [view addSubview:imageView];
    self.navigationItem.titleView = view;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    leftButton.frame = CGRectMake(0, 0, 20, 20);
    [leftButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftDrawerButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    rightButton.frame = CGRectMake(0, 0, 20, 20);
    [rightButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(settingPage:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self theRefresh];
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
-(void)logOut
{
    [self showLoginPageFunc];
}
-(IBAction)settingPage:(id)sender
{
    [self.navigationController pushViewController:[PulseViewController new] animated:YES];
}
-(void)reloadData
{
    [self.tableView reloadData];
    
    NSLog(@"self.datas: %@", self.datas);
    NSLog(@"self.datas.count:::: %lu", (unsigned long)self.datas.count);
    if (self.datas.count > 0) {
        self.addDeviceLabel.hidden = YES;
    } else {
        self.addDeviceLabel.text = NSLocalizedString(@"      您当前的设备列表是空的, 请点击右上角'+'图标进行添加设备.", nil);
        self.addDeviceLabel.hidden = NO;
    }
}
-(void)fetchData
{
    NSLog(@"login successfull");
    //先加载本地数据
    [self fetchDataFromLocal];

    //----加载网络数据
    [NetworkingManage getAllDevicesList:^(NSDictionary *dic, NSError *error) {
        [NetworkingManage getUserDeviceList:^(NSArray *array, NSError *error) {
            if(error.code!= 404)
            {
                if (array) {
                    [self.datas removeAllObjects];
                    for (NSDictionary *temp in array) {
                        DeviceObject *dev = [DeviceObject convert:temp];
                        NSDictionary *detais = dic[dev.CID];
                        if (detais) {
                            dev.ename=detais[@"ename"];
                            dev.cname = detais[@"name"];
                            NSDictionary *normalUrl = detais[@"logo_url"];
                            dev.deviceLogo=normalUrl[@"normal"];
                        }else{
                            dev.ename=NSLocalizedString(@"未知", nil);
                            dev.cname=NSLocalizedString(@"未知", nil);;
                            dev.deviceLogo=@"";
                        }
                        [self.datas addObject:dev];
                    }
                    [[StorageManage sharedInstance] saveUserDevices:self.datas];
                    [self reloadData];
                }else {
                    
                    [self reloadData];
                }
                
            }else{
                [self reloadData];
                NSLog(@"404 error");
            }
        }];
    }];
   
}

- (void)setupRefresh
{
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.header.textColor = [UIColor whiteColor];
    self.tableView.header.updatedTimeHidden = YES;
    [self theRefresh];
    [self.tableView.header beginRefreshing];
}

- (void)loadNewData
{
    [self fetchData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self.tableView reloadData];
        
        [self.tableView.header endRefreshing];
    });
}


-(void)fetchDataFromLocal
{
    NSArray *array = [[StorageManage sharedInstance] getUserDevices];
    [self.datas removeAllObjects];
    [self.datas addObjectsFromArray:array];
    [self reloadData];
}

-(void)loginSuccess
{
    [self theRefresh];
    [self.tableView.header beginRefreshing];
    [self loadNewData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.datas count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"MainTableViewCell";
    MainTableViewCell* cell =(MainTableViewCell *) [tableView dequeueReusableCellWithIdentifier:str];
        if (!cell) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MainTableViewCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
     cell.rightUtilityButtons = [self rightButtons];
     cell.delegate = self;
    // 去除点击Cell后tableView上面产生的阴影
    DeviceObject *object = [self.datas objectAtIndex:indexPath.row];
    
    [self determineTheLanguage];
    
    // 变更语言
    if ([self.currentLanguage hasPrefix:@"zh-H"]) {
        self.cellTitleName = object.cname;
        self.currentLanguage = @"zh-CN";
    } else
    {
        self.cellTitleName = object.ename;
        self.currentLanguage = @"en-US";
    }
    
    NSString *tidName =@" ";
    if (object.TID.length >2) {
        tidName= [object.TID substringFromIndex:object.TID.length-2];
    }
    [cell.productIcon sd_setImageWithURL:[NSURL URLWithString:object.deviceLogo]];

    [cell.productIcon sd_setImageWithURL:[NSURL URLWithString:object.deviceLogo]];
    cell.productName.text= object.name.length > 0 ? object.name : [NSString stringWithFormat:@"%@_%@",self.cellTitleName,tidName];

    if (object.online == NO) {
        cell.switchsStatus.text = NSLocalizedString(@"离线", nil);
        cell.switchs.text = NSLocalizedString(@"离线", nil);
        
        cell.productName.textColor = [UIColor lightGrayColor];
        cell.switchs.textColor = [UIColor lightGrayColor];
        cell.switchsStatus.textColor = [UIColor lightGrayColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    } else if (object.online == YES) {
        cell.switchs.text = NSLocalizedString(@"在线", nil);
        cell.switchsStatus.text = NSLocalizedString(@"在线", nil);
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.switchsStatus.textColor = [UIColor whiteColor];
        cell.switchs.textColor = [UIColor whiteColor];
        cell.productName.textColor = [UIColor whiteColor];
        if ([object.state  isEqual: @"1"]) {
            cell.switchsStatus.text = NSLocalizedString(@"已开", nil);
            cell.switchs.text = NSLocalizedString(@"已开", nil);
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        } else if ([object.state isEqual:@"0"])
        {
            cell.switchs.text = NSLocalizedString(@"已关", nil);
            cell.switchsStatus.text = NSLocalizedString(@"已关", nil);
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        } 
    }

    return cell;
}
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:0.7]
                                                title:NSLocalizedString(@"设置",nil)];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:0.7f]
                                                title:NSLocalizedString(@"删除",nil)];
    for(UIButton *btn in rightUtilityButtons)
    {
        CGRect rect = btn.frame;
        rect.size.height=rect.size.height-10;
        btn.frame=rect;
    }
    return rightUtilityButtons;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    DeviceObject *obj = [self.datas objectAtIndex:indexPath.row];
    NSString *url = [NSString stringWithFormat:@"http://app.hekr.me/vendor/%@/index.html?access_key=%@&tid=%@&lang=%@&user=%@",obj.MID,[[StorageManage sharedInstance] getUserToken],obj.TID,self.currentLanguage,[UUIDManager shareInstance].getUUID];
    DeviceViewController *deviceView = [DeviceViewController new];
    deviceView.urlString=url;
    deviceView.isShowNav=NO;
    
    MainTableViewCell *cell = (MainTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
   
    DeviceObject *object = [self.datas objectAtIndex:indexPath.row];
    
    if (object.online == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"设备已经离线", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
        [alertView show];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    } else if (object.online == YES)
    {
        if (self.flag == NO) {
            [cell.whiteRoundedCornerView mdInflateAnimatedFromPoint:cell.toucheBegiPoint backgroundColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.2] duration:0.5 completion:^{
                cell.whiteRoundedCornerView.backgroundColor=[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.2];
                [self.navigationController pushViewController:deviceView animated:YES];
                self.flag = NO;
            }];
            self.flag = YES;
        }
    }

}



- (void)determineTheLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *theCurrentLanguage = [languages objectAtIndex:0];
    self.currentLanguage = theCurrentLanguage;
}

- (void)theRefresh
{
    [self.tableView.header setTitle:NSLocalizedString(@"下拉可以刷新", nil) forState:MJRefreshHeaderStateIdle];
    [self.tableView.header setTitle:NSLocalizedString(@"松开立即刷新", nil) forState:MJRefreshHeaderStatePulling];
    [self.tableView.header setTitle:NSLocalizedString(@"加载中...", nil) forState:MJRefreshHeaderStateRefreshing];
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    DeviceObject *device = [self.datas safeObjectAtIndex:cellIndexPath.row];
    switch (index) {
        case 0:
        {
            if (device.online) {
                DeviceInfoViewController *deviceInfo = [DeviceInfoViewController new];
                deviceInfo.device=device;
                [self.navigationController pushViewController:deviceInfo animated:YES];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"设备已经离线", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
            break;
        case 1:
        {
            // Delete button was pressed
           
            [NetworkingManage deleteDeviceFromCloud:device.TID Block:^(bool isok, NSError *error) {
                if (isok) {
                    [self.datas removeObjectAtIndex:cellIndexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                }else{
                    [KVNProgress showErrorWithStatus:NSLocalizedString(@"删除失败",nil)];
                }
            }];
          
            break;
        }
        default:
            break;
    }
}

-(void)showLoginPageFunc
{
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
       [self.navigationController pushViewController:[LoginViewController new] animated:NO];
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [self theRefresh];
    [self.tableView.header beginRefreshing];    
    [self loadNewData];
}

@end
