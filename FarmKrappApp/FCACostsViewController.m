//
//  FCACostsViewController.m
//  FarmCrapApp
//
//  Created by Nicholas Outram on 21/03/2014.
//  Copyright (c) 2014 Plymouth University. All rights reserved.
//

#import "FCACostsViewController.h"

@interface FCACostsViewController ()
@property (weak, nonatomic) IBOutlet UIStepper *stepperN;
@property (weak, nonatomic) IBOutlet UIStepper *stepperP;
@property (weak, nonatomic) IBOutlet UIStepper *stepperK;
@property (weak, nonatomic) IBOutlet UILabel *labelNCost;
@property (weak, nonatomic) IBOutlet UILabel *labelPCost;
@property (weak, nonatomic) IBOutlet UILabel *labelKCost;
@property (readwrite, nonatomic, strong) NSNumber* Ncost;
@property (readwrite, nonatomic, strong) NSNumber* Pcost;
@property (readwrite, nonatomic, strong) NSNumber* Kcost;

-(void)updateUI;

@end

@implementation FCACostsViewController
@synthesize Ncost = _Ncost;
@synthesize Pcost = _Pcost;
@synthesize Kcost = _Kcost;

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
    self.Ncost = [[NSUserDefaults standardUserDefaults] objectForKey:@"NperKg"];
    self.Pcost = [[NSUserDefaults standardUserDefaults] objectForKey:@"PperKg"];
    self.Kcost = [[NSUserDefaults standardUserDefaults] objectForKey:@"KperKg"];
    [self updateUI];
}

-(NSString*)formattedString:(NSNumber*)cost
{
    return [NSString stringWithFormat:@"£%4.2f/Kg", [cost doubleValue]];
}

-(void)updateUI
{
    self.labelNCost.text = [self formattedString:self.Ncost];
    self.labelPCost.text = [self formattedString:self.Pcost];
    self.labelKCost.text = [self formattedString:self.Kcost];
    self.stepperN.value = self.Ncost.doubleValue;
    self.stepperP.value = self.Pcost.doubleValue;
    self.stepperK.value = self.Kcost.doubleValue;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)doNStepper:(id)sender {
    self.Ncost = [NSNumber numberWithDouble:((UIStepper*)sender).value];
    [self updateUI];
}

- (IBAction)doPStepper:(id)sender {
    self.Pcost = [NSNumber numberWithDouble:((UIStepper*)sender).value];
    [self updateUI];
}
- (IBAction)doKStepper:(id)sender {
    self.Kcost = [NSNumber numberWithDouble:((UIStepper*)sender).value];
    [self updateUI];    
}
- (IBAction)doSave:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.Ncost forKey:@"NperKg"];
    [[NSUserDefaults standardUserDefaults] setObject:self.Pcost forKey:@"PperKg"];
    [[NSUserDefaults standardUserDefaults] setObject:self.Kcost forKey:@"KperKg"];
    [self performSegueWithIdentifier:@"backtofields" sender:self];
}
- (IBAction)doCancel:(id)sender {
    [self performSegueWithIdentifier:@"backtofields" sender:self];
}
@end
