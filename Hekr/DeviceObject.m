//
//  DeviceObject.m
//  Hekr
//
//  Created by Michael Scofield on 2015-06-25.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import "DeviceObject.h"
#import "Tools.h"
#import <objc/runtime.h>

NSString * makeString(NSString* str){
    return str?str:@"";
}
@implementation DeviceObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ename=@" ";
        self.name=@" ";
        self.deviceLogo=@" ";
        self.updateTime=@" ";
        self.MID=@" ";
        self.CID=@" ";
        self.maxs = @" ";
        self.maxd = @" ";
        self.online =0;
        self.state =@" ";
        self.TID=@" ";
        self.UID=@" ";
        self.dVersion=@" ";
    }
    return self;
}


+(DeviceObject *)convert:(NSDictionary *)dic
{
    NSDictionary *maxd = dic[@"max(d"];
    NSDictionary *maxs = dic[@"max(s"];
    DeviceObject *object = [DeviceObject new];
    NSString *details = dic[@"detail"];
    NSDictionary * detail = [Tools sexpTokensToDictionary:[Tools parseString:details]];
    object.MID = makeString([[detail objectForKey:@"mid"] description]);
    object.TID = makeString([[detail objectForKey:@"mid"] description]);
    object.mname = makeString([detail objectForKey:@"mname"]);
    object.PID = [[detail objectForKey:@"pid"] integerValue];
    object.CID = makeString([[detail objectForKey:@"cid"] description]);
    object.softapkey = makeString([[detail objectForKey:@"softapkey"] description]);
    object.dVersion = makeString([[detail objectForKey:@"ver"] description]);
//    NSArray *array = [details componentsSeparatedByString:@" "];
//    object.MID=[array safeObjectAtIndex:1];
//    object.CID=[array safeObjectAtIndex:5];
    object.ename=makeString(dic[@"ename"]);
    object.name=makeString(dic[@"name"]);
    object.deviceLogo=dic[@"logo_url"];
    object.updateTime=dic[@"updated_at"];
    object.maxs = [maxs[@"time)"] description];
    object.maxd = [maxd[@"time)"] description];
    object.online = [dic[@"online"] integerValue];
    
    NSDictionary * state = [Tools sexpTokensToDictionary:[Tools parseString:[dic objectForKey:@"state"]]];
    
    NSString *stateString =  [[state objectForKey:@"power"] description];
    object.state =stateString;
    if (stateString.length >1) {
        object.state=@"0";
    }
    
    object.TID=dic[@"tid"];
    object.UID=dic[@"uid"];
    return object;
}
+ (NSDictionary*)getObjectData:(id)obj
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [self getObjectInternal:value];
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}
+ (id)getObjectInternal:(id)obj
{
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]])
    {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
}
+(DeviceObject *)dicConvert:(NSDictionary *)dic
{
 
    DeviceObject *ob = [DeviceObject new];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
      //  NSString *propertyKey = [self propertyForKey:key];
        
        if (key)
        {
            objc_property_t property = class_getProperty([self class], [key UTF8String]);
//            
//
//            NSString *attributeString = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
//       
            [ob setValue:obj forKey:key];
        }
    }];
    return ob;
}
-(SEL)getSetterWithAttributeName:(NSString *)attributeName
{
    NSString *firstAlpha = [[attributeName substringToIndex:1] uppercaseString];
    NSString *otherAlpha = [attributeName substringFromIndex:1];
    NSString *setterMethodName = [NSString stringWithFormat:@"set%@%@:", firstAlpha, otherAlpha];
    return NSSelectorFromString(setterMethodName);
}
@end
