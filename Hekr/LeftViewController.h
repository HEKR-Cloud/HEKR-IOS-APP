//
//  LeftViewController.h
//  HEKR
//
//  Created by Mario on 15/5/25.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftViewController : UIViewController

@property (nonatomic, strong) UIImageView *backView;
@property (nonatomic, strong) UIImageView *logoView;

@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *gagButton;
@property (weak, nonatomic) IBOutlet UIButton *quiteButton;

@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *gagLabel;
@property (weak, nonatomic) IBOutlet UILabel *quiteLabel;



@end
