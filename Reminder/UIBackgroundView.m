//
//  UIBackgroundView.m
//  Reminder
//
//  Created by Shelton on 10/7/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UIBackgroundView.h"
#import "AppConst.h"
@implementation UIBackgroundView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
// 5,5s:320x568
// 6,6s,7,8:375x667
// 6p,6sp,7p,8p:414x736
// X:375x812
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIImage* navImg = [UIImage imageNamed:@"nav_bg"];
    float navBarY = NAV_BAR_ORIGN_Y;
    if (rect.size.height > 736) {
        navBarY += 24;
        rect.size.height-=31;
    }
    [navImg drawInRect:CGRectMake(0, navBarY, rect.size.width, navImg.size.height)];
    NSLog(@"%@ view size: %f x %f",[UIDevice currentDevice].localizedModel,rect.size.width,rect.size.height);
    rect.origin.y+=(navBarY+navImg.size.height);
    rect.size.height-=(navBarY+navImg.size.height);
    [[UIImage imageNamed:@"daily_background"] drawInRect:rect];
    
}


@end
