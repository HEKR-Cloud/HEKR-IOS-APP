//
//  DeviceObject.h
//  Hekr
//
//  Created by Michael Scofield on 2015-06-25.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceObject : NSObject
@property(copy)NSString *cname;
@property(copy)NSString *ename;
@property(copy)NSString *name;
@property(copy)NSString *mname;
@property(copy)NSString *CID;
@property(assign)NSUInteger PID;
@property(copy)NSString *MID;
@property(copy)NSString *TID;
@property(copy)NSString *UID;
@property(copy)NSString *maxd;
@property(copy)NSString *maxs;
@property(assign)BOOL online;
@property(copy)NSString *state;
@property(copy)NSString *deviceLogo;
@property(copy)NSString *updateTime;
@property(copy)NSString *softapkey;
@property(copy)NSString *dVersion;
+(DeviceObject *)convert:(NSDictionary *)dic;
+ (NSDictionary*)getObjectData:(id)obj;
+(DeviceObject *)dicConvert:(NSDictionary *)dic;
@end
