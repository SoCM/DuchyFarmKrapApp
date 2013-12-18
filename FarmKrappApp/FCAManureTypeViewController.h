//
//  FCAManureTypeViewController.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 18/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCADataModel.h"

@interface FCAManureTypeViewController : UITableViewController
@property (readwrite,nonatomic, copy) void(^callBackBlock)(ManureType*, ManureQuality*);
@end
