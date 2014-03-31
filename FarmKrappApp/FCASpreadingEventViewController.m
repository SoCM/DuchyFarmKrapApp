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
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [[FCADataModel numberOfSpreadingEventsForField:self.fieldSelected] intValue]) {
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.1];
    }
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
    NSLog(@"Field: %@", self.fieldSelected.name);
    NSInteger N = [[FCADataModel numberOfSpreadingEventsForField:self.fieldSelected] intValue]+1;
    return N;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Spreading events for %@", self.fieldSelected.name];
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"";
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
        cell.manureTypeLabel.text = se.manureType.displayName;
        cell.dateLabel.text = [se.date stringForUKShortFormatUsingGMT:YES];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0;
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

    //Desination view controller
    FCASpreadingEventDetailsTableViewController* dest = (FCASpreadingEventDetailsTableViewController*)vc;
    
    //Create child context
    NSManagedObjectContext* childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [childContext setParentContext:[FCADataModel managedObjectContext]];
    
    //Set MOC for destination view controller
    dest.managedChildObjectContext = childContext;
    
    if ([identifier isEqualToString:@"EditSegue"]) {
        //****
        //EDIT - pass reference of managed object to destination controller
        //****
        NSIndexPath* indexPath = (NSIndexPath*)sender;
        
        //Get reference to selected spreading event from current (parent) context
        SpreadingEvent* currentSpreadingEvent = [[FCADataModel arrayOfSpreadingEventsForField:self.fieldSelected] objectAtIndex:indexPath.row];
        
        //Pass reference to the view controller
        dest.spreadingEvent = (SpreadingEvent*)[childContext objectWithID:[currentSpreadingEvent objectID]];
    }
    else if ([identifier isEqualToString:@"AddSegue"]) {
        //***
        //ADD
        //***
        //This is a new temporary record - pass to destination using child context
        dest.spreadingEvent = [NSEntityDescription insertNewObjectForEntityForName:@"SpreadingEvent" inManagedObjectContext:childContext];
        dest.spreadingEvent.density = @10;
        dest.spreadingEvent.date = [NSDate date];
        NSManagedObjectID  *currentFieldID = [self.fieldSelected objectID];
        Field* fieldInNewContext = (Field*)[childContext objectWithID:currentFieldID];
        [fieldInNewContext addSpreadingEventsObject:dest.spreadingEvent];
    }
    else if ([identifier isEqualToString:@"SummarySegue"])
    {
        //This leads to a summary view. Although it's "mostly" read-only, there is the option to add an image
        //Hence, a child context is used to allow for changes that can be discarded.
        FCASpreadingEventSummaryTableViewController* dest = (FCASpreadingEventSummaryTableViewController*)vc;
        dest.managedChildObjectContext = childContext;
        
        //Get the row that was selected
        UITableViewCell* cell = (UITableViewCell*)sender;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        
        //Get reference to selected spreading event from current (parent) context
        SpreadingEvent* currentSpreadingEvent = [[FCADataModel arrayOfSpreadingEventsForField:self.fieldSelected] objectAtIndex:indexPath.row];
        dest.spreadingEvent = currentSpreadingEvent;
    }
    
    //Turn off editing before the transition
    [self setEditing:FALSE animated:YES];    
}



@end
