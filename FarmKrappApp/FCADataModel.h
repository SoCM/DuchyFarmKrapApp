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

#pragma mark - Enumerated
//ENUMERATED TYPES - ALLOWING FOR SUBCATEGORIES TO BE ADDED LATER
typedef enum {SANDY_SHALLOW=100, MEDIUM_HEAVY=200} SOIL_TYPE;
typedef enum {ALL_CROPS=100, GRASSLAND_OR_WINTER_OILSEED_RAPE=200} CROP_TYPE;
typedef enum {CATTLE_SLURRY=100, FARMYARD_MANURE=200, PIG_SLURRY=300, POULTRY_LITTER=400} MANURE_TYPE;
typedef enum {THIN_SOUP=100, THICK_SOUP=200, PORRIGDE=300} MANURE_QUALITY;

#pragma mark - Constants
//CONSTANT NSNUMBER WRAPPERS AROUND ENUMERATED TYPES
#define kSOILTYPE_SANDY_SHALLOW [NSNumber numberWithInt:(SOIL_TYPE)SANDY_SHALLOW]
#define kSOILTYPE_MEDIUM_HEAVY  [NSNumber numberWithInt:(SOIL_TYPE)MEDIUM_HEAVY]

#define kCROPTYPE_ALL_CROPS                         [NSNumber numberWithInt:(CROP_TYPE)ALL_CROPS]
#define kCROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE  [NSNumber numberWithInt:(CROP_TYPE)GRASSLAND_OR_WINTER_OILSEED_RAPE]

#define kMANURETYPE_CATTLE_SLURRY   [NSNumber numberWithInt:(MANURE_TYPE)CATTLE_SLURRY]
#define kMANURETYPE_FARMYARD_MANURE [NSNumber numberWithInt:(MANURE_TYPE)FARMYARD_MANURE]
#define kMANURETYPE_PIG_SLURRY      [NSNumber numberWithInt:(MANURE_TYPE)PIG_SLURRY]
#define kMANURETYPE_POULTRY_LITTER  [NSNumber numberWithInt:(MANURE_TYPE)POULTRY_LITTER]

#define kMANUREQUALITY_THIN_SOUP    [NSNumber numberWithInt:(MANURE_QUALITY)THIN_SOUP]
#define kMANUREQUALITY_THICK_SOUP   [NSNumber numberWithInt:(MANURE_QUALITY)THICK_SOUP]
#define kMANUREQUALITY_PORRIGDE     [NSNumber numberWithInt:(MANURE_QUALITY)PORRIGDE]

#pragma mark - Category on Field
//Category on Field
@interface Field (FCADataModel)
- (id)initWithDefaults;
+(id)FieldWithName:(NSString*)nameString soilType:(SOIL_TYPE)soil_type cropType:(CROP_TYPE)crop_type sizeInHectares:(NSNumber*)size;
@end

#pragma mark - Category on SpreadingEvent
//Category on Spreading Event
@interface SpreadingEvent (FCADataModel)
+(SpreadingEvent*)spreadingEventWithDate:(NSDate*)date manureType:(MANURE_TYPE)manure_type quality:(MANURE_QUALITY)manure_quality density:(NSNumber*)manure_density;
- (id)initWithDefaults;
@end

#pragma mark - FCADataModel CLASS
//DATA MODEL WRAPPER CLASS
@interface FCADataModel : NSObject
//MODEL API
#pragma mark - Field
+(void)addNewField:(Field*)field;
+(void)updateField:(Field*)oldField withNewFieldData:(Field*)newField;
+(void)removeField:(Field*)field;
+(NSArray*)arrayOfFields;
+(NSArray*)arrayOfFieldsWithSortString:(NSString*)predicateString;
+(NSNumber*)numberOfFields;
#pragma mark - SpreadingEvent
+(void)addNewSpreadingEvent:(SpreadingEvent*)spreadingEvent toField:(Field*)field;
+(void)updateSpreadingEvent:(SpreadingEvent*)oldSpreadingEvent toNewSpreadingEvent:(SpreadingEvent*)newSpreadingEvent;
+(void)removeSpreadingEvent:spreadingEvent;
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field;
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field withSortString:(NSString*)predicateString;
+(NSNumber*)numberOfSpreadingEventsForField:(Field*)field;

#pragma mark - CoreData Convenience Methods
//CORE DATA Convenience Methods
+(NSManagedObjectContext*)managedObjectContext;
+(NSManagedObjectModel*)managedObjectModel;
+(NSPersistentStoreCoordinator*)persistentStoreCoordinator;
+(void)saveContext;

@end
