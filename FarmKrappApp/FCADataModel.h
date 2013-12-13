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
#import "Photo.h"

#pragma mark - Enumerated
//ENUMERATED TYPES - ALLOWING FOR SUBCATEGORIES TO BE ADDED LATER
typedef enum {SOILTYPE_SANDY_SHALLOW=100, SOILTYPE_MEDIUM_HEAVY=200} SOIL_TYPE;
typedef enum {CROPTYPE_ALL_CROPS=100, CROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE=200} CROP_TYPE;
typedef enum {MANURETYPE_CATTLE_SLURRY=100, MANURETYPE_FARMYARD_MANURE=200, MANURETYPE_PIG_SLURRY=300, MANURETYPE_POULTRY_LITTER=400} MANURE_TYPE;
typedef enum {MANUREQUALITY_THIN_SOUP=100, MANUREQUALITY_THICK_SOUP=200, MANUREQUALITY_PORRIGDE=300} MANURE_QUALITY;

#pragma mark - Constants
//CONSTANT NSNUMBER WRAPPERS AROUND ENUMERATED TYPES
#define kSOILTYPE_SANDY_SHALLOW [NSNumber numberWithInt:(SOIL_TYPE)SOILTYPE_SANDY_SHALLOW]
#define kSOILTYPE_MEDIUM_HEAVY  [NSNumber numberWithInt:(SOIL_TYPE)SOILTYPE_MEDIUM_HEAVY]
#define SOILTYPE_STRING_DICT [NSDictionary dictionaryWithObjectsAndKeys:@"Sandy Shallow",kSOILTYPE_SANDY_SHALLOW,@"Medium Heavy",kSOILTYPE_MEDIUM_HEAVY,nil]

#define kCROPTYPE_ALL_CROPS                         [NSNumber numberWithInt:(CROP_TYPE)CROPTYPE_ALL_CROPS]
#define kCROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE  [NSNumber numberWithInt:(CROP_TYPE)CROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE]
#define CROPTYPE_STRING_DICT [NSDictionary dictionaryWithObjectsAndKeys:@"All Crops",kCROPTYPE_ALL_CROPS,@"Grassland or Winter Oilseed Rape",kCROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE,nil]

#define kMANURETYPE_CATTLE_SLURRY   [NSNumber numberWithInt:(MANURE_TYPE)MANURETYPE_CATTLE_SLURRY]
#define kMANURETYPE_FARMYARD_MANURE [NSNumber numberWithInt:(MANURE_TYPE)MANURETYPE_FARMYARD_MANURE]
#define kMANURETYPE_PIG_SLURRY      [NSNumber numberWithInt:(MANURE_TYPE)MANURETYPE_PIG_SLURRY]
#define kMANURETYPE_POULTRY_LITTER  [NSNumber numberWithInt:(MANURE_TYPE)MANURETYPE_POULTRY_LITTER]
#define MANURETYPE_STRING_DICT [NSDictionary dictionaryWithObjectsAndKeys:@"Cattle Slurry",kMANURETYPE_CATTLE_SLURRY, @"Farmyard Manure", kMANURETYPE_FARMYARD_MANURE, @"Pig Slurry", kMANURETYPE_PIG_SLURRY, @"Poultry Litter", kMANURETYPE_POULTRY_LITTER, nil]

#define kMANUREQUALITY_THIN_SOUP    [NSNumber numberWithInt:(MANURE_QUALITY)MANUREQUALITY_THIN_SOUP]
#define kMANUREQUALITY_THICK_SOUP   [NSNumber numberWithInt:(MANURE_QUALITY)MANUREQUALITY_THICK_SOUP]
#define kMANUREQUALITY_PORRIGDE     [NSNumber numberWithInt:(MANURE_QUALITY)MANUREQUALITY_PORRIGDE]
#define MANUREQUALITY_STRING_DICT [NSDictionary dictionaryWithObjectsAndKeys:@"Thin Soup", kMANUREQUALITY_THIN_SOUP, @"Thick Soup", kMANUREQUALITY_THICK_SOUP, @"Porridge", kMANUREQUALITY_PORRIGDE, nil]

#define kACRES_PER_HECTARE 2.47105

#pragma mark - Category on Field
//Category on Field
@interface Field (FCADataModel)
+(id)InsertFieldWithName:(NSString*)nameString soilType:(SOIL_TYPE)soil_type cropType:(CROP_TYPE)crop_type sizeInHectares:(NSNumber*)size;
-(NSArray*)arrayOfSpreadingEvents;
@end

#pragma mark - Category on SpreadingEvent
//Category on Spreading Event
@interface SpreadingEvent (FCADataModel)
+(SpreadingEvent*)InsertSpreadingEventWithDate:(NSDate*)date manureType:(MANURE_TYPE)manure_type quality:(MANURE_QUALITY)manure_quality density:(NSNumber*)manure_density;
-(NSArray*)arrayOfPhotos;
@end

#pragma mark - Category on Photo
//Category on Photo
@interface Photo (FCADataModel)
+(Photo*)InsertPhotoWithImageData:(NSData*)imageData onDate:(NSDate*)date;
+(NSData*)imageDataForPhoto:(Photo*)photo;
@end

#pragma mark - FCADataModel CLASS
//DATA MODEL WRAPPER CLASS
@interface FCADataModel : NSObject
//MODEL API
#pragma mark - Field
+(id)addNewFieldWithName:(NSString*)nameString soilType:(SOIL_TYPE)soil_type cropType:(CROP_TYPE)crop_type sizeInHectares:(NSNumber*)size;
+(void)removeField:(Field*)field;
+(NSArray*)arrayOfFields;
+(NSArray*)arrayOfFieldsWithSortString:(NSString*)sortString;
+(NSArray*)arrayOfFieldsWithSortString:(NSString*)sortString andPredicateString:(NSString*)predicateString;
+(NSNumber*)numberOfFields;
#pragma mark - SpreadingEvent
+(id)addNewSpreadingEventWithDate:(NSDate*)date manureType:(MANURE_TYPE)manure_type quality:(MANURE_QUALITY)manure_quality density:(NSNumber*)manure_density toField:(Field*)field;
+(void)removeSpreadingEvent:spreadingEvent;
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field;
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field withSortString:(NSString*)sortString;

+(NSNumber*)numberOfSpreadingEventsForField:(Field*)field;
#pragma mark - Photo
+(void)addImageData:(NSData*)image toSpreadingEvent:(SpreadingEvent*)se onDate:(NSDate*)date;
+(void)removeImageData:(NSData*)image fromSpreadingEvent:(SpreadingEvent*)se;
+(NSArray*)arrayOfPhotosForSpreadingEvent:(SpreadingEvent*)se;
+(NSNumber*)numberOfPhotosForSpreadingEvent:(SpreadingEvent*)se;

#pragma mark - CoreData Convenience Methods
//CORE DATA Convenience Methods
+(NSManagedObjectContext*)managedObjectContext;
+(NSManagedObjectModel*)managedObjectModel;
+(NSPersistentStoreCoordinator*)persistentStoreCoordinator;
+(void)saveContext;

@end
