//
//  UINavigationBarEx.m
//  Reminder
//
//  Created by Shelton on 8/23/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UINavigationBarEx.h"

@implementation UINavigationBarEx


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
//    NSLog(@"topItem:%@",self.topItem.title);
    if (self.topItem.title) {
        UIImage* navImg = [UIImage imageNamed:@"nav_bg"];
        [navImg drawInRect:rect];

    }
    else{
        [super drawRect:rect];
    }
//    NSLog(@"Navigation Bar size: %f x %f",rect.size.width,rect.size.height);
    
}


@end
