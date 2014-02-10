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


#pragma mark - class for calculating nutrient availability
@interface FCAAvailableNutrients ()

@property(readwrite, nonatomic, strong) SpreadingEvent* spreadingEvent;
@property(readwrite, nonatomic, assign) BOOL metric;
@property(readonly, nonatomic, strong) NSNumber* nitrogen;
@property(readonly, nonatomic, strong) NSNumber* phosphate;
@property(readonly, nonatomic, strong) NSNumber* potassium;

-(FCAAvailableNutrients*)calculateAvailableNutrients;

@end

//Seperate class for calculating nutrients
//This is seperate so it can pre-calculate values and thus improve performance when calculating for different rates
@implementation FCAAvailableNutrients {
    //Dictionary of data derived from DEFRA
    NSDictionary* _dict;
    SEASON season;
    SOIL_TYPE soil_type;
    CROP_TYPE crop_type;
    NSString* manureTypeID;
    
    //Internal cache
    ManureQuality* _qual;
    NSArray* _N;
    NSArray* _P;
    NSArray* _K;
}

@synthesize spreadingEvent = _spreadingEvent;
@synthesize phosphate = _phosphate;
@synthesize potassium = _potassium;
@synthesize nitrogen = _nitrogen;

- (id)initWithSpreadingEvent:(SpreadingEvent*)se
{
    self = [super init];
    if (self) {
        self.spreadingEvent = se;
        _qual = nil;
        
        //Get the season
        season = [se.date season];
        
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
                        break;
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
                        break;
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
    
    //PHASE 2 - calculate
    [self calculateAvailableNutrients];
    
    return self;
}
-(FCAAvailableNutrients*)calculateAvailableNutrients
{
    
    //Drill down into the object heirarchy (an array of dictionaries)
    
    // qual.seqID determines the quality
    // crop_type determines the crop type as "AllCrops" or "GrassWinterOilseedRape"

    //Generic block
    BOOL(^foundit)(id, NSUInteger,BOOL*) = ^(id obj, NSUInteger idx, BOOL* stop)
    {
        NSNumber* next = [obj objectForKey:@"seqID"];
        if (next.intValue ==  self.spreadingEvent.manureQuality.seqID.intValue) {
            *stop = YES;
            return YES;
        } else {
            return NO;
        }
    };

    NSUInteger idxN, idxP, idxK;
    NSNumber *nvalueForAllCrops, *pvalueForAllCrops, *kvalueForAllCrops;
    NSNumber *nvalueForGrassWinterOilseedRape, *pvalueForGrassWinterOilseedRape, *kvalueForGrassWinterOilseedRape;
    
    //Look up NPK Values (metric)
    idxN = [_N indexOfObjectPassingTest:foundit];
    idxP = [_P indexOfObjectPassingTest:foundit];
    idxK = [_K indexOfObjectPassingTest:foundit];
    
    nvalueForAllCrops = [[_N objectAtIndex:idxN] objectForKey:@"AllCrops"];
//    nvalueForGrassWinterOilseedRape = [[_N objectAtIndex:idxN] objectForKey:@"GrassWinterOilseedRape"];

    pvalueForAllCrops = [[_P objectAtIndex:idxP] objectForKey:@"AllCrops"];
//    pvalueForGrassWinterOilseedRape = [[_P objectAtIndex:idxP] objectForKey:@"GrassWinterOilseedRape"];
    
    kvalueForAllCrops = [[_K objectAtIndex:idxK] objectForKey:@"AllCrops"];
//    kvalueForGrassWinterOilseedRape = [[_K objectAtIndex:idxK] objectForKey:@"GrassWinterOilseedRape"];
    
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
    
    // NOW SCALE (depending on manure type data) to units per hectare
    // I took the bottom table from the DEFRA data
    double fScale;
    if ([self.spreadingEvent.manureType.stringID isEqualToString:@"CattleSlurry"]) {
        //CattleSlurry data based on 100m3/ha
        fScale = 0.01;
    }
    else if ([self.spreadingEvent.manureType.stringID isEqualToString:@"PigSlurry"]) {
        //Pig slurry data based on 50m3/ha
        fScale = 0.02;
    }
    else if ([self.spreadingEvent.manureType.stringID isEqualToString:@"FarmyardManure"]) {
        //FYM data based on 50m3/ha
        fScale = 0.02;
    }
    else if ([self.spreadingEvent.manureType.stringID isEqualToString:@"PoultryLitter"]) {
        //Poultry litter: based on 10t/ha
        fScale = 0.1;
    } else {
        NSLog(@"Serious error in %s", __PRETTY_FUNCTION__);
        fScale = -1.0;      //This will make it apparent something is wrong (defensive strategy)
    }

    //Scale to 1 unit / ha
    _nitrogen  = [NSNumber numberWithDouble:_nitrogen.doubleValue  * fScale];
    _phosphate = [NSNumber numberWithDouble:_phosphate.doubleValue * fScale];
    _potassium = [NSNumber numberWithDouble:_potassium.doubleValue * fScale];
    
    return self;
}
//Available nutrient for a given spreading event
-(NSNumber*)nitrogenAvailable
{
    return [self nitrogenAvailableForRate:self.spreadingEvent.density];
}
-(NSNumber*)phosphateAvailable
{
    return [self phosphateAvailableForRate:self.spreadingEvent.density];
}
-(NSNumber*)potassiumAvailable
{
    return [self potassiumAvailableForRate:self.spreadingEvent.density];
}
+(NSString*)stringFormatForNutrientRate:(NSNumber*)rate usingMetric:(BOOL)isMetric
{
    double fValue = [rate doubleValue];
    if (isMetric == NO) {
        fValue *= 0.8130081300813;
        return [NSString stringWithFormat:@"%5.1f units/acre", fValue];
    } else {
        return [NSString stringWithFormat:@"%5.1f Kg/ha", fValue];
    }
}

-(NSNumber*)nitrogenAvailableForRate:(NSNumber*)rate
{
    float fN1 = [[self nitrogen] doubleValue] * rate.doubleValue;
    return [NSNumber numberWithDouble:fN1];
}
-(NSNumber*)phosphateAvailableForRate:(NSNumber*)rate
{
    float fP1 = self.phosphate.doubleValue * rate.doubleValue;
    return [NSNumber numberWithDouble:fP1];
}
-(NSNumber*)potassiumAvailableForRate:(NSNumber*) rate
{
    float fK1 = [[self potassium] doubleValue] * rate.doubleValue;
    return [NSNumber numberWithDouble:fK1];
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
-(NSString*)rateAsStringUsingMetric:(BOOL)isMetric
{
    NSString *units;
    
    //First the manure type
    BOOL isSlurry;
    double fRate = self.density.doubleValue;
    
    if ([self.manureType.stringID isEqualToString:@"CattleSlurry"] || [self.manureType.stringID isEqualToString:@"PigSlurry"]) {
        isSlurry = YES;
    } else {
        isSlurry = NO;
    }

    //Now derive the label based on metric/imperial setting
    if (isMetric) {
        if (isSlurry) {
            units = @"m3/ha";
        } else {
            units = @"tonnes/ha";
        }
    } else {
        if (isSlurry) {
            fRate *= 89.0183597;
            units = @"gallons/acre";
        } else {
            fRate *= 0.398294251;
            units = @"tons/acre";
        }
    }
    return [NSString stringWithFormat:@"%u %@", (unsigned)round(fRate), units];
}

-(NSString*)volumeAsStringUsingMetric:(BOOL)isMetric
{
    NSString *units;
    
    //First the manure type
    BOOL isSlurry;
    double fQuantity = self.density.doubleValue * self.field.sizeInHectares.doubleValue;
    
    if ([self.manureType.stringID isEqualToString:@"CattleSlurry"] || [self.manureType.stringID isEqualToString:@"PigSlurry"]) {
        isSlurry = YES;
    } else {
        isSlurry = NO;
    }
    
    //Now derive the label based on metric/imperial setting
    if (isMetric) {
        if (isSlurry) {
            units = @"m3";
        } else {
            units = @"tonnes";
        }
    } else {
        if (isSlurry) {
            fQuantity *= 219.969157;
            units = @"gallons";
        } else {
            fQuantity *= 0.984206528;
            units = @"tons";
        }
    }
    return [NSString stringWithFormat:@"%u %@", (unsigned)round(fQuantity), units];
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
