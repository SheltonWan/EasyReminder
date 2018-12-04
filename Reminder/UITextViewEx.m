//
//  UITextViewEx.m
//  Reminder
//
//  Created by Shelton on 8/31/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UITextViewEx.h"

@implementation UITextViewEx


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [[UIImage imageNamed:@"textview_background"] drawInRect:rect];
}


@end
