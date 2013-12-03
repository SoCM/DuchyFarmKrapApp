//
//  SoCMViewControllerCommonBase.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 03/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoCMViewControllerCommonBase : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
