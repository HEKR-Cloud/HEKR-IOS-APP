//
//  PulseViewController.h
//  Hekr
//
//  Created by Mario on 15/6/29.
//  Copyright (c) 2015年 Michael Hu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>

@interface PulseViewController : UIViewController

@property (nonatomic, assign) NSInteger number;

- (IBAction)touchPulseButton:(id)sender withEvent:(UIEvent *)event;

@end
