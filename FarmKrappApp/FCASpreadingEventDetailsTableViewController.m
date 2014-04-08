//
//  FCASpreadingEventInfoTableViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 13/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCASpreadingEventDetailsTableViewController.h"
#import "NSDate+NSDateUOPCategory.h"
#import "UIImageUOPCategory.h"
#import "FCAManureTypeViewController.h"

#import "FCADataModel.h"
#import "FCASpreadingEventSingleLabelCell.h"
#import "FCADateStringCell.h"
#import "FCADatePickerCell.h"
#import "FCAManureCell.h"
#import "FCAApplicationRateCell.h"
#import "FCASquareImageCell.h"

@interface FCASpreadingEventDetailsTableViewController ()
- (IBAction)doDateUpdate:(id)sender;
- (IBAction)doPhoto:(id)sender;

//Nutrient calculation obect
@property(readwrite, nonatomic, strong) FCAAvailableNutrients* nutrientCalc;
@property(readwrite, nonatomic, assign) BOOL guiNeedsUpdating;

//State
@property(readwrite, nonatomic, assign) BOOL datePickerShowing;
@property(readwrite, nonatomic, assign) BOOL manureTypePickerShowing;
@property(readwrite, nonatomic, assign) BOOL manureQualityPickerShowing;
@property(readwrite, nonatomic, assign) BOOL imageShowing;
@property(readwrite, nonatomic, strong) NSString* currentImageFileName;
@property(readonly) BOOL isMetric;
@end

@implementation FCASpreadingEventDetailsTableViewController {
    dispatch_once_t pred_isMetric;
}

@synthesize  nutrientCalc = _nutrientCalc;
@synthesize isMetric = _isMetric;

-(BOOL)isMetric {
    dispatch_once(&pred_isMetric, ^() {
        _isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"Metric"];
    });
    return _isMetric;
}

