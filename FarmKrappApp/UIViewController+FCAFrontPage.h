//
//  UIViewController+FCAFrontPage.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 03/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//
//  This is a category on UIViewController which contains common
//  code / actions for both iPhone and iPad controllers
//

#import <UIKit/UIKit.h>

@interface UIViewController (FCAFrontPage)
- (void)openSiteWithURLString:(NSString*) strURL;
- (IBAction)showPlymouthUniversityWWW:(id)sender;
- (IBAction)showSWARMWWW:(id)sender;
- (IBAction)showDuchyRBSWWW:(id)sender;
- (IBAction)showDuchyCollegeWWW:(id)sender;
- (IBAction)showThinkManures:(id)sender;
@end
