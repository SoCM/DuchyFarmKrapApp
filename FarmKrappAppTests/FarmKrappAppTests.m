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
#import "Photo.h"
#import "UIImageUOPCategory.h"

@interface FarmKrappAppTests : XCTestCase {
    NSUInteger numberOfFields;
    NSUInteger numberOFSpreadingEvents;
    NSUInteger numberOfPhotos;
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
    
    //Count entries going in

    //Count the number of fields and spreading events before....
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    numberOfFields = [[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] count];
    
    fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    numberOFSpreadingEvents = [[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] count];

    fr = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    numberOfPhotos = [[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] count];
}

- (void)tearDown
{
    //Count entries going out
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    NSUInteger numberOfFieldsOut = [[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] count];
    
    fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    NSUInteger numberOFSpreadingEventsOut = [[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] count];

    fr = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    NSUInteger numberOfPhotosOut = [[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] count];

    XCTAssertTrue(numberOfFieldsOut == numberOfFields, @"Number of fields unbalaned");
    XCTAssertTrue(numberOFSpreadingEventsOut == numberOFSpreadingEvents, @"Number of spreading events unbalaned");
    XCTAssertTrue(numberOfPhotosOut == numberOfPhotos, @"Number of photos unbalaned");
    
    self.managedObjectContext = nil;
    self.managedObjectModel = nil;
    self.persistentStoreCoordinator = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
#pragma mark - Data model generic
-(void)testConstantsFCAAvailableNutients
{
    //Double equivalence check used for testing results
    BOOL(^isCloseTo)(double, double) = ^(double a, double b) {
        if (fabs(a-b) < 0.00001) return YES;
        else return NO;
    };

    double fVal;
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];

    FCAAvailableNutrients *availNutrient;
    
    //WINTER
    NSDateComponents* dc1 = [[NSDateComponents alloc] init];
    dc1.day = 01; dc1.month = 01; dc1.year = 2013;
    NSDate *d1 = [gregorian dateFromComponents:dc1];

    //SANDY SHALLOW, ALL CROPS
    SoilType* st1 = [SoilType FetchSoilTypeForID:kSOILTYPE_SANDY_SHALLOW];
    CropType* ct1 = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    
    //CATTLE SLURRY
    ManureType *mt1 = [ManureType FetchManureTypeForStringID:@"CattleSlurry"];
    ManureQuality *mq1 = [ManureQuality FetchManureQualityForID:[NSNumber numberWithInt:CS_DM2]];
    
    //SPREAD THAT SLURRY!
    Field *f1 = [Field InsertFieldWithName:@"F1" soilType:st1 cropType:ct1 sizeInHectares:@10];
    SpreadingEvent*s1 = [FCADataModel addNewSpreadingEventWithDate:d1 manureType:mt1 quality:mq1 density:@100 toField:f1]; //rate = 100.0
    
    //CHECK AVAILABLE NUTRIENTS
    availNutrient = [[FCAAvailableNutrients alloc] initWithSpreadingEvent:s1];
    fVal = [availNutrient nitrogenAvailable].doubleValue;
    XCTAssertTrue(isCloseTo(48.0, fVal), @"Wrong N value");
    fVal = [availNutrient nitrogenAvailableForRate:@50.0].doubleValue;
    XCTAssertTrue(isCloseTo(24.0, fVal), @"Wrong N value");
    

    
    //Tidy up
    [FCADataModel removeField:f1];
    
}

-(void)testCoreDataChildParent
{
    //Core data tests
    NSError *cerror, *perror;
    NSManagedObjectContext* pmoc = [FCADataModel managedObjectContext];
    NSManagedObjectContext* cmoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [cmoc setParentContext:pmoc];

    //Add field to child context
    Field* f1 = (Field*)[NSEntityDescription insertNewObjectForEntityForName:@"Field" inManagedObjectContext:cmoc];
    f1.name = @"Fred19756";
    [cmoc save:&cerror];  //This will save the changes to the child moc
    [pmoc save:&perror];  //Save the changes to the parent

    //Check it was committed
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    fr.predicate = [NSPredicate predicateWithFormat:@"name == \"Fred19756\""];
    NSArray* res = [pmoc executeFetchRequest:fr error:&perror];
    XCTAssertTrue(res.count == 1, @"Error - got back %lu", res.count);

    //Create spreading event using ONLY CHILD CONTEXT
    Field *fieldFromParentContext = [res objectAtIndex:0];
    NSManagedObjectID *f1ID = [fieldFromParentContext objectID];
    Field* f2 = (Field*)[cmoc objectWithID:f1ID];
    SpreadingEvent* se1 = [NSEntityDescription insertNewObjectForEntityForName:@"SpreadingEvent" inManagedObjectContext:cmoc];
//    [fieldFromParentContext addSpreadingEventsObject:se1];
    [f2 addSpreadingEventsObject:se1];
    [cmoc save:&cerror];
    
    //Delete field
    [cmoc deleteObject:f1];
    [cmoc save:&cerror];  //This will save the changes to the child moc
    [pmoc save:&perror];
    
    //Recheck
    res = [pmoc executeFetchRequest:fr error:&perror];
    XCTAssertTrue(res.count == 0, @"Error - got back %lu", res.count);
    
}


