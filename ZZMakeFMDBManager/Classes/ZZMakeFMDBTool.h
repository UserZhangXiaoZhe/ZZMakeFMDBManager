//
//  ZZMakeFMDBTool.h

//  Created by  on 2019/12/10.
//  Copyright © 2019 . All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const ZZKEY_USERID;
FOUNDATION_EXTERN NSString *const ZZKEY_TYPEVALUE1;
FOUNDATION_EXTERN NSString *const ZZKEY_TYPEVALUE2;
FOUNDATION_EXTERN NSString *const ZZKEY_KEYNAME;
FOUNDATION_EXTERN NSString *const ZZKEY_DICTNAME;
FOUNDATION_EXTERN NSString *const ZZKEY_CURRENTTIME;

@interface ZZMakeFMDBTool : NSObject

+(void)initialize;

/** 判断是否存在表 */
+ (BOOL)zzfmdb_checkTableName:(NSString *)tableName;

/** 数据是否存在 */
+ (BOOL)zzfmdb_checkDataWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1 typeValue2:(NSString*)typeValue2 keyName:(NSString *)keyName;

/** 创建一个表 */
+(void)zzfmdb_createTableWithName:(NSString *)tableName;

/** 插入字典数据 */
+(void)zzfmdb_insertDataWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString*)typeValue1 typeValue2:(NSString*)typeValue2 keyValue:(NSString *)keyValue dict:(NSDictionary *)dictValue;

/** 取出所有数据 返回字典数组 */
+(NSMutableArray *)zzfmdb_queryArrayWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1;

/** 取出某一类数据 返回字典数组 */
+(NSMutableArray *)zzfmdb_queryArrayWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1 typeValue2:(NSString *)typeValue2;

/** 取出某一个数据 返回字典数组 */
+(NSMutableArray *)zzfmdb_queryArrayWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1 typeValue2:(NSString *)typeValue2 keyName:(NSString *)keyName;

/** 清除所有数据  */
+(void)zzfmdb_deleteAllDataWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1;

/** 清除某一类数据 */
+(void)zzfmdb_deleteSomeDataWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1 typeValue2:(NSString *)typeValue2;


/** 清除某一条数据 */
+(void)zzfmdb_deleteOneDataWithTableName:(NSString *)tableName userID:(NSString *)userID typeValue1:(NSString *)typeValue1 typeValue2:(NSString *)typeValue2 typeValue2:(NSString *)keyName;

@end

NS_ASSUME_NONNULL_END
