//
//  FCAAboutViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 02/02/2014.
//  Copyright (c) 2014 Plymouth University. All rights reserved.
//

#import "FCAAboutViewController.h"

@interface FCAAboutViewController ()

@end

@implementation FCAAboutViewController

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
    

//        [webVu loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:fileName ofType:@"html"]isDirectory:NO]]];

    NSString* path = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
    self.webview.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doBack:(id)sender {
    [self.webview goBack];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (request.URL.host) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    } else {
        return YES;
    }
}
@end
