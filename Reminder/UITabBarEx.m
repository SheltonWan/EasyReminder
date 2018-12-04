//
//  UITabBarEx.m
//  Reminder
//
//  Created by Shelton on 8/4/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UITabBarEx.h"

@implementation UITabBarEx


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
// 5,5s:320x49
// 6,6s,7,8:375x49
// 6p,6sp,7p,8p:414x49
// X: 375x83
- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSLog(@"tab bar size: %f x %f",rect.size.width,rect.size.height);
    if (rect.size.height > 49) {
        UIImage* img = [UIImage imageNamed:@"toolbar_bg"];
        rect.size.height = img.size.height;
        [img drawInRect:rect];
    }
    else{
        [[UIImage imageNamed:@"toolbar_bg"] drawInRect:rect];
    }
    
    
}


@end
