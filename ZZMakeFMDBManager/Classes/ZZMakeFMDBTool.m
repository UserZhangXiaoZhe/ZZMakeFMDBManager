//
//  ZZMakeFMDBTool.m

//  Created by  on 2019/12/10.
//  Copyright © 2019 . All rights reserved.
//

#import "ZZMakeFMDBTool.h"
#import "FMDB.h"

NSString *const ZZKEY_DBNAME = @"ZZDictList.sqlite";
NSString *const ZZKEY_TABLENAME = @"DictTable";
NSString *const ZZKEY_ID = @"ZZKEY_ID";

NSString *const ZZKEY_USERID = @"ZZKEY_UserID";
NSString *const ZZKEY_TYPEVALUE1 = @"ZZKEY_TypeValue1";
NSString *const ZZKEY_TYPEVALUE2 = @"ZZKEY_TypeValue2";
NSString *const ZZKEY_KEYNAME = @"ZZKEY_KeyName";
NSString *const ZZKEY_DICTNAME = @"ZZKEY_DictValue";
NSString *const ZZKEY_CURRENTTIME = @"ZZKEY_CurrentTime";

@interface ZZMakeFMDBTool ()

@end

@implementation ZZMakeFMDBTool

#pragma mark - init methods
static FMDatabase *_db;

