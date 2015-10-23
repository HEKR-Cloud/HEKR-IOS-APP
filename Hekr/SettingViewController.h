//
//  SettingViewController.h
//  Hekr
//
//  Created by Michael Scofield on 2015-06-25.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
-(IBAction)connectWithSoftAP:(id)sender;
-(IBAction)hiddenKeyboard:(id)sender;
@end
