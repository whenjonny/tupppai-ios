//
//  ATOMAtComment.h
//  ATOMPSGod
//
//  Created by atom on 15/3/31.
//  Copyright (c) 2015年 ATOM. All rights reserved.
//

#import "PIEBaseModel.h"

@interface PIEEntityCommentReply : PIEBaseModel;

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *text;

@end