-(FCAAvailableNutrients*)nutrientCalc
{
    if (_nutrientCalc) {
        return _nutrientCalc;
    }

    //Make sure all essential data is available
    if ((self.spreadingEvent.manureQuality == nil) || (self.spreadingEvent.manureType == nil) || (self.spreadingEvent.date == nil)) {
        _nutrientCalc = nil;
        return nil;
    }
    
    //If we get this far, the data is available
    self.nutrientCalc = [[FCAAvailableNutrients alloc] initWithSpreadingEvent:self.spreadingEvent];
    self.guiNeedsUpdating = YES;
    return _nutrientCalc;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setHidesBottomBarWhenPushed:NO];
    self.navigationController.toolbarHidden = NO;
}
-(void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self setHidesBottomBarWhenPushed:YES];
    self.navigationController.toolbarHidden = YES;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.1];
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Initial state
    self.datePickerShowing = NO;
    self.manureQualityPickerShowing = NO;
    self.manureTypePickerShowing = NO;
    if ((self.spreadingEvent.manureType) && (self.spreadingEvent.manureQuality) && (self.spreadingEvent.density)) {
        self.imageShowing = YES;
    } else {
        self.imageShowing = NO;
    }
    self.nutrientCalc = nil;
    self.guiNeedsUpdating = YES;
    NSLog(@"FIELD: %@", self.spreadingEvent);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.imageShowing) {
        if (self.spreadingEvent.photo == nil) {
            //Guide image only
            return 5;
        } else {
            //Photo
            return 6;
        }

    } else {
        return 3;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"FIELD NAME:";
            break;
        case 1:
            return @"DATE:";
            break;
        case 2:
            return @"MANURE TYPE & QUALITY";
            break;
        case 3:
            return @"CROP AVAIL. & EST. EQUIV. PRICE";
            break;
        case 4:
            return @"Guide image:";
            break;
        case 5:
            return @"Photo";
        default:
            return @"";
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    switch (section) {
        case 0:
            //Field name
            return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 64.0 : 60.0;
            break;
        case 1:
            //Date + Picker
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                return (row==0) ? 60.0 : 160.0;
            } else {
                return (row==0) ? 64.0 : 217.0;
            }
        case 2:
            //Manure type + quality
            return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 120.0 : 100.0;
            break;
        case 3:
            //Application rate
            return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 230.0 : 210.0;
            break;
        case 4:
        case 5:
            //Image
            return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 768.0 : 320.0;
            break;
            //Should not be needed
        default:
            return 60.0;
            break;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            //Field name
            return 1;
            break;
            
        case 1:
            //Date + Date Picker
            if (self.datePickerShowing == YES) {
                return 2;
            } else {
                return 1;
            }
            break;
            
        case 2:
            //Manure Type + quality
        case 3:
            //Application rate
            return 1;
            break;
            
        case 4:
        case 5:
            //Image
            return 1;
            break;

        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    FCASpreadingEventSingleLabelCell* fieldNameCell;
    FCADateStringCell* dateStringCell;
    FCADatePickerCell* datePickerCell;
    FCAManureCell* manureCell;
    FCAApplicationRateCell* appRateCell;
    FCASquareImageCell* imageCell;
    FCASquareImageCell* photoCell;
    UIImage* piccy;
    
    switch (indexPath.section) {
        case 0:
            //Field
            cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLabelCell" forIndexPath:indexPath];
            fieldNameCell = (FCASpreadingEventSingleLabelCell*)cell;
            fieldNameCell.label.text = self.spreadingEvent.field.name;
            break;
            
        case 1:
            //Date
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"DateStringCell" forIndexPath:indexPath];
                dateStringCell = (FCADateStringCell*)cell;
                dateStringCell.label.text = [self.spreadingEvent.date stringForUKShortFormatUsingGMT:YES];
                //TBD
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"DatePickerCell" forIndexPath:indexPath];
                datePickerCell = (FCADatePickerCell*)cell;
                if (self.spreadingEvent.date) {
                    datePickerCell.datePicker.date = self.spreadingEvent.date;
                }
            }
            break;

        case 2:
            //Manure type + quality
            cell = [tableView dequeueReusableCellWithIdentifier:@"ManureCell" forIndexPath:indexPath];
            manureCell = (FCAManureCell*)cell;
            if (self.spreadingEvent.manureType) {
                manureCell.manureTypeLabel.text = self.spreadingEvent.manureType.displayName;
                manureCell.manureQualityLabel.text = self.spreadingEvent.manureQuality.name;
            } else {
                manureCell.manureTypeLabel.text = @"Manure Type:";
                manureCell.manureQualityLabel.text = @"None Selected";
            }
            break;
            
        case 3:
            //Application rate
            cell = [tableView dequeueReusableCellWithIdentifier:@"ApplicationRateCell" forIndexPath:indexPath];
            appRateCell = (FCAApplicationRateCell*)cell;
            
