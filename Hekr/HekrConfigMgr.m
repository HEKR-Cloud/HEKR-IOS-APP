//
//  ScanDevice.m
//  Hekr
//
//  Created by Michael Scofield on 2015-06-30.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import "HekrConfigMgr.h"
#import "StorageManage.h"
#import "HekrConfig.h"

@implementation HekrConfigMgr
DEF_SINGLETON(HekrConfigMgr)
-(void)sendPasswordToSSID:(NSString *)passowrd ssidName:(NSString *)name Mtime:(NSInteger)mtime{
    [[HekrConfig sharedInstance] setDeviceToken:[[StorageManage sharedInstance] getDeviceToken]];
    [[HekrConfig sharedInstance] hekrConfig:name password:passowrd callback:^(BOOL ret) {
        [[NSNotificationCenter defaultCenter] postNotificationName:(ret ? @"ADD_SUCCESS" : @"ADD_NOT_FIND") object:nil];
    }];
}
- (void)stopSend{
    [[HekrConfig sharedInstance] cancelConfig];
}
@end