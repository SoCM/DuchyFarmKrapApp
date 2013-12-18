//
//  FCAManureQualityViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 18/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCAManureQualityViewController.h"
@interface FCAManureQualityViewController ()
@property(readwrite, nonatomic, strong) ManureQuality* selectedManureQuality;
@property(readwrite, nonatomic, strong) NSArray* arrayOfAllManureQuality;
@end

@implementation FCAManureQualityViewController
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray*)arrayOfAllManureQuality
{
    if (_arrayOfAllManureQuality == nil) {
        self.arrayOfAllManureQuality = [ManureQuality allSortedManagedObjectsForManureType:self.selectedManureType];
    }
    return _arrayOfAllManureQuality;
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
    return self.arrayOfAllManureQuality.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    ManureQuality* mq = [self.arrayOfAllManureQuality objectAtIndex:indexPath.row];
    cell.textLabel.text = mq.name;
    return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedManureQuality = [self.arrayOfAllManureQuality objectAtIndex:indexPath.row];
}
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



@end