+ (void)initialize{
    // 数据库文件的地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *sqlPath = [path stringByAppendingPathComponent:ZZKEY_DBNAME];

    _db = [FMDatabase databaseWithPath:sqlPath];
}
/** 创建一个表 */
+(void)zzfmdb_createTableWithName:(NSString *)tableName{
    if ([_db open]) {
        
        if ([self zzfmdb_checkTableName:tableName]) return;
        
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '%@' TEXT NOT NULL,'%@' TEXT NOT NULL,'%@' TEXT NOT NULL, '%@' TEXT NOT NULL, '%@' TEXT NOT NULL,'%@' BLOB NOT NULL)",tableName,ZZKEY_ID,ZZKEY_CURRENTTIME,ZZKEY_USERID,ZZKEY_TYPEVALUE1,ZZKEY_TYPEVALUE2,ZZKEY_KEYNAME,ZZKEY_DICTNAME];
        
        BOOL successCreate =  [_db executeUpdate:sqlCreateTable];
        
        if (successCreate) {
            NSLog(@"FMDB创建%@表成功",tableName);
            NSLog(@"%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
        }else{
            NSLog(@"FMDB创建%@表失败",tableName);
            [_db close];
            return;
        }
        
        [_db close];
    }
    
}
#pragma mark - Private methods
/** 判断是否存在表 */
+ (BOOL)zzfmdb_checkTableName:(NSString *)tableName{
    
    FMResultSet *rs = [_db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        NSInteger count = [rs intForColumn:@"count"];
        
        if (0 == count){
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

/** 数据是否存在 */
+ (BOOL)zzfmdb_checkDataWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1 typeValue2:(NSString*)typeValue2 keyName:(NSString *)keyName{
    
    NSString * sqlQuery =[NSString stringWithFormat:@"SELECT COUNT(*) as 'count' FROM %@ where %@='%@' and %@='%@' and %@='%@' and %@='%@'",tableName,ZZKEY_USERID,userID,ZZKEY_TYPEVALUE1,typeValue1,ZZKEY_TYPEVALUE2,typeValue2,ZZKEY_KEYNAME,keyName];
    FMResultSet *rs = [_db executeQuery:sqlQuery];
    while ([rs next])
    {
        NSInteger count = [rs intForColumn:@"count"];
        if (0 == count){
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

#pragma mark - FMDB数据库操作
/** 插入字典数据 */
+(void)zzfmdb_insertDataWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString*)typeValue1 typeValue2:(NSString*)typeValue2 keyValue:(NSString *)keyValue dict:(NSDictionary *)dictValue{
    
    NSLog(@"result == %@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
    
    if ([_db open]) {
        
        if (![self zzfmdb_checkTableName:tableName]) {
            //表不存在
            [self zzfmdb_createTableWithName:tableName];
            
            [self zzfmdb_insertDataWithTableName:tableName userID:userID typeValue1:typeValue1 typeValue2:typeValue2 keyValue:keyValue dict:dictValue];
            [_db close];
            return;
        }
        
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSS"];
        NSString *currentTime = [formatter stringFromDate:[NSDate date]];

        if ([self zzfmdb_checkDataWithTableName:tableName userID:userID typeValue1:typeValue1 typeValue2:typeValue2 keyName:keyValue]) {
            //数据存在,将字典转换为二进制后存储
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dictValue];
            tempDict[ZZKEY_USERID] = userID;
            tempDict[ZZKEY_TYPEVALUE1] = typeValue1;
            tempDict[ZZKEY_TYPEVALUE2] = typeValue2;
            tempDict[ZZKEY_KEYNAME] = keyValue;
            tempDict[ZZKEY_CURRENTTIME] = currentTime;
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:tempDict options:NSJSONWritingPrettyPrinted error:nil];
            
            //存在更新数据,不更新时间
            //NSString *sql=[NSString stringWithFormat:@"UPDATE %@ SET %@ = ? WHERE %@ = ? AND %@ = ? AND %@ = ? AND %@ = ?",tableName,ZZKEY_DICTNAME,ZZKEY_USERID,ZZKEY_USERNAME,ZZKEY_TYPENAME,ZZKEY_KEYNAME];
            //MyLog(@"sql==%@",sql);
            
            //更新时间 (SET语句用:" , "，WHERE语句:" And ")
            NSString *sql=[NSString stringWithFormat:@"UPDATE %@ SET %@ = ? , %@ = ? WHERE %@ = ? AND %@ = ? AND %@ = ? AND %@ = ?",tableName,ZZKEY_CURRENTTIME,ZZKEY_DICTNAME,ZZKEY_USERID,ZZKEY_TYPEVALUE1,ZZKEY_TYPEVALUE2,ZZKEY_KEYNAME];
            BOOL successSave = [_db executeUpdate:sql,currentTime,data,userID,typeValue1,typeValue2,keyValue];
            
            if (successSave) {
                NSLog(@"update success");
            } else {
                NSLog(@"update error");
            }
        }else{
            // 获取字典,将字典转换为二进制后存储
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dictValue];
            tempDict[ZZKEY_USERID] = userID;
            tempDict[ZZKEY_TYPEVALUE1] = typeValue1;
            tempDict[ZZKEY_TYPEVALUE2] = typeValue2;
            tempDict[ZZKEY_KEYNAME] = keyValue;
            tempDict[ZZKEY_CURRENTTIME] = currentTime;
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:tempDict options:NSJSONWritingPrettyPrinted error:nil];
            
            //更新 时间和数据
            NSString*sql=[NSString stringWithFormat:@"INSERT INTO '%@' ('%@','%@','%@', '%@', '%@', '%@') VALUES (?, ?, ?, ?, ?,?)",tableName,ZZKEY_CURRENTTIME,ZZKEY_USERID,ZZKEY_TYPEVALUE1,ZZKEY_TYPEVALUE2,ZZKEY_KEYNAME,ZZKEY_DICTNAME];
            BOOL successSave = [_db executeUpdate:sql,currentTime,userID,typeValue1,typeValue2,keyValue,data];
            
            if (successSave) {
                NSLog(@"save success");
            } else {
                NSLog(@"save error");
            }
        }
        [_db close];
    }
}

/** 取出所有数据 返回字典数组 */
+(NSMutableArray *)zzfmdb_queryArrayWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1{
    
    NSMutableArray *modelArr = [NSMutableArray array];
    
    if ([_db open]) {
        // 1.定义结果集保存查询到的结果
        FMResultSet *resultSet = nil;
        
        // 返回数据库数据，按时间倒序（最近在前）排列
        NSString * sqlQuery =[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' and %@ = '%@' order by %@ desc",tableName,ZZKEY_USERID,userID,ZZKEY_TYPEVALUE1,typeValue1,ZZKEY_CURRENTTIME];
        
        resultSet  = [_db executeQuery:sqlQuery];
        
//        // 遍历查询结果
//        while ([resultSet next]) {
//            NSString *str0 = [resultSet stringForColumnIndex:0];
//            NSString *str1 = [resultSet stringForColumnIndex:1];
//            NSString *str2 = [resultSet stringForColumnIndex:2];
//            NSString *str3 = [resultSet stringForColumnIndex:3];
//            //NSString *str4 = [resultSet stringForColumnIndex:4];
//            NSLog(@"%@\n%@\n%@\n%@\n",str0,str1,str2,str3);
//        }

        // 3.取出结果集中的数据,转换为模型后保存到数组中
        while ([resultSet next]) {
            NSData *data = [resultSet dataForColumn:ZZKEY_DICTNAME];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
            [modelArr addObject:dict];
        }
    }
    return modelArr;
}

/** 取出某一类数据 返回字典数组 */
+(NSMutableArray *)zzfmdb_queryArrayWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1 typeValue2:(NSString *)typeValue2{
    
    NSMutableArray *modelArr = [NSMutableArray array];
    if ([_db open]) {
        FMResultSet *resultSet = nil;
        
        // 按时间倒序（最近在前）排列
        NSString * sqlQuery =[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' and %@ = '%@' and %@ = '%@' order by %@ desc ",tableName,ZZKEY_USERID,userID,ZZKEY_TYPEVALUE1,typeValue1,ZZKEY_TYPEVALUE2,typeValue2,ZZKEY_CURRENTTIME];
        resultSet  = [_db executeQuery:sqlQuery];

        while ([resultSet next]) {
            NSData *data = [resultSet dataForColumn:ZZKEY_DICTNAME];
            NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
            [modelArr addObject:dict];
           
        }
    }
    return modelArr;
}

/** 取出某一个数据 返回字典数组 */
+(NSMutableArray *)zzfmdb_queryArrayWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1 typeValue2:(NSString *)typeValue2 keyName:(NSString *)keyName{
    
    NSMutableArray *modelArr = [NSMutableArray array];
    if ([_db open]) {
        FMResultSet *resultSet = nil;
        // 按时间倒序（最近在前）排列
        NSString * sqlQuery =[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' and %@ = '%@' and %@ = '%@' and %@ = '%@' order by %@ desc ",tableName,ZZKEY_USERID,userID,ZZKEY_TYPEVALUE1,typeValue1,ZZKEY_TYPEVALUE2,typeValue2,ZZKEY_KEYNAME,keyName,ZZKEY_CURRENTTIME];
        resultSet  = [_db executeQuery:sqlQuery];
        
        while ([resultSet next]) {
            NSData *data = [resultSet dataForColumn:ZZKEY_DICTNAME];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
            [modelArr addObject:dict];
        }
    }
    return modelArr;
}

/** 清除所有数据  */
+(void)zzfmdb_deleteAllDataWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1{
    
    if ([_db open]) {
        NSString *deleteSql = [NSString stringWithFormat:
                               @"DELETE FROM %@ WHERE %@ ='%@' and %@ ='%@'",
                               tableName,ZZKEY_USERID,userID,ZZKEY_TYPEVALUE1,typeValue1];
        BOOL res = [_db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"Error when Delete!");
        } else {
            NSLog(@"Success when Delete!");
        }
        
        [_db close];
    }
}
/** 清除某一类数据 */
+(void)zzfmdb_deleteSomeDataWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1 typeValue2:(NSString *)typeValue2{
    
    if ([_db open]) {
        NSString *deleteSql = [NSString stringWithFormat:
                               @"DELETE FROM %@ WHERE %@ ='%@' and %@ ='%@' and %@ ='%@' ",
                               tableName,ZZKEY_USERID,userID,ZZKEY_TYPEVALUE1,typeValue1,ZZKEY_TYPEVALUE2,typeValue2];
        BOOL res = [_db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"Error when Delete!");
        } else {
            NSLog(@"Success when Delete!");
        }
        
        [_db close];
    }
}

/** 清除某一条数据 */
+(void)zzfmdb_deleteOneDataWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1 typeValue2:(NSString *)typeValue2 typeValue2:(NSString *)keyName{
    
    if ([_db open]) {
        NSString *deleteSql = [NSString stringWithFormat:
                               @"DELETE FROM %@ WHERE %@ ='%@' and %@ ='%@' and %@ ='%@' and %@ ='%@' ",
                               tableName,ZZKEY_USERID,userID,ZZKEY_TYPEVALUE1,typeValue1,ZZKEY_TYPEVALUE2,typeValue2,ZZKEY_KEYNAME,keyName];
        BOOL res = [_db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"Error when Delete!");
        } else {
            NSLog(@"Success when Delete!");
        }
        
        [_db close];
    }
}
@end
