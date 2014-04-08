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
@property(readwrite, nonatomic, assign) BOOL guiNeedsRefresh;
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

    self.spreadingEvent.date = [NSDate dateWithYear:2000 month:9 day:1];
    self.spreadingEvent.density = @0.0;
    self.nutrientCalc = nil;
    self.guiNeedsRefresh = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
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
    if (self.spreadingEvent.manureType) {
        return 6;
    } else {
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
//    NSUInteger row = indexPath.row;
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
        
        NSString* strManureType = self.spreadingEvent.manureQuality.name;
        if (strManureType) {
            NSUInteger loc = [strManureType rangeOfString:@"incorporated"].location;
            if  (loc == NSNotFound) {
                //Disable the last segment summer
                [sCell.segmentedControl setEnabled:YES forSegmentAtIndex:3];
            } else {
                [sCell.segmentedControl setEnabled:NO forSegmentAtIndex:3];
            }
        }

        
//([self.spreadingEvent.date season] == SUMMER)        
        return sCell;
    }
    else if (indexPath.section == 4) {
        FCAApplicationRateCell* appRateCell = (FCAApplicationRateCell*)[self.tableView dequeueReusableCellWithIdentifier:@"ApplicationRateCell"];
        if ( self.guiNeedsRefresh ) {
            //Everytime this is reset, reset the GUI
            appRateCell.slider.value = 0.0;
            self.guiNeedsRefresh = NO;
        }
        
        appRateCell.slider.maximumValue = [self.spreadingEvent maximumValueUsingMetric:isMetric];
        double val = appRateCell.slider.value;
        val = round(val);
        appRateCell.slider.value = val;
        
        //Set label to match
        appRateCell.label.text = [NSString stringWithFormat:@"%5.0f %@", val, [self.spreadingEvent rateUnitsAsStringUsingMetric:isMetric]];
        
        //Calculate the N P K (conditional on all data being available)
        if (self.nutrientCalc) {
            NSNumber *N, *P, *K;
            N = [self.nutrientCalc nitrogenAvailableForRate:self.spreadingEvent.density];
            P = [self.nutrientCalc phosphateAvailableForRate:self.spreadingEvent.density];
            K = [self.nutrientCalc potassiumAvailableForRate:self.spreadingEvent.density];
            
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
    BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"Metric"];
    
    //Get value
    UISlider* slider = (UISlider*)sender;
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

    [self.spreadingEvent setRate:v usingMetric:isMetric];
    
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
            self.spreadingEvent.density = @0;
            self.guiNeedsRefresh = YES;
            
            [self.tableView reloadData];
        };
        
        FCAManureTypeViewController* vc = (FCAManureTypeViewController*)segue.destinationViewController;
        vc.season = [self.spreadingEvent.date season];
        vc.callBackBlock = callBack;
    }
}



@end
