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
    
}

- (IBAction)doGetStarted:(id)sender {
    NSLog(@"GO");
    
}



@end
