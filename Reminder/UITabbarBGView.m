//
//  UITabbarBGView.m
//  Reminder
//
//  Created by Shelton on 8/5/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UITabbarBGView.h"
#import "AppConst.h"
@implementation UITabbarBGView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
// 5,5s:320x568
// 6,6s,7,8:375x667
// 6p,6sp,7p,8p:414x736
// X:375x812
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
//    [[self imageWithColor:[UIColor blackColor] size:CGSizeMake(rect.size.width, NAV_BAR_ORIGN_Y+22)] drawAtPoint:CGPointZero];
    
    UIImage* navImg = [UIImage imageNamed:@"nav_bg"];
    if (rect.size.height > 736) {
        rect.size.height-=74;
    }
//    [navImg drawInRect:CGRectMake(0, NAV_BAR_ORIGN_Y, rect.size.width, navImg.size.height)];
    NSLog(@"%@ view size: %f x %f",[UIDevice currentDevice].localizedModel,rect.size.width,rect.size.height);
    rect.origin.y+=(NAV_BAR_ORIGN_Y+navImg.size.height);
    rect.size.height-=(NAV_BAR_ORIGN_Y+navImg.size.height);
    [[UIImage imageNamed:@"daily_background"] drawInRect:rect];
    
    
}

//- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
//{
//    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, (CGRect){ {0,0}, size} );
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
//}
@end
