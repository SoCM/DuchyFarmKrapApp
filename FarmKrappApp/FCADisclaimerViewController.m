//
//  FCADisclaimerViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 09/01/2014.
//  Copyright (c) 2014 Plymouth University. All rights reserved.
//

#import "FCADisclaimerViewController.h"

@interface FCADisclaimerViewController ()

@end

@implementation FCADisclaimerViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doYes:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"T&C"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSegueWithIdentifier:@"BackToMainPage" sender:self];

}
- (IBAction)doNo:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"T&C"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSegueWithIdentifier:@"BackToMainPage" sender:self];
}



@end