#pragma mark - Field Category
//TESTS FOR CATEGORY ON FIELD
-(void)testFieldCategoryMethods
{
    NSError* err;
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    Field* f1 = nil;

    SoilType* st = [SoilType FetchSoilTypeForID:kSOILTYPE_SANDY_SHALLOW];
    CropType* ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    f1 = [Field InsertFieldWithName:@"Top8576" soilType:st cropType:ct sizeInHectares:@2];
    [FCADataModel saveContext];
    XCTAssertNotNil(f1, @"FieldWithName:... failed");

    XCTAssertTrue([f1.name isEqualToString:@"Top8576"], @"Field name incorrect - %s", __PRETTY_FUNCTION__);
    XCTAssertTrue(((SoilType*)f1.soilType).seqID.intValue == SOILTYPE_SANDY_SHALLOW, @"Field soild type incorrect - %s", __PRETTY_FUNCTION__);
    XCTAssertTrue(((CropType*)f1.cropType).seqID.intValue == CROPTYPE_ALL_CROPS, @"Field crop type incorrect - %s", __PRETTY_FUNCTION__);
    XCTAssertTrue(f1.sizeInHectares.intValue == 2, @"Field size incorrect - %s", __PRETTY_FUNCTION__);
    XCTAssertNotNil(f1.spreadingEvents, @"No spreading event set - %s", __PRETTY_FUNCTION__);
    
    //Read back from CoreData store
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    fr.predicate = [NSPredicate predicateWithFormat:@"name == \"Top8576\""];
    NSArray* results = [self.managedObjectContext executeFetchRequest:fr error:&err];
    XCTAssertTrue((results.count==1), @"Incorrect number of entries");
    
    
    //Now tidy up
    [[FCADataModel managedObjectContext] deleteObject:f1];
    [FCADataModel saveContext];
    
    //Read back from CoreData store
    fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    fr.predicate = [NSPredicate predicateWithFormat:@"name == \"Top8576\""];
    results = [self.managedObjectContext executeFetchRequest:fr error:&err];
    XCTAssertTrue((results.count==0), @"Incorrect number of entries");
}



#pragma mark - Spreading Event Category
//TESTS FOR CATEGORY ON SPREADING EVENT
-(void)testSpreadEventCategoryMethods
{
    NSError* err;
    SpreadingEvent* se;
    
    ManureType* mt = [ManureType FetchManureTypeForStringID:@"CattleSlurry"];
    ManureQuality* mq = [ManureQuality FetchManureQualityForID:@200];
    se = [SpreadingEvent InsertSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:0.0]
                                     manureType:mt
                                        quality:mq
                                        density:@421];
    [FCADataModel saveContext];
    
    XCTAssertNotNil(se, @"spreadingEventWithData failed - %s", __PRETTY_FUNCTION__);
    XCTAssertTrue([se.date isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0.0]], @"spreadingEventWithDate failed - %s", __PRETTY_FUNCTION__);
    XCTAssertTrue(([se.manureType.stringID isEqualToString:@"CattleSlurry"]), @"spreadingEventWithDate failed - %s", __PRETTY_FUNCTION__);
    XCTAssertTrue( (se.manureQuality.seqID.intValue == 200), @"spreadingEventWithDate failed - %s", __PRETTY_FUNCTION__);
    XCTAssertTrue((se.density.intValue == 421), @"spreadingEventWithDate failed - %s", __PRETTY_FUNCTION__);
    
    //Read back from CoreData store
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    fr.predicate = [NSPredicate predicateWithFormat:@"density == 421"];
    
    NSArray* results = [self.managedObjectContext executeFetchRequest:fr error:&err];
    XCTAssertTrue((results.count==1), @"Incorrect number of entries = %lu", results.count);
    
    
    
    //Tidy up
    [[FCADataModel managedObjectContext] deleteObject:se];
    [FCADataModel saveContext];
    
    //Read back from CoreData store
    fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    fr.predicate = [NSPredicate predicateWithFormat:@"density == 421"];
    results = [self.managedObjectContext executeFetchRequest:fr error:&err];
    XCTAssertTrue((results.count==0), @"Incorrect number of entries = %lu", results.count);
}

#pragma mark - Photo Category
//+(Photo*)InsertPhotoWithImageData:(NSData*)imageData onDate:(NSDate*)date;
//+(NSData*)imageDataForPhoto:(Photo*)photo;

