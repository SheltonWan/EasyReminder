//
//  UITableCellView.m
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UITableCellView.h"

#define RIGHT_WIDTH 92.0f
#define DATE_ORIGIN_Y 85.0f
#define EVENT_DATE_ORIGIN_Y 30.0f
#define DATE_FONT_SIZE 12.0f
@implementation UITableCellView

//--87--94--130--
- (void)drawBackgroundAtRect:(CGRect)rect {
    // Drawing code
      NSString* name = nil;
    switch (self.cellType) {
        case TABLE_CELL_BIRTHDAY:
            name = @"cellbg_birthday";
            break;
        case TABLE_CELL_BIRTHDAY_LUNAR:
            name = @"cellbg_birthday_lunar";
            break;
        case TABLE_CELL_ANNIVERSARY:
            name = @"cellbg_aniversary";
            break;
        case TABLE_CELL_EVENT:
            name = @"cellbg_event";
            break;
        default:
            name = @"cellbg_birthday";
            break;
    }
    UIImage* background = [UIImage imageNamed:name];

    if (self.isToday) {
        UIImage* today = [UIImage imageNamed:@"cellbg_today"];

        
        CGImageRef frontImageRef = CGImageCreateWithImageInRect([background CGImage], CGRectMake(0, 0, 181*[UIScreen mainScreen].scale, background.size.height*[UIScreen mainScreen].scale));
        UIImage *frontImage = [UIImage imageWithCGImage:frontImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        [frontImage drawAtPoint:CGPointZero];
        
        float midWidth = (rect.size.width-today.size.width-frontImage.size.width - 38);
        float maxWidth = 94;
        float w = MIN(midWidth, maxWidth);
        float startX = frontImage.size.width;
        
        while (midWidth > 0) {
            CGImageRef midImageRef = CGImageCreateWithImageInRect([background CGImage], CGRectMake(87*[UIScreen mainScreen].scale, 0, w*[UIScreen mainScreen].scale, background.size.height*[UIScreen mainScreen].scale));
            UIImage *midImage = [UIImage imageWithCGImage:midImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            [midImage drawAtPoint:CGPointMake(startX, 0)];
            
            midWidth -= w;
            startX += w;
            w = MIN(midWidth, maxWidth);
        }
        w = 38;
        CGImageRef midImageRef = CGImageCreateWithImageInRect([background CGImage], CGRectMake((background.size.width - today.size.width - w)*[UIScreen mainScreen].scale, 0, w*[UIScreen mainScreen].scale, background.size.height*[UIScreen mainScreen].scale));
        UIImage *midImage = [UIImage imageWithCGImage:midImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        [midImage drawAtPoint:CGPointMake(startX, 0)];
        
        [today drawInRect:CGRectMake(rect.size.width - today.size.width, 0, today.size.width, rect.size.height)];
    }
    else{
        CGImageRef frontImageRef = CGImageCreateWithImageInRect([background CGImage], CGRectMake(0, 0, background.size.width/2*[UIScreen mainScreen].scale, background.size.height*[UIScreen mainScreen].scale));
        UIImage *frontImage = [UIImage imageWithCGImage:frontImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        [frontImage drawAtPoint:CGPointZero];
        
        float midWidth = rect.size.width-background.size.width;
        float maxWidth = 94;
        float w = MIN(midWidth, maxWidth);
        float startX = frontImage.size.width;
        
        while (midWidth > 0) {
            CGImageRef midImageRef = CGImageCreateWithImageInRect([background CGImage], CGRectMake(87*[UIScreen mainScreen].scale, 0, w*[UIScreen mainScreen].scale, background.size.height*[UIScreen mainScreen].scale));
            UIImage *midImage = [UIImage imageWithCGImage:midImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            [midImage drawAtPoint:CGPointMake(startX, 0)];
            
            midWidth -= w;
            startX += w;
            w = MIN(midWidth, maxWidth);
        }

        
        
        CGImageRef backImageRef = CGImageCreateWithImageInRect([background CGImage], CGRectMake(background.size.width/2*[UIScreen mainScreen].scale, 0, background.size.width/2*[UIScreen mainScreen].scale, background.size.height*[UIScreen mainScreen].scale));
        UIImage *backImage = [UIImage imageWithCGImage:backImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        [backImage drawAtPoint:CGPointMake(rect.size.width-backImage.size.width, 0)];
    }
}
-(NSString*)localDescpritionFormDate:(NSDate*)displayDate  atRect:(CGRect)rect
{
    NSLocale* currentLocale = [NSLocale currentLocale];
    NSString* languageCode = [currentLocale objectForKey:NSLocaleLanguageCode];
    
    NSString* date = [displayDate descriptionWithLocale:[NSLocale currentLocale]];
    //NSLog(@"%@",date);
    if ([languageCode isEqualToString:@"zh"])
    {
        NSRange range = [date rangeOfString:@"星期"];
        if (range.location==NSNotFound) {
            range = [date rangeOfString:@"星期"];
        }
        if (range.location!=NSNotFound)
            date = [date substringToIndex:range.location+range.length+1];
    }
    else{
        if (rect.size.width > 320) {
            if([languageCode isEqualToString:@"en"])
            {
                NSRange range = [date rangeOfString:@"at "];
                if (range.location!=NSNotFound)
                    date = [date substringToIndex:range.location];
                else
                {
                    range = [date rangeOfString:@":"];
                    if (range.location!=NSNotFound)
                        date = [date substringToIndex:range.location-2];
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
- (void)drawDisplayDateAtRect:(CGRect)rect {
    if (self.displayDate) {
        
        NSString* date = [self localDescpritionFormDate:self.displayDate atRect:rect];

        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
        style.lineBreakMode = NSLineBreakByClipping;
        
        NSMutableAttributedString* dateString = [[NSMutableAttributedString alloc] initWithString:date attributes:[NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName,[UIColor lightGrayColor],NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize: DATE_FONT_SIZE],NSFontAttributeName,nil]];

        if (self.cellType == TABLE_CELL_EVENT) {
            [dateString drawInRect:CGRectMake(EVENT_DATE_ORIGIN_Y, 41,rect.size.width-EVENT_DATE_ORIGIN_Y-RIGHT_WIDTH,dateString.size.height)];
        }
        else{
            [dateString drawInRect:CGRectMake(DATE_ORIGIN_Y, 40,rect.size.width-DATE_ORIGIN_Y-RIGHT_WIDTH,dateString.size.height)];
//            if (self.dateLabel) {
//                NSMutableAttributedString* dateLabelString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)",self.dateLabel] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor],NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize: DATE_FONT_SIZE],NSFontAttributeName,nil]];
//                float maxWidth = rect.size.width-DATE_ORIGIN_Y-RIGHT_WIDTH - dateString.size.width;
//                if (dateLabelString.size.width < maxWidth) {
//                    [dateLabelString drawAtPoint:CGPointMake(DATE_ORIGIN_Y+dateString.size.width, 40)];
//                }
//                
//            }
        }
        


        
    }
}

- (void)drawNameLabel {
    if (self.name) {
        NSString* text = self.name;
        if (self.dateLabel) {
            text = [text stringByAppendingString:[NSString stringWithFormat:@"(%@)",self.dateLabel]];
        }
        
        NSMutableAttributedString* nameString = [[NSMutableAttributedString alloc] initWithString:text attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize: 15],NSFontAttributeName,nil]];
        [nameString drawAtPoint:CGPointMake(72, 15)];
        
        
    }
}
- (void)drawEventTitle
{
    if (self.eventTitle) {
        
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        
        self.eventTitle = [[self.eventTitle componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
        NSMutableAttributedString* nameString = [[NSMutableAttributedString alloc] initWithString:self.eventTitle attributes:[NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName,[UIColor blackColor],NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize: 15],NSFontAttributeName,nil]];
        //NSLog(@"nameString.size.height:%f",nameString.size.height); 18
        [nameString drawInRect:CGRectMake(16, 15, CGRectGetWidth(self.frame)-RIGHT_WIDTH-16, nameString.size.height)];
        //[nameString drawAtPoint:CGPointMake(16, 15)];
    }
}
- (void)drawAgesLabelAtRect:(CGRect)rect {
    if (self.ages > 0) {
            NSMutableAttributedString* agesString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ldth",(long)self.ages] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize: 10],NSFontAttributeName,nil]];
            [agesString drawAtPoint:CGPointMake(rect.size.width-RIGHT_WIDTH-32, 7)];
    }
}

- (void)drawLeftDaysLabelAtRect:(CGRect)rect {
    if (self.isToday) {
        NSMutableAttributedString* leftDaysString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Today", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize: 28],NSFontAttributeName,nil]];
        [leftDaysString drawAtPoint:CGPointMake(rect.size.width-RIGHT_WIDTH+(RIGHT_WIDTH-leftDaysString.size.width)/2, (rect.size.height - leftDaysString.size.height)/2)];
    }
    else
    {
        NSMutableAttributedString* leftDaysString = [[NSMutableAttributedString alloc] initWithString:[NSNumber numberWithInteger:labs(self.leftDays)].stringValue attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize: 28],NSFontAttributeName,nil]];
        [leftDaysString drawAtPoint:CGPointMake(rect.size.width-RIGHT_WIDTH+(RIGHT_WIDTH-leftDaysString.size.width)/2, 30)];
        NSMutableAttributedString* leftDaysDesc = [[NSMutableAttributedString alloc] initWithString:self.leftDays >0 ? NSLocalizedString(@"LeftDays", nil) :NSLocalizedString(@"DaysPast", nil)attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize: 11],NSFontAttributeName,nil]];
        [leftDaysDesc drawAtPoint:CGPointMake(rect.size.width-RIGHT_WIDTH+(RIGHT_WIDTH-leftDaysDesc.size.width)/2-3, 7)];
    }
}

- (void)drawHeadPortraitAtRect:(CGRect)rect {
    UIImage* face = [UIImage imageNamed:@"default_face"];
    CGRect faceFrame = CGRectMake((rect.size.height - face.size.height+1)/2, (rect.size.height - face.size.height)/2-2, face.size.width, face.size.height);
    if (self.face)
    {
        [self.face drawInRect:faceFrame];
    }
    else{

        [face drawInRect:faceFrame];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    //NSLog(@"table cell size: %f x %f (scale:%f)",rect.size.width,rect.size.height,[UIScreen mainScreen].scale);
    [self drawBackgroundAtRect:rect];
    
    if (self.cellType!=TABLE_CELL_EVENT) {
        [self drawHeadPortraitAtRect:rect];
        [self drawAgesLabelAtRect:rect];
    }

    [self drawNameLabel];
    [self drawEventTitle];
    [self drawDisplayDateAtRect:rect];
    [self drawLeftDaysLabelAtRect:rect];
}


@end
