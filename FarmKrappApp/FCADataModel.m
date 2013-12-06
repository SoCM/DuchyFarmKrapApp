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
- (id)initWithDefaults
{
    NSEntityDescription* ed = [NSEntityDescription entityForName:@"Field" inManagedObjectContext:self.managedObjectContext];
    self = [super initWithEntity:ed insertIntoManagedObjectContext:self.managedObjectContext];
    if (self != nil) {
        // Perform additional initialization.
    }
    return self;
}
+(id)FieldWithName:(NSString*)nameString soilType:(SOIL_TYPE)soil_type cropType:(CROP_TYPE)crop_type sizeInHectares:(NSNumber*)size
{
    Field* field = [[Field alloc] initWithDefaults];
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
- (id)initWithDefaults
{
    NSEntityDescription* ed = [NSEntityDescription entityForName:@"SpreadingEvent" inManagedObjectContext:self.managedObjectContext];
    self = [super initWithEntity:ed insertIntoManagedObjectContext:self.managedObjectContext];
    if (self != nil) {
        // Perform additional initialization.
    }
    return self;
}
+(SpreadingEvent*)spreadingEventWithDate:(NSDate*)date manureType:(MANURE_TYPE)manure_type quality:(MANURE_QUALITY)manure_quality density:(NSNumber*)manure_density
{
    SpreadingEvent* se = [[SpreadingEvent alloc] initWithDefaults];
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
+(void)addNewField:(Field*)field
{
    //Safety check
    if (field == nil) {
        NSLog(@"Error - nil field cannot be added");
        return;
    }
    [[FCADataModel managedObjectContext] insertObject:field];
    [FCA_APP_DELEGATE saveContext];
}

+(void)updateField:(Field*)oldField withNewFieldData:(Field*)newField
{
    
}
+(void)removeField:(Field*)field
{  
    
}
+(NSArray*)arrayOfFields
{
    NSArray* result = nil;
    return result;
}
+(NSArray*)arrayOfFieldsWithSortString:(NSString*)predicateString
{
    //NSPredicate* pred = [NSPredicate predicateWithFormat:predicateString];
    NSArray* result = nil;
    return result;
}
+(NSNumber*)numberOfFields
{
    return nil;
}

#pragma mark - DataModel Wrapper Class Methods - Spreading Events

// Spreading events
+(void)addNewSpreadingEvent:(SpreadingEvent*)spreadingEvent toField:(Field*)field
{
    
}
+(void)updateSpreadingEvent:(SpreadingEvent*)oldSpreadingEvent toNewSpreadingEvent:(SpreadingEvent*)newSpreadingEvent
{
    
}
+(void)removeSpreadingEvent:spreadingEvent
{
    
}
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field
{
    NSArray* result = nil;
    return result;
}
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field withSortString:(NSString*)predicateString
{
    //NSPredicate* pred = [NSPredicate predicateWithFormat:predicateString];
    NSArray* result = nil;
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
