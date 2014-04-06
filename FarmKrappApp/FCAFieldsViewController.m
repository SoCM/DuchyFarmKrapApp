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
#import "FCASpreadingEventViewController.h"
#import "NSBundleUOPCategory.h"

@interface FCAFieldsViewController ()

@end

@implementation FCAFieldsViewController {
    BOOL _isMetric;
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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    UIImage *image = [UIImage imageNamed:@"bg.png"];
//    self.tableView.backgroundView = nil;
//    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    _isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"Metric"];
    
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [[FCADataModel numberOfFields] intValue] ) {
        cell.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.1];
    }
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
        cell.spreadingEventLabel.text = [NSString stringWithFormat:@"%u", (unsigned)field.spreadingEvents.count];
        if (_isMetric) {
            cell.sizeLabel.text = [NSString stringWithFormat:@"%5.1f ha", field.sizeInHectares.doubleValue];
        } else {
            cell.sizeLabel.text = [NSString stringWithFormat:@"%5.1f acres", field.sizeInHectares.doubleValue*kACRES_PER_HECTARE];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfFields = [[FCADataModel numberOfFields] intValue];
    if (indexPath.row == numberOfFields) {
        return 80.0;
    } else {
        return  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 110 : 80;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"EditFieldSegue" sender:indexPath];
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
- (IBAction)doSetUnits:(id)sender {
    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"UNITS"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Metric", @"Imperial", nil];
    [as showFromToolbar:self.navigationController.toolbar];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //Metric
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Metric"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _isMetric = YES;
            [self.tableView reloadData];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Metric"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _isMetric = NO;
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewController* vc;
    vc = [segue destinationViewController];
    NSString* identifier = [segue identifier];
    
    if ([identifier isEqualToString:@"EditFieldSegue"]) {
        //EDIT - pass reference of managed object to destination controller
        FCAFieldInfoTableViewController* dest = (FCAFieldInfoTableViewController*)vc;
        NSIndexPath* indexPath = (NSIndexPath*)sender;
        dest.managedFieldObject = [[FCADataModel arrayOfFields] objectAtIndex:indexPath.row];
    }
    else if ([identifier isEqualToString:@"AddFieldSegue"]) {
        //Ensure the reference to the managed object is nil (signals a new entity)
        FCAFieldInfoTableViewController* dest = (FCAFieldInfoTableViewController*)vc;
        dest.managedFieldObject = nil;
    }
    else if ([identifier isEqualToString:@"ShowSpreadingEvent"]) {
        FCASpreadingEventViewController* dest = (FCASpreadingEventViewController*)vc;
        UITableViewCell* cell = (UITableViewCell*)sender;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        dest.fieldSelected = [[FCADataModel arrayOfFields] objectAtIndex:indexPath.row];
    }
    else if ([identifier isEqualToString:@"costs"]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            NSLog(@"TO DO - change size of popover");
            if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]){
                [[(UIStoryboardPopoverSegue *)segue popoverController] setPopoverContentSize:CGSizeMake(480, 640)];
            }
        }
        
    } else {
        NSLog(@"ERROR!");
    }
    
    //Turn off editing before the transition
    [self setEditing:FALSE animated:YES];
    
}

//Action button for sending data
- (IBAction)doActionButton:(id)sender {
    
    NSError* err;
    
    if ([MFMailComposeViewController canSendMail] == NO) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Cannot send email" message:@"You cannot send email from this device. Check your settings or device capabilities" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    
    NSMutableString* attachment = [NSMutableString string];
    BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"Metric"];
    
    [attachment appendString:@"Field name,Size,Size units,Soil,Crop,Manure,Date,N, P, K, Nutrient units,Spreading rate,Spreading rate units,Total Amount,Total units,Quality,Season,N Field Saving,P Field Saving,K Field Saving,N Unit price,P Unit price,K Unit price"];
    [attachment appendString:@"\n"];
    
    NSManagedObjectContext* moc = [FCADataModel managedObjectContext];
    
