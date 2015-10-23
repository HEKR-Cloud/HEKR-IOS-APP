//
//  DeviceViewController.h
//  Hekr
//
//  Created by Michael Scofield on 2015-06-26.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceViewController : UIViewController<UIWebViewDelegate>
@property(weak)IBOutlet UIWebView *webView;
@property(assign)BOOL isShowNav;
@property(copy)NSString *urlString;
-(IBAction)goBack:(id)sender;
@end
