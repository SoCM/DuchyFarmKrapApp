//
//  FarmKrappAppTests.m
//  FarmKrappAppTests
//
//  Created by Nicholas Outram on 29/11/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FCADataModel.h"
#import "Field.h"
#import "SpreadingEvent.h"


@interface FarmKrappAppTests : XCTestCase
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation FarmKrappAppTests
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.managedObjectContext = [FCADataModel managedObjectContext];
    self.managedObjectModel = [FCADataModel managedObjectModel];
    self.persistentStoreCoordinator = [FCADataModel persistentStoreCoordinator];
}

- (void)tearDown
{
    self.managedObjectContext = nil;
    self.managedObjectModel = nil;
    self.persistentStoreCoordinator = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testCoreData
{
    NSError* err;
    
    //Insert some data
    NSEntityDescription* ed = [[NSEntityDescription alloc] init];
    [ed setName:@"Field"];
    
    Field* field = [[Field alloc] initWithEntity:ed insertIntoManagedObjectContext:self.managedObjectContext];
    [field setName:@"Top"];
    [field setSoilType:@1];
    [field setCropType:@2];
    [field setSizeInHectares:@1.5];
    
    
    [FCADataModel saveContext];
    
//    [self.managedObjectContext insertObject:<#(NSManagedObject *)#>]
    
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    [fr setSortDescriptors:@[@"name"]];
    [fr setPredicate:[NSPredicate predicateWithFormat:@"name = Top"]];
    
    NSArray* result = [self.managedObjectContext executeFetchRequest:fr error:&err];
    
    
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}






@end
