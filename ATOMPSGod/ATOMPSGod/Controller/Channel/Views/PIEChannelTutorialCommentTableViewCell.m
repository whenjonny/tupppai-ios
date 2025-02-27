//
//  PIEChannelTutorialCommentTableViewCell.m
//  TUPAI
//
//  Created by TUPAI-Huangwei on 1/27/16.
//  Copyright © 2016 Shenzhen Pires Internet Technology CO.,LTD. All rights reserved.
//

#import "PIEChannelTutorialCommentTableViewCell.h"
#import "PIEAvatarView.h"
#import "PIECommentVM.h"

@interface PIEChannelTutorialCommentTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *cell_separator_bottom;

@end

@implementation PIEChannelTutorialCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.cell_separator_bottom mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)injectVM:(PIECommentVM *)commentVM
{
//    [self.avatarView.avatarImageView sd_setImageWithURL:
//     [NSURL URLWithString:commentVM.avatar]];
    self.avatarView.url = commentVM.avatar;
    
    self.userNameLabel.text    = commentVM.username;

    self.publishTimeLabel.text = commentVM.time;

    self.commentTextLabel.text = commentVM.text;
}

@end
