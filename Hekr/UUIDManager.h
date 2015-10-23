//
//  UUIDManager.h
//  HEKR
//
//  Created by Michael Scofield on 2015-06-19.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import"SFHFKeychainUtils.h"
@interface UUIDManager : NSObject
+ (instancetype)shareInstance;
-(NSString *)getUUID;
@end
