//
//  InstanceObject.m
//  HEKR
//
//  Created by Michael Scofield on 2015-06-16.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import "HekrRuntime.h"
#import <SystemConfiguration/CaptiveNetwork.h>
@implementation HekrRuntime
+ (instancetype)shareInstance
{
    static HekrRuntime* g_instanceObject;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instanceObject = [HekrRuntime new];
    });
    return g_instanceObject;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        self.hostReach = [Reachability reachabilityWithHostName:@"hekr.im"];
        [self.hostReach startNotifier];
    }
    return self;
}
-(void)checkNetWork
{
    if (self.block) {
        self.block();
    }
    
}
-(void)reachabilityChanged:(NSNotification *)note
{
    Reachability * reach = [note object];
    if (reach.isReachableViaWiFi) {

        
    }
    NetworkStatus netWorkStatus = [reach currentReachabilityStatus];
    switch (netWorkStatus)
    {
        case NotReachable:
           NSLog(@"not network");
            break;
        case ReachableViaWiFi:
           NSLog(@"wifi");
            break;
        case ReachableViaWWAN:
            NSLog(@"3g");
            break;
    }
    
    if (self.block) {
        self.block();
    }
}
@end
