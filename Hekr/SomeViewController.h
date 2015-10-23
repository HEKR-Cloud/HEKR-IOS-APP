//
//  SomeViewController.h
//  Hekr
//
//  Created by Mario on 15/7/8.
//  Copyright (c) 2015年 Michael Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SomeViewController : UIViewController

@property (nonatomic, strong) NSString *howToUrlString;
@property (weak, nonatomic) IBOutlet UIWebView *web;
@property (nonatomic, strong) NSString *urlString;
@property (weak, nonatomic) IBOutlet UIButton *GoBack;

@end
