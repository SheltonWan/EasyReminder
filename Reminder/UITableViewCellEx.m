//
//  UITableViewCellEx.m
//  Reminder
//
//  Created by Shelton on 8/16/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UITableViewCellEx.h"

@implementation UITableViewCellEx

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)didTransitionToState:(UITableViewCellStateMask)state
{
    [super didTransitionToState:state];
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask)
    {
        for (UIView *subview in self.subviews)
        {
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"])
            {
                subview.backgroundColor = [UIColor clearColor];
                

                id obj = [subview subviews].firstObject;
                if ([NSStringFromClass([obj class]) isEqualToString:@"_UITableViewCellActionButton"]) {
                    if ([obj isKindOfClass:[UIButton class]]) {
                        UIButton* button = (UIButton*)obj;
                        button.backgroundColor =[UIColor clearColor];
                        
                        UIImage* image = [UIImage imageNamed:@"button_delete"];
                        [button setImage:image forState:UIControlStateNormal];
                        button.frame = CGRectMake(0, (subview.bounds.size.height-image.size.height)/2, image.size.width, image.size.height);
                    }

                }

            }
        }
    }
}

@end
