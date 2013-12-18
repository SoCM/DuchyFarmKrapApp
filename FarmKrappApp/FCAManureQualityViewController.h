//
//  FCAManureQualityViewController.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 18/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCADataModel.h"


@interface FCAManureQualityViewController : UITableViewController
@property (readwrite, nonatomic, strong) ManureType* selectedManureType;
@end
