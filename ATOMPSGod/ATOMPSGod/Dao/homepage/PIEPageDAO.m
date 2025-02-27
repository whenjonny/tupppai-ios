//
//  ATOMAskPageDAO.m
//  ATOMPSGod
//
//  Created by atom on 15/3/19.
//  Copyright (c) 2015年 ATOM. All rights reserved.
//

#import "PIEPageDAO.h"


@implementation PIEPageDAO

//- (instancetype)init {
//    self=[super init];
//    if (self) {
//    }
//    return self;
//}
//
//- (void)insertHomeImage:(PIEPageModel *)page {
//    dispatch_queue_t q = dispatch_queue_create("insert", NULL);
//    dispatch_async(q, ^{
//        [[[self class] sharedFMQueue] inDatabase:^(FMDatabase *db) {
//            NSString *stmt = [MTLFMDBAdapter insertStatementForModel:page];
//            NSArray *param = [MTLFMDBAdapter columnValues:page];
//            BOOL flag = [db executeUpdate:stmt withArgumentsInArray:param];
//            if (flag) {
//                //NSLog(@"save homeImage %ld succeed",(long)homeImage.imageID);
//            } else {
//                NSLog(@"save homeImage fail");
//            }
//        }];
//    });
//}
//
//- (void)updateHomeImage:(PIEPageModel *)page {
//    dispatch_queue_t q = dispatch_queue_create("update", NULL);
//    dispatch_async(q, ^{
//        [[[self class] sharedFMQueue] inDatabase:^(FMDatabase *db) {
//            NSString *stmt = [MTLFMDBAdapter updateStatementForModel:page];
//            NSMutableArray *param = [[MTLFMDBAdapter columnValues:page] mutableCopy];
//            [param addObject:@(page.ID)];
//            BOOL flag = [db executeUpdate:stmt withArgumentsInArray:param];
//            if (flag) {
//            } else {
//                NSLog(@"update homeImage fail");
//            }
//        }];
//    });
//}
//
//- (PIEPageModel *)selectHomeImageByImageID:(NSInteger)imageID {
//    __block PIEPageModel *homeImage;
//    [[[self class] sharedFMQueue] inDatabase:^(FMDatabase *db) {
//        NSString *stmt = @"select * from PIEPageModel where imageID = ?";
//        NSArray *param = @[@(imageID)];
//        FMResultSet *rs = [db executeQuery:stmt withArgumentsInArray:param];
//        while ([rs next]) {
//            homeImage = [MTLFMDBAdapter modelOfClass:[PIEPageModel class] fromFMResultSet:rs error:NULL];
//            break;
//        }
//        [rs close];
//    }];
//    return homeImage;
//}
//
////- (NSArray *)selectHomeImagesWithHomeType:(PIEHomeType)homeType {
////    __block NSMutableArray *muArray = [NSMutableArray array];
////    [[[self class] sharedFMQueue] inDatabase:^(FMDatabase *db) {
////        NSString* homeTypeStr = homeType == PIEHomeTypeHot?@"hot":@"new";
////        NSString *stmt = @"SELECT * FROM PIEPageModel where homePageType = ? ORDER BY uploadTime DESC LIMIT 10";
////        NSArray *param =  @[homeTypeStr];
////        FMResultSet *rs = [db executeQuery:stmt withArgumentsInArray:param];
////        while ([rs next]) {
////            PIEPageModel *homeImage = [MTLFMDBAdapter modelOfClass:[PIEPageModel class] fromFMResultSet:rs error:NULL];
////            [muArray addObject:homeImage];
////        }
////        [rs close];
////    }];
////    return [muArray copy];
////}
//- (NSArray *)selectHomeImages {
//    __block NSMutableArray *muArray = [NSMutableArray array];
//    [[[self class] sharedFMQueue] inDatabase:^(FMDatabase *db) {
//        NSString *stmt = @"SELECT * FROM PIEPageModel ORDER BY uploadTime DESC limit 15";
//        FMResultSet *rs = [db executeQuery:stmt];
//        while ([rs next]) {
//            PIEPageModel *homeImage = [MTLFMDBAdapter modelOfClass:[PIEPageModel class] fromFMResultSet:rs error:NULL];
//            [muArray addObject:homeImage];
//        }
//        [rs close];
//    }];
//    return [muArray copy];
//}
//
//- (BOOL)isExistHomeImage:(PIEPageModel *)homeImage {
//    __block BOOL flag;
//    [[[self class] sharedFMQueue] inDatabase:^(FMDatabase *db) {
//        NSString *stmt = @"select * from PIEPageModel where imageID = ?";
//        NSArray *param = @[@(homeImage.ID)];
//        FMResultSet *rs = [db executeQuery:stmt withArgumentsInArray:param];
//        while ([rs next]) {
//            PIEPageModel *homeImage = [MTLFMDBAdapter modelOfClass:[PIEPageModel class] fromFMResultSet:rs error:NULL];
//            if (homeImage) {
//                flag = YES;
//            } else {
//                flag = NO;
//            }
//            break;
//        }
//        [rs close];
//    }];
//    return flag;
//}
//- (void)clearHomeImages {
//    [[[self class] sharedFMQueue] inDatabase:^(FMDatabase *db) {
//        
//        NSString *stmt = @"delete from PIEPageModel";
//        BOOL flag = [db executeUpdate:stmt];
//        if (flag) {
////            NSLog(@"delete homeImage success");
//        } else {
//            NSLog(@"delete homeImage fail");
//        }
//    }];
//}
//- (void)clearHomeImagesWithHomeType:(NSString *)homeType {
//    [[[self class] sharedFMQueue] inDatabase:^(FMDatabase *db) {
//        NSString *stmt = @"delete from PIEPageModel where homePageType = ?";
//        NSArray *param = @[homeType];
//        BOOL flag = [db executeUpdate:stmt withArgumentsInArray:param];
//        if (flag) {
////            NSLog(@"delete homeImage ok");
//        } else {
//            NSLog(@"delete homeImage fail");
//        }
//    }];
//}



















@end
