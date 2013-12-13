//
//  FCASpreadingEventViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 13/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCASpreadingEventViewController.h"
#import "NSDate+NSDateUOPCategory.h"
#import "FCASpreadingEventDetailsTableViewController.h"
#import "FCASpreadingEventSummaryTableViewController.h"

@interface FCASpreadingEventViewController ()

@end

@implementation FCASpreadingEventViewController

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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
}
-(void)viewDidAppear:(BOOL)animated
{
    //Scroll to last row
    NSUInteger lastRow = [[FCADataModel numberOfSpreadingEventsForField:self.fieldSelected] intValue];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[FCADataModel numberOfSpreadingEventsForField:self.fieldSelected] intValue]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SpreadingEvent";
    
    //Select the cell type
    NSUInteger numberOfSE = [[FCADataModel numberOfSpreadingEventsForField:self.fieldSelected] intValue];
    if (indexPath.row == numberOfSE) {
        //The last row is always a PLUS cell
        CellIdentifier = @"AddSpreadingEventCell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        CellIdentifier = @"SpreadingEventSummaryCell";
        FCASpreadingEventCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSArray* arrayOfSE = [FCADataModel arrayOfSpreadingEventsForField:self.fieldSelected];
        SpreadingEvent* se = [arrayOfSE objectAtIndex:indexPath.row];
        cell.manureTypeLabel.text = [MANURETYPE_STRING_DICT objectForKey:se.manureType];
        cell.dateLabel.text = [se.date stringForUKShortFormatUsingGMT:YES];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfSpreadingEvents = [[FCADataModel numberOfSpreadingEventsForField:self.fieldSelected] intValue];
    if (indexPath.row == numberOfSpreadingEvents) {
        return 69.0;
    } else {
        return 69.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"EditSegue" sender:indexPath];
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfSpreadingEvents = [[FCADataModel numberOfSpreadingEventsForField:self.fieldSelected] intValue];
    if (indexPath.row == numberOfSpreadingEvents) {
        return NO;
    } else {
        return YES;
    }
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete object in data store
        NSArray* array = [FCADataModel arrayOfSpreadingEventsForField:self.fieldSelected];
        SpreadingEvent* se = [array objectAtIndex:indexPath.row];
        [FCADataModel removeSpreadingEvent:se];
        
        // Delete the row from the table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    UITableViewController* vc;
    vc = [segue destinationViewController];
    NSString* identifier = [segue identifier];
    
    if ([identifier isEqualToString:@"EditSegue"] || [identifier isEqualToString:@"SummarySegue"]) {
        //EDIT - pass reference of managed object to destination controller
        FCASpreadingEventDetailsTableViewController* dest = (FCASpreadingEventDetailsTableViewController*)vc;
        NSIndexPath* indexPath = (NSIndexPath*)sender;
        //Pass the selected (existing) spreading event
        dest.managedObject = [[FCADataModel arrayOfSpreadingEventsForField:self.fieldSelected] objectAtIndex:indexPath.row];
    }
    else if ([identifier isEqualToString:@"AddSegue"]) {
        //Ensure the reference to the managed object is nil (signals a new entity)
        FCASpreadingEventDetailsTableViewController* dest = (FCASpreadingEventDetailsTableViewController*)vc;
        //Flag this is a new record by passing a field (not a spreading event)
        dest.managedObject = self.fieldSelected;
        
    }
    else
    {
        NSLog(@"ERROR!");
    }
    
    //Turn off editing before the transition
    [self setEditing:FALSE animated:YES];    
}



@end