//            appRateCell.label.text = [NSString stringWithFormat:@"%@ m3/ha", self.spreadingEvent.density];
//            appRateCell.label.text = [self.spreadingEvent rateAsStringUsingMetric:self.isMetric];
            
            //Update slider if needed
            if (self.guiNeedsUpdating) {
                NSLog(@"UPDATE GUI: %@", self.spreadingEvent.density);
                
                //Set scale depending on manure type
                appRateCell.slider.maximumValue = [self.spreadingEvent maximumValueUsingMetric:self.isMetric];

                //Set slider position
                appRateCell.slider.value = [self.spreadingEvent rateUsingMetric:self.isMetric];
                self.guiNeedsUpdating = NO;
                //appRateCell.slider.value = self.spreadingEvent.density.floatValue;
            }
            
            //Match text to slider
            appRateCell.label.text = [NSString stringWithFormat:@"%4.0f %@", appRateCell.slider.value, [self.spreadingEvent rateUnitsAsStringUsingMetric:self.isMetric]];
            
            //Calculate the N P K (conditional on all data being available)
            
            if (self.nutrientCalc) {
                NSNumber *N, *P, *K;
                N = [self.nutrientCalc nitrogenAvailableForRate:self.spreadingEvent.density];
                P = [self.nutrientCalc phosphateAvailableForRate:self.spreadingEvent.density];
                K = [self.nutrientCalc potassiumAvailableForRate:self.spreadingEvent.density];
                
//                appRateCell.NitrogenLabel.text = [NSString stringWithFormat:@"%4.1f", N.floatValue];
                appRateCell.NitrogenLabel.text = [FCAAvailableNutrients stringFormatForNutrientRate:N usingMetric:self.isMetric];
                
                appRateCell.PhosphateLabel.text = [FCAAvailableNutrients stringFormatForNutrientRate:P usingMetric:self.isMetric];
                appRateCell.PotassiumLabel.text = [FCAAvailableNutrients stringFormatForNutrientRate:K usingMetric:self.isMetric];
                
                //Costings (per area)
                double Ncost = [[NSUserDefaults standardUserDefaults] doubleForKey:@"NperKg"]*N.doubleValue;
                double Pcost = [[NSUserDefaults standardUserDefaults] doubleForKey:@"PperKg"]*P.doubleValue;
                double Kcost = [[NSUserDefaults standardUserDefaults] doubleForKey:@"KperKg"]*K.doubleValue;
                /*
                 Cost is given per ha or acre
                 */
                
//                Ncost *= self.spreadingEvent.field.sizeInHectares.doubleValue;
//                Pcost *= self.spreadingEvent.field.sizeInHectares.doubleValue;
//                Kcost *= self.spreadingEvent.field.sizeInHectares.doubleValue;
                if (self.isMetric) {
                    appRateCell.NitrogenCostLabel.text = [NSString stringWithFormat:@"£%6.2f/ha", Ncost];
                    appRateCell.PhosphateCostLabel.text = [NSString stringWithFormat:@"£%6.2f/ha", Pcost];
                    appRateCell.PotassiumCostLabel.text = [NSString stringWithFormat:@"£%6.2f/ha", Kcost];
                } else {
                    double fScale = kACRES_PER_HECTARE;
                    Ncost *= fScale;
                    Pcost *= fScale;
                    Kcost *= fScale;
                    appRateCell.NitrogenCostLabel.text = [NSString stringWithFormat:@"£%6.2f/acre", Ncost];
                    appRateCell.PhosphateCostLabel.text = [NSString stringWithFormat:@"£%6.2f/acre", Pcost];
                    appRateCell.PotassiumCostLabel.text = [NSString stringWithFormat:@"£%6.2f/acre", Kcost];
                }
                
            } else {
                appRateCell.NitrogenLabel.text = @"---";
                appRateCell.PhosphateLabel.text = @"---";
                appRateCell.PotassiumLabel.text = @"---";
            }
            break;
            
        case 4:
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
            imageCell = (FCASquareImageCell*)cell;
            if (self.spreadingEvent.manureType) {
                NSString* fileName = [FCADataModel imageNameForManureType:self.spreadingEvent.manureType andRate:self.spreadingEvent.density];
                
                //Has the image name changed? (changing the image is expensive)
                if (![self.currentImageFileName isEqualToString:fileName]) {
                    self.currentImageFileName = fileName;
                    imageCell.poopImageView.image = [UIImage imageNamed:fileName];
                }
            }
            break;
            
        case 5:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
            photoCell = (FCASquareImageCell*)cell;
            piccy = [UIImage imageWithData:self.spreadingEvent.photo];
            photoCell.poopImageView.image = piccy;
            break;
            
        default:
            break;
    }
    
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - UITableViewDelgate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        self.datePickerShowing = !self.datePickerShowing;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    return;
}

#pragma mark - actions
- (IBAction)doApplicationRateSliderUpdate:(id)sender {
    
    UISlider* slider = (UISlider*)sender;
    
    //Get value
    double v = slider.value;
    
    //For large values, quantise to 100 steps
    double fMax = slider.maximumValue;
    if (fMax>100) {
        //Quantise
        double fRes = (fMax * 0.01);
        v = fRes * round(v/fRes);
    }
    
    //Round
    v =round(v);
    slider.value = v;
    
    [self.spreadingEvent setRate:v usingMetric:self.isMetric];
    //iOS7 only code
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        //Code for iOS 6.1 or earlier
        double r = v / slider.maximumValue;
        double b = 1.0-r;
        [slider setTintColor:[UIColor colorWithRed:r green:0.0 blue:b alpha:1.0]];
    }
    
    [self.tableView reloadData];
}


