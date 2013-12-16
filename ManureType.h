//
//  ManureType.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 16/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ManureQuality, SpreadingEvent;

@interface ManureType : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * stringID;
@property (nonatomic, retain) NSSet *qualitySet;
@property (nonatomic, retain) NSSet *spreadingEvents;
@end

@interface ManureType (CoreDataGeneratedAccessors)

- (void)addQualitySetObject:(ManureQuality *)value;
- (void)removeQualitySetObject:(ManureQuality *)value;
- (void)addQualitySet:(NSSet *)values;
- (void)removeQualitySet:(NSSet *)values;

- (void)addSpreadingEventsObject:(SpreadingEvent *)value;
- (void)removeSpreadingEventsObject:(SpreadingEvent *)value;
- (void)addSpreadingEvents:(NSSet *)values;
- (void)removeSpreadingEvents:(NSSet *)values;

@end
