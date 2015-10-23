//
//  NetworkingManage.h
//  Hekr
//
//  Created by Michael Scofield on 2015-06-24.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
@interface NetworkingManage : NSObject

+(void)loginByLocal:(void(^)(BOOL finish))block;
+(void)loginByQQ:(NSString *)url Block:(void(^)(BOOL finish))block;
+(void)getAllDevicesList:(void(^)(NSDictionary *dic,NSError *error))block;
+(void)getUserDeviceList:(void(^)(NSArray *array,NSError *error))block;
+(void)sendFeedback:(NSString *)content Block:(void(^)(BOOL finish))block;
+(void)getListFromSoftAP:(void(^)(NSArray *array,NSError *error))block;
+(void)setAK:(void(^)(bool isok,NSError *error))block;
+(void)checkSSIDInfo:(NSDictionary *)dic Password:(NSString *)password Block:(void(^)(bool isok,NSError *error))block;
+(void)closeDevice;
+(void)deleteDeviceFromCloud:(NSString *)tid Block:(void(^)(bool isok,NSError *error))block;
+ (NSString *)currentWifiSSID;
+(void)changeDeviceName:(NSString *)tid Name:(NSString *)name Block:(void(^)(bool isok,NSError *error))block;

@end
