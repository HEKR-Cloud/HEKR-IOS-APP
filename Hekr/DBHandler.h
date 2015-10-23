//
//  DBHandler.h
//  HEKR
//
//  Created by Mario on 15/6/12.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>
#import "UserModel.h"
#import "UT.h"
#import "DT.h"
#import "Data.h"
#import "DeviceList.h"

@interface DBHandler : NSObject
{
    sqlite3 *dbPoint;
}

+ (DBHandler *)shareInstance;

- (void)openDB;
- (void)closeDB;
- (void)creatTable;


// 插入数据
- (int)insertData:(UserModel *)user;
- (int)insertDT:(DT *)dt;
- (int)insertUT:(UT *)ut;
- (int)insertNSData:(Data *)parse;
- (int)insertDeviceList:(DeviceList *)list;

// 查询数据
- (NSMutableArray *)selectUserModel;
- (NSMutableArray *)selectUT;
- (NSMutableArray *)selectDT;
- (NSMutableArray *)selectData;
- (NSMutableArray *)selectDeviceList;

// 删除数据
- (int)deleteDataReading:(UserModel *)user;
- (int)deleteUT:(UT *)ut;
- (int)deleteDT:(DT *)dt;

- (int)deleteAllData;

- (NSString *)selectUTT;

@end
