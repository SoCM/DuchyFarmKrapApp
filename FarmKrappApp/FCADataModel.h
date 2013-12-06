//
//  FCADataModel.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 06/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//
// PURE CLASS - NO iVars

#import <Foundation/Foundation.h>
#import "SoCMAppDelegate.h"
#import "Field.h"
#import "SpreadingEvent.h"

//Constants
#define kSOILTYPE_SANDY_SHALLOW @1
#define kSOILTYPE_MEDIUM_HEAVY  @2

#define kCROPTYPE_ALL_CROPS @1
#define kCROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAP @2

#define kMANURETYPE_CATTLE_SLURRY @1
#define kMANURETYPE_FARMYARD_MANURE @2
#define kMANURETYPE_PIG_SLURRY @3
#define kMANURETYPE_POULTRY_LITTER @4

#define kMANUREQUALITY_THIN_SOUP @1
#define kMANUREQUALITY_THICK_SOUP @2
#define kMANUREQUALITY_PORRIGDE @3


@interface FCADataModel : NSObject

+(NSManagedObjectContext*)managedObjectContext;
+(NSManagedObjectModel*)managedObjectModel;
+(NSPersistentStoreCoordinator*)persistentStoreCoordinator;
+(void)saveContext;

@end
