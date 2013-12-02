//
//  SoCMViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 29/11/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "SoCMViewController.h"

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

/**********************
 ACTIONS for Front Page
***********************/

-(void)openSiteWithURLString:(NSString*) strURL
{
    NSURL* urlWebSite = [NSURL URLWithString:strURL];
    [[UIApplication sharedApplication] openURL:urlWebSite];
}

- (IBAction)showPlymouthUniversityWWW:(id)sender {
    [self openSiteWithURLString:@"http://www.plymouth.ac.uk"];
}

- (IBAction)showSWARMWWW:(id)sender {
    [self openSiteWithURLString:@"http://www.swarmhub.co.uk"];
}

- (IBAction)showDuchyRBSWWW:(id)sender {
    [self openSiteWithURLString:@"https://www.ruralbusinessschool.org.uk"];
}

- (IBAction)showDuchyCollegeWWW:(id)sender {
    [self openSiteWithURLString:@"http://www.duchy.ac.uk"];
}

- (IBAction)doGetStarted:(id)sender {
    NSLog(@"GO");
}

@end
