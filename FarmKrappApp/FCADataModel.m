//
//  FCADataModel.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 06/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCADataModel.h"

//Singleton Application Delegate
#define FCA_APP_DELEGATE (SoCMAppDelegate*)[[UIApplication sharedApplication] delegate]


#pragma mark - Category on Field
//******************
//CATEGORY ON FIELD*
//******************

@implementation SoilType (FCADataModel)
+(SoilType*)FetchSoilTypeForID:(NSNumber*)seqID
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"SoilType"];
    fr.predicate = [NSPredicate predicateWithFormat:@"seqID == %@", seqID];
    return ([[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] objectAtIndex:0]);
}
@end

@implementation CropType (FCADataModel)
+(CropType*)FetchCropTypeForID:(NSNumber*)seqID
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"CropType"];
    fr.predicate = [NSPredicate predicateWithFormat:@"seqID == %@", seqID];
    return ([[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] objectAtIndex:0]);
}
@end

@implementation ManureType (FCADataModel)
+(ManureType*)FetchManureTypeForStringID:(NSString*)stringID
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"ManureType"];
    fr.predicate = [NSPredicate predicateWithFormat:@"stringID == %@", stringID];
    return ([[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] objectAtIndex:0]);
}
+(NSUInteger)count
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"ManureType"];
    return ([[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] count]);    
}
+(NSArray*)allManagedObjectsSortedByName
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"ManureType"];
    fr.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES] ];
    NSArray* res = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    return res;
}

@end

@implementation ManureQuality (FCADataModel)
+(ManureQuality*)FetchManureQualityForID:(NSNumber*)seqID
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"ManureQuality"];
    fr.predicate = [NSPredicate predicateWithFormat:@"seqID == %@", seqID];
    return ([[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] objectAtIndex:0]);
}
+(NSArray*)allSortedManagedObjectsForManureType:(ManureType*)mt
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"ManureQuality"];
    fr.predicate = [NSPredicate predicateWithFormat:@"manureType == %@", mt];
    fr.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"seqID" ascending:YES] ];
    NSArray* res = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    return res;
}
@end

@implementation Field (FCADataModel)

+(id)InsertFieldWithName:(NSString*)nameString soilType:(SoilType*)soil_type cropType:(CropType*)crop_type sizeInHectares:(NSNumber*)size
{
    
    NSEntityDescription* ed = [NSEntityDescription entityForName:@"Field" inManagedObjectContext:[FCA_APP_DELEGATE managedObjectContext]];
    Field* field = [[Field alloc] initWithEntity:ed insertIntoManagedObjectContext:[FCA_APP_DELEGATE managedObjectContext]];
    if (field) {
        field.name = nameString;
        field.soilType = soil_type;
        field.cropType = crop_type;
        field.sizeInHectares = size;
        [FCA_APP_DELEGATE saveContext];
    }
    return field;
}

-(NSArray*)arrayOfSpreadingEvents
{
    return [FCADataModel arrayOfSpreadingEventsForField:self];
}
@end

#pragma mark - Category on Spreading Event
//****************************
//CATEGORY ON SPREADING EVENT*
//****************************
@implementation SpreadingEvent (FCADataModel)

+(SpreadingEvent*)InsertSpreadingEventWithDate:(NSDate*)date manureType:(ManureType*)manure_type quality:(ManureQuality*)manure_quality density:(NSNumber*)manure_density
{
    NSEntityDescription* ed = [NSEntityDescription entityForName:@"SpreadingEvent" inManagedObjectContext:[FCA_APP_DELEGATE managedObjectContext]];
    SpreadingEvent* se = [[SpreadingEvent alloc] initWithEntity:ed insertIntoManagedObjectContext:[FCA_APP_DELEGATE managedObjectContext]];
    if (se) {
        se.date = date;
        se.manureType = manure_type;
        se.manureQuality = manure_quality;
        se.density = manure_density;
        [FCA_APP_DELEGATE saveContext];
    }
    return se;
}
-(NSArray*)arrayOfPhotos
{
    return [FCADataModel arrayOfPhotosForSpreadingEvent:self];
}
@end

#pragma mark - Category on Photo
//*******************
//CATEGORY ON PHOTO *
//*******************
@implementation Photo (FCADataModel)

+(Photo*)InsertPhotoWithImageData:(NSData*)imageData onDate:(NSDate*)date
{
    NSEntityDescription* ed = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:[FCA_APP_DELEGATE managedObjectContext]];
    Photo *ph = [[Photo alloc] initWithEntity:ed insertIntoManagedObjectContext:[FCA_APP_DELEGATE managedObjectContext]];
    ph.date = date;
    ph.photo = imageData;
    [FCA_APP_DELEGATE saveContext];
    return ph;
}
+(NSData*)imageDataForPhoto:(Photo*)photo
{
    return photo.photo;
}

@end




#pragma mark - DataModel Wrapper Class Methods - Field
//*************************
//DATA MODEL WRAPPER CLASS*
//*************************
@implementation FCADataModel


