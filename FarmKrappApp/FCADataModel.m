//
//  FCADataModel.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 06/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "FCADataModel.h"
#import "NSDate+NSDateUOPCategory.h"

//Singleton Application Delegate
#define FCA_APP_DELEGATE (SoCMAppDelegate*)[[UIApplication sharedApplication] delegate]


#pragma mark - class for calculating nutrient availability
@interface FCAAvailableNutrients ()

@property(readwrite, nonatomic, strong) SpreadingEvent* spreadingEvent;
@property(readwrite, nonatomic, assign) BOOL metric;

@property(readonly, nonatomic, strong) NSNumber* nitrogen;
@property(readonly, nonatomic, strong) NSNumber* phosphate;
@property(readonly, nonatomic, strong) NSNumber* potassium;
@end

@implementation FCAAvailableNutrients {
    //Dictionary of data derived from DEFRA
    NSDictionary* _dict;
    enum {AUTUMN, WINTER, SPRING, SUMMER} season;
    SOIL_TYPE soil_type;
    CROP_TYPE crop_type;
    NSString* manureTypeID;
    
    //Internal cache
    NSNumber* _rate;
    ManureQuality* _qual;
    NSArray* _N;
    NSArray* _P;
    NSArray* _K;
}

@synthesize spreadingEvent = _spreadingEvent;
@synthesize phosphate = _phosphate;
@synthesize potassium = _potassium;
@synthesize nitrogen = _nitrogen;

- (id)initWithSpreadingEvent:(SpreadingEvent*)se inMetric:(BOOL)m
{
    self = [super init];
    if (self) {
        self.spreadingEvent = se;
        self.metric = m;
        _qual = nil;
        _rate = nil;
        
        //Get the season
        NSString* month = [[se.date dateComponentsAsDictionaryUsingGMT:YES] valueForKey:@"month"];
        NSUInteger uMonth = [month intValue];
        switch (uMonth) {
            case 8:
            case 9:
            case 10:
                season = AUTUMN;
                break;
            case 11:
            case 12:
            case 1:
                season = WINTER;
                break;
            case 2:
            case 3:
            case 4:
                season = SPRING;
                break;
            case 5:
            case 6:
            case 7:
                season = SUMMER;
                break;
            default:
                //OOPS
                season = -1;
                break;
        }
        
        //Soil type
        SoilType* st = (SoilType*)se.field.soilType;
        soil_type = [st.seqID intValue];
        
        //Crop type
        CropType* ct = (CropType*)se.field.cropType;
        crop_type = [ct.seqID intValue];
        
        //ManureType
        manureTypeID = se.manureType.stringID;
        
        //Get top level dictionary
        _dict = [[FCA_APP_DELEGATE availableNutrients100m3] objectForKey:manureTypeID];
        
        //***************************************************
        //Get the NPK objects (each an array of dictionaries)
        //***************************************************
        _P = [_dict objectForKey:@"P"]; //Array
        _K = [_dict objectForKey:@"K"]; //Array
        
        //N is buried a little deeper
        switch (season) {
            case AUTUMN:
                //st.seqID is the value
                switch (st.seqID.intValue) {
                    case SOILTYPE_SANDY_SHALLOW:
                        _N = [_dict valueForKeyPath:@"N.Autumn.SandyShallow"];
                        break;
                    case SOILTYPE_MEDIUM_HEAVY:
                        _N = [_dict valueForKeyPath:@"N.Autumn.MediumHeavy"];
                    default:
                        NSLog(@"Error - did not recognise soil type");
                        _N = nil;
                        break;
                }
                break;
                
            case WINTER:
                switch (st.seqID.intValue) {
                    case SOILTYPE_SANDY_SHALLOW:
                        _N = [_dict valueForKeyPath:@"N.Winter.SandyShallow"];
                        break;
                    case SOILTYPE_MEDIUM_HEAVY:
                        _N = [_dict valueForKeyPath:@"N.Winter.MediumHeavy"];
                    default:
                        NSLog(@"Error - did not recognise soil type");
                        _N = nil;
                        break;
                }
                break;
                
            case SPRING:
                _N = [_dict valueForKeyPath:@"N.Spring"];
                break;
                
            case SUMMER:
                _N = [_dict valueForKeyPath:@"N.Summer"];
                break;

            default:
                NSLog(@"Error");
                break;
        }
        
    }
    return self;
}
-(FCAAvailableNutrients*)availableNutrientsForRate:(NSNumber*)rate andQuality:(ManureQuality*)qual
{
    //Don't re-calculate if the parameters are the same
    if ((rate.intValue == _rate.intValue ) && (qual.seqID.intValue == _qual.seqID.intValue)) {
        return self;
    }
    //Set internal state
    _rate = rate;
    _qual = qual;
    
    //Drill down into the object heirarchy (an array of dictionaries)
    
    // qual.seqID determines the quality
    // crop_type determines the crop type as "AllCrops" or "GrassWinterOilseedRape"

    //Generic block
    BOOL(^foundit)(id, NSUInteger,BOOL*) = ^(id obj, NSUInteger idx, BOOL* stop)
    {
        NSNumber* next = [obj objectForKey:@"seqID"];
        if (next.intValue == _qual.seqID.intValue) {
            *stop = YES;
            return YES;
        } else {
            return NO;
        }
    };

    NSUInteger idxN, idxP, idxK;
    NSNumber *nvalueForAllCrops, *pvalueForAllCrops, *kvalueForAllCrops;
    NSNumber *nvalueForGrassWinterOilseedRape, *pvalueForGrassWinterOilseedRape, *kvalueForGrassWinterOilseedRape;
    
    //Potassium
    idxN = [_N indexOfObjectPassingTest:foundit];
    idxP = [_P indexOfObjectPassingTest:foundit];
    idxK = [_K indexOfObjectPassingTest:foundit];
    
    nvalueForAllCrops = [[_N objectAtIndex:idxN] objectForKey:@"AllCrops"];
    nvalueForGrassWinterOilseedRape = [[_N objectAtIndex:idxN] objectForKey:@"GrassWinterOilseedRape"];

    pvalueForAllCrops = [[_P objectAtIndex:idxP] objectForKey:@"AllCrops"];
    pvalueForGrassWinterOilseedRape = [[_P objectAtIndex:idxP] objectForKey:@"GrassWinterOilseedRape"];

    
    kvalueForAllCrops = [[_K objectAtIndex:idxK] objectForKey:@"AllCrops"];
    kvalueForGrassWinterOilseedRape = [[_K objectAtIndex:idxK] objectForKey:@"GrassWinterOilseedRape"];
    
    switch (crop_type) {
        case CROPTYPE_ALL_CROPS:
            _nitrogen = nvalueForAllCrops;
            _phosphate = pvalueForAllCrops;
            _potassium = kvalueForAllCrops;
            break;
        case CROPTYPE_GRASSLAND_OR_WINTER_OILSEED_RAPE:
            //Try and see if such a value exists
            nvalueForGrassWinterOilseedRape = [[_N objectAtIndex:idxN] objectForKey:@"GrassWinterOilseedRape"];
            pvalueForGrassWinterOilseedRape = [[_P objectAtIndex:idxP] objectForKey:@"GrassWinterOilseedRape"];
            kvalueForGrassWinterOilseedRape = [[_K objectAtIndex:idxK] objectForKey:@"GrassWinterOilseedRape"];

            _nitrogen = (nvalueForGrassWinterOilseedRape==nil) ? nvalueForAllCrops : nvalueForGrassWinterOilseedRape;
            _phosphate = (pvalueForGrassWinterOilseedRape==nil) ? pvalueForAllCrops : pvalueForGrassWinterOilseedRape;
            _potassium = (kvalueForGrassWinterOilseedRape==nil) ? kvalueForAllCrops : kvalueForGrassWinterOilseedRape;
            break;
            
        default:
            NSLog(@"Invalid crop type: %s", __PRETTY_FUNCTION__);
    }
    return self;
}

