//
//  FCAFieldsViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 10/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCAFieldsViewController.h"
#import "FCADataModel.h"
#import "FCAFieldInfoTableViewController.h"
#import "FCAFieldCell.h"

@interface FCAFieldsViewController ()

@end

@implementation FCAFieldsViewController

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
    NSUInteger lastRow = [[FCADataModel numberOfFields] intValue];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows - one more than the number of fields (use a plus)
    return [[FCADataModel numberOfFields] intValue]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Field";
    
    //Select the cell type
    NSUInteger numberOfFields = [[FCADataModel numberOfFields] intValue];
    if (indexPath.row == numberOfFields) {
        //The last row is always a PLUS cell
        CellIdentifier = @"Plus";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        CellIdentifier = @"Field";
        FCAFieldCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSArray* fields = [FCADataModel arrayOfFields];
        Field* field = [fields objectAtIndex:indexPath.row];
        cell.nameLabel.text = field.name;
        cell.spreadingEventLabel.text = [NSString stringWithFormat:@"%u", field.spreadingEvents.count];
        cell.sizeLabel.text = [NSString stringWithFormat:@"%5.1f", field.sizeInHectares.doubleValue];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfFields = [[FCADataModel numberOfFields] intValue];
    if (indexPath.row == numberOfFields) {
        return 80.0;
    } else {
        return 110.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"EditFieldSegue" sender:self];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    NSUInteger numberOfFields = [[FCADataModel numberOfFields] intValue];
    if (indexPath.row == numberOfFields) {
        return NO;
    } else {
        return YES;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //Delete data from data store
        NSArray* array = [FCADataModel arrayOfFields];
        Field* field = [array objectAtIndex:indexPath.row];
        [FCADataModel removeField:field];
        //Make row dissapear
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
    FCAFieldInfoTableViewController* vc;
    vc = [segue destinationViewController];
    
    NSString* identifier = [segue identifier];
    
    if ([identifier isEqualToString:@"EditFieldSegue"]) {
        //EDIT
        //TO DO - get field object and configure destination
        
    }
    else if ([identifier isEqualToString:@"AddFieldSegue"]) {
        vc.managedFieldObject = nil;
        //TODO - add defaults
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



@end
