//
//  FCAFieldInfoTableViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 10/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCAFieldInfoTableViewController.h"
#import "UIScreen+OOTY.h"

@interface FCAFieldInfoTableViewController ()

@end

@implementation FCAFieldInfoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

//Make keyboard go away if another cell is touched
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        [self.nameTextBox resignFirstResponder];
    }
    if ([UIScreen deviceClass] == UIScreenDeviceClassiPhone4SAspect1p5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }
}
//Respond to return key (make k/b go away)
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([UIScreen deviceClass] == UIScreenDeviceClassiPhone4SAspect1p5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)doSegmentedValueChanged:(id)sender {
    //Make k/b go away if visible
    [self.nameTextBox resignFirstResponder];
    NSLog(@"Segment changed to %u", self.soilTypeSegmentControl.selectedSegmentIndex);
    if ([UIScreen deviceClass] == UIScreenDeviceClassiPhone4SAspect1p5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

}

- (IBAction)doSliderChanged:(id)sender {
    double val = self.fieldSizeSlider.value;
    self.fieldSizeStepper.value = val;
    self.fieldSizeLabel.text = [NSString stringWithFormat:@"%5.1f", val];
}

- (IBAction)doStepperChanged:(id)sender {
    double val = self.fieldSizeStepper.value;
    self.fieldSizeLabel.text = [NSString stringWithFormat:@"%5.1f", val];
    self.fieldSizeSlider.value = val;
}

//Update internal data state from view components
-(void)updateDataFromView
{
    //Get the field name
    self.name = self.nameTextBox.text;
    
    //Get the selected soil type
    switch (self.soilTypeSegmentControl.selectedSegmentIndex) {
        
        case 0:
            self.soilType = SOILTYPE_SANDY_SHALLOW;
            break;
        case 1:
            self.soilType = SOILTYPE_MEDIUM_HEAVY;
            break;
        default:
            //Do nothing - very bad!
            NSLog(@"INVALID SOIL TYPE");
            
    }
    
    //Get the selected crop type
    switch (self.cropTypeSegmentControl.selectedSegmentIndex) {
        case 0:
            self.cropType = CROPTYPE_ALL_CROPS;
            break;
            
        case 1:
            self.cropType = CROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE;
            break;
            
        default:
            //Do nothing - very bad!
            NSLog(@"INVALID CROP TYPE");
            break;
    }
    
    //Get the field size (round to nearest 0.5)
    self.fieldSize = floor(0.5+10.0*self.fieldSizeSlider.value)/10.0;
}
- (IBAction)doSave:(id)sender {
    
    //Update the data records from the view components
    [self updateDataFromView];
    
    //Check for empty name
    if ([self.name isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Name Missing" message:@"Please enter a name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self.nameTextBox becomeFirstResponder];
        return;
    }
    
    //All data is now assumed to be valid
    //Edit or Add?
    if (self.managedFieldObject) {
        //EDIT MODE - SIMPLY UPDATE THE RECORD
        NSLog(@"EDIT FIELD");
        self.managedFieldObject.name = self.name;
        self.managedFieldObject.soilType = [NSNumber numberWithInt:self.soilType];
        self.managedFieldObject.cropType = [NSNumber numberWithInt:self.cropType];
        self.managedFieldObject.sizeInHectares = [NSNumber numberWithFloat:self.fieldSize];
        //Persist the changes
        [FCADataModel saveContext];
        
    } else {
        //ADD
        [FCADataModel addNewFieldWithName:self.name
                                 soilType:self.soilType
                                 cropType:self.cropType
                           sizeInHectares:[NSNumber numberWithFloat:self.fieldSize]
         ];
        NSLog(@"ADDED FIELD");
    }
    
    //Pop back to fields view
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
