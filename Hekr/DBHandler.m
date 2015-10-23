//
//  DBHandler.m
//  HEKR
//
//  Created by Mario on 15/6/12.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "DBHandler.h"

@implementation DBHandler

+ (DBHandler *)shareInstance
{
    static DBHandler *dbHander = nil;
    if (dbHander == nil) {
        dbHander = [[DBHandler alloc] init];
        [dbHander openDB];
        [dbHander creatTable];
    }
    return dbHander;
}

- (void)creatTable
{
    sqlite3_exec(dbPoint, "create table UserModel(name text,value text)", NULL, NULL, NULL);
    sqlite3_exec(dbPoint, "create table UT(UserToken text)", NULL, NULL, NULL);
    sqlite3_exec(dbPoint, "create table DT(DeviceToken text)", NULL, NULL, NULL);
    sqlite3_exec(dbPoint, "create table Data(respones blob)", NULL, NULL, NULL);
    sqlite3_exec(dbPoint, "create table DeviceList(detail text,online text,state text,tid text,uid text)", NULL, NULL, NULL);
}

- (void)openDB
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath  = [path stringByAppendingPathComponent:@"UserModel.db"];
    int result =  sqlite3_open([dbPath UTF8String],&dbPoint);
    [self judgeResult:result name:@"打开数据库"];
    NSLog(@"数据库的地址 == %@", dbPath);
}

- (void)closeDB
{
    int result = sqlite3_close(dbPoint);
    [self judgeResult:result name:@"关闭数据库"];
}

- (int)insertData:(UserModel *)user
{
    NSString *string = [NSString stringWithFormat:@"insert into UserModel values('%@','%@')", user.name, user.value];
    NSLog(@"%@", string);
    int result = sqlite3_exec(dbPoint, [string UTF8String], NULL, NULL, NULL);
    [self judgeResult:result name:@"插入name and Value表"];
    return result;
}


- (int)insertUT:(UT *)ut
{
    NSString *string = [NSString stringWithFormat:@"insert into UT values('%@')", ut.UserToken];
    int reslut = sqlite3_exec(dbPoint, [string UTF8String], NULL, NULL, NULL);
    [self judgeResult:reslut name:@"插入UserToken表"];
    return reslut;
}


- (int)insertDT:(DT *)dt
{
    NSString *string = [NSString stringWithFormat:@"insert into DT values('%@')", dt.DeviceToken];
    int result = sqlite3_exec(dbPoint, [string UTF8String], NULL, NULL, NULL);
    [self judgeResult:result name:@"插入DeviceToken表"];
    return result;
}

- (int)insertNSData:(Data *)parse
{
    NSString *string = [NSString stringWithFormat:@"insert into parseData values('%@')", parse.parseData];
    
    NSData *data = [NSData dataWithContentsOfFile:string];
    
    int result = sqlite3_exec(dbPoint, [data bytes], NULL, NULL, NULL);
    
    [self judgeResult:result name:@"插入data数据"];
    
//    NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"insert into respones Values('%@')", datasss.respones]];
    
    return result;
}


- (int)insertDeviceList:(DeviceList *)list
{
    NSString *string = [NSString stringWithFormat:@"insert into DeviceList values('%@','%ld','%@','%@','%@')", list.detail, (long)list.online, list.state, list.tid, list.uid];
    int result = sqlite3_exec(dbPoint, [string UTF8String], NULL, NULL, NULL);
    [self judgeResult:result name:@"插入设备的名称"];
    return result;
}


// 查询
- (NSMutableArray *)selectUserModel
{
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare(dbPoint, "select * from UserModel", -1, &stmt, NULL);
    NSMutableArray *arr = [NSMutableArray array];
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const unsigned char *nameChar = sqlite3_column_text(stmt, 0);
            const unsigned char *valueChar = sqlite3_column_text(stmt, 1);
            
            NSString *name = [NSString stringWithUTF8String:(const char *)nameChar];
            NSString *value = [NSString stringWithUTF8String:(const char *)valueChar];
            
            UserModel *model = [[UserModel alloc] init];
            model.name = name;
            model.value = value;

            [arr addObject:model.name];
            [arr addObject:model.value];

        }
        sqlite3_finalize(stmt);
    }
    return arr;
}

