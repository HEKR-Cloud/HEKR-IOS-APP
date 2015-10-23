//
//  StorageManage.m
//  Hekr
//
//  Created by Michael Scofield on 2015-06-24.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import "StorageManage.h"
#import "NSString+Additions.h"
#import "DBHelper.h"
#import "DeviceObject.h"
@interface StorageManage()
@property(strong)DBHelper *datasdb;
@end
@implementation StorageManage
DEF_SINGLETON(StorageManage)
- (instancetype)init
{
    self = [super init];
    if (self) {
        BOOL isExist = ![[NSFileManager defaultManager] fileExistsAtPath:[self dbPath]];
        if (isExist) {
            self.datasdb = [[DBHelper alloc] initWithPath:[self dataPath]];
        }
    }
    return self;
}
-(NSString *) dataPath
{
    return [[NSString documentPath] stringByAppendingPathComponent:@"hekr_data"];
}
-(NSString*) dbPath{
    return [[NSString documentPath] stringByAppendingPathComponent:@"hekr_db"];
}
-(void)setDeviceToken:(NSString *)string
{
        [self.datasdb setObject:string forKey:D_TOKEN];
}
-(NSString *)getDeviceToken
{
    return [self.datasdb objectForKey:D_TOKEN];
}
-(void)setUserToken:(NSString *)string
{
    [self.datasdb setObject:string forKey:U_TOKEN];
}
-(NSString *)getUserToken
{
    return [self.datasdb objectForKey:U_TOKEN];
}
-(void)setCSRF:(NSString *)string
{
    [self.datasdb setObject:string forKey:CSRF];
}
-(NSString *)getCSRF
{
    return [self.datasdb objectForKey:CSRF];
}
-(void) setCookies:(NSArray *)cookies{
    [self.datasdb setObject:cookies forKey:U_COOKIES];
}
-(NSArray*) getCookies{
    return [self.datasdb objectForKey:U_COOKIES];
}
-(void)saveAllDevices:(NSDictionary *)dic
{
    [self.datasdb setObject:dic forKey:@"AllDevices"];
}
-(NSDictionary *)getAllDevices
{
    return [self.datasdb objectForKey:@"AllDevices"];
}
-(void)saveUserDevices:(NSArray *)array
{
    NSMutableArray *convert = [NSMutableArray new];
    for (id tmp in array) {
        if ([tmp isKindOfClass:[DeviceObject class]]) {
            NSDictionary *dic = [DeviceObject getObjectData:tmp];
            [convert addObject:dic];
        }
    }
     [self.datasdb setObject:convert forKey:@"UserDevices"];
}
-(NSArray *)getUserDevices
{
    NSArray *array = [self.datasdb objectForKey:@"UserDevices"];
    NSMutableArray *convert = [NSMutableArray new];
    for (id tmp in array) {
        if ([tmp isKindOfClass:[NSDictionary class]]) {
            DeviceObject *obj = [DeviceObject dicConvert:tmp];
            [convert addObject:obj];
        }
    }
    return convert;

}
-(void)clearUserData
{
    [self.datasdb removeValueForKey:@"UserDevices"];
    [self.datasdb removeValueForKey:U_TOKEN];
    [self.datasdb removeValueForKey:D_TOKEN];
    [self.datasdb removeValueForKey:CSRF];
    [self.datasdb removeValueForKey:U_COOKIES];
}
@end