//    NSEntityDescription* ed = [NSEntityDescription entityForName:@"Field" inManagedObjectContext:moc];
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    fr.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSArray* fields = [moc executeFetchRequest:fr error:&err];
    for (Field* field in fields) {
        NSFetchRequest* fr_se = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
        fr_se.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        fr_se.predicate = [NSPredicate predicateWithFormat:@"field = %@", field];
        NSArray* spreadingEvents = [moc executeFetchRequest:fr_se error:&err];
        for (SpreadingEvent* se in spreadingEvents) {
            
            FCAAvailableNutrients* calc = [[FCAAvailableNutrients alloc] initWithSpreadingEvent:se];
            double fSize = se.field.sizeInHectares.doubleValue;
            NSNumber* N = [calc nitrogenAvailable];
            NSNumber* P = [calc phosphateAvailable];
            NSNumber* K = [calc potassiumAvailable];
            
            //Name
            [attachment appendString:[NSString stringWithFormat:@"%@,", field.name]];   //name
            
            //Field Size
            double fieldSize = (isMetric==YES) ? field.sizeInHectares.doubleValue : field.sizeInHectares.doubleValue*kACRES_PER_HECTARE;
            [attachment appendString:[NSString stringWithFormat:@"%5.1f,", fieldSize]];

            //Field size units
            [attachment appendString:(isMetric==YES) ? @"Ha," : @"Acres,"];

            //Soil type
            [attachment appendString:[NSString stringWithFormat:@"%@,", ((SoilType*)field.soilType).displayName]];
            
            //Crop type
            [attachment appendString:[NSString stringWithFormat:@"%@,", ((CropType*)field.cropType).displayName]];
            
            //Manure type
            [attachment appendString:[NSString stringWithFormat:@"%@,", se.manureType.displayName]];
             
            //Spreading date
            [attachment appendString:[NSString stringWithFormat:@"%@,", [se.date stringForUKShortFormatUsingGMT:NO] ]];
            
            //N,P,K
            [attachment appendString:[NSString stringWithFormat:@"%1.1f,", N.doubleValue]];
            [attachment appendString:[NSString stringWithFormat:@"%1.1f,", P.doubleValue]];
            [attachment appendString:[NSString stringWithFormat:@"%1.1f,", K.doubleValue]];
            
            //Nutrient units
            [attachment appendString:(isMetric==YES) ? @"Kg/Ha," : @"Units/Acre,"];
            
            //Spreading rate
            [attachment appendString:[NSString stringWithFormat:@"%@,", se.density]];
            
            //spreading rate units - TODO - sort this out
            NSString* rateAsString = [se rateAsStringUsingMetric:isMetric]; //%u %s
            char strUnits[64]; unsigned int rate;
            sscanf([rateAsString cStringUsingEncoding:NSUTF8StringEncoding],"%u %s", &rate, strUnits);
            [attachment appendString:[NSString stringWithFormat:@"%s,", strUnits]];
            
            //Total amount
            [attachment appendString:[NSString stringWithFormat:@"%lu,", se.density.longValue * field.sizeInHectares.longValue]];

            //Total amount units
            char strTop[64]; char strBottom[64];
            sscanf(strUnits, "%s/%s", strTop, strBottom);
            [attachment appendString:[NSString stringWithFormat:@"%s,", strTop]];
            
            //Quality
            [attachment appendString:[NSString stringWithFormat:@"%@,", se.manureQuality.name]];
            
            //Season
            [attachment appendString:[NSString stringWithFormat:@"%@,", se.date.seasonString]];
            
            //NPK savings
            double fN = N.doubleValue * fSize;
            double fP = N.doubleValue * fSize;
            double fK = K.doubleValue * fSize;
            double fCostN = [[NSUserDefaults standardUserDefaults] doubleForKey:@"NperKg"];
            double fCostP = [[NSUserDefaults standardUserDefaults] doubleForKey:@"PperKg"];
            double fCostK = [[NSUserDefaults standardUserDefaults] doubleForKey:@"KperKg"];
            [attachment appendString:[NSString stringWithFormat:@"£%1.2f,", fN*fCostN]];
            [attachment appendString:[NSString stringWithFormat:@"£%1.2f,", fP*fCostP]];
            [attachment appendString:[NSString stringWithFormat:@"£%1.2f,", fK*fCostK]];

            //NPK unit prices
            [attachment appendString:[NSString stringWithFormat:@"£%1.2f,", fCostN]];
            [attachment appendString:[NSString stringWithFormat:@"£%1.2f,", fCostP]];
            [attachment appendString:[NSString stringWithFormat:@"£%1.2f\n", fCostK]];
            
        }
    }
    
    //DEBUG
//    NSLog(@"%@", attachment);
    
    NSString* path = [NSBundle pathToFileInDocumentsFolder:@"fields.csv"];

    NSFileManager* fm = [NSFileManager defaultManager];
    [fm createFileAtPath:path contents:[attachment dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];

    UIImage* img = [UIImage imageNamed:@"logo"];
    NSData* imgData = UIImageJPEGRepresentation(img, 1.0);
    
    MFMailComposeViewController* vc = [[MFMailComposeViewController alloc] init];
    [vc setSubject:@"Field data from the FarmCrapApp"];
    [vc addAttachmentData:[attachment dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/csv" fileName:@"fields"];
    [vc addAttachmentData:imgData mimeType:@"image/jpeg" fileName:@"logo"];
    [vc setMailComposeDelegate:self];
    [self presentViewController:vc animated:YES completion:^(){ }];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//Change the name of this method to match the view controller you are using
- (IBAction)unwindToFieldsViewController:(UIStoryboardSegue*)sender
{
    
}
@end
