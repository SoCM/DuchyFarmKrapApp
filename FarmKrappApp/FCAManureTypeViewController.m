//
//  FCAManureTypeViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 18/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCAManureTypeViewController.h"

#import "FCAManureQualityViewController.h"

@interface FCAManureTypeViewController ()
@property(readwrite, nonatomic, strong) NSArray* arrayOfManureTypes;
@property(readwrite, nonatomic, strong) NSArray* arrayOfAllManureQuality;
@property(readwrite,nonatomic, strong) ManureType* selectedManureType;
@property(readwrite,nonatomic, strong) ManureQuality* selectedManureQuality;
@property(readwrite, nonatomic, strong) NSNumber* selectedSection;
@end

@implementation FCAManureTypeViewController
@synthesize arrayOfManureTypes = _arrayOfManureTypes;
@synthesize arrayOfAllManureQuality = _arrayOfAllManureQuality;

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
    self.selectedSection = nil;
    self.selectedManureType = nil;
    self.selectedManureQuality = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - accessors
-(NSArray*)arrayOfManureTypes
{
    if (_arrayOfManureTypes == nil) {
        self.arrayOfManureTypes = [ManureType allManagedObjectsSortedByName];
    }
    return _arrayOfManureTypes;
}
-(NSArray*) arrayOfAllManureQuality
{
    if (_selectedManureType == nil) {
        return nil;
    }
  
    _arrayOfAllManureQuality = [ManureQuality allSortedManagedObjectsForManureType:self.selectedManureType];
    return _arrayOfAllManureQuality;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [ManureType count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.selectedSection == nil) return 1;
    
    if (self.selectedSection.intValue == section) {
        return [self.arrayOfAllManureQuality count]+1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell __block *cell;
    ManureType* mt = [self.arrayOfManureTypes objectAtIndex:indexPath.section];
    NSString* strMT = mt.displayName;

    //Generic code for cell with manure type string
    void(^basicCellBlock)(void) = ^(void) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
        
        cell.textLabel.text = strMT;
    };
    
    //*************************
    //Case of no selection made
    //*************************
    if (self.selectedSection == nil) {
        basicCellBlock();
        return cell;
    }
    
    //*************************
    //A selection has been made
    //*************************
    
    //This is the section header - normal cell
    if (indexPath.row == 0) {
        basicCellBlock();
        return cell;
    }
    
    //Must be a manure quality
    ManureQuality* mq = [self.arrayOfAllManureQuality objectAtIndex:indexPath.row-1];
    cell = [tableView dequeueReusableCellWithIdentifier:@"QualityCell" forIndexPath:indexPath];
    cell.textLabel.text = mq.name;
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 80.0;
    } else {
        return 60.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    void(^updateTable)(void) = ^(void) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    
    //No selection yet been made
    if (self.selectedSection == nil) {
        //Simply flag which section (and hence manure type) has been chosen
        self.selectedSection = [NSNumber numberWithInt:indexPath.section];
        self.selectedManureType = self.selectedManureType = [self.arrayOfManureTypes objectAtIndex:indexPath.section];
        self.selectedManureQuality = nil;

        updateTable();
        return;
    }
    
    //Previous selection must have been made
    
    //Toggle off current selection?
    if ((self.selectedSection.intValue == indexPath.section) && (indexPath.row == 0)) {
        self.selectedSection = nil;
        self.selectedManureType = nil;
        self.selectedManureQuality = nil;
        updateTable();
        return;
    }
    
    //Chose a different section?
    if (indexPath.row == 0) {
        int prev = self.selectedSection.intValue;
        int next = indexPath.section;
        NSRange r;
        r.location = 0;
        r.length = [ManureType count];
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:r];
        
        self.selectedSection = [NSNumber numberWithInt:next];
        self.selectedManureType = self.selectedManureType = [self.arrayOfManureTypes objectAtIndex:next];
        self.selectedManureQuality = nil;
        
        //Update table (2 sections)
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    //A quality type must have been selected
    NSInteger item = indexPath.row-1;
    self.selectedManureQuality = [self.arrayOfAllManureQuality objectAtIndex:item];
    self.callBackBlock(self.selectedManureType, self.selectedManureQuality);
    [self.navigationController popViewControllerAnimated:YES];
    
}


@end
