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


@interface FarmKrappAppTests : XCTestCase {

}
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

#pragma mark - Field Category
//TESTS FOR CATEGORY ON FIELD
-(void)testFieldCategoryMethods
{
     XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);   
}

#pragma mark - Spreading Event Category
//TESTS FOR CATEGORY ON SPREADING EVENT
-(void)testSpreadEventCategoryMethods
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

#pragma mark - Field
// TESTS FOR FCADATA MODEL (CoreData wrapper class)
-(void)testAddNewField
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
-(void)testUpdateField
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
-(void)testRemoveField
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
-(void)testArrayOfFields
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
- (void)testArrayOfFieldsWithSortString
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
- (void)testNumberOfFields
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
#pragma mark - Spreading Event
-(void)testAddNewSpreadingEvent
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
-(void)testUpdateSpreadingEvent
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
-(void)testRemoveSpreadingEvent
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
-(void)testArrayOfSpreadingEventsForField
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
-(void)testarrayOfSpreadingEventsForFieldWithSortString
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
-(void)testNumberOfSpreadingEventsForField
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}





@end
