//
//  SoCMViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 29/11/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "SoCMViewController.h"
#import "UIViewController+FCAFrontPage.h"
#import "SoCMAppDelegate.h"

@interface SoCMViewController ()

@end

@implementation SoCMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Change the name of this method to match the view controller you are using
- (IBAction)unwindToFrontPageViewController:(UIStoryboardSegue*)sender
{
    BOOL tAndC = [[NSUserDefaults standardUserDefaults] boolForKey:@"T&C"];
    if (tAndC) {
        [self performSegueWithIdentifier:@"proceed" sender:self];
    }
}
- (IBAction)doDisclaimer:(id)sender {
    [self performSegueWithIdentifier:@"disclaimer" sender:self];
}

- (IBAction)doGetStarted:(id)sender {
    BOOL tAndC = [[NSUserDefaults standardUserDefaults] boolForKey:@"T&C"];
    if (tAndC) {
        [self performSegueWithIdentifier:@"proceed" sender:self];
    } else {
        [self performSegueWithIdentifier:@"disclaimer" sender:self];
    }
    NSLog(@"GO");
    
}


@end
