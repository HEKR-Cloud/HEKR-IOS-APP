//
//  DeviceNameForSSID.m
//  Hekr
//
//  Created by Mario on 15/7/10.
//  Copyright (c) 2015年 Michael Hu. All rights reserved.
//

#import "DeviceNameForSSID.h"

@implementation DeviceNameForSSID


+ (instancetype)shareInstace
{
    static DeviceNameForSSID *deviceName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceName = [DeviceNameForSSID new];
    });
    return deviceName;
}

@end
