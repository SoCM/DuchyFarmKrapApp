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
#import "SoilType.h"
#import "CropType.h"
#import "Field.h"
#import "ManureType.h"
#import "ManureQuality.h"
#import "Photo.h"
#import "SpreadingEvent.h"
#import "NSDate+FCADateAndSeason.h"

#pragma mark - FCAAvailableNutrients class
//Class for calculating NPK values efficiently.
@interface FCAAvailableNutrients : NSObject <NSObject>

- (id)initWithSpreadingEvent:(SpreadingEvent*)se;

//Available nutrient for a given spreading event
-(NSNumber*)nitrogenAvailable;
-(NSNumber*)phosphateAvailable;
-(NSNumber*)potassiumAvailable;

//Available nutrient for a given spreading event given a different rate
-(NSNumber*)nitrogenAvailableForRate:(NSNumber*) rate;
-(NSNumber*)phosphateAvailableForRate:(NSNumber*) rate;
-(NSNumber*)potassiumAvailableForRate:(NSNumber*) rate;

//Formatting convenience method
+(NSString*)stringFormatForNutrientRate:(NSNumber*)rate usingMetric:(BOOL)isMetric;

@end

#pragma mark - Enumerated
//ENUMERATED TYPES - ALLOWING FOR SUBCATEGORIES TO BE ADDED LATER
typedef enum {SOILTYPE_SANDY_SHALLOW=100, SOILTYPE_MEDIUM_HEAVY=200} SOIL_TYPE;
typedef enum {CROPTYPE_ALL_CROPS=100, CROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE=200} CROP_TYPE;
typedef enum {CS_DM2=100, CS_DM6=200, CS_DM10=300, FYM_OLDSURF=400, FYM_FRSURF=500, FYM_OLDINC=600, FYM_FRINC=700, PS_DM2=800, PS_DM4=900, PS_DM6=1000, PL_LAY=1100, PL_BROI=1200} QUAL_KEY;
//typedef enum {AUTUMN, WINTER, SPRING, SUMMER} SEASON;

#pragma mark - Constants

//CONSTANT NSNUMBER WRAPPERS AROUND ENUMERATED TYPES
// TO DO - I WANT TO GET RID OF THESE!!!!
#define kSOILTYPE_SANDY_SHALLOW [NSNumber numberWithInt:(SOIL_TYPE)SOILTYPE_SANDY_SHALLOW]
#define kSOILTYPE_MEDIUM_HEAVY [NSNumber numberWithInt:(SOIL_TYPE)SOILTYPE_MEDIUM_HEAVY]

#define kCROPTYPE_ALL_CROPS [NSNumber numberWithInt:(CROP_TYPE)CROPTYPE_ALL_CROPS]
#define kCROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE [NSNumber numberWithInt:(CROP_TYPE)CROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE]

#define kACRES_PER_HECTARE 2.47105

#pragma mark - Category on Field
//Category on SoilType
@interface SoilType (FCADataModel)
+(SoilType*)FetchSoilTypeForID:(NSNumber*)seqID;
@end

//Category on CropType
@interface CropType (FCADataModel)
+(CropType*)FetchCropTypeForID:(NSNumber*)seqID;
@end

//Category on ManureType
@interface ManureType (FCADataModel)
+(ManureType*)FetchManureTypeForStringID:(NSString*)stringID;
+(NSUInteger)count;
+(NSArray*)allManagedObjectsSortedByName;
@end

//Category on ManureQuality
@interface ManureQuality (FCADataModel)
+(ManureQuality*)FetchManureQualityForID:(NSNumber*)seqID;
+(NSArray*)allSortedManagedObjectsForManureType:(ManureType*)mt;
@end

//Category on Field
@interface Field (FCADataModel)
+(id)InsertFieldWithName:(NSString*)nameString soilType:(SoilType*)soil_type cropType:(CropType*)crop_type sizeInHectares:(NSNumber*)size;
-(NSArray*)arrayOfSpreadingEvents;
@end

#pragma mark - Category on SpreadingEvent
//Category on Spreading Event
@interface SpreadingEvent (FCADataModel)
+(SpreadingEvent*)InsertSpreadingEventWithDate:(NSDate*)date manureType:(ManureType*)manure_type quality:(ManureQuality*)manure_quality density:(NSNumber*)manure_density;
-(NSArray*)arrayOfPhotos;
-(NSString*)rateAsStringUsingMetric:(BOOL)isMetric;
-(NSString*)volumeAsStringUsingMetric:(BOOL)isMetric;
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
+(id)addNewFieldWithName:(NSString*)nameString soilType:(SoilType*)soil_type cropType:(CropType*)crop_type sizeInHectares:(NSNumber*)size;
+(void)removeField:(Field*)field;
+(NSArray*)arrayOfFields;
+(NSArray*)arrayOfFieldsWithSortString:(NSString*)sortString;
+(NSArray*)arrayOfFieldsWithSortString:(NSString*)sortString andPredicateString:(NSString*)predicateString;
+(NSNumber*)numberOfFields;

#pragma mark - SpreadingEvent
+(id)addNewSpreadingEventWithDate:(NSDate*)date manureType:(ManureType*)manure_type quality:(ManureQuality*)manure_quality density:(NSNumber*)manure_density toField:(Field*)field;
+(void)removeSpreadingEvent:spreadingEvent;
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field;
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field withSortString:(NSString*)sortString;
+(NSDictionary*)availableNutrients100m3;
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

#pragma mark - image selection
+(NSString*)imageNameForManureType:(ManureType*)mt andRate:(NSNumber*)rate;

@end