@end
#pragma mark - Category on SoilType
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

#pragma mark - Category on CropType
@implementation CropType (FCADataModel)
+(CropType*)FetchCropTypeForID:(NSNumber*)seqID
{
    NSError* err;
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"CropType"];
    fr.predicate = [NSPredicate predicateWithFormat:@"seqID == %@", seqID];
    return ([[[FCADataModel managedObjectContext] executeFetchRequest:fr error:&err] objectAtIndex:0]);
}
@end

#pragma mark - Category on ManureType
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

#pragma mark - Category on ManureQuality
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

#pragma mark - Category on Field
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
    return [NSNumber numberWithLong:[[FCADataModel arrayOfFields]count]];

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
    NSUInteger N = [[self arrayOfSpreadingEventsForField:field] count];
    return [NSNumber numberWithLong:N];
}
+(NSDictionary*)availableNutrients100m3
{
    return [FCA_APP_DELEGATE availableNutrients100m3];
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

#pragma mark - image selection
+(NSString*)imageNameForManureType:(ManureType*)mt andRate:(NSNumber*)rate
{
    float fRate = rate.floatValue;
    if ([mt.stringID isEqualToString:@"CattleSlurry"]) {
        if (fRate <= 37.5) {
            return @"cattle_25m3.jpg";
        } else if (fRate <= 75.0) {
            return @"cattle_50m3.jpg";
        } else {
            return @"cattle_100m3.jpg";
        }
    }
    else if ([mt.stringID isEqualToString:@"FarmyardManure"]) {
        if (fRate <= 37.5) {
            return @"fym_25t.jpg";
        } else {
            return @"fym_50t.jpg";
        }
    }
    else if ([mt.stringID isEqualToString:@"PigSlurry"]) {
        if (fRate <= 37.5) {
            return @"pig_25m3.jpg";
        } else {
            return @"pig_50m3.jpg";
        }
    }
    else if ([mt.stringID isEqualToString:@"PoultryLitter"]) {
        if (fRate <= 7.5) {
            return @"poultry_5t.jpg";
        } else {
            return @"poultry_10t.jpg";
        }
    } else {
        return nil;
    }
}
@end