-(void)testPhotoCategoryMethods
{
    NSError* err;
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    fr.predicate = [NSPredicate predicateWithFormat:@"date = %@", [NSDate dateWithTimeIntervalSince1970:123.0]];
    NSArray* res = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    NSUInteger before = [res count];
    
    UIImage* img = [UIImage imageNamed:@"logo"];
    XCTAssertNotNil(img, @"Cannot load test image");

    NSData* imgData = [img imageAsData];
    XCTAssertNotNil(imgData, @"Cannot load test image");

    //Create photo object (testing InsertPhotoWithImageData)
    [Photo InsertPhotoWithImageData:imgData onDate:[NSDate dateWithTimeIntervalSince1970:123.0]];
    
    //Check core data (testing imageDateForPhoto)
    fr = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    fr.predicate = [NSPredicate predicateWithFormat:@"date = %@", [NSDate dateWithTimeIntervalSince1970:123.0]];
    
    res = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    
    NSUInteger after = (NSUInteger)[res count];
    XCTAssertTrue((after-before)==1, @"Wrong number of photos: delta = %lu", (after-before));
    XCTAssertEqualObjects(imgData, [Photo imageDataForPhoto:res[0]], @"Wrong number of photos: delta = %lu", (after-before) );
    
    //Tidy up
    [[FCADataModel managedObjectContext] deleteObject:res[0] ];
    
    //Check
    fr = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    fr.predicate = [NSPredicate predicateWithFormat:@"date = %@", [NSDate dateWithTimeIntervalSince1970:123.0]];
    res = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    after = [res count];
    XCTAssertTrue((after-before)==0, @"Wrong number of photos");

}


#pragma mark - Field
// TESTS FOR FCADATA MODEL (CoreData wrapper class)
-(void)testAddNewField
{
    NSError *err;
    NSArray *results;
    
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE];
    Field* f1 = [FCADataModel addNewFieldWithName:@"UPPER183749283" soilType:st cropType:ct sizeInHectares:@20];

    //Now perform a core data query to read back
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    fr.predicate = [NSPredicate predicateWithFormat:@"name == \"UPPER183749283\""];
    results = [self.managedObjectContext executeFetchRequest:fr error:&err];
    XCTAssertTrue(results.count == 1, @"addNewField failed - %s", __PRETTY_FUNCTION__);
    Field* qField = [results objectAtIndex:0];
    XCTAssertTrue([qField.name isEqualToString:@"UPPER183749283"], @"addNewField failed - %s", __PRETTY_FUNCTION__);
    
    //Tidy up
    [[FCADataModel managedObjectContext] deleteObject:f1];
    [FCADataModel saveContext];
    
}

-(void)testRemoveField
{
    NSError* err;
    
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field* f1 = [FCADataModel addNewFieldWithName:@"FreddyTheFish" soilType:st cropType:ct sizeInHectares:@123];
    
    //Now perform a core data query to read back
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    fr.predicate = [NSPredicate predicateWithFormat:@"name == \"FreddyTheFish\""];
    NSArray* results = [self.managedObjectContext executeFetchRequest:fr error:&err];
    XCTAssertTrue(results.count == 1, @"addField failed - %s", __PRETTY_FUNCTION__);
    
    [FCADataModel removeField:f1];
    
    fr = [NSFetchRequest fetchRequestWithEntityName:@"Field"];
    fr.predicate = [NSPredicate predicateWithFormat:@"name == \"FreddyTheFish\""];
    results = [self.managedObjectContext executeFetchRequest:fr error:&err];
    XCTAssertTrue(results.count == 0, @"addField failed - %s", __PRETTY_FUNCTION__);
    
}

-(void)testArrayOfFields
{
    NSArray* allFields = [FCADataModel arrayOfFields];
    NSUInteger before = [allFields count];
    
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field* f1 = [FCADataModel addNewFieldWithName:@"TED" soilType:st cropType:ct sizeInHectares:@10];
    Field* f2 = [FCADataModel addNewFieldWithName:@"RALPH" soilType:st cropType:ct sizeInHectares:@20];
    Field* f3 = [FCADataModel addNewFieldWithName:@"LOWERFIELD" soilType:st cropType:ct sizeInHectares:@30];
    
    allFields = [FCADataModel arrayOfFields];
    NSUInteger after = [allFields count];
    
    XCTAssertTrue((after-before)==3, @"Number of fields was expected to be 3.");
    
    [FCADataModel removeField:f1];
    [FCADataModel removeField:f2];
    [FCADataModel removeField:f3];
}

