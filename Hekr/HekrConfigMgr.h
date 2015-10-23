//
//  ScanDevice.h
//  Hekr
//
//  Created by Michael Scofield on 2015-06-30.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface HekrConfigMgr : NSObject
AS_SINGLETON(HekrConfigMgr)
-(void)sendPasswordToSSID:(NSString *)passowrd ssidName:(NSString *)name Mtime:(NSInteger)mtime;
- (void)stopSend;
@end
