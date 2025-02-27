//
//  ATOMSubmitUserInfomation.m
//  ATOMPSGod
//
//  Created by atom on 15/3/16.
//  Copyright (c) 2015年 ATOM. All rights reserved.
//

#import "DDPageManager.h"
#import "PIEUserModel.h"
#import "PIEModelImage.h"
//



@implementation DDPageManager

+ (void)getPhotos:(NSDictionary *)param withBlock:(void (^)(NSMutableArray *returnArray))block {
    [DDService getPhotos:param withBlock:^(NSArray *data) {
            NSMutableArray *returnArray = [NSMutableArray array];
            for (int i = 0; i < data.count; i++) {
                PIEPageModel *homeImage = [MTLJSONAdapter modelOfClass:[PIEPageModel class] fromJSONDictionary:[data objectAtIndex:i] error:NULL];
                [returnArray addObject:homeImage];
            }
            if (block) { block(returnArray); }
    }];
}

+ (void)getAsk:(NSDictionary *)param withBlock:(void (^)(NSMutableArray *returnArray))block {
    [DDService getAsk:param withBlock:^(NSArray *data) {
        NSMutableArray *returnArray = [NSMutableArray array];
        for (int i = 0; i < data.count; i++) {
            PIEPageModel *homeImage = [MTLJSONAdapter modelOfClass:[PIEPageModel class] fromJSONDictionary:[data objectAtIndex:i] error:NULL];
            [returnArray addObject:homeImage];
        }
        if (block) { block(returnArray); }
    }];
}

+ (void)getReply:(NSDictionary *)param withBlock:(void (^)(NSMutableArray *returnArray))block {
    [DDService getReply:param withBlock:^(NSArray *data) {
        NSMutableArray *returnArray = [NSMutableArray array];
        for (int i = 0; i < data.count; i++) {
            PIEPageModel *homeImage = [MTLJSONAdapter modelOfClass:[PIEPageModel class] fromJSONDictionary:[data objectAtIndex:i] error:NULL];
            [returnArray addObject:homeImage];
        }
        if (block) { block(returnArray); }
    }];
}

+ (void)getCollection:(NSDictionary *)param withBlock:(void (^)(NSMutableArray *))block {
    [DDService ddGetCollection:param withBlock:^(NSArray* data) {
        NSMutableArray *resultArray = [NSMutableArray array];
        for (int i = 0; i < data.count; i++) {
            PIEPageModel *homeImage = [MTLJSONAdapter modelOfClass:[PIEPageModel class] fromJSONDictionary:data[i] error:NULL];
            [resultArray addObject:homeImage];
        }
        if (block) {
            block(resultArray);
        }
    }];
}


+ (void)getCommentedPages:(NSDictionary *)param withBlock:(void (^)(NSMutableArray *))block {
    [DDService getCommentedPages:param withBlock:^(NSArray* data) {
        NSMutableArray *resultArray = [NSMutableArray array];
        for (int i = 0; i < data.count; i++) {
            NSDictionary* dic = [data objectAtIndex:i];
            PIEPageModel *entity = [MTLJSONAdapter modelOfClass:[PIEPageModel class] fromJSONDictionary:dic error:NULL];
            entity.uploadTime = [[dic objectForKey:@"comment_time"]integerValue];
            PIEPageVM* vm = [[PIEPageVM alloc]initWithPageEntity:entity];
            vm.content = [dic objectForKey:@"content"];
            [resultArray addObject:vm];
        }
        if (block) {
            block(resultArray);
        }
    }];
}

+ (void)getLikedPages:(NSDictionary *)param withBlock:(void (^)(NSMutableArray *))block {
    [DDService getLikedPages:param withBlock:^(NSArray* data) {
        NSMutableArray *resultArray = [NSMutableArray array];
        for (int i = 0; i < data.count; i++) {
            PIEPageModel *entity = [MTLJSONAdapter modelOfClass:[PIEPageModel class] fromJSONDictionary:data[i] error:NULL];
            PIEPageVM* vm = [[PIEPageVM alloc]initWithPageEntity:entity];
            [resultArray addObject:vm];
        }
        if (block) {
            block(resultArray);
        }
    }];
}

+ (void)getAskWithReplies:(NSDictionary *)param withBlock:(void (^)(NSArray *returnArray))block {
    [DDService ddGetAskWithReplies:param withBlock:^(NSArray *returnArray) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < returnArray.count; i++) {
            NSMutableArray * source = [NSMutableArray new];
            NSArray* askImageDic = [[returnArray objectAtIndex:i]objectForKey:@"ask_uploads"];
            NSMutableArray* askImageEntities = [NSMutableArray array];
            for (NSDictionary* dic in askImageDic) {
                PIEModelImage* ie = [MTLJSONAdapter modelOfClass:[PIEModelImage class] fromJSONDictionary:dic error:NULL];
                [askImageEntities addObject:ie];
            }
            for (PIEModelImage* ie in askImageEntities) {
                PIEPageModel *askEntity = [MTLJSONAdapter modelOfClass:[PIEPageModel class] fromJSONDictionary:[returnArray objectAtIndex:i] error:NULL];
//                askEntity.imageWidth = ie.width;
//                askEntity.imageHeight = ie.height;
                askEntity.imageURL = ie.url;
                PIEPageVM* vm = [[PIEPageVM alloc]initWithPageEntity:askEntity];
                [source addObject:vm];
            }
            
            NSArray* repliesDic = [[returnArray objectAtIndex:i]objectForKey:@"replies"];
            for (NSDictionary* dic in repliesDic) {
                PIEPageModel *entity = [MTLJSONAdapter modelOfClass:[PIEPageModel class] fromJSONDictionary:dic error:NULL];
                PIEPageVM* vm = [[PIEPageVM alloc]initWithPageEntity:entity];
                [source addObject:vm];
            }
            [array addObject:source];
        }
        if (block) {
            if (array.count > 0) {
                block(array);
            } else {
                block (nil);
            }
        }
    }];
}




@end
