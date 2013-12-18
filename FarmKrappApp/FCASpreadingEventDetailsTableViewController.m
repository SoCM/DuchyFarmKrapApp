//
//  FCASpreadingEventInfoTableViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 13/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCASpreadingEventDetailsTableViewController.h"
#import "NSDate+NSDateUOPCategory.h"
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

@property(readwrite, nonatomic, strong) Field* field;
@property(readwrite, nonatomic, strong) SpreadingEvent* spreadingEvent;

//Local temporary data
@property (readwrite, nonatomic, strong) NSDate* date;
@property (readwrite, nonatomic, strong) NSString* manureType;
@property (readwrite, nonatomic, strong) NSNumber* manureQuality;
@property (readwrite, nonatomic, strong) NSNumber* applicationRate;

//State
@property(readwrite, nonatomic, assign) BOOL datePickerShowing;
@property(readwrite, nonatomic, assign) BOOL manureTypePickerShowing;
@property(readwrite, nonatomic, assign) BOOL manureQualityPickerShowing;
@property(readwrite, nonatomic, assign) BOOL imageShowing;
@property(readwrite, nonatomic, strong) ManureQuality* selectedManureQuality;
@property(readwrite, nonatomic, strong) ManureType* selectedManureType;
@property(readwrite, nonatomic, strong) NSString* currentImageFileName;

@end

@implementation FCASpreadingEventDetailsTableViewController

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
    id obj = self.managedObject;

    //Introspect
    if ([obj isKindOfClass:[Field class]]) {
        //This is a new spreading event - only the field is provided
        self.field = (Field*)self.managedObject;
        self.spreadingEvent = nil;
        self.date = [NSDate date];
        self.manureType = nil;
        self.manureQuality = nil;
        self.applicationRate = @10;
        self.selectedManureQuality = nil;
        self.selectedManureType = nil;
    }
    if ([obj isKindOfClass:[SpreadingEvent class]]) {
        //This is an existing spreading event
        self.spreadingEvent = (SpreadingEvent*)self.managedObject;
        self.field = self.spreadingEvent.field;
        self.date = self.spreadingEvent.date;
        self.manureType = ((ManureType*)self.spreadingEvent.manureType).stringID;
        self.manureQuality = ((ManureQuality*)self.spreadingEvent.manureQuality).seqID;
        self.selectedManureType = self.spreadingEvent.manureType;
        self.selectedManureQuality = self.spreadingEvent.manureQuality;
        self.applicationRate = self.spreadingEvent.density;
    }
    
    //Eitherway, we know the field
    
    //Initial state
    self.datePickerShowing = NO;
    self.manureQualityPickerShowing = NO;
    self.manureTypePickerShowing = NO;
    self.imageShowing = NO;
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
        return 5;
    } else {
        return 4;
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
            return @"APPLICATION RATE";
            break;
        case 4:
            return @"Guide image:";
            break;
        default:
            return @"";
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    switch (section) {
        case 0:
            //Field name
            return 60.0;
            break;
        case 1:
            //Date + Picker
            return (row==0) ? 60.0 : 160.0;
        case 2:
            //Manure type + quality
            return 100;
            break;
        case 3:
            //Application rate
            return 130.0;
            break;
        case 4:
            //Image
            return 320.0;
            break;
            //Should not be needed
        default:
            return 60.0;
            break;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
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
#warning This needs checking
    UITableViewCell *cell;
    FCASpreadingEventSingleLabelCell* fieldNameCell;
    FCADateStringCell* dateStringCell;
    FCADatePickerCell* datePickerCell;
    FCAManureCell* manureCell;
    FCAApplicationRateCell* appRateCell;
    FCASquareImageCell* imageCell;
    
    switch (indexPath.section) {
        case 0:
            //Field
            cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLabelCell" forIndexPath:indexPath];
            fieldNameCell = (FCASpreadingEventSingleLabelCell*)cell;
            fieldNameCell.label.text = self.field.name;
            break;
            
        case 1:
            //Date
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"DateStringCell" forIndexPath:indexPath];
                dateStringCell = (FCADateStringCell*)cell;
                dateStringCell.label.text = [self.date stringForUKShortFormatUsingGMT:YES];
                //TBD
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"DatePickerCell" forIndexPath:indexPath];
                datePickerCell = (FCADatePickerCell*)cell;
                if (self.date) {
                    datePickerCell.datePicker.date = self.date;
                }
            }
            break;

        case 2:
            //Manure type + quality
            cell = [tableView dequeueReusableCellWithIdentifier:@"ManureCell" forIndexPath:indexPath];
            manureCell = (FCAManureCell*)cell;
            if (self.manureType) {
                manureCell.manureTypeLabel.text = self.selectedManureType.displayName;
                manureCell.manureQualityLabel.text = self.selectedManureQuality.name;
            } else {
                manureCell.manureTypeLabel.text = @"Select a Manure Type";
                manureCell.manureQualityLabel.text = @"";
            }
            break;
            
        case 3:
            //Application rate
            cell = [tableView dequeueReusableCellWithIdentifier:@"ApplicationRateCell" forIndexPath:indexPath];
            appRateCell = (FCAApplicationRateCell*)cell;
            appRateCell.label.text = [NSString stringWithFormat:@"%@", self.applicationRate];
            
            //Update slider if different
            if (appRateCell.slider.value != self.applicationRate.floatValue) {
                appRateCell.slider.value = self.applicationRate.floatValue;
            }

            //Set scale depending on manure type
            if (self.selectedManureType) {
                if ([self.selectedManureType.stringID isEqualToString:@"PoultryLitter"]) {
                    appRateCell.slider.maximumValue = 15.0;
                } else {
                    appRateCell.slider.maximumValue = 100.0;
                }
            }
            break;
            
        case 4:
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
            imageCell = (FCASquareImageCell*)cell;
            if (self.selectedManureType) {
                NSString* fileName = [FCADataModel imageNameForManureType:self.selectedManureType andRate:self.applicationRate];
                
                //Has the image name changed? (changing the image is expensive)
                if (![self.currentImageFileName isEqualToString:fileName]) {
                    NSLog(@"Updating %@ to %@", self.currentImageFileName, fileName);
                    self.currentImageFileName = fileName;
                    imageCell.poopImageView.image = [UIImage imageNamed:fileName];
                }
            }
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
    float v = slider.value;
    v = roundf(v);
    self.applicationRate = [NSNumber numberWithInt:(int)v];
    [self.tableView reloadData];
}


