//
//  FCACaclulatorTableViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 05/01/2014.
//  Copyright (c) 2014 Plymouth University. All rights reserved.
//

#import "FCACaclulatorTableViewController.h"
#import "FCADataModel.h"
#import "FCAManureCell.h"
#import "FCASoilTypeCell.h"
#import "FCACropTypeCell.h"
#import "FCASeasonCell.h"
#import "FCASquareImageCell.h"
#import "FCAApplicationRateCell.h"
#import "FCAManureTypeViewController.h"
#import "SpreadingEvent.h"
#import "Field.h"

@interface FCACaclulatorTableViewController ()
@property(readonly) NSManagedObjectContext* managedObjectContext;
@property(readwrite, nonatomic, strong) Field* field;
@property(readwrite, nonatomic, strong) SpreadingEvent* spreadingEvent;
@property(readwrite, nonatomic, strong) FCAAvailableNutrients* nutrientCalc;
@property(readwrite, nonatomic, strong) NSString* currentImageFileName;
@end

@implementation FCACaclulatorTableViewController {

}
@synthesize managedObjectContext = _managedObjectContext;
@synthesize field = _field;
@synthesize spreadingEvent = _spreadingEvent;
@synthesize nutrientCalc = _nutrientCalc;

//Child managed object context
-(NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext == nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.parentContext = [FCADataModel managedObjectContext];
    }
    return _managedObjectContext;
}
-(Field*)field
{
    if (_field == nil) {
        self.field = (Field*)[NSEntityDescription insertNewObjectForEntityForName:@"Field" inManagedObjectContext:self.managedObjectContext];
        [self.field setName:@"Temp"];
        self.field.sizeInHectares = @1;
    }
    return _field;
}
-(SpreadingEvent*)spreadingEvent {
    if (_spreadingEvent == nil) {
        SpreadingEvent* se = (SpreadingEvent*)[NSEntityDescription insertNewObjectForEntityForName:@"SpreadingEvent" inManagedObjectContext:self.managedObjectContext];
        self.spreadingEvent = se;
        [self.field addSpreadingEventsObject:se];
    }
    return _spreadingEvent;
}
-(FCAAvailableNutrients*)nutrientCalc
{
    if (_nutrientCalc == nil) {
        self.nutrientCalc = [[FCAAvailableNutrients alloc] initWithSpreadingEvent:self.spreadingEvent];
    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Initial values
    CropType *ct = [CropType FetchCropTypeForID:@100];
    self.field.cropType = [self.managedObjectContext objectWithID:ct.objectID];
    SoilType *st = [SoilType FetchSoilTypeForID:@100];
    self.field.soilType = [self.managedObjectContext objectWithID:st.objectID];
    self.spreadingEvent.density = @10;
    self.spreadingEvent.date = [NSDate dateWithYear:2000 month:9 day:1];
    self.nutrientCalc = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    if (self.spreadingEvent.manureType) {
        return 6;
    } else {
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"MANURE TYPE & QUALITY:";
            break;
        case 1:
            return @"SOIL TYPE:";
            break;
        case 2:
            return @"CROP TYPE:";
            break;
        case 3:
            return @"SEASON:";
            break;
        case 4:
            return @"APPLICATION RATE:";
            break;
        case 5:
            return @"GUIDE IMAGE:";
            break;
        default:
            return @"";
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    switch (section) {
        case 0:
            return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 120.0 : 100.0;
            break;
        case 1:
        case 2:
        case 3:
            return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 80.0 : 60.0;
            break;
        case 4:
            return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 210 : 210.0;
            break;
        case 5:
            return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 230.0 : 210.0;
            break;
        case 6:
            //Image
            return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 768.0 : 320.0;
            break;
            //Should not be needed
        default:
            return 60.0;
            break;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"Metric"];
    
    //Section 0 - manure type
    if (indexPath.section == 0) {
        FCAManureCell* manureCell = (FCAManureCell*)[self.tableView dequeueReusableCellWithIdentifier:@"ManureCell" forIndexPath:indexPath];
        if (self.spreadingEvent.manureType) {
            manureCell.manureTypeLabel.text = self.spreadingEvent.manureType.displayName;
        }
        if (self.spreadingEvent.manureQuality) {
            manureCell.manureQualityLabel.text = self.spreadingEvent.manureQuality.name;
        }
        return manureCell;
    }
    else if (indexPath.section == 1) {
        FCASoilTypeCell* stCell = (FCASoilTypeCell*)[self.tableView dequeueReusableCellWithIdentifier:@"SoilTypeCell"];
        return stCell;
    }
    else if (indexPath.section == 2) {
        FCACropTypeCell* ctCell = (FCACropTypeCell*)[self.tableView dequeueReusableCellWithIdentifier:@"CropTypeCell"];
        return ctCell;
    }
    else if (indexPath.section == 3) {
        FCASeasonCell* sCell = (FCASeasonCell*)[self.tableView dequeueReusableCellWithIdentifier:@"SeasonCell"];
        return sCell;
    }
    else if (indexPath.section == 4) {
        FCAApplicationRateCell* appRateCell = (FCAApplicationRateCell*)[self.tableView dequeueReusableCellWithIdentifier:@"ApplicationRateCell"];
        
        appRateCell.label.text = [self.spreadingEvent rateAsStringUsingMetric:isMetric];
        
        //Update slider if different
        if (appRateCell.slider.value != self.spreadingEvent.density.floatValue) {
            appRateCell.slider.value = self.spreadingEvent.density.floatValue;
        }
        
        //Set scale depending on manure type
        if (self.spreadingEvent.manureType) {
            if ([self.spreadingEvent.manureType.stringID isEqualToString:@"PoultryLitter"]) {
                appRateCell.slider.maximumValue = 15.0;
            } else {
                appRateCell.slider.maximumValue = 100.0;
            }
        }
        
        //Calculate the N P K (conditional on all data being available)
        
        if (self.nutrientCalc) {
            NSNumber *N, *P, *K;
            N = [self.nutrientCalc nitrogenAvailableForRate:self.spreadingEvent.density];
            P = [self.nutrientCalc phosphateAvailableForRate:self.spreadingEvent.density];
            K = [self.nutrientCalc potassiumAvailableForRate:self.spreadingEvent.density];
            
            //                appRateCell.NitrogenLabel.text = [NSString stringWithFormat:@"%4.1f", N.floatValue];
            appRateCell.NitrogenLabel.text = [FCAAvailableNutrients stringFormatForNutrientRate:N usingMetric:isMetric];
            
            appRateCell.PhosphateLabel.text = [FCAAvailableNutrients stringFormatForNutrientRate:P usingMetric:isMetric];
            appRateCell.PotassiumLabel.text = [FCAAvailableNutrients stringFormatForNutrientRate:K usingMetric:isMetric];
            
            //Costings
            double Ncost = [[NSUserDefaults standardUserDefaults] doubleForKey:@"NperKg"]*N.doubleValue;
            double Pcost = [[NSUserDefaults standardUserDefaults] doubleForKey:@"PperKg"]*P.doubleValue;
            double Kcost = [[NSUserDefaults standardUserDefaults] doubleForKey:@"KperKg"]*K.doubleValue;
            Ncost *= self.spreadingEvent.field.sizeInHectares.doubleValue;
            Pcost *= self.spreadingEvent.field.sizeInHectares.doubleValue;
            Kcost *= self.spreadingEvent.field.sizeInHectares.doubleValue;
            
            appRateCell.NitrogenCostLabel.text = [NSString stringWithFormat:@"£%6.2f", Ncost];
            appRateCell.PhosphateCostLabel.text = [NSString stringWithFormat:@"£%6.2f", Pcost];
            appRateCell.PotassiumCostLabel.text = [NSString stringWithFormat:@"£%6.2f", Kcost];
            
        } else {
            appRateCell.NitrogenLabel.text = @"---";
            appRateCell.PhosphateLabel.text = @"---";
            appRateCell.PotassiumLabel.text = @"---";
        }
        
        return appRateCell;
    }
    else if (indexPath.section == 5) {
        FCASquareImageCell* imageCell = (FCASquareImageCell*)[self.tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
        if (self.spreadingEvent.manureType) {
            NSString* fileName = [FCADataModel imageNameForManureType:self.spreadingEvent.manureType andRate:self.spreadingEvent.density];
            
            //Has the image name changed? (changing the image is expensive)
            if (![self.currentImageFileName isEqualToString:fileName]) {
                self.currentImageFileName = fileName;
                imageCell.poopImageView.image = [UIImage imageNamed:fileName];
            }
        }
        return imageCell;
    }
    else {
        return nil;
    }
}

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

#pragma mark - Navigation
- (IBAction)doSoilTypeChanged:(id)sender {
    UISegmentedControl* seg = (UISegmentedControl*)sender;
    NSNumber *type;
    if (seg.selectedSegmentIndex == 0) {
        type = @100;
    } else {
        type = @200;
    }
    self.field.soilType = [self.managedObjectContext objectWithID:[SoilType FetchSoilTypeForID:type].objectID];
    
    //Reset object to calc NPK values
    self.nutrientCalc = nil;
    
    //Reload table data
    [self.tableView reloadData];
}
- (IBAction)doCropTypeChanged:(id)sender {
    UISegmentedControl* seg = (UISegmentedControl*)sender;
    NSNumber* type;
    if (seg.selectedSegmentIndex == 0) {
        type = @100;
    } else {
        type = @200;
    }
    self.field.cropType = [self.managedObjectContext objectWithID:[CropType FetchCropTypeForID:type].objectID];
    //Reset object to calc NPK values
    self.nutrientCalc = nil;

    //Reload table data
    [self.tableView reloadData];
}
- (IBAction)doSeasonChanged:(id)sender {
    UISegmentedControl* seg = (UISegmentedControl*)sender;
    NSDate* date;
    
    switch (seg.selectedSegmentIndex) {
        case 0:
            date = [NSDate dateWithYear:2000 month:10 day:1];
            break;
        case 1:
            date = [NSDate dateWithYear:2000 month:12 day:1];
            break;
        case 2:
            date = [NSDate dateWithYear:2000 month:3 day:1];
            break;
        case 3:
            date = [NSDate dateWithYear:2000 month:6 day:1];
            break;
        default:
            NSLog(@"Error: %s", __PRETTY_FUNCTION__);
            break;
    }
    self.spreadingEvent.date = date;
    
    //Reset object to calc NPK values
    self.nutrientCalc = nil;
    
    //Reload table data
    [self.tableView reloadData];
}
- (IBAction)doApplicationRateChanged:(id)sender {
    UISlider* slider = (UISlider*)sender;
    self.spreadingEvent.density = [NSNumber numberWithFloat:slider.value];
    
    //Refresh view
    [self.tableView reloadData];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ManureDetailsSegue"]) {
        
        void(^callBack)(ManureType*, ManureQuality*) = ^(ManureType *mt, ManureQuality *mq) {
            self.spreadingEvent.manureQuality = (ManureQuality*)[self.managedObjectContext objectWithID:mq.objectID];
            self.spreadingEvent.manureType = (ManureType*)[self.managedObjectContext objectWithID:mt.objectID];
            self.nutrientCalc = nil;
            self.spreadingEvent.density = @10;
            [self.tableView reloadData];
        };
        
        FCAManureTypeViewController* vc = (FCAManureTypeViewController*)segue.destinationViewController;
        vc.callBackBlock = callBack;
    }
}



@end