//
//  Field.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 16/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpreadingEvent;

@interface Field : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sizeInHectares;
@property (nonatomic, retain) NSSet *spreadingEvents;
@property (nonatomic, retain) NSManagedObject *cropType;
@property (nonatomic, retain) NSManagedObject *soilType;
@end

@interface Field (CoreDataGeneratedAccessors)

- (void)addSpreadingEventsObject:(SpreadingEvent *)value;
- (void)removeSpreadingEventsObject:(SpreadingEvent *)value;
- (void)addSpreadingEvents:(NSSet *)values;
- (void)removeSpreadingEvents:(NSSet *)values;

@end
