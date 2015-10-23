//
//  LoginViewController.h
//  Hekr
//
//  Created by Michael Scofield on 2015-06-25.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *loaclLand;
@property (weak, nonatomic) IBOutlet UIButton *sinaLand;
@property (weak, nonatomic) IBOutlet UIButton *twitterLand;
@property (weak, nonatomic) IBOutlet UIButton *googleLand;
@property (weak, nonatomic) IBOutlet UIButton *qqland;


-(IBAction)localLogin:(id)sender;
-(IBAction)qqLogin:(id)sender;
-(IBAction)sinaLogin:(id)sender;
-(IBAction)facebookLogin:(id)sender;
-(IBAction)twitterLogin:(id)sender;
@end
