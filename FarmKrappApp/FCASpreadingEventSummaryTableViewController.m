//
//  FCASpreadingEventSummaryTableViewController.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 13/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCASpreadingEventSummaryTableViewController.h"
#import "NSDate+FCADateAndSeason.h"
#import "FCADataModel.h"

@interface FCASpreadingEventSummaryTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *seasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *cropLabel;
@property (weak, nonatomic) IBOutlet UILabel *soilLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;

@property (weak, nonatomic) IBOutlet UILabel *availableNLabel;
@property (weak, nonatomic) IBOutlet UILabel *availablePLabel;
@property (weak, nonatomic) IBOutlet UILabel *availableKLabel;
@property (weak, nonatomic) IBOutlet UILabel *costNLabel;
@property (weak, nonatomic) IBOutlet UILabel *costPLabel;
@property (weak, nonatomic) IBOutlet UILabel *costKLabel;


@end

@implementation FCASpreadingEventSummaryTableViewController

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
    BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"Metric"];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.typeLabel.text = self.spreadingEvent.manureType.displayName;
    self.dateLabel.text = [self.spreadingEvent.date stringForUKShortFormatUsingGMT:YES];
    self.amountLabel.text = [self.spreadingEvent rateAsStringUsingMetric:isMetric];
    self.qualityLabel.text = self.spreadingEvent.manureQuality.name;
    self.seasonLabel.text = [self.spreadingEvent.date seasonString];
    self.cropLabel.text = ((CropType*)self.spreadingEvent.field.cropType).displayName;
    self.soilLabel.text = ((SoilType*)self.spreadingEvent.field.soilType).displayName;
    if (isMetric) {
        self.sizeLabel.text = [NSString stringWithFormat:@"%@ ha", self.spreadingEvent.field.sizeInHectares];
    } else {
        self.sizeLabel.text = [NSString stringWithFormat:@"%5.1f acres", self.spreadingEvent.field.sizeInHectares.doubleValue*kACRES_PER_HECTARE];
    }
//    double totalAmount = self.spreadingEvent.density.doubleValue * self.spreadingEvent.field.sizeInHectares.doubleValue;
    self.totalAmountLabel.text = [self.spreadingEvent volumeAsStringUsingMetric:isMetric];
    
    FCAAvailableNutrients* calc = [[FCAAvailableNutrients alloc] initWithSpreadingEvent:self.spreadingEvent];
    double fSize = self.spreadingEvent.field.sizeInHectares.doubleValue;
    double fN = [calc nitrogenAvailable].doubleValue * fSize;
    double fP = [calc phosphateAvailable].doubleValue * fSize;
    double fK = [calc potassiumAvailable].doubleValue * fSize;
    
    self.availableNLabel.text = [FCAAvailableNutrients stringFormatForNutrientRate:[calc nitrogenAvailable]  usingMetric:isMetric];;
    self.availablePLabel.text = [FCAAvailableNutrients stringFormatForNutrientRate:[calc phosphateAvailable] usingMetric:isMetric];;
    self.availableKLabel.text = [FCAAvailableNutrients stringFormatForNutrientRate:[calc potassiumAvailable] usingMetric:isMetric];;
    
    double fCostN = [[NSUserDefaults standardUserDefaults] doubleForKey:@"NperKg"];
    double fCostP = [[NSUserDefaults standardUserDefaults] doubleForKey:@"PperKg"];
    double fCostK = [[NSUserDefaults standardUserDefaults] doubleForKey:@"KperKg"];
    
    self.costNLabel.text = [NSString stringWithFormat:@"£%5.2f", fCostN * fN];
    self.costPLabel.text = [NSString stringWithFormat:@"£%5.2f", fCostP * fP];
    self.costKLabel.text = [NSString stringWithFormat:@"£%5.2f", fCostK * fK];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
