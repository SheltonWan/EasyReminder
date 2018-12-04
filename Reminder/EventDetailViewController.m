//
//  EventDetailViewController.m
//  Reminder
//
//  Created by Shelton on 8/30/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "EventDetailViewController.h"
#import "UITextViewEx.h"
#import "UIDatePickerView.h"
#import "AppConst.h"
#import "NSDate+Function.h"
#import "ReminderData.h"
@interface EventDetailViewController ()
{
    BOOL checkBoxOn;
    
    UIDatePickerView* _datePickerView;
    
    NSArray*   _repeatContents;
}

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIButton *buttonDate;
@property (weak, nonatomic) IBOutlet UIButton *buttonTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonRepeatMode;
@property (weak, nonatomic) IBOutlet UITextViewEx *textView;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonCheckBox;
@property (weak, nonatomic) IBOutlet UILabel *textCheckBox;
@property (strong, nonatomic) IBOutlet UIView *repeatView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (assign) BOOL update;
@end

@implementation EventDetailViewController
+(id)viewControllerWithItem:(SWCellItem*)item
{
    EventDetailViewController* viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    [viewController setItem:(SWEventCellItem *)item];
    viewController.eventDate = item.eventDate;
    viewController.update = YES;
    return viewController;
}
-(void)setItem:(SWEventCellItem *)item
{
    _item = item;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!_item) {
        _item = [[SWEventCellItem alloc] init];
    }
    
    
    _repeatContents = [NSArray arrayWithObjects:@"Never",@"Weekly",@"Monthly",@"Yearly", nil];
    _repeatView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 120);
    
    if (!self.eventDate) {
        self.eventDate = [NSDate zeroSecondsFromDate:[NSDate date]];
    }
    
    [self setNavigationBarButton];
    [self positionControl];
    [self updateDateAndTime];
    
    
    
    
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    style.lineBreakMode = NSLineBreakByClipping;
    style.alignment = NSTextAlignmentLeft;
    NSString* repeatType = [NSString stringWithFormat:@"Repeat %@", [_repeatContents objectAtIndex:_item.repeatType]];
    NSMutableAttributedString* repeatTypeString = [[NSMutableAttributedString alloc] initWithString:repeatType attributes:[NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName,[UIColor blackColor],NSForegroundColorAttributeName, [UIFont systemFontOfSize: 16],NSFontAttributeName,nil]];
    [self.buttonRepeatMode setAttributedTitle:repeatTypeString forState:UIControlStateNormal];
    
    [self.pickerView selectRow:_item.repeatType inComponent:0 animated:NO];
    self.textView.text = _item.eventDescription;
    
    if (_item.alreadyFinished) {
        [self checkboxClick:self.buttonCheckBox];
    }
}
- (void)positionControl
{
    
    CGRect frame = self.backImageView.frame;
    frame.origin.y = NAV_BAR_ORIGN_Y + NAV_BAR_HEIGHT +2;
    if (CGRectGetHeight(self.view.frame) > 736) {
        frame.origin.y += 22;
    }
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    if (CGRectGetHeight(self.view.frame) > 736) {
        frame.size.height -= 31;
    }
    self.backImageView.frame = frame;
    
    CGFloat distance = 5;
    CGRect r = self.buttonDate.frame;
    
    r.origin.y = frame.origin.y+33;
    r.size.height = r.size.width*self.buttonDate.currentBackgroundImage.size.height/self.buttonDate.currentBackgroundImage.size.width;
    self.buttonDate.frame = r;
    
    r.origin.y +=r.size.height+distance;
    self.buttonTime.frame = r;
    
    r.origin.y +=r.size.height+distance;
    self.buttonRepeatMode.frame = r;

    r = self.buttonCheckBox.frame;
    r.origin.y = self.buttonRepeatMode.frame.origin.y + self.buttonRepeatMode.frame.size.height + 10;
    self.buttonCheckBox.frame = r;
    
    r = self.textCheckBox.frame;
    r.origin.x = self.buttonCheckBox.frame.origin.x+self.buttonCheckBox.frame.size.width+5;
    r.origin.y = self.buttonCheckBox.frame.origin.y + (self.buttonCheckBox.frame.size.height - self.textCheckBox.frame.size.height)/2;
    self.textCheckBox.frame = r;
    
    r= self.textView.frame;
    r.origin.y = self.buttonCheckBox.frame.origin.y + self.buttonCheckBox.frame.size.height + 10;
     r.size.height = r.size.width*self.textView.frame.size.height/self.textView.frame.size.width;
    self.textView.frame = r;
    self.textView.backgroundColor = [UIColor clearColor];
    
    r = self.buttonDelete.frame;
    r.size.height = r.size.width*self.buttonDelete.currentBackgroundImage.size.height/self.buttonDelete.currentBackgroundImage.size.width;
    r.origin.y = CGRectGetMaxY(self.backImageView.frame) - r.size.height - 33;
    
    self.buttonDelete.frame = r;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setNavigationBarButton
{
    UIImage* image = [[UIImage imageNamed:@"nav_back_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClick:)];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];

}
#pragma mark
- (IBAction)dateButtonClick:(id)sender {
    [_repeatView removeFromSuperview];
    
    if (!_datePickerView) {
        _datePickerView = [[UIDatePickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-270, self.view.frame.size.width, 255)];
        _datePickerView.datePicker.date = self.eventDate;
        [_datePickerView.okButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchDown];
        [_datePickerView.cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchDown];
    }
    
    if ([sender isEqual:self.buttonDate]) {
        _datePickerView.datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else if ([sender isEqual:self.buttonTime]){
        _datePickerView.datePicker.datePickerMode = UIDatePickerModeTime;
    }

    [self showView:_datePickerView];
}
- (IBAction)repeatButtonClick:(id)sender {
    [_datePickerView removeFromSuperview];
    [self showView:_repeatView];
}

- (IBAction)checkboxClick:(id)sender {
    
    checkBoxOn ^= true;
    
    UIButton* button = sender;
    NSLog(@"checkbox state: %ld",(unsigned long)button.state);
    [button setImage:[UIImage imageNamed:checkBoxOn?@"checkbox_background_selected":@"checkbox_background"] forState:UIControlStateNormal];
    
    self.buttonDate.enabled = !checkBoxOn;
    self.buttonTime.enabled = !checkBoxOn;
    self.buttonRepeatMode.enabled = !checkBoxOn;
    

}
-(IBAction)cancelButtonClick:(id)sender
{
    if (((UIButton*)sender).tag ==121) {
        [self removeView:_repeatView];
    }
    else{
        [self removeView:_datePickerView];
    }
    
}
-(IBAction)okButtonClick:(id)sender
{
    if (((UIButton*)sender).tag ==121)
    {
        [self removeView:_repeatView];
        _item.repeatType = (RepeatType)[_repeatContents objectAtIndex:[self.pickerView selectedRowInComponent:0]];
    }
    else{
        [self removeView:_datePickerView];
        self.eventDate = _datePickerView.datePicker.date;
        [self updateDateAndTime];
        
        _item.eventDate = self.eventDate;
    }
    

//    NSLog(@"%@",[_datePickerView.datePicker.date descriptionWithLocale:[NSLocale currentLocale]]);
}
#pragma mark
-(void)updateDateAndTime
{
    NSString* date = [self localDescpritionFormDate:self.eventDate wantDate:YES];
    
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    style.lineBreakMode = NSLineBreakByClipping;
    style.alignment = NSTextAlignmentLeft;
    
    NSMutableAttributedString* dateString = [[NSMutableAttributedString alloc] initWithString:date attributes:[NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName,[UIColor blackColor],NSForegroundColorAttributeName, [UIFont systemFontOfSize: 16],NSFontAttributeName,nil]];
    
    [self.buttonDate setAttributedTitle:dateString forState:UIControlStateNormal];
    
    NSString* time = [self localDescpritionFormDate:self.eventDate wantDate:NO];
    NSMutableAttributedString* timeString = [[NSMutableAttributedString alloc] initWithString:time attributes:[NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName,[UIColor blackColor],NSForegroundColorAttributeName, [UIFont systemFontOfSize: 16],NSFontAttributeName,nil]];
    [self.buttonTime setAttributedTitle:timeString forState:UIControlStateNormal];
}
-(void)removeView:(UIView*)view
{
    CGRect frame = view.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.4];
    [UIView setAnimationTransition: UIViewAnimationTransitionNone forView:view cache: YES];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector:@selector(pickerViewDisappeared:)];

    view.frame = frame;
    
    [UIView commitAnimations];
}
-(void)showView:(UIView*)view
{
    if (!view.superview)
    {
        [self.view addSubview:view];
        
        CGRect frame = view.frame;
        frame.origin.y = self.view.frame.size.height;
        view.frame = frame;
        
        
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationDuration: 0.4];
        [UIView setAnimationTransition: UIViewAnimationTransitionNone forView:view cache: YES];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector:@selector(viewShowFinished:)];
        
        frame.origin.y = self.view.frame.size.height - view.frame.size.height;
        view.frame = frame;
        [UIView commitAnimations];
    }

}
-(void)pickerViewDisappeared:(id)sender
{
    if (_datePickerView.superview)
        [_datePickerView removeFromSuperview];
    if (_repeatView.subviews) {
        [_repeatView removeFromSuperview];
    }
}
-(void)viewShowFinished:(id)sender
{
    
}
-(void)backButtonClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveItem:(id)sender {
    _item.eventDescription = self.textView.text;
    _item.repeatType = (RepeatType)[self.pickerView selectedRowInComponent:0];
    _item.eventDate = self.eventDate;
    
    _item.alreadyFinished  = checkBoxOn;
    _item.finishedDate = checkBoxOn?[NSDate date]:nil;
    if (self.update) {
        [[ReminderData defaultData] updateItem:_item];

    }
    else{
        [[ReminderData defaultData] addItem:_item];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark
-(NSString*)localDescpritionFormDate:(NSDate*)displayDate  wantDate:(BOOL)wantDate
{
    NSLocale* currentLocale = [NSLocale currentLocale];
    NSString* languageCode = [currentLocale objectForKey:NSLocaleLanguageCode];//currentLocale.languageCode;
    
    NSString* date = [displayDate descriptionWithLocale:[NSLocale currentLocale]];
    //NSLog(@"%@",date);
    if ([languageCode isEqualToString:@"zh"])
    {
        NSRange range = [date rangeOfString:@"星期"];
        if (range.location!=NSNotFound)
        {
            if (wantDate) {
                date = [date substringToIndex:range.location+range.length+1];
            }
            else{
                range = [date rangeOfString:@"上午"];
                if (range.location==NSNotFound)
                    range = [date rangeOfString:@"下午"];
                date = [date substringFromIndex:range.location];
            }
            
        }
    }
    else{
        if (self.view.frame.size.width > 320) {
            if([languageCode isEqualToString:@"en"])
            {
                NSRange range = [date rangeOfString:@"at "];
                if (range.location!=NSNotFound)
                {
                    if (wantDate) {
                        date = [date substringToIndex:range.location];
                    }
                    else{
                        date = [date substringFromIndex:range.location+range.length];
                        range = [date rangeOfString:@"PM"];
                        if (range.location!=NSNotFound) {
                            date = [date substringToIndex:range.location+range.length];
                        }
                        else{
                            range = [date rangeOfString:@"AM"];
                            if (range.location!=NSNotFound) {
                                date = [date substringToIndex:range.location+range.length];
                            }
                        }
                    }
                    
                }
                else
                {
                    range = [date rangeOfString:@":"];
                    if (range.location!=NSNotFound)
                    {
                        if (wantDate) {
                            date = [date substringToIndex:range.location-2];
                        }
                        else{
                            date = [date substringFromIndex:range.location-2];
                        }
                        
                    }
                }
            }
            else if ([languageCode isEqualToString:@"ja"])
            {
                NSRange range = [date rangeOfString:@"曜日"];
                if (range.location!=NSNotFound)
                    date = [date substringToIndex:range.location+2];
            }
            else if ([languageCode isEqualToString:@"ko"])
            {
                NSRange range = [date rangeOfString:@"오전"];
                if (range.location!=NSNotFound)
                    date = [date substringToIndex:range.location+2];
            }
            else{
                date = [displayDate descriptionWithLocale:[NSLocale systemLocale]];
                NSRange range = [date rangeOfString:@":"];
                if (range.location!=NSNotFound)
                    date = [date substringToIndex:range.location-2];
            }
            
        }
        else{
            date = [displayDate descriptionWithLocale:[NSLocale systemLocale]];
            NSRange range = [date rangeOfString:@":"];
            if (range.location!=NSNotFound)
                date = [date substringToIndex:range.location-2];
        }
        
    }
    return date;
}

#pragma mark Repeat Mode Picker
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_repeatContents count];
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_repeatContents objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self _selectRepeatModeAtIndex:row];
}
-(void)_selectRepeatModeAtIndex:(NSInteger)index
{
    NSString* mode = [_repeatContents objectAtIndex:index];
    
    NSMutableAttributedString* timeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Repeat %@",mode] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName, [UIFont systemFontOfSize: 16],NSFontAttributeName,nil]];
    [self.buttonRepeatMode setAttributedTitle:timeString forState:UIControlStateNormal];
}
@end
