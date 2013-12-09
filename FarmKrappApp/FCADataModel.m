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
@implementation Field (FCADataModel)

+(id)InsertFieldWithName:(NSString*)nameString soilType:(SOIL_TYPE)soil_type cropType:(CROP_TYPE)crop_type sizeInHectares:(NSNumber*)size
{
    NSEntityDescription* ed = [NSEntityDescription entityForName:@"Field" inManagedObjectContext:[FCA_APP_DELEGATE managedObjectContext]];
    Field* field = [[Field alloc] initWithEntity:ed insertIntoManagedObjectContext:[FCA_APP_DELEGATE managedObjectContext]];
    if (field) {
        field.name = nameString;
        field.soilType = [NSNumber numberWithInt:soil_type];
        field.cropType = [NSNumber numberWithInt:crop_type];
        field.sizeInHectares = size;
    }
    return field;
}
@end

#pragma mark - Category on Spreading Event
//****************************
//CATEGORY ON SPREADING EVENT*
//****************************
@implementation SpreadingEvent (FCADataModel)

+(SpreadingEvent*)InsertSpreadingEventWithDate:(NSDate*)date manureType:(MANURE_TYPE)manure_type quality:(MANURE_QUALITY)manure_quality density:(NSNumber*)manure_density
{
    NSEntityDescription* ed = [NSEntityDescription entityForName:@"SpreadingEvent" inManagedObjectContext:[FCA_APP_DELEGATE managedObjectContext]];
    SpreadingEvent* se = [[SpreadingEvent alloc] initWithEntity:ed insertIntoManagedObjectContext:[FCA_APP_DELEGATE managedObjectContext]];
    if (se) {
        se.date = date;
        se.manureType = [NSNumber numberWithInt:manure_type];
        se.quality = [NSNumber numberWithInt:manure_quality];
        se.density = manure_density;
    }
    return se;
}
@end


//
// NOTE TO SELF:
//
//    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
//    [fr setSortDescriptors:@[@"name"]];
//    [fr setPredicate:[NSPredicate predicateWithFormat:@"name = Top"]];
//    NSArray* result = [self.managedObjectContext executeFetchRequest:fr error:&err];




#pragma mark - DataModel Wrapper Class Methods - Field
//*************************
//DATA MODEL WRAPPER CLASS*
//*************************
@implementation FCADataModel

// Fields
+(id)addNewFieldWithName:(NSString*)nameString soilType:(SOIL_TYPE)soil_type cropType:(CROP_TYPE)crop_type sizeInHectares:(NSNumber*)size
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
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    NSArray* result = [[FCA_APP_DELEGATE managedObjectContext] executeFetchRequest:fr error:&err];
    return result;
}
+(NSArray*)arrayOfFieldsWithSortString:(NSString*)predicateString
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    fr.predicate = [NSPredicate predicateWithFormat:predicateString];
    NSArray* result = [[FCA_APP_DELEGATE managedObjectContext] executeFetchRequest:fr error:&err];
    
    return result;
}
+(NSNumber*)numberOfFields
{
    return [NSNumber numberWithInt:[[FCADataModel arrayOfFields]count]];

}

#pragma mark - DataModel Wrapper Class Methods - Spreading Events

// Spreading events
+(id)addNewSpreadingEventWithDate:(NSDate*)date manureType:(MANURE_TYPE)manure_type quality:(MANURE_QUALITY)manure_quality density:(NSNumber*)manure_density toField:(Field*)field
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
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    fr.predicate = [NSPredicate predicateWithFormat:@"field == %@", field];
    NSArray* result = [[FCA_APP_DELEGATE managedObjectContext] executeFetchRequest:fr error:&err];
    return result;
}
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field withSortString:(NSString*)predicateString
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    fr.predicate = [NSPredicate predicateWithFormat:@"field == %@", field];
    fr.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES] ];
    NSArray* result = [[FCA_APP_DELEGATE managedObjectContext] executeFetchRequest:fr error:&err];
    return result;
}
+(NSNumber*)numberOfSpreadingEventsForField:(Field*)field
{
    return nil;
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
