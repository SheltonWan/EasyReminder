//
//  UIDatePickerView.m
//  Reminder
//
//  Created by Shelton on 9/1/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UIDatePickerView.h"

@implementation UIDatePickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    assert(frame.size.height >= 255);
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat height = 220;
        _datePicker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, self.frame.size.height - height, self.frame.size.width, height)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [self addSubview: _datePicker];
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        _cancelButton.frame = CGRectMake(5, 5, 65, 30);
        [self addSubview:_cancelButton];
        
        _okButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_okButton setTitle:@"Done" forState:UIControlStateNormal];
        _okButton.frame = CGRectMake(self.frame.size.width -5 - 45, 5, 45, 30);
        [self addSubview:_okButton];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

//-(void)removeView:(UIView*)view
//{
//    CGRect frame = view.frame;
//    frame.origin.y -= frame.size.height;
//    
//    [UIView beginAnimations: nil context: nil];
//    [UIView setAnimationDuration: 0.4];
//    [UIView setAnimationTransition: UIViewAnimationTransitionNone forView:view cache: YES];
//    [UIView setAnimationDelegate: self];
//    [UIView setAnimationDidStopSelector:@selector(viewDisappeared)];
//    
//    view.frame = frame;
//    
//    [UIView commitAnimations];
//}
//-(void)viewDisappeared
//{
//    if (self.superview) {
//        [self removeFromSuperview];
//    }
//    
//}
//- (BOOL)resignFirstResponder
//{
//    [self removeView:self];
//    return YES;
//}
@end
