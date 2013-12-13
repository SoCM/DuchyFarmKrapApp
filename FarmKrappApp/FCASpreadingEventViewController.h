//
//  FCASpreadingEventViewController.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 13/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCADataModel.h"
#import "FCASpreadingEventCell.h"

@interface FCASpreadingEventViewController : UITableViewController

@property(readwrite, nonatomic, strong) Field* fieldSelected;

@end
