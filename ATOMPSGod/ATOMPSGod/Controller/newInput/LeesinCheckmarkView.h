//
//  QBCheckmarkView.h
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface LeesinCheckmarkView : UIView
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable CGFloat checkmarkLineWidth;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, strong) IBInspectable UIColor *bodyColor;
@property (nonatomic, strong) IBInspectable UIColor *checkmarkColor;

@property (nonatomic, strong) IBInspectable UIColor *borderColorSelected;
@property (nonatomic, strong) IBInspectable UIColor *bodyColorSelected;
@property (nonatomic, strong) IBInspectable UIColor *checkmarkColorSelected;


@end
