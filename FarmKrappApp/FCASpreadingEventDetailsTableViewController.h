//
//  FCASpreadingEventInfoTableViewController.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 13/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpreadingEvent.h"
#import "Field.h"
#import "FCADataModel.h"
 
@interface FCASpreadingEventDetailsTableViewController : UITableViewController

@property(readwrite, nonatomic, strong) NSManagedObject* managedObject;
@end
