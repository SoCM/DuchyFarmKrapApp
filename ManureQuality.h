//
//  ManureQuality.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 16/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ManureType, SpreadingEvent;

@interface ManureQuality : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * seqID;
@property (nonatomic, retain) ManureType *manureType;
@property (nonatomic, retain) NSSet *spreadingEvents;
@end

@interface ManureQuality (CoreDataGeneratedAccessors)

- (void)addSpreadingEventsObject:(SpreadingEvent *)value;
- (void)removeSpreadingEventsObject:(SpreadingEvent *)value;
- (void)addSpreadingEvents:(NSSet *)values;
- (void)removeSpreadingEvents:(NSSet *)values;

@end
