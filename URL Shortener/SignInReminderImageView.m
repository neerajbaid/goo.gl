//
//  SignInReminderImageView.m
//  URL Shortener
//
//  Created by Neeraj Baid on 5/11/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import "SignInReminderImageView.h"
#import "Mixpanel.h"

@implementation SignInReminderImageView

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"test4");
    self = [super initWithFrame:frame];
    if (self)
    {
        [[Mixpanel sharedInstance] track:@"Sign In Reminder Appeared"];
        UITapGestureRecognizer *UItgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissImage)];
        [self addGestureRecognizer:UItgr];
    }
    return self;
}

- (void)dismissImage:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"test");
        [[Mixpanel sharedInstance] track:@"Dismissed Sign In Reminder"];
        [UIView animateWithDuration:0.2 animations:^void
         {
             self.alpha = 0;
         }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
