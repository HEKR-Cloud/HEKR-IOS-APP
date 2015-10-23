//
//  Tools.h
//  HekrSDK
//
//  Created by WangMike on 15/8/5.
//  Copyright (c) 2015年 Hekr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Location : NSObject
-(void) getLocation:(void(^)(BOOL,CLLocationCoordinate2D)) block;
@end