- (IBAction)doSave:(id)sender {
    //Validate form
    if (!self.date) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please provide a date" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [av show];
        return;
    }
    if (!self.manureType) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select a manure type" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [av show];
        return;
    }
    if (!self.applicationRate) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please provide a spreading rate" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [av show];
        return;
    }
    //If we get this far, the data is complete - we simple save
    if (!self.spreadingEvent) {
        self.spreadingEvent = [FCADataModel addNewSpreadingEventWithDate:self.date
                                                              manureType:self.selectedManureType
                                                                 quality:self.selectedManureQuality
                                                                 density:self.applicationRate
                                                                 toField:self.field];
    } else {
        self.spreadingEvent.date = self.date;
        self.spreadingEvent.manureType = self.selectedManureType;
        self.spreadingEvent.manureQuality = self.selectedManureQuality;
        self.spreadingEvent.density = self.applicationRate;
    }
    //Save and pop back
    [FCADataModel saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

//Change the name of this method to match the view controller you are using
- (IBAction)unwindToSpreadingEventDetails:(UIStoryboardSegue*)sender
{
    NSLog(@"Back!");
}


- (IBAction)doDateUpdate:(id)sender {
    UIDatePicker* datePicker = (UIDatePicker*)sender;
    self.date = datePicker.date;
    [self.tableView reloadData];
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
        self.manureType = manureType.displayName;
        self.manureQuality = manureQual.seqID;
        self.selectedManureQuality = manureQual;
        self.selectedManureType = manureType;
        self.applicationRate = @10.0;   //Reset the application rate
        self.imageShowing = YES;
        [self.tableView reloadData];
    };
    
    if ([segue.identifier isEqualToString:@"ManureDetailsSegue"]) {
        FCAManureTypeViewController* mtva = (FCAManureTypeViewController*)vc;
        mtva.callBackBlock =callBack;
    }
    
}

@end
