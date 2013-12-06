//
//  Field.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 05/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Field : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * soilType;
@property (nonatomic, retain) NSNumber * cropType;
@property (nonatomic, retain) NSNumber * sizeInHectares;
@property (nonatomic, retain) NSSet *spreadingEvents;
@end

@interface Field (CoreDataGeneratedAccessors)

- (void)addSpreadingEventsObject:(NSManagedObject *)value;
- (void)removeSpreadingEventsObject:(NSManagedObject *)value;
- (void)addSpreadingEvents:(NSSet *)values;
- (void)removeSpreadingEvents:(NSSet *)values;

@end