- (void)testArrayOfFieldsWithSortString
{
    NSArray* allFields = [FCADataModel arrayOfFieldsWithSortString:@"sizeInHectares"];
    NSUInteger before = [allFields count];
    
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field* f1 = [FCADataModel addNewFieldWithName:@"TED" soilType:st cropType:ct sizeInHectares:@10];
    Field* f2 = [FCADataModel addNewFieldWithName:@"RALPH" soilType:st cropType:ct sizeInHectares:@30];
    Field* f3 = [FCADataModel addNewFieldWithName:@"LOWERFIELD" soilType:st cropType:ct sizeInHectares:@20];

    allFields = [FCADataModel arrayOfFieldsWithSortString:@"sizeInHectares"];
    NSUInteger after = [allFields count];
    XCTAssertTrue((after-before)==3, @"Number of fields was expected to be 3.");
    
    //Are they sorted in the correct sequence?
    XCTAssertEqualObjects(f1, allFields[0], @"Sort failed");
    XCTAssertEqualObjects(f2, allFields[2], @"Sort failed");
    XCTAssertEqualObjects(f3, allFields[1], @"Sort failed");
    
    [FCADataModel removeField:f1];
    [FCADataModel removeField:f2];
    [FCADataModel removeField:f3];
}
- (void)testArrayOfFieldsWithSortStringAndPredicate
{
    NSArray* allFields = [FCADataModel arrayOfFieldsWithSortString:@"sizeInHectares" andPredicateString:@"sizeInHectares > 10"];
    NSUInteger before = [allFields count];
    
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field* f1 = [FCADataModel addNewFieldWithName:@"TED" soilType:st cropType:ct sizeInHectares:@10];
    Field* f2 = [FCADataModel addNewFieldWithName:@"RALPH" soilType:st cropType:ct sizeInHectares:@30];
    Field* f3 = [FCADataModel addNewFieldWithName:@"LOWERFIELD" soilType:st cropType:ct sizeInHectares:@20];
    
    allFields = [FCADataModel arrayOfFieldsWithSortString:@"sizeInHectares" andPredicateString:@"sizeInHectares > 10"];
    NSUInteger after = [allFields count];
    XCTAssertTrue((after-before)==2, @"Number of fields was expected to be 2.");
    
    //Are they sorted in the correct sequence?
    XCTAssertEqualObjects(f2, allFields[1], @"Sort failed");
    XCTAssertEqualObjects(f3, allFields[0], @"Sort failed");
    
    [FCADataModel removeField:f1];
    [FCADataModel removeField:f2];
    [FCADataModel removeField:f3];
}
- (void)testNumberOfFields
{
    NSArray* allFields = [FCADataModel arrayOfFields];
    NSUInteger before = [allFields count];
    
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field* f1 = [FCADataModel addNewFieldWithName:@"TED" soilType:st cropType:ct sizeInHectares:@10];
    Field* f2 = [FCADataModel addNewFieldWithName:@"RALPH" soilType:st cropType:ct sizeInHectares:@20];
    Field* f3 = [FCADataModel addNewFieldWithName:@"LOWERFIELD" soilType:st cropType:ct sizeInHectares:@30];
    
    NSUInteger after = [[FCADataModel numberOfFields] intValue];
    XCTAssertTrue((after-before)==3, @"Number of fields was expected to be 3.");
    
    [FCADataModel removeField:f1];
    [FCADataModel removeField:f2];
    [FCADataModel removeField:f3];

}
#pragma mark - Spreading Event
-(void)testAddNewSpreadingEventToField
{
    //Count the number of spreading events before....
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    NSArray* arrayOfSpreads = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    NSUInteger before = [arrayOfSpreads count];
    
    //Create a field and add a spreading event - these are unique relationships
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field* f1 = [FCADataModel addNewFieldWithName:@"TED" soilType:st cropType:ct sizeInHectares:@10];
    
    SpreadingEvent* se1 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"CattleSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@200]
                                                             density:@10
                                                             toField:f1];
    
    SpreadingEvent* se2 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:1.0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"PigSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@1000]
                                                             density:@20
                                                             toField:f1];

    //Confirm all attributes are as expected
    fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    fr.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"density" ascending:YES] ];
    arrayOfSpreads = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    SpreadingEvent* res = (SpreadingEvent*)[arrayOfSpreads objectAtIndex:0];
    XCTAssertTrue([res.manureType.stringID isEqualToString:@"CattleSlurry"], @"Manure type wrong");
    XCTAssertTrue(res.manureQuality.seqID.intValue == 200, @"Manure quality wrong");
    XCTAssertTrue(res.density.intValue == 10, @"Manure density wrong, should be 10, found %d", res.density.intValue);

    //Create additional field and add am identical spreading event - verify these are unique relationships
    
    Field* f2 = [FCADataModel addNewFieldWithName:@"TED" soilType:st cropType:ct sizeInHectares:@10];
    SpreadingEvent* se3 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"CattleSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@200]
                                                             density:@10
                                                             toField:f2];

    
    //Query number of SE in CoreData for field f1
    XCTAssertTrue((f1.spreadingEvents.count == 2), @"addSpreadingEvent failed");

    //Query number of SE in CoreData for field f2
    XCTAssertTrue((f2.spreadingEvents.count == 1), @"addSpreadingEvent failed");

    //Have we added 3 additional spreading events in the entity?
    fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    arrayOfSpreads = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    NSUInteger after = [arrayOfSpreads count];
    XCTAssertTrue(((after-before)==3), @"Number of spreading events inconsistent");

    //Remove field f1 - the relationship is setup as a cascaded delete so the spreading events should also be deleted
    [FCADataModel removeField:f1];
    
    //All cleaned up?
    //Have we removed the 2 additional spreading events?
    fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    arrayOfSpreads = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    after = [arrayOfSpreads count];
    NSLog(@"NUMBER OF SPREADING EVENTS = %lu", after);
    XCTAssertTrue(((after-before)==1), @"Number of spreading events inconsistent");
    
    //Remove field f2 - the relationship is setup as a cascaded delete so the spreading events should also be deleted
    [FCADataModel removeField:f2];

    //Have we removed the additional spreading event?
    fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    arrayOfSpreads = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    after = [arrayOfSpreads count];
    NSLog(@"NUMBER OF SPREADING EVENTS = %lu", after);
    XCTAssertTrue(((after-before)==0), @"Number of spreading events inconsistent");
    
    se1 = nil;
    se2 = nil;
    se3 = nil;
    
}
-(void)testRemoveSpreadingEvent
{
    //Count the number of spreading events before....
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    NSArray* arrayOfSpreads = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    NSUInteger before = [arrayOfSpreads count];
    
    //Create a field and add a spreading event - these are unique relationships
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field* f1 = [FCADataModel addNewFieldWithName:@"TED"   soilType:st cropType:ct sizeInHectares:@10];
    Field* f2 = [FCADataModel addNewFieldWithName:@"RALPH" soilType:st cropType:ct sizeInHectares:@10];
    
    //Three spreading events, two for field1, and one for field2
    SpreadingEvent* se1 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"CattleSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@200]
                                                             density:@10
                                                             toField:f1];
    
    SpreadingEvent* se2 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:1.0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"PigSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@1000]
                                                             density:@20
                                                             toField:f1];

    SpreadingEvent* se3 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:1.0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"PigSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@1000]
                                                             density:@20
                                                             toField:f2];
    
    //Test reverse lookup
    XCTAssertTrue((se1.field == f1), @"Reverse reference is incorrect");
    XCTAssertTrue((se2.field == f1), @"Reverse reference is incorrect");
    XCTAssertTrue((se3.field == f2), @"Reverse reference is incorrect");
    
    //Confirm numbers
    fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    arrayOfSpreads = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    NSUInteger after = [arrayOfSpreads count];
    XCTAssertTrue((after-before)==3, @"Inconsistent number of spreading events: delta = %lu", (after-before));
    
    //Remove fields se2 and se3
    [FCADataModel removeSpreadingEvent:se2];
    [FCADataModel removeSpreadingEvent:se3];
    
    //Check fields 
    XCTAssertTrue([f1.spreadingEvents count]==1, @"Inconsistent number of spreading events = %lu", f1.spreadingEvents.count);
    XCTAssertTrue([f2.spreadingEvents count]==0, @"Inconsistent number of spreading events = %lu", f2.spreadingEvents.count);

    //Confirm numbers
    fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    arrayOfSpreads = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    after = [arrayOfSpreads count];
    XCTAssertTrue((after-before)==1, @"Inconsistent number of spreading events: delta = %lu", (after-before));
    
    //Remove se1
    [FCADataModel removeSpreadingEvent:se1];
    
    //Confirm everything is balanced
    fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    arrayOfSpreads = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    after = [arrayOfSpreads count];
    XCTAssertTrue((after-before)==0, @"Inconsistent number of spreading events: delta = %lu", (after-before));
    XCTAssertTrue([f1.spreadingEvents count]==0, @"Inconsistent number of spreading events = %lu", f1.spreadingEvents.count);

    //Tidy up
    [FCADataModel removeField:f1];
    [FCADataModel removeField:f2];
    
    se1 = nil;
    se2 = nil;
    se3 = nil;
    
}
-(void)testArrayOfSpreadingEventsForField
{
    //Count the number of spreading events before....
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    NSArray* arrayOfSpreads = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    NSUInteger before = [arrayOfSpreads count];
    
    //Create a field and add a spreading event - these are unique relationships
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field* f1 = [FCADataModel addNewFieldWithName:@"TED"   soilType:st cropType:ct sizeInHectares:@10];
    Field* f2 = [FCADataModel addNewFieldWithName:@"RALPH" soilType:st cropType:ct sizeInHectares:@10];
    
    //Three spreading events, two for field1, and one for field2
    SpreadingEvent* se1 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"CattleSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@200]
                                                             density:@10
                                                             toField:f1];
    
    SpreadingEvent* se2 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:1.0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"PigSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@1000]
                                                             density:@20
                                                             toField:f1];

    //This one looks identical, but is added to a different field
    SpreadingEvent* se3 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:1.0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"PigSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@1000]
                                                             density:@20
                                                             toField:f2];
    
    //Check array counts
    NSArray* allSpreadingEventsForf1 = [FCADataModel arrayOfSpreadingEventsForField:f1];
    NSArray* allSpreadingEventsForf2 = [FCADataModel arrayOfSpreadingEventsForField:f2];
    XCTAssertTrue(allSpreadingEventsForf1.count == 2, @"Inconsistent number of spreading events for f1 = %lu", allSpreadingEventsForf1.count);
    XCTAssertTrue(allSpreadingEventsForf2.count == 1, @"Inconsistent number of spreading events for f2 = %lu", allSpreadingEventsForf2.count);
    
    //Tidy up
    [FCADataModel removeField:f1];
    [FCADataModel removeField:f2];
    
    //Check
    fr = [NSFetchRequest fetchRequestWithEntityName:@"SpreadingEvent"];
    arrayOfSpreads = [[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err];
    NSUInteger after = [arrayOfSpreads count];
    XCTAssertTrue(after == before, @"Inconsistent number of spreading events: delta=%lu", (after-before));
    se1 = nil;
    se2 = nil;
    se3 = nil;
}
-(void)testarrayOfSpreadingEventsForFieldWithSortString
{
    //Create a field and add a spreading event - these are unique relationships
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field* f1 = [FCADataModel addNewFieldWithName:@"TED"   soilType:st cropType:ct sizeInHectares:@10];
    
    //Three spreading events, two for field1, and one for field2
    SpreadingEvent* se1 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"CattleSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@200]
                                                             density:@10
                                                             toField:f1];
    
    SpreadingEvent* se2 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:3.0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"PigSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@1000]
                                                             density:@30
                                                             toField:f1];
    
    SpreadingEvent* se3 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:2.0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"PigSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@1000]
                                                             density:@20
                                                             toField:f1];

    //Query back in date order
    NSArray* sortArray = [FCADataModel arrayOfSpreadingEventsForField:f1 withSortString:@"date"];
    XCTAssertEqualObjects(se1, sortArray[0], @"Sort of spreding event failed");
    XCTAssertEqualObjects(se2, sortArray[2], @"Sort of spreding event failed");
    XCTAssertEqualObjects(se3, sortArray[1], @"Sort of spreding event failed");
    
    //Tidy up
    [FCADataModel removeField:f1];
    se1 = nil;
    se2 = nil;
    se3 = nil;
}
-(void)testNumberOfSpreadingEventsForField
{
    //Create a field and add a spreading event - these are unique relationships
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field* f1 = [FCADataModel addNewFieldWithName:@"TED"   soilType:st cropType:ct sizeInHectares:@10];
    Field* f2 = [FCADataModel addNewFieldWithName:@"RALPH" soilType:st cropType:ct sizeInHectares:@10];
    
    //Three spreading events, two for field1, and one for field2
    SpreadingEvent* se1 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"CattleSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@200]
                                                             density:@10
                                                             toField:f1];
    
    SpreadingEvent* se2 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:2.0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"PigSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@1000]
                                                             density:@20
                                                             toField:f1];
    
    SpreadingEvent* se3 = [FCADataModel addNewSpreadingEventWithDate:[NSDate dateWithTimeIntervalSince1970:1.0]
                                                          manureType:[ManureType FetchManureTypeForStringID:@"PigSlurry"]
                                                             quality:[ManureQuality FetchManureQualityForID:@1000]
                                                             density:@20
                                                             toField:f2];
    
    //Test
    NSUInteger seInf1 = [[FCADataModel arrayOfSpreadingEventsForField:f1] count];
    NSUInteger seInf2 = [[FCADataModel arrayOfSpreadingEventsForField:f2] count];
    XCTAssertTrue(seInf1==2, @"Wrong number of spreading events reported: %lu", seInf1);
    XCTAssertTrue(seInf2==1, @"Wrong number of spreading events reported: %lu", seInf2);
    
    //Tidy
    [FCADataModel removeField:f1];
    [FCADataModel removeField:f2];
    se1 = nil;
    se2 = nil;
    se3 = nil;
}

