//
//  Tools.h
//  HekrSDK
//
//  Created by WangMike on 15/8/5.
//  Copyright (c) 2015年 Hekr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SexpToken : NSObject
@property (nonatomic,strong) NSString * type;
@property (nonatomic,strong) id value;
@end

@interface Tools : NSObject
+(NSArray*) parseString:(NSString*) string;
+(NSDictionary*) sexpTokensToDictionary:(NSArray*) tokens;
@end
