//
//  SoCMViewControllerCommonBase.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 03/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//
// THIS CODE IS COMMON TO MANY/ALL VIEW CONTROLLERS
// Provides:
//  Accessor to Singleton CoreData managedobjectcontext


#import "SoCMViewControllerCommonBase.h"
#import "SoCMAppDelegate.h"

@interface SoCMViewControllerCommonBase ()

@end

@implementation SoCMViewControllerCommonBase
@synthesize managedObjectContext = _managedObjectContext;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}





//************
// CORE DATA *
//************

// Lazy-Read Accessor for Singleton ManagedObjectContext (CoreData singleton object)
-(NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext == nil) {
        
        //Singleton Application Delegate
        SoCMAppDelegate* ad = [[UIApplication sharedApplication] delegate];
        
        //Singleton managed object context
        self.managedObjectContext = [ad managedObjectContext];
    }
    return _managedObjectContext;
}

@end
