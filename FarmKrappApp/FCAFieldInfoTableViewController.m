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
@property(readonly) BOOL isMetric;
@end

@implementation FCAFieldInfoTableViewController

-(BOOL)isMetric
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"Metric"];
}

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
    
    //In edit mode, there will already be a valid Field object
    if (self.managedFieldObject) {
        //EDIT MODE
        self.name = self.managedFieldObject.name;
        self.soilType = ((SoilType*)self.managedFieldObject.soilType).seqID;
        self.cropType = ((CropType*)self.managedFieldObject.cropType).seqID;
        self.fieldSize = self.managedFieldObject.sizeInHectares;
    } else {
        //ADD MODE (defaults)
        self.name = @"";
        self.soilType = kSOILTYPE_SANDY_SHALLOW;
        self.cropType = kCROPTYPE_ALL_CROPS;
        self.fieldSize = @0.0;
    }
    [self updateViewFromModel];
    
    //Tweak stepper increment if imperial
    if (!self.isMetric) {
        self.fieldSizeStepper.stepValue = 0.04;
    }

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
    NSLog(@"Segment changed to %u", (unsigned)self.soilTypeSegmentControl.selectedSegmentIndex);
    if ([UIScreen deviceClass] == UIScreenDeviceClassiPhone4SAspect1p5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

//The slider holds a value 0..100. For imperial, this must be multiplied by kFIELDSIZE_IMPERIAL_SCALING_FACTOR to get a sensible value in Acres
- (IBAction)doSliderChanged:(id)sender {
    double val = self.fieldSizeSlider.value;
    
    //Slider can return fractional values - quantise
    if (self.isMetric) {
        val = 0.1*round(val*10.0);
    } else {
        val *= 2.5;
        val = 0.1*round(val*10.0);
        val *= 0.4;
    }
    self.fieldSizeSlider.value = val;
    
    //Synchronise stepper and slider
    self.fieldSizeStepper.value = val;          //Keep stepper in sync

    
    if (self.isMetric == NO) {
        val = val * 2.5;     //Scale by 2.5 to get a sensible range (in Acres)
    }
    
    if (self.isMetric) {
        self.fieldSizeLabel.text = [NSString stringWithFormat:@"%5.1f ha", val];
    } else {
        self.fieldSizeLabel.text = [NSString stringWithFormat:@"%5.1f acres", val];
    }
}

- (IBAction)doStepperChanged:(id)sender {
    double val = self.fieldSizeStepper.value;
    
    //Synchronise stepper with slider
    self.fieldSizeSlider.value = val;
    
    if (self.isMetric) {
        self.fieldSizeLabel.text = [NSString stringWithFormat:@"%5.1f ha", val];
    } else {
        val *= 2.5;
        self.fieldSizeLabel.text = [NSString stringWithFormat:@"%5.1f acres", val];
    }
}

//Update internal data state from view components
-(void)updateDataFromView
{
    //Get the field name
    self.name = self.nameTextBox.text;
    
    //Get the selected soil type
    switch (self.soilTypeSegmentControl.selectedSegmentIndex) {
        
        case 0:
            self.soilType = kSOILTYPE_SANDY_SHALLOW;;
            break;
        case 1:
            self.soilType = kSOILTYPE_MEDIUM_HEAVY;
            break;
        default:
            //Do nothing - very bad!
            NSLog(@"INVALID SOIL TYPE");
            break;
    }

    //Get the selected crop type
    switch (self.cropTypeSegmentControl.selectedSegmentIndex) {
        case 0:
            self.cropType = kCROPTYPE_ALL_CROPS;
            break;
            
        case 1:
            self.cropType = kCROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE;
            break;
            
        default:
            //Do nothing - very bad!
            NSLog(@"INVALID CROP TYPE");
            break;
    }
    double sz = self.fieldSizeSlider.value;
    if (self.isMetric) {
        sz = 0.1*round(sz*10.0);
        self.fieldSize = [NSNumber numberWithDouble:sz];
    } else {
        sz = sz * 2.5;              //Scale to Acres
        sz = 0.1*round(sz*10.0);    //Round to 1dp
        sz *= kHECTARES_PER_ACRE;   //Convert to ha
        self.fieldSize = [NSNumber numberWithDouble:sz];
    }
   
}
//Update view based on model data
-(void)updateViewFromModel
{
    BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"Metric"];
    
    //Field name
    self.nameTextBox.text = self.name;
    
    //Soil type
    switch (self.soilType.intValue) {
        case SOILTYPE_SANDY_SHALLOW:
            self.soilTypeSegmentControl.selectedSegmentIndex = 0;
            break;
        case SOILTYPE_MEDIUM_HEAVY:
            self.soilTypeSegmentControl.selectedSegmentIndex = 1;
            break;
            
        default:
            NSLog(@"INVALID SOIL TYPE");
            break;
    }
    
    //Crop type
    switch (self.cropType.intValue) {
        case CROPTYPE_ALL_CROPS:
            self.cropTypeSegmentControl.selectedSegmentIndex = 0;
            break;
            
        case CROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE:
            self.cropTypeSegmentControl.selectedSegmentIndex = 1;
            break;
            
        default:
            NSLog(@"INVALID CROP TYPE");
            break;
    }
    
    //Field size
    // TBD - I need one access for all of these
    double val = self.fieldSize.doubleValue;        //Size in ha
    
    if (isMetric) {
        val = 0.1*round(val*10.0);
        self.fieldSizeSlider.value = val;
        self.fieldSizeStepper.value = val;
        self.fieldSizeLabel.text = [NSString stringWithFormat:@"%5.1f ha", val];
    } else {
        val *= kACRES_PER_HECTARE;  //Convert to Acres
        self.fieldSizeLabel.text = [NSString stringWithFormat:@"%5.1f acres", 0.1*round(val*10.0)];
        val *= 0.4;                 //Scale
        self.fieldSizeStepper.value = val;
        self.fieldSizeSlider.value = val;
    }
    
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
    
    SoilType* st = [SoilType FetchSoilTypeForID:self.soilType];
    CropType* ct = [CropType FetchCropTypeForID:self.cropType];
    
    if (self.managedFieldObject) {
        //EDIT MODE - SIMPLY UPDATE THE RECORD
        NSLog(@"EDIT FIELD");
        self.managedFieldObject.name = self.name;
        self.managedFieldObject.soilType = st;
        self.managedFieldObject.cropType = ct;
        self.managedFieldObject.sizeInHectares = self.fieldSize;
//        if (self.isMetric) {
//            self.managedFieldObject.sizeInHectares = self.fieldSize;
//        } else {
//            self.managedFieldObject.sizeInHectares = [NSNumber numberWithDouble:self.fieldSize.doubleValue * kHECTARES_PER_ACRE];
//        }
        
        //Persist the changes
        [FCADataModel saveContext];
        
    } else {
        //ADD MODE - create new managed object (via my own model API)
        [Field InsertFieldWithName:self.name soilType:st cropType:ct sizeInHectares:self.fieldSize];
        NSLog(@"ADDED FIELD");
    }
    
    //Pop back to fields view
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