// Fields
+(id)addNewFieldWithName:(NSString*)nameString soilType:(SoilType*)soil_type cropType:(CropType*)crop_type sizeInHectares:(NSNumber*)size
{
    Field* result = [Field InsertFieldWithName:nameString soilType:soil_type cropType:crop_type sizeInHectares:size];
    [FCA_APP_DELEGATE saveContext];
    return result;
}
+(void)removeField:(Field*)field
{  
    [[FCA_APP_DELEGATE managedObjectContext] deleteObject:field];
    [FCA_APP_DELEGATE saveContext];
}
+(NSArray*)arrayOfFields
{
    return [FCADataModel arrayOfFieldsWithSortString:@"name"];
}
+(NSArray*)arrayOfFieldsWithSortString:(NSString*)sortString
{
    return [FCADataModel arrayOfFieldsWithSortString:sortString andPredicateString:nil];
}
+(NSArray*)arrayOfFieldsWithSortString:(NSString*)sortString andPredicateString:(NSString*)predicateString
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    fr.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:sortString ascending:YES] ];
    fr.predicate = [NSPredicate predicateWithFormat:predicateString];
    NSArray * result = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    return result;
}
+(NSNumber*)numberOfFields
{
    return [NSNumber numberWithInt:[[FCADataModel arrayOfFields]count]];

}

#pragma mark - DataModel Wrapper Class Methods - Spreading Events

// Spreading events
+(id)addNewSpreadingEventWithDate:(NSDate*)date manureType:(ManureType*)manure_type quality:(ManureQuality*)manure_quality density:(NSNumber*)manure_density toField:(Field*)field
{
    SpreadingEvent* result = [SpreadingEvent InsertSpreadingEventWithDate:date
                                                               manureType:manure_type
                                                                  quality:manure_quality
                                                                  density:manure_density];
    [field addSpreadingEvents:[NSSet setWithObject:result]];
    [FCA_APP_DELEGATE saveContext];
    return result;
}
+(void)removeSpreadingEvent:(SpreadingEvent*)spreadingEvent
{
    //Remove from the field
    [[FCA_APP_DELEGATE managedObjectContext] deleteObject:spreadingEvent];    
    [FCA_APP_DELEGATE saveContext];
}
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field
{
    return [FCADataModel arrayOfSpreadingEventsForField:field withSortString:@"date"];
}
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field withSortString:(NSString*)sortString
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    fr.predicate = [NSPredicate predicateWithFormat:@"field == %@", field];
    fr.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:sortString ascending:YES] ];
    NSArray* result = [[FCA_APP_DELEGATE managedObjectContext] executeFetchRequest:fr error:&err];
    return result;
}
+(NSNumber*)numberOfSpreadingEventsForField:(Field*)field
{
    NSInteger N = [[self arrayOfSpreadingEventsForField:field] count];
    return [NSNumber numberWithInt:N];
}

#pragma mark - DataModel Wrapper Class Methods - Photo
+(void)addImageData:(NSData*)image toSpreadingEvent:(SpreadingEvent*)se onDate:(NSDate*)date
{
    Photo* photo = [Photo InsertPhotoWithImageData:image onDate:date];
    [se addPhotos:[NSSet setWithObject:photo]];
    [FCADataModel saveContext];
}
+(void)removeImageData:(NSData*)image fromSpreadingEvent:(SpreadingEvent*)se
{
    //Fetch the matching image
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    fr.predicate = [NSPredicate predicateWithFormat:@"photo == %@", image];
    NSArray* array = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    Photo* photoToBeDeleted = (Photo*)array[0];
    [[FCADataModel managedObjectContext] deleteObject:photoToBeDeleted];
    [FCADataModel saveContext];
}
+(NSArray*)arrayOfPhotosForSpreadingEvent:(SpreadingEvent*)se
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    fr.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES] ];
    fr.predicate = [NSPredicate predicateWithFormat:@"spreadingEvent == %@", se];
    NSArray* arrayOfPhotos = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    //Extract the array of imageData
    return [arrayOfPhotos valueForKeyPath:@"photo"];
}
+(NSNumber*)numberOfPhotosForSpreadingEvent:(SpreadingEvent*)se
{
    return ([NSNumber numberWithInteger:se.photos.count]);
}

#pragma mark - CORE DATA Convenience Methods

//****************************
// CORE DATA OBJECTS AND API *
//****************************

// Singleton ManagedObjectContext (CoreData singleton object)
+(NSManagedObjectContext*)managedObjectContext
{
    //Singleton managed object context
    return [FCA_APP_DELEGATE managedObjectContext];
}

+(NSManagedObjectModel*)managedObjectModel
{
    //Singleton managed object model (mom)
    return [FCA_APP_DELEGATE managedObjectModel];
}

+(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    //Singleton persistent store coordinator
    return [FCA_APP_DELEGATE persistentStoreCoordinator];
}

+(void)saveContext
{    
    //Save to persistent store
    [FCA_APP_DELEGATE saveContext];
}
@end
