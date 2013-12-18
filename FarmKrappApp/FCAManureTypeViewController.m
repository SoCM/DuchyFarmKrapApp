//
//  FCAManureTypeViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 18/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCAManureTypeViewController.h"
#import "FCADataModel.h"
#import "FCAManureQualityViewController.h"

@interface FCAManureTypeViewController ()
@property(readwrite, nonatomic, strong) NSArray* arrayOfManureTypes;
@property(readwrite,nonatomic, strong) ManureType* selectedManureType;
@end

@implementation FCAManureTypeViewController
@synthesize arrayOfManureTypes = _arrayOfManureTypes;

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

#pragma mark - accessors
-(NSArray*)arrayOfManureTypes
{
    if (_arrayOfManureTypes == nil) {
        self.arrayOfManureTypes = [ManureType allManagedObjectsSortedByName];
    }
    return _arrayOfManureTypes;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [ManureType count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    ManureType* mt = [self.arrayOfManureTypes objectAtIndex:indexPath.row];
    NSString* strMT = mt.displayName;
    cell.textLabel.text = strMT;
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell* cell = (UITableViewCell*)sender;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
   self.selectedManureType = [self.arrayOfManureTypes objectAtIndex:indexPath.row];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    FCAManureQualityViewController* mvc = (FCAManureQualityViewController*)segue.destinationViewController;
    mvc.selectedManureType = self.selectedManureType;
}


@end
