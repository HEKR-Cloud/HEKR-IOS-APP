//
//  DeviceList.h
//  HEKR
//
//  Created by Mario on 15/6/12.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceList : NSObject

@property (nonatomic, strong) NSString *detail;
@property (nonatomic, assign) NSInteger online;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *tid;
@property (nonatomic, strong) NSString *uid;

@end