#pragma mark - Test Photo

-(void)testAddImageData
{
    NSError* err;
    
    //Get the nunber of photos before
    NSUInteger before = [[[FCADataModel managedObjectContext] executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Photo"] error:&err] count];
    
    //Create a new field
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field *f1 = [FCADataModel addNewFieldWithName:@"FREDDY"
                                         soilType:st
                                         cropType:ct
                                   sizeInHectares:@2];
    //Add spreading event
    SpreadingEvent* se = [FCADataModel addNewSpreadingEventWithDate:[NSDate date]
                                                         manureType:[ManureType FetchManureTypeForStringID:@"CattleSlurry"]
                                                            quality:[ManureQuality FetchManureQualityForID:@200]
                                                            density:@1.5
                                                            toField:f1 ];
    XCTAssertNotNil(se, @"spreading event in test not formed");
    
    //Grab some images
    UIImage* img1 = [UIImage imageNamed:@"logo"];
    NSData* imgData1 = [img1 imageAsData];
    UIImage* img2 = [UIImage imageNamed:@"logo_duchy"];
    NSData* imgData2 = [img2 imageAsData];
    XCTAssertNotNil(imgData1, @"image in test not formed");
    XCTAssertNotNil(imgData2, @"image in test not formed");
    
    //Add images to spreading event
    [FCADataModel addImageData:imgData1 toSpreadingEvent:se onDate:[NSDate dateWithTimeIntervalSince1970:1.0]];
    [FCADataModel addImageData:imgData2 toSpreadingEvent:se onDate:[NSDate dateWithTimeIntervalSince1970:2.0]];

    //Check Photo entity for spreading event is the correct size
    NSSet* setOfPhotos = se.photos;
    XCTAssertNotNil(setOfPhotos, @"Photo is nil");
    XCTAssertTrue([setOfPhotos count]==2, @"Wrong number of photos");
    
    //Check that each Photo entity for spreading event contains a valid photos
    id collection = [setOfPhotos valueForKeyPath:@"photo"]; //Returns a collection of objects type NSData* (using the photo key)
    XCTAssertTrue([collection containsObject:imgData1], @"Photo not found");
    XCTAssertTrue([collection containsObject:imgData2], @"Photo not found");
    
    //Tidy up + cascade delete
    [FCADataModel removeField:f1];
    
    //Check number of photos remains unchanged
    NSUInteger after = [[[FCADataModel managedObjectContext] executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Photo"] error:&err] count];
    XCTAssertTrue((before==after), @"Was expecting %lu photos, found %lu", before, after);
}

-(void)testRemoveImagedata
{
    NSError* err;
    
    //Get the nunber of photos before
    NSUInteger before = [[[FCADataModel managedObjectContext] executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Photo"] error:&err] count];
    
    //    +(void)addImageData:(NSData*)image toSpreadingEvent:(SpreadingEvent*)se;
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field *f1 = [FCADataModel addNewFieldWithName:@"FREDDY"
                                         soilType:st
                                         cropType:ct
                                   sizeInHectares:@2];
    
    SpreadingEvent* se = [FCADataModel addNewSpreadingEventWithDate:[NSDate date]
                                                         manureType:[ManureType FetchManureTypeForStringID:@"CattleSlurry"]
                                                            quality:[ManureQuality FetchManureQualityForID:@200]
                                                            density:@1.5
                                                            toField:f1 ];
    XCTAssertNotNil(se, @"spreading event in test not formed");
    
    //Grab some images
    UIImage* img1 = [UIImage imageNamed:@"logo"];
    NSData* imgData1 = [img1 imageAsData];
    UIImage* img2 = [UIImage imageNamed:@"logo_duchy"];
    NSData* imgData2 = [img2 imageAsData];
    XCTAssertNotNil(imgData1, @"image in test not formed");
    XCTAssertNotNil(imgData2, @"image in test not formed");
    
    //Add images to spreading event
    [FCADataModel addImageData:imgData1 toSpreadingEvent:se onDate:[NSDate dateWithTimeIntervalSince1970:1.0]];
    [FCADataModel addImageData:imgData2 toSpreadingEvent:se onDate:[NSDate dateWithTimeIntervalSince1970:2.0]];
    
    //Check Photo entity for spreading event is the correct size
    NSSet* setOfPhotos = se.photos;
    XCTAssertNotNil(setOfPhotos, @"Photo = nil");
    XCTAssertTrue([setOfPhotos count]==2, @"Wrong number of photos");
    
    //Check that each Photo entity for spreading event contains a valid photos
    id collection = [setOfPhotos valueForKeyPath:@"photo"]; //Returns a collection of objects type NSData* (using the photo key)
    XCTAssertTrue([collection containsObject:imgData1], @"Photo not found");
    XCTAssertTrue([collection containsObject:imgData2], @"Photo not found");
    
    //TEST REMOVE IMAGE DATA
    [FCADataModel removeImageData:imgData1 fromSpreadingEvent:se];
    
    //Check that each Photo entity for spreading event contains a valid photos
    collection = [setOfPhotos valueForKeyPath:@"photo"]; //Returns a collection of objects type NSData* (using the photo key)
    XCTAssertFalse([collection containsObject:imgData1], @"Photo not found");
    XCTAssertTrue([collection containsObject:imgData2], @"Photo not found");
    
    //Check number
    NSUInteger after = [[[FCADataModel managedObjectContext] executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Photo"] error:&err] count];
    XCTAssertTrue((after-before)==1, @"Was expecting %lu photos, found %lu", before-1, after);
    
    //Tidy up + cascade delete
    [FCADataModel removeField:f1];
    
    //Check number of photos remains unchanged
    after = [[[FCADataModel managedObjectContext] executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Photo"] error:&err] count];
    XCTAssertTrue((before==after), @"Was expecting %lu photos, found %lu", before, after);

}
-(void)testArrayOfPhotosForSpreadingEvent
{
    NSError* err;
    
    //Get the nunber of photos before
    NSUInteger before = [[[FCADataModel managedObjectContext] executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Photo"] error:&err] count];
    
    //Create a new field
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field *f1 = [FCADataModel addNewFieldWithName:@"FREDDY"
                                         soilType:st
                                         cropType:ct
                                   sizeInHectares:@2];
    //Add spreading event
    SpreadingEvent* se = [FCADataModel addNewSpreadingEventWithDate:[NSDate date]
                                                         manureType:[ManureType FetchManureTypeForStringID:@"CattleSlurry"]
                                                            quality:[ManureQuality FetchManureQualityForID:@200]
                                                            density:@1.5
                                                            toField:f1 ];
    XCTAssertNotNil(se, @"spreading event in test not formed");
    
    //Grab some images
    UIImage* img1 = [UIImage imageNamed:@"logo"];
    NSData* imgData1 = [img1 imageAsData];
    UIImage* img2 = [UIImage imageNamed:@"logo_duchy"];
    NSData* imgData2 = [img2 imageAsData];
    XCTAssertNotNil(imgData1, @"image in test not formed");
    XCTAssertNotNil(imgData2, @"image in test not formed");
    
    //Add images to spreading event
    [FCADataModel addImageData:imgData1 toSpreadingEvent:se onDate:[NSDate dateWithTimeIntervalSince1970:2.0]];
    [FCADataModel addImageData:imgData2 toSpreadingEvent:se onDate:[NSDate dateWithTimeIntervalSince1970:1.0]];
    
    //Get sorted array of photos for spreading event
    NSArray* arrayOfImages = [FCADataModel arrayOfPhotosForSpreadingEvent:se];
    XCTAssertTrue(arrayOfImages.count == 2, @"Found %lu, expected 2", arrayOfImages.count);
    
    //Are the images found in the correct order
    XCTAssertEqualObjects(imgData1, arrayOfImages[1], @"Wrong image found");
    XCTAssertEqualObjects(imgData2, arrayOfImages[0], @"Wrong image found");
    
    //Tidy up + cascade delete
    [FCADataModel removeField:f1];
    
    //Check number of photos remains unchanged
    NSUInteger after = [[[FCADataModel managedObjectContext] executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Photo"] error:&err] count];
    XCTAssertTrue((before==after), @"Was expecting %lu photos, found %lu", before, after);
    
}
-(void)testNumberOfPhotosForSpreadingEvent
{
    NSError* err;
    
    //Get the nunber of photos before
    NSUInteger before = [[[FCADataModel managedObjectContext] executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Photo"] error:&err] count];
    
    //Create a new field
    SoilType *st = [SoilType FetchSoilTypeForID:kSOILTYPE_MEDIUM_HEAVY];
    CropType *ct = [CropType FetchCropTypeForID:kCROPTYPE_ALL_CROPS];
    Field *f1 = [FCADataModel addNewFieldWithName:@"FREDDY"
                                         soilType:st
                                         cropType:ct
                                   sizeInHectares:@2];
    //Add spreading event
    SpreadingEvent* se = [FCADataModel addNewSpreadingEventWithDate:[NSDate date]
                                                         manureType:[ManureType FetchManureTypeForStringID:@"CattleSlurry"]
                                                            quality:[ManureQuality FetchManureQualityForID:@200]
                                                            density:@1.5
                                                            toField:f1 ];
    XCTAssertNotNil(se, @"spreading event in test not formed");
    
    //Grab some images
    UIImage* img1 = [UIImage imageNamed:@"logo"];
    NSData* imgData1 = [img1 imageAsData];
    UIImage* img2 = [UIImage imageNamed:@"logo_duchy"];
    NSData* imgData2 = [img2 imageAsData];
    XCTAssertNotNil(imgData1, @"image in test not formed");
    XCTAssertNotNil(imgData2, @"image in test not formed");
    
    //Add images to spreading event
    [FCADataModel addImageData:imgData1 toSpreadingEvent:se onDate:[NSDate dateWithTimeIntervalSince1970:2.0]];
    [FCADataModel addImageData:imgData2 toSpreadingEvent:se onDate:[NSDate dateWithTimeIntervalSince1970:1.0]];
    
    //Get sorted array of photos for spreading event
    NSNumber* N = [FCADataModel numberOfPhotosForSpreadingEvent:se];
    XCTAssertTrue(N.intValue == 2, @"Found %d, expected 2", N.intValue);
    
    //Tidy up + cascade delete
    [FCADataModel removeField:f1];
    
    //What is the field is deleted?
    N = [FCADataModel numberOfPhotosForSpreadingEvent:se];
    XCTAssertTrue(N.intValue == 0, @"Found %d, expected 0", N.intValue);
    
    //Check number of photos remains unchanged
    NSUInteger after = [[[FCADataModel managedObjectContext] executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Photo"] error:&err] count];
    XCTAssertTrue((before==after), @"Was expecting %lu photos, found %lu", before, after);
}


@end
