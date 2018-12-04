//
//  UITabBarItemEx.m
//  Reminder
//
//  Created by Shelton on 8/4/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UITabBarItemEx.h"

@implementation UITabBarItemEx

-(UIImage*)selectedImage
{
    UIImage* background = [UIImage imageNamed:@"tabbaritem_hover"];
    UIImage* item = [super selectedImage];
    
    CGSize newSize = background.size;
    newSize.height+=20;
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);

    [background drawInRect:CGRectMake(0, 20, background.size.width, background.size.height)];
    CGRect clipRect;
    clipRect.origin.x = (newSize.width - item.size.width)/2;
    clipRect.origin.y = (newSize.height - item.size.height)/2+1;
    clipRect.size = item.size;
    [item drawInRect:clipRect];
    
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return [backgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


@end