- (IBAction)doSave:(id)sender {
    //Validate form
    if (!self.spreadingEvent.date) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please provide a date" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [av show];
        return;
    }
    if (!self.spreadingEvent.manureType) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select a manure type" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [av show];
        return;
    }
    if (!self.spreadingEvent.density) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please provide a spreading rate" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [av show];
        return;
    }
    //If we get this far, the data is complete - we simple save
     //Save and pop back
    NSError* err;
    [self.managedChildObjectContext save:&err];
    [self.managedChildObjectContext.parentContext save:&err];       //DO I NEED THIS?
    [self.navigationController popViewControllerAnimated:YES];
}

//Change the name of this method to match the view controller you are using
- (IBAction)unwindToSpreadingEventDetails:(UIStoryboardSegue*)sender
{
    [self.tableView reloadData];
    NSLog(@"Back!");
}


- (IBAction)doDateUpdate:(id)sender {
    UIDatePicker* datePicker = (UIDatePicker*)sender;
    
    //First the special case -
    //  FYM is already selected as soil incorporated
    //  If the date is set to summer, nullify the MT
    ManureQuality* mq = self.spreadingEvent.manureQuality;
    bool isIncorporated = ( (mq.seqID.intValue == FYM_OLDINC) || (mq.seqID.intValue == FYM_FRINC));
    
    self.spreadingEvent.date = datePicker.date;
    self.nutrientCalc = nil;        //Reset nutrient calculator
    
    //No not allow SAVE if date is moved to summer and a soil-incorporated quality is already selected
    if (([self.spreadingEvent.date season] == SUMMER) && (isIncorporated)) {
        self.spreadingEvent.manureType = nil;
        self.spreadingEvent.manureQuality = nil;
        self.imageShowing = NO;
    }
    [self.tableView reloadData];
}

- (IBAction)doPhoto:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO) {
        return;
    }
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imgPicker.allowsEditing = YES;
    imgPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    imgPicker.showsCameraControls = YES;
    imgPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imgPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    imgPicker.delegate = self;
    [self presentViewController:imgPicker animated:YES completion:^(){}];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissViewControllerAnimated:YES completion:^(){}];
}
// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    // Handle a still image capture
    UIImage* image = (UIImage *) [info objectForKey: UIImagePickerControllerEditedImage];
    
    //Choose the image
    if (image == nil) {
        image = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
    }
    
    [self dismissViewControllerAnimated:YES completion:^(){
        //Save
//        self.spreadingEvent.photo = UIImagePNGRepresentation(image);]
        UIImage* smaller = [image resizeByFactor:0.5];
        self.spreadingEvent.photo = UIImageJPEGRepresentation(smaller, 0.5);
        
        [self.tableView reloadData];
    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewController* vc;
    vc = [segue destinationViewController];
    
    void(^callBack)(ManureType*, ManureQuality*) = ^(ManureType* manureType, ManureQuality* manureQual) {
        //managedobjects passed are from a different context
        self.spreadingEvent.manureType = (ManureType*)[self.managedChildObjectContext objectWithID:[manureType objectID]];
        self.spreadingEvent.manureQuality = (ManureQuality*)[self.managedChildObjectContext objectWithID:[manureQual objectID]];
        self.spreadingEvent.density = @0.0;   //Reset the application rate
        self.imageShowing = YES;
        self.guiNeedsUpdating = YES;
        self.nutrientCalc = nil;        //Reset nutrient calculator
//        [self.tableView reloadData];  //This needs to be called later - moved to viewDidAppear
    };
    
    if ([segue.identifier isEqualToString:@"ManureDetailsSegue"]) {
        FCAManureTypeViewController* mtva = (FCAManureTypeViewController*)vc;
        mtva.callBackBlock = callBack;
        mtva.season = [self.spreadingEvent.date season];
    }
    
}

@end
