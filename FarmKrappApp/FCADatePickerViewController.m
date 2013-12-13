//
//  FCADatePickerViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 13/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCADatePickerViewController.h"

@interface FCADatePickerViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@end

@implementation FCADatePickerViewController

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
    if (self.initialDate) {
        self.datePicker.date = self.initialDate;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doDone:(id)sender {
    self.callBackWithDate(self.datePicker.date);
}
- (IBAction)doCancel:(id)sender {
    self.callBackWithDate(nil);
}


@end
