//
//  FCASpreadingEventSummaryTableViewController.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 13/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCADataModel.h"
#import "SpreadingEvent.h"

@interface FCASpreadingEventSummaryTableViewController : UITableViewController

@property(readwrite, nonatomic, strong) SpreadingEvent* managedObject;

@end
