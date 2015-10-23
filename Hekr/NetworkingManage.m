//
//  NetworkingManage.m
//  Hekr
//
//  Created by Michael Scofield on 2015-06-24.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import "NetworkingManage.h"
#import "DBHandler.h"
#import "UUIDManager.h"
#import "HekrRuntime.h"
#import "AFHTTPRequestOperationManager.h"
#import "HekrRuntime.h"
#import "StorageManage.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#define TOKEN_BASE @"http://user.hekr.me/token/generate.json"
@implementation NetworkingManage
#pragma mark -QQ登陆
+(AFHTTPRequestOperationManager*) manage:(BOOL) typeJson{
    AFHTTPRequestOperationManager * manage = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer * requestSerializer = typeJson ? [AFJSONRequestSerializer new] : [AFHTTPRequestSerializer new];
    manage.requestSerializer = requestSerializer;
    manage.responseSerializer = [AFJSONResponseSerializer new];
    manage.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/json", nil];
    NSArray * arr = [[StorageManage sharedInstance] getCookies];
    NSMutableArray * cookies = [NSMutableArray array];
    for (NSDictionary * dict in arr) {
        [cookies addObject:[NSHTTPCookie cookieWithProperties:dict]];
    }
    if (arr.count > 0) {
        NSDictionary* dict = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    return manage;
}
+(NSString*) parseCookies{
    NSMutableArray * array = [NSMutableArray array];
    NSString * csrf = nil;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        if([cookie.domain rangeOfString:@"hekr.me"].location != NSNotFound ||
           [cookie.domain rangeOfString:@"smartmatrix.mx"].location != NSNotFound){
            [array addObject:cookie.properties];
        }
        if ([cookie.name isEqualToString:@"_csrftoken_"]) {
            csrf = cookie.value;
        }
    }
    [[StorageManage sharedInstance] setCookies:array];
    return csrf;
}

+(void)loginByQQ:(NSString *)url Block:(void(^)(BOOL finish))block
{
    if ([url hasPrefix:@"http://login.hekr.me/success.htm?"] || [url hasPrefix:@"http://login.smartmatrix.mx/success.htm?"]) {
       
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:3];
        __block NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSString * csrf = [self parseCookies];
            if(csrf){
                [NetworkingManage getUserToken:csrf];
                [NetworkingManage getDeviceToken:csrf];
                block(YES);
            }
        }];
    }
}
#pragma mark - 本地登陆
+(void)loginByLocal:(void(^)(BOOL finish))block
{
   
    [NetworkingManage clearAllCookie];
    NSDictionary *parmeters = @{@"ver":@"1.0",@"mobileuuid":[UUIDManager shareInstance].getUUID};
    AFHTTPRequestOperationManager *manager = [self manage:NO];
    [manager GET:@"http://user.hekr.me/user/guestAccount.json" parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"code"] integerValue] == 200) {
                NSString *uString = responseObject[@"u"];
                NSString *csrfString =responseObject[@"_csrftoken_"];
                [self parseCookies];
                if (csrfString) {
                    [NetworkingManage getUserToken:csrfString];
                    [NetworkingManage getDeviceToken:csrfString];
                    block(YES);
                }
            }
            
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(NO);
        NSLog(@"Error: %@", error);
    }];
   
}
#pragma mark - 获取用户token
+(void)getUserToken:(NSString *)csrf
{
    [[StorageManage sharedInstance] setCSRF:csrf];
    AFHTTPRequestOperationManager *manager = [self manage:NO];
    [manager GET:TOKEN_BASE parameters:@{@"_csrftoken_":csrf,@"type":@"USER"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject objectForKey:@"token"]) {
                [self parseCookies];
                [[StorageManage sharedInstance] setUserToken:[responseObject objectForKey:@"token"]];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"Error: %@", error);
    }];

}

#pragma mark - 获取设备token
+(void)getDeviceToken:(NSString *)csrf
{
    AFHTTPRequestOperationManager *manager = [self manage:NO];
    [manager GET:TOKEN_BASE parameters:@{@"_csrftoken_":csrf,@"type":@"DEVICE"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject objectForKey:@"token"]) {
                [self parseCookies];
                [[StorageManage sharedInstance] setDeviceToken:[responseObject objectForKey:@"token"]];
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}
-(NSString *)encodeUrlString:(NSString *)urlString
{
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)urlString, NULL, (CFStringRef)@"!*’();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    return encodedString;
}
+(void)clearAllCookie
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *obj in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:obj];
    }
    [[StorageManage sharedInstance] setCookies:@[]];
}
#pragma mark - 获取设备列表
/**
 *  获取所有的设备列表
 *
 *  @param block 无
 */
+(void)getAllDevicesList:(void(^)(NSDictionary *dic,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [self manage:NO];
    [manager GET:@"http://poseido.hekr.me/appcategories.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [[StorageManage sharedInstance] saveAllDevices:responseObject];
            block(responseObject,nil);
        }else{
            NSLog(@"..%@..", [responseObject class]);
            block(nil,[NSError errorWithDomain:@"hekr" code:800 userInfo:nil]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil,error);
        /*
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示请检查网络" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        });
        */
        /*
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示请检查网络" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        */
        NSLog(@"Error: %@", error);
    }];

}