- (NSMutableArray *)selectDeviceList
{
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(dbPoint, "select * from DeviceList", -1, &stmt, NULL);
    NSMutableArray *arr = [NSMutableArray array];
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const unsigned char *detailChar = sqlite3_column_text(stmt, 0);
            const unsigned char *stateChar = sqlite3_column_text(stmt, 2);
            const unsigned char *tidChar = sqlite3_column_text(stmt, 3);
            const unsigned char *uidChar = sqlite3_column_text(stmt, 4);
            
            NSString *detail = [NSString stringWithUTF8String:(const char *)detailChar];
            NSString *state = [NSString stringWithUTF8String:(const char *)stateChar];
            NSString *tid = [NSString stringWithUTF8String:(const char *)tidChar];
            NSString *uid = [NSString stringWithUTF8String:(const char *)uidChar];
            
            DeviceList *list = [[DeviceList alloc] init];
            list.detail = detail;
            list.state = state;
            list.tid = tid;
            list.uid = uid;
            
            [arr addObject:list.detail];
            [arr addObject:list.state];
            [arr addObject:list.tid];
            [arr addObject:list.uid];
        }
        sqlite3_finalize(stmt);
    }
    return arr;
}



- (NSMutableArray *)selectDT
{
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(dbPoint, "select * from DT", -1, &stmt, NULL);
    NSMutableArray *arr = [NSMutableArray array];
    if (result ==SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const unsigned char *DeviceTokenChar = sqlite3_column_text(stmt, 0);
            NSString *DeviceToken = [NSString stringWithUTF8String:(const char *)DeviceTokenChar];
            DT *dt = [[DT alloc] init];
            dt.DeviceToken = DeviceToken;
            [arr addObject:dt.DeviceToken];
        }
        sqlite3_finalize(stmt);
    }
    return arr;
}


- (NSMutableArray *)selectData
{
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(dbPoint, "select * from Data", -1, &stmt, NULL);
    NSMutableArray *arr = [NSMutableArray array];
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSData *data = (__bridge NSData *)(sqlite3_column_value(stmt, 0));
            Data *parseData = [[Data alloc] init];
            parseData.parseData = data;
            [arr addObject:parseData.parseData];
        }
        sqlite3_finalize(stmt);
    }
    return arr;
}


- (NSMutableArray *)selectUT
{
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(dbPoint, "select * from UT", -1, &stmt, NULL);
    NSMutableArray *arr = [NSMutableArray array];
    if (result ==SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const unsigned char *DeviceTokenChar = sqlite3_column_text(stmt, 0);
            NSString *DeviceToken = [NSString stringWithUTF8String:(const char *)DeviceTokenChar];
            DT *dt = [[DT alloc] init];
            dt.DeviceToken = DeviceToken;
            [arr addObject:dt.DeviceToken];
        }
        sqlite3_finalize(stmt);
    }
    return arr;
}


- (NSString *)selectUTT
{
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(dbPoint, "select * from DT", -1, &stmt, NULL);
    NSString *strrr;
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const unsigned char *DeviceTokenChar = sqlite3_column_text(stmt, 0);
            NSString *DeviceToken = [NSString stringWithUTF8String:(const char *)DeviceTokenChar];
            DT *dt = [[DT alloc] init];
            dt.DeviceToken = DeviceToken;
            strrr = dt.DeviceToken;
        }
        sqlite3_finalize(stmt);
    }
    return strrr;
}



- (int)deleteDataReading:(UserModel *)user
{
    NSString *string = [NSString stringWithFormat:@"delete from UserModel where contentid = '%@'", user.name];
    int result = sqlite3_exec(dbPoint, [string UTF8String], NULL, NULL, NULL);
    [self judgeResult:result name:@"删除"];
    return result;
}


//结果的判断方法
- (void)judgeResult:(int)result name:(NSString *)name
{  if (result ==  SQLITE_OK){
    
    NSLog(@"成功");
    }else {
        NSLog(@"%@失败,错误代码:%d",name,result);
    
    }

}



- (int)deleteAllData
{
    NSString *UserModelString = [NSString stringWithFormat:@"delete from UserModel"];
    NSString *DTString = [NSString stringWithFormat:@"delete from DT"];
    NSString *UTString = [NSString stringWithFormat:@"delete from UT"];
    NSString *DeliveListsss = [NSString stringWithFormat:@"delete from DeviceList"];
    int UserTokenResult = sqlite3_exec(dbPoint, [UserModelString UTF8String], NULL, NULL, NULL);
    int DTResult = sqlite3_exec(dbPoint, [DTString UTF8String], NULL, NULL, NULL);
    int UTResult = sqlite3_exec(dbPoint, [UTString UTF8String], NULL, NULL, NULL);
    int DeviceList = sqlite3_exec(dbPoint, [DeliveListsss UTF8String], NULL, NULL, NULL);

    return UserTokenResult;
    return DTResult;
    return UTResult;
    return DeviceList;
}






@end
