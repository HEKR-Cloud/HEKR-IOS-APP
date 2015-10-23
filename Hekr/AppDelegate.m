//
//  AppDelegate.m
//  Hekr
//
//  Created by Michael Scofield on 2015-06-24.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import "AppDelegate.h"
#import <MMDrawerController.h>
#import <MMDrawerVisualState.h>
#import "NetworkingManage.h"
#import "MainViewController.h"
#import "LeftViewController.h"
#import <UIKit/UIView.h>
#import "MMExampleDrawerVisualStateManager.h"
static BOOL OSVersionIsAtLeastiOS7() {
    return (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1);
}
@interface AppDelegate ()
@property (nonatomic, strong) MMDrawerController *drawerController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *leftVC = [[LeftViewController alloc] init];
    UINavigationController *centerNaviVC = [[UINavigationController alloc] initWithRootViewController:[MainViewController new]];
    [centerNaviVC setRestorationIdentifier:@"MMExampleCenterNavigationControllerRestorationKey"];
        UINavigationController *leftNavigationController = [[UINavigationController alloc] initWithRootViewController:[LeftViewController new]];
        [leftNavigationController setRestorationIdentifier:@"MMExampleLeftNavigationControllerRestorationKey"];
        self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:centerNaviVC leftDrawerViewController:leftVC];
    [self.drawerController setShowsShadow:YES];
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumLeftDrawerWidth:leftVC.view.frame.size.width *2/5];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [self.drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        MMDrawerControllerDrawerVisualStateBlock block;
        block = [[MMExampleDrawerVisualStateManager sharedManager] drawerVisualStateBlockForDrawerSide:drawerSide];
        if (block) {
            block(drawerController, drawerSide, percentVisible);
        }
    }];
    
    if (OSVersionIsAtLeastiOS7()) {
        UIColor *tintColor = [UIColor whiteColor];
        [self.window setTintColor:tintColor];
    }
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [self.window setRootViewController:self.drawerController];
    [self.window makeKeyAndVisible];
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    
    [[HekrRuntime shareInstance] setBlock:^{
        
        if ([HekrRuntime shareInstance].hostReach.currentReachabilityStatus == NotReachable)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"网络连接失败", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
            alertView.tag = 101;
            [alertView show];
        }
    }];
    
//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
//        NSLog(@"%@----cookie name ,%@----cookie value", cookie.name,cookie.value);
//    }
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [[HekrRuntime shareInstance] checkNetWork];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
