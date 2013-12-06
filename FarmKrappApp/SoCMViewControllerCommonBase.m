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
#import "FCADataModel.h"

@interface SoCMViewControllerCommonBase ()

@end

@implementation SoCMViewControllerCommonBase
@synthesize managedObjectContext = _managedObjectContext;


//************
// CORE DATA *
//************

// Lazy-Read Accessor for Singleton ManagedObjectContext (CoreData singleton object)
-(NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext == nil) {
        
        //Singleton managed object context
        self.managedObjectContext = [FCADataModel managedObjectContext];
    }
    return _managedObjectContext;
}

@end
