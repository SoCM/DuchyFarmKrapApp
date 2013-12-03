//
//  UIViewController+FCAFrontPage.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 03/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "UIViewController+FCAFrontPage.h"

@implementation UIViewController (FCAFrontPage)

/***************************************************
 ACTIONS for Front Page - COMMON TO iPAD and iPhone
***************************************************/
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

@end
