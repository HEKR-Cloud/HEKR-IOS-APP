//
//  InstanceObject.h
//  HEKR
//
//  Created by Michael Scofield on 2015-06-16.
//  Copyright (c) 2015 mac. All rights reserved.
//
typedef void(^NetWorkBlock)();
#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface HekrRuntime : NSObject
@property(strong)NSString *csrf;
@property(strong)Reachability *hostReach;
@property(copy)NetWorkBlock block;
+ (instancetype)shareInstance;
-(BOOL)HekrNetIsAlready;
-(void)checkNetWork;
-(void)networkHadChanged:(void(^)(BOOL isok))block;
-(void)reachabilityChanged:(NSNotification *)note;
@end
