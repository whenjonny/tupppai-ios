//
//  SSDKAuthorizeCredential.h
//  ShareSDK
//
//  Created by 冯 鸿杰 on 15/2/6.
//  Copyright (c) 2015年 掌淘科技. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  授权类型
 */
typedef NS_ENUM(NSUInteger, SSDKCredentialType){
    /**
     *  未知
     */
    SSDKCredentialTypeUnknown = 0,
    /**
     *  OAuth 1.x
     */
    SSDKCredentialTypeOAuth1x = 1,
    /**
     *  OAuth 2
     */
    SSDKCredentialTypeOAuth2  = 2,
};

/**
 *  授权凭证
 */
@interface SSDKCredential : NSObject

/**
 *  用户标识
 */
@property (nonatomic, copy) NSString *uid;

/**
 *  用户令牌
 */
@property (nonatomic, copy) NSString *token;

/**
 *  用户令牌密钥
 */
@property (nonatomic, copy) NSString *secret;

/**
 *  过期时间
 */
@property (nonatomic,copy) NSDate *expired;

/**
 *  授权类型
 */
@property (nonatomic) SSDKCredentialType type;

/**
 *  原始数据
 */
@property (nonatomic, retain) NSDictionary *rawData;

/**
 *  标识授权是否可用，YES 可用， NO 已过期
 */
@property (nonatomic, readonly) BOOL available;

@end
