//
//  Tools.m
//  HekrSDK
//
//  Created by WangMike on 15/8/5.
//  Copyright (c) 2015年 Hekr. All rights reserved.
//

#import "Tools.h"

@implementation SexpToken
-(instancetype) initWithType:(NSString *)type value:(id)value{
    self = [super init];
    if (self) {
        self.type = type;
        self.value = value;
    }
    return self;
}
-(NSString*) description{
    return [NSString stringWithFormat:@"type:%@ value:%@",_type,_value];
}
@end

@implementation Tools
+(NSArray*) parseString:(NSString *)string{
    NSScanner *scanner = [NSScanner scannerWithString:string];
    return [self parseSexpScaner:scanner];
}
+(NSArray*) parseSexpScaner:(NSScanner*) scanner{
    NSMutableArray *tokens = [NSMutableArray array];
    
    NSMutableCharacterSet* idenSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"@+-*/"];
    [idenSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    [idenSet formUnionWithCharacterSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    [idenSet formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
    
    if ([scanner scanString:@"(" intoString:NULL]) {
        while (![scanner isAtEnd]) {
            if ([scanner scanString:@"\"" intoString:NULL]) {
                NSString * str = nil;
                if ([scanner scanString:@"\"" intoString:NULL]) {
                    str = @"";
                    [tokens addObject:[[SexpToken alloc] initWithType:@"string" value:str]];
                    continue;
                }else if ([scanner scanUpToString:@"\"" intoString:&str]){
                    [tokens addObject:[[SexpToken alloc] initWithType:@"string" value:str]];
                    [scanner scanString:@"\"" intoString:NULL];
                    continue;
                }
            }
            if ([scanner scanString:@"(" intoString:NULL]) {
                scanner.scanLocation -= 1;
                NSArray * arr = [self parseSexpScaner:scanner];
                if (arr) {
                    [tokens addObject:[[SexpToken alloc] initWithType:@"sexp" value:arr]];
                    continue;
                }
            }
            if ([scanner scanString:@"true" intoString:NULL]) {
                [tokens addObject:[[SexpToken alloc] initWithType:@"bool" value:@(true)]];
                continue;
            }
            if ([scanner scanString:@"false" intoString:NULL]) {
                [tokens addObject:[[SexpToken alloc] initWithType:@"bool" value:@(false)]];
                continue;
            }
            if ([scanner scanString:@"#nil" intoString:NULL]) {
                [tokens addObject:[[SexpToken alloc] initWithType:@"nil" value:@""]];
                continue;
            }
            if ([scanner scanString:@"." intoString:NULL]) {
//                [tokens addObject:[[SexpToken alloc] initWithType:@"nil" value:@""]];
                continue;
            }
            double val = 0;
            if ([scanner scanDouble:&val]) {
                if (floor(val) == val) {
                    [tokens addObject:[[SexpToken alloc] initWithType:@"int" value:@(val)]];
                }else{
                    [tokens addObject:[[SexpToken alloc] initWithType:@"float" value:@(val)]];
                }
                continue;
            }
            NSString * str = nil;
            if([scanner scanCharactersFromSet:idenSet intoString:&str]){
                [tokens addObject:[[SexpToken alloc] initWithType:@"identifier" value:str]];
                continue;
            }
            if ([scanner scanString:@")" intoString:NULL]) {
                break;
            }
            NSAssert(NO, @"unknow charset");
            return nil;
        }
    }
    return tokens;
}
+(NSDictionary*) sexpTokensToDictionary:(NSArray *)tokens{
    NSInteger count = tokens.count / 2;
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i< count; i++) {
        SexpToken * key = [tokens objectAtIndex:i*2];
        SexpToken * val = [tokens objectAtIndex:i*2+1];
        if ([[key type] isEqualToString:@"string"]) {
            if ([[val type] isEqualToString:@"nil"]) {
                continue;
            }
            if ([[val type] isEqualToString:@"sexp"]) {
                val.value = [self sexpTokensToDictionary:val.value];
            }
            if (key.value && val.value) {
                [dict setValue:val.value forKey:key.value];
            }
        }
    }
    return dict.count > 0 ? dict : nil;
}
@end