+(void)getUserDeviceList:(void(^)(NSArray *array,NSError *error))block
{
    NSString *csrf = [[StorageManage sharedInstance] getCSRF];
    if (csrf) {
        AFHTTPRequestOperationManager *manager = [self manage:NO];
        [manager GET:@"http://user.hekr.me/device/list.json" parameters:@{@"_csrftoken_":csrf} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                block(responseObject,nil);
            }else{
                block(nil,[NSError errorWithDomain:@"hekr" code:800 userInfo:nil]);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(nil,error);
            NSLog(@"Error: %@", error);
        }];
        
    }else
    {
         block(nil,[NSError errorWithDomain:@"hekr" code:800 userInfo:nil]);
    }
    
}
+(void)sendFeedback:(NSString *)content Block:(void(^)(BOOL finish))block
{
    NSString *userToken = [[StorageManage sharedInstance] getUserToken];
    if (userToken) {
        AFHTTPRequestOperationManager *manager = [self manage:YES];
        [manager POST:@"http://poseido.hekr.me/tucao.json" parameters:@{@"userAccessKey":userToken, @"content":content} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            block(YES); 
           
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(NO);
            NSLog(@"Error: %@", error);
        }];
    }else
    {
        
    }
    
}
+(void)getListFromSoftAP:(void(^)(NSArray *array,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [self manage:NO];
    [manager GET:@"http://192.168.10.1/t/get_aplist" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil,error);
        NSLog(@"Error: %@", error);
    }];
}
+(void)setAK:(void(^)(bool isok,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [self manage:NO];
    if ([[StorageManage sharedInstance] getDeviceToken]) {
        [manager GET:@"http://192.168.10.1/t/set_ak" parameters:@{@"ak":[[StorageManage sharedInstance] getDeviceToken]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            bool code=1;
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                code = [[responseObject objectForKey:@"code"] integerValue];
            }
            block(code,nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(NO,error);
            NSLog(@"Error: %@", error);
        }];
    }else{
        block(NO,nil);
    }
    
}
+(void)checkSSIDInfo:(NSDictionary *)dic Password:(NSString *)password Block:(void(^)(bool isok,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [self manage:NO];
    NSString *ssid = [dic objectForKey:@"ssid"];
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)ssid, NULL, (CFStringRef)@"!*’();:@&=+$,/?%#[]", kCFStringEncodingUTF8));

    NSString *bssid = [dic objectForKey:@"bssid"];
    NSInteger encryption = [NetworkingManage convertSSID:[dic objectForKey:@"auth_suites"]];
    NSString *channel = [dic objectForKey:@"channel"];
    NSDictionary *parameters = @{@"ssid":encodedString,@"bssid":bssid,@"key":password,@"channel":channel,@"encryption":@(encryption)};
    [manager GET:@"http://192.168.10.1/t/set_bridge" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        bool code=1;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            code = [[responseObject objectForKey:@"code"] integerValue];
        }
        block(code,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil,error);
        NSLog(@"Error: %@", error);
    }];
}
+(void)closeDevice
{
    AFHTTPRequestOperationManager *manager = [self manage:NO];
    [manager GET:@"http://192.168.10.1/t/set_ap?hidden=3" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"Error: %@", error);
    }];
}
+(NSInteger)convertSSID:(NSString *)ssidName
{
    if (ssidName) {
        NSArray *array = [ssidName.lowercaseString componentsSeparatedByString:@"_"];
        if ([array containsObject:@"open"]) {
            return 0;
        }else if ([array containsObject:@"wep"])
        {
            return 1;
        }
        else if ([array containsObject:@"psk2"] ||[array containsObject:@"psk"] )
        {
            return 2;
        }
        else if ([array containsObject:@"eap"])
        {
            return 1;
        }
    }
    return 999;
}
+ (NSString *)currentWifiSSID {
    // Does not work on the simulator.
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}
+(void)deleteDeviceFromCloud:(NSString *)tid Block:(void(^)(bool isok,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [self manage:NO];
    NSString *csrf =[[StorageManage sharedInstance] getCSRF];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    __block BOOL ret1, ret2;
    [manager GET:@"http://user.hekr.me/device/clearAccesskey.json" parameters:@{@"_csrftoken_":csrf,@"tid":tid} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code=1;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            code = [[responseObject objectForKey:@"code"] integerValue];
        }
        //删除成功
        ret1 = code == 200;
        dispatch_group_leave(group);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ret1 = NO;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [manager GET:@"http://user.hekr.me/device/delete.json" parameters:@{@"_csrftoken_":csrf,@"tid":tid} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code=1;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            code = [[responseObject objectForKey:@"code"] integerValue];
        }
        //删除成功
        ret2 = code == 200;
        dispatch_group_leave(group);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ret2 = NO;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        block(ret1 || ret2 ,nil);
    });
}
+(void)changeDeviceName:(NSString *)tid Name:(NSString *)name Block:(void(^)(bool isok,NSError *error))block
{
    AFHTTPRequestOperationManager *manager = [self manage:NO];
    NSString *csrf =[[StorageManage sharedInstance] getCSRF];
    NSString *url =[NSString stringWithFormat:@"http://user.hekr.me/device/rename/%@.json",tid];
    [manager GET:url parameters:@{@"_csrftoken_":csrf,@"name":name} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code=1;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            code = [[responseObject objectForKey:@"code"] integerValue];
        }
        if (code == 200) {
            block(YES,nil);
        }else{
            block(NO,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(NO,error);
        NSLog(@"Error: %@", error);
    }];

}
@end
