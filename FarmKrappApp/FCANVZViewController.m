//
//  FCANVZViewController.m
//  FarmCrapApp
//
//  Created by Nicholas Outram on 18/03/2014.
//  Copyright (c) 2014 Plymouth University. All rights reserved.
//

#import "FCANVZViewController.h"

@interface FCANVZViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation FCANVZViewController

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
    
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"NVZ" ofType:@"pages"];
//    NSURL* url = [NSURL fileURLWithPath:path];
//    [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
    
//    [self.webview setScalesPageToFit:NO];
    [self loadDocument:@"NVZ9" inView:self.webview];
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

-(void)loadDocument:(NSString*)documentName inView:(UIWebView*)webView
{
    NSString *path = [[NSBundle mainBundle] pathForResource:documentName ofType:@"pages"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];

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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
