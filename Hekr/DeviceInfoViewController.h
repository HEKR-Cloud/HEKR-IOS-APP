//
//  DeviceInfoViewController.h
//  HEKR
//
//  Created by Michael Scofield on 2015-08-26.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceObject.h"
@interface DeviceInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(weak)IBOutlet UITableView *tableView;
@property(strong)DeviceObject *device;
-(IBAction)goToDeviceControlView:(id)sender;
-(IBAction)deleteDevice:(id)sender;
@end
