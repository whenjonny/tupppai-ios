//
//  QBAlbumCell.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/06.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBAlbumCell.h"

@implementation QBAlbumCell

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    
    self.imageView1.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.imageView1.layer.borderWidth = borderWidth;
    self.imageView1.layer.cornerRadius = 5.0;
//    
//    self.imageView2.layer.borderColor = [[UIColor whiteColor] CGColor];
//    self.imageView2.layer.borderWidth = borderWidth;
//    
//    self.imageView3.layer.borderColor = [[UIColor whiteColor] CGColor];
//    self.imageView3.layer.borderWidth = borderWidth;
}

@end
