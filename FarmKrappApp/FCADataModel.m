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

@implementation FCADataModel

// Fields
+(void)addNewField:(Field*)field
{
    
}
+(void)updateField:(Field*)oldField withNewFieldData:(Field*)newField
{
    
}
+(Field*)deepCopyOfField:(Field*)field
{
    return nil;
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

// Spreading events
+(void)addNewSpreadingEvent:(SpreadingEvent*)spreadingEvent toField:(Field*)field
{
    
}
+(void)updateSpreadingEvent:(SpreadingEvent*)oldSpreadingEvent toNewSpreadingEvent:(SpreadingEvent*)newSpreadingEvent
{
    
}
+(SpreadingEvent*)deepCopyOfSpreadingEvent:(SpreadingEvent*)spreadingEvent
{
    return nil;
}
+(void)removeSpreadingEvent:spreadingEvent
{
    
}
+(NSArray*)arrayOfSpreadingEventsForField:(Field*)field
{
    NSArray* result = nil;
    return result;
}
+(NSArray*)arrayOfSpreadingEventsWithSortString:(NSString*)predicateString
{
    //NSPredicate* pred = [NSPredicate predicateWithFormat:predicateString];
    NSArray* result = nil;
    return result;
}
+(NSNumber*)numberOfSpreadingEventsForField:(Field*)field
{
    return nil;
}


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
