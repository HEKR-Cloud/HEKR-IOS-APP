//
//  StorageManage.h
//  Hekr
//
//  Created by Michael Scofield on 2015-06-24.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define D_TOKEN @"device_token"
#define U_TOKEN @"user_token"
#define CSRF    @"csrf"
#define U_COOKIES @"cookies"
@interface StorageManage : NSObject
AS_SINGLETON(StorageManage)
-(void)setDeviceToken:(NSString *)string;
-(NSString *)getDeviceToken;
-(void)setUserToken:(NSString *)string;
-(NSString *)getUserToken;
-(void)setCSRF:(NSString *)string;
-(NSString *)getCSRF;
-(void)setCookies:(NSArray*) cookies;
-(NSArray*) getCookies;
-(void)saveAllDevices:(NSDictionary *)dic;
-(NSDictionary *)getAllDevices;
-(void)saveUserDevices:(NSArray *)array;
-(NSArray *)getUserDevices;
-(void)clearUserData;
@end
