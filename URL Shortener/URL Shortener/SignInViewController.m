//
//  SignInViewController.m
//  URL Shortener
//
//  Created by Neeraj Baid on 3/13/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIImageView *googleLogo;
@property (strong, nonatomic) IBOutlet UIImageView *signInTextFieldsBackground;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_navigationBar setBackgroundImage:[UIImage imageNamed:@"top bar.png"] forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
