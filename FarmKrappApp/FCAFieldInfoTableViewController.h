//
//  FCAFieldInfoTableViewController.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 10/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCADataModel.h"
#import "Field.h"

@interface FCAFieldInfoTableViewController : UITableViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
@property (weak, nonatomic) IBOutlet UISegmentedControl *soilTypeSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cropTypeSegmentControl;
@property (weak, nonatomic) IBOutlet UILabel *fieldSizeLabel;
@property (weak, nonatomic) IBOutlet UIStepper *fieldSizeStepper;
@property (weak, nonatomic) IBOutlet UISlider *fieldSizeSlider;
- (IBAction)doSave:(id)sender;

//Temporary holding properties
@property(readwrite, nonatomic, strong) NSString* name;
@property(readwrite, nonatomic, assign) SOIL_TYPE soilType;
@property(readwrite, nonatomic, assign) CROP_TYPE cropType;
@property(readwrite, nonatomic, assign) float fieldSize;

//Master copy
@property(readwrite, nonatomic, strong) Field* managedFieldObject;

@end
