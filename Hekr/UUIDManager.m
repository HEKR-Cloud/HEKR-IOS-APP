//
//  UUIDManager.m
//  HEKR
//
//  Created by Michael Scofield on 2015-06-19.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import "UUIDManager.h"

@implementation UUIDManager
+ (instancetype)shareInstance
{
    static UUIDManager* g_instanceObject;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instanceObject = [UUIDManager new];
    });
    return g_instanceObject;
}

-(NSString *)makeUUIDString
{
    return [[NSUUID UUID] UUIDString];
}

-(void)setUUIDtoSave:(NSString *)uuidStr
{
    NSString *SERVICE_NAME=@"hekr";
    [SFHFKeychainUtils storeUsername:@"UUID"
                         andPassword:uuidStr
                      forServiceName:SERVICE_NAME
                      updateExisting:1
                               error:nil];
}
-(NSString *)getUUID
{
    NSString *SERVICE_NAME=@"hekr";
    NSString *uuid =  [SFHFKeychainUtils getPasswordForUsername:@"UUID"
                                                     andServiceName:SERVICE_NAME
                                                              error:nil];
    if (uuid == nil || uuid.length == 0) {
        NSString *newUUID = [self makeUUIDString];
        uuid = newUUID;
        [self setUUIDtoSave:newUUID];
    }
    return uuid;
}
@end
