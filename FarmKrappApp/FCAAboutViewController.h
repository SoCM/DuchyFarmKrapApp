//
//  FCAAboutViewController.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 02/02/2014.
//  Copyright (c) 2014 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCAAboutViewController : UIViewController<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;
- (IBAction)doBack:(id)sender;

@end
