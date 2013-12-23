//
//  SoCMAppDelegate.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 29/11/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "SoCMAppDelegate.h"
#import "CropType.h"
#import "SoilType.h"
#import "ManureType.h"
#import "ManureQuality.h"

@implementation SoCMAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize availableNutrients100m3 = _availableNutrients100m3;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self populateModel];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

//Accessors
-(NSDictionary*)availableNutrients100m3
{
    if (_availableNutrients100m3 == nil) {
        NSString *myPlistFilePath = [[NSBundle mainBundle] pathForResource: @"Available100m3" ofType: @"plist"];
        _availableNutrients100m3 = [NSDictionary dictionaryWithContentsOfFile: myPlistFilePath];
    }
    return _availableNutrients100m3;
}

// CORE DATA CODE
-(void)populateModelSimpleWithEntity:(NSString*)entityName plistName:(NSString*)plistName
{
    NSError *err;
    NSManagedObject* objType;
    NSEntityDescription* entityCT = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest* fr;
    
    //Read / parse constant data plist (XML)
    NSString *myPlistFilePath = [[NSBundle mainBundle] pathForResource: plistName ofType: @"plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile: myPlistFilePath];
    
    //Get all keys
    NSArray* rootKeys = [dict allKeys];
    
    //Traverse each - add if not present
    for (NSString* strRootKey in rootKeys) {
        //Get data for next object
        NSDictionary* cropTypeDict = [dict objectForKey:strRootKey];
        NSString* displayName = [cropTypeDict objectForKey:@"displayName"];
        NSNumber* seqID = [cropTypeDict objectForKey:@"seqID"];
        
        //Is it in the data store?
        fr = [NSFetchRequest fetchRequestWithEntityName:entityName];
        fr.predicate = [NSPredicate predicateWithFormat:@"seqID == %@", seqID];
        NSArray* arrayObjects = [self.managedObjectContext executeFetchRequest:fr error:&err];
        if ([arrayObjects count] == 0) {
            //New
            objType = [[NSManagedObject alloc] initWithEntity:entityCT insertIntoManagedObjectContext:self.managedObjectContext];
        } else if ([arrayObjects count] == 1) {
            //Update
            objType = [arrayObjects objectAtIndex:0];
        } else {
            NSLog(@"ERROR - duplicates found in data model : %s", __PRETTY_FUNCTION__);
            return;
        }
        [objType setValue:seqID forKey:@"seqID"];
        [objType setValue:displayName forKey:@"displayName"];

        [self saveContext];
    }
}


//Populate data store with data from manure_types.plist
// This will also bring in any changes made to this plist
-(void)populateModel
{
    [self populateModelSimpleWithEntity:@"CropType" plistName:@"crop_types"];
    [self populateModelSimpleWithEntity:@"SoilType" plistName:@"soil_types"];
    
    NSError *err;
    ManureType* mt;
    ManureQuality* mq;
    
    //Read / parse constant data plist (XML)
    NSString *myPlistFilePath = [[NSBundle mainBundle] pathForResource: @"manure_types" ofType: @"plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile: myPlistFilePath];
    
    //Get array of all keys (Manure Type Strings)
    NSArray* allRootKeys = [dict allKeys];
    
    //Traverse - Populate all ManureType entries that do not exist (yum)
    NSEntityDescription* entityMT = [NSEntityDescription entityForName:@"ManureType" inManagedObjectContext:self.managedObjectContext];
    NSEntityDescription* entityMQ = [NSEntityDescription entityForName:@"ManureQuality" inManagedObjectContext:self.managedObjectContext];
    
    
    for (NSString* strRootKey in allRootKeys) {
        
        //Is it in the ManureType table?
        NSFetchRequest* frmt = [NSFetchRequest fetchRequestWithEntityName:@"ManureType"];
        frmt.predicate = [NSPredicate predicateWithFormat:@"stringID == %@", strRootKey];
        NSArray* res = [self.managedObjectContext executeFetchRequest:frmt error:&err];
        
        //pList object
        NSDictionary* manureTypeDict = [dict objectForKey:strRootKey];
        
        if ([res count] == 0) {
            //No entry found - create
            mt = [[ManureType alloc] initWithEntity:entityMT
                     insertIntoManagedObjectContext:self.managedObjectContext];
            mt.stringID = strRootKey;
            mt.displayName = [manureTypeDict objectForKey:@"displayName"];
            
        } else if (res.count == 1) {
            mt = [res objectAtIndex:0];
        } else {
            NSLog(@"Error - rebuild core data model");
        }
        
        //For each manure type, get the array of "ManureQuality" keys
        NSString* kp = [NSString stringWithFormat:@"%@.types", strRootKey];
        NSArray* manureTypes = [dict valueForKeyPath:kp];
        
        //For each manure type, check to see if it exists in the core data store
        for (NSDictionary* manureTypeDict in manureTypes) {
            NSString* displayName = [manureTypeDict objectForKey:@"displayName"];
            NSNumber* seqID = [manureTypeDict objectForKey:@"seqID"];
            
            NSFetchRequest* frmq = [NSFetchRequest fetchRequestWithEntityName:@"ManureQuality"];
            frmq.predicate = [NSPredicate predicateWithFormat:@"seqID == %@", seqID];
            NSArray* arrayMQ = [self.managedObjectContext executeFetchRequest:frmq error:&err];
            if ([arrayMQ count] == 0) {
                mq = [[ManureQuality alloc] initWithEntity:entityMQ
                            insertIntoManagedObjectContext:self.managedObjectContext];
                mq.seqID = seqID;
                mq.name = displayName;
            } else if ([arrayMQ count] == 1 ) {
                mq = [arrayMQ objectAtIndex:0];
            } else {
                NSLog(@"Error");
            }
            
            //Create relationship
            [mt addQualitySetObject:mq];
            [self saveContext];
        }
        [self saveContext];
    }
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    //Lightweight migration is ON
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
