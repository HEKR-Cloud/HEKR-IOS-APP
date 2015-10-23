//
//  DeviceNameForSSID.h
//  Hekr
//
//  Created by Mario on 15/7/10.
//  Copyright (c) 2015年 Michael Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceNameForSSID : NSObject

+ (instancetype)shareInstace;
@property (nonatomic, strong) NSString *ssidName;

@end
