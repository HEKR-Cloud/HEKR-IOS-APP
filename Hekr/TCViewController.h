//
//  TCViewController.h
//  Hekr
//
//  Created by Mario on 15/6/29.
//  Copyright (c) 2015年 Michael Hu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"


@interface TCViewController : UIViewController

@property (nonatomic, strong) UIPlaceHolderTextView *tuTextField;
@property (weak, nonatomic) IBOutlet UIButton *gagBackButton;
@property (weak, nonatomic) IBOutlet UILabel *gagTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *gagSubTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *gagSendMegButton;

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *gagPlaceHolder;


@end
