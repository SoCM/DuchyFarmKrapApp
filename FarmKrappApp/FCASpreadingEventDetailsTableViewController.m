//
//  FCASpreadingEventInfoTableViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 13/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCASpreadingEventDetailsTableViewController.h"
#include "NSDate+NSDateUOPCategory.h"

#define ActionSheetManureType 1
#define ActionSheetManureQuality 2

@interface FCASpreadingEventDetailsTableViewController ()

@property(readwrite, nonatomic, strong) Field* field;
@property(readwrite, nonatomic, strong) SpreadingEvent* spreadingEvent;

//Local temporary data
@property (readwrite, nonatomic, strong) NSDate * date;
@property (readwrite, nonatomic, strong) NSNumber* manureType;
@property (readwrite, nonatomic, strong) NSNumber* manureQuality;
@property (readwrite, nonatomic, strong) NSNumber* applicationRate;

@property (weak, nonatomic) IBOutlet UILabel *fieldNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *manureTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *manureQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *applicationRateLabel;
@property (weak, nonatomic) IBOutlet UISlider *applicationRateSlider;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;



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
        self.date = nil;
        self.manureType = nil;
        self.manureQuality = nil;
        self.applicationRate = nil;
        
    }
    if ([obj isKindOfClass:[SpreadingEvent class]]) {
        //This is an existing spreading event
        self.spreadingEvent = (SpreadingEvent*)self.managedObject;
        self.field = self.spreadingEvent.field;

        self.date = self.spreadingEvent.date;
        self.dateLabel.text = [self.spreadingEvent.date stringForUKShortFormatUsingGMT:YES];
        
        self.manureType = self.spreadingEvent.manureType;
        self.manureTypeLabel.text = [MANURETYPE_STRING_DICT objectForKey:self.spreadingEvent.manureType];
        
        self.manureQuality = self.spreadingEvent.quality;
        self.manureQualityLabel.text = [MANUREQUALITY_STRING_DICT objectForKey:self.spreadingEvent.quality];
        
        self.applicationRate = self.spreadingEvent.density;
        self.applicationRateSlider.value = self.spreadingEvent.density.floatValue;
        self.applicationRateLabel.text = [NSString stringWithFormat:@"%5.1f m3/ha", self.applicationRateSlider.value];
    }
    
    //Eitherway, we know the field
    self.fieldNameLabel.text = self.field.name;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



#pragma mark - UITableViewDelgate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"ROW = %d", indexPath.row);
    
    NSString* strCS = [MANURETYPE_STRING_DICT objectForKey:kMANURETYPE_CATTLE_SLURRY];
    NSString* strPS = [MANURETYPE_STRING_DICT objectForKey:kMANURETYPE_PIG_SLURRY];
    NSString* strPL = [MANURETYPE_STRING_DICT objectForKey:kMANURETYPE_POULTRY_LITTER];
    UIActionSheet* asManureType = [[UIActionSheet alloc] initWithTitle:@"Manure Type"
                                                              delegate:self cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:strCS,strPS, strPL, nil];
    asManureType.tag = ActionSheetManureType;
    
    
    NSString* strTHIN     = [MANUREQUALITY_STRING_DICT objectForKey:kMANUREQUALITY_THIN_SOUP];
    NSString* strTHICK    = [MANUREQUALITY_STRING_DICT objectForKey:kMANUREQUALITY_THICK_SOUP];
    NSString* strPORRIDGE = [MANUREQUALITY_STRING_DICT objectForKey:kMANUREQUALITY_PORRIGDE];
    UIActionSheet* asManureQuality = [[UIActionSheet alloc] initWithTitle:@"Manure Quality"
                                                              delegate:self cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:strTHIN, strTHICK, strPORRIDGE, nil];
    asManureQuality.tag = ActionSheetManureQuality;

    
    switch (indexPath.row) {
        case 0:
        case 4:
        case 5:
            //Name - do nothing
            break;
            
        case 1:
            //Set date
            NSLog(@"Select date");
            //TBD
            break;
        case 2:
            //Set manure type
            NSLog(@"Select Type");
            [asManureType showFromToolbar:self.navigationController.toolbar];
            break;
            
        case 3:
            //Manure Quality
            NSLog(@"Select quality");
            [asManureQuality showFromToolbar:self.navigationController.toolbar];
            break;
            
        default:
            break;
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *selectionString = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([selectionString isEqualToString:@"Cancel"]) {
        return;
    }
    
    NSLog(@"%@", selectionString);
    NSLog(@"Selected %d", buttonIndex);
    switch (actionSheet.tag) {
        case ActionSheetManureType:
            //The following works because all objects and keys are unique
            self.manureTypeLabel.text = selectionString;
            self.manureType = [[MANURETYPE_STRING_DICT allKeysForObject:selectionString] objectAtIndex:0];
            break;
            
        case ActionSheetManureQuality:
            self.manureQualityLabel.text = selectionString;
            self.manureQuality = [[MANUREQUALITY_STRING_DICT allKeysForObject:selectionString] objectAtIndex:0];
            break;
            
        default:
            break;
    }
}
#pragma mark - actions
- (IBAction)doSliderValueChanged:(id)sender {
    self.applicationRateLabel.text = [NSString stringWithFormat:@"%5.1f m3/ha", self.applicationRateSlider.value];
    self.applicationRate = [NSNumber numberWithFloat:self.applicationRateSlider.value];
}

- (IBAction)doSave:(id)sender {
    //Validate form
    if (!self.date) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please provide a date" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [av show];
        return;
    }
    if (!self.manureType) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select a manure type" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [av show];
        return;
    }
    if (!self.manureQuality) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select a manure quality" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [av show];
        return;
    }
    if (!self.applicationRate) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please provide a spreading rate" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [av show];
        return;
    }
    //If we get this far, the data is complete - we simple save
    if (!self.spreadingEvent) {
        self.spreadingEvent = [FCADataModel addNewSpreadingEventWithDate:self.date
                                                              manureType:self.manureType.intValue
                                                                 quality:self.manureQuality.intValue
                                                                 density:self.applicationRate
                                                                 toField:self.field];
    } else {
        self.spreadingEvent.date = self.date;
        self.spreadingEvent.manureType = self.manureType;
        self.spreadingEvent.quality = self.manureQuality;
        self.spreadingEvent.density = self.applicationRate;
    }
    //Save and pop back
    [FCADataModel saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */
#undef ActionSheetManureType
#undef ActionSheetManureQuality

@end
