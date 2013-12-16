//
//  SoilType.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 16/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Field;

@interface SoilType : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * seqID;
@property (nonatomic, retain) NSSet *fields;
@end

@interface SoilType (CoreDataGeneratedAccessors)

- (void)addFieldsObject:(Field *)value;
- (void)removeFieldsObject:(Field *)value;
- (void)addFields:(NSSet *)values;
- (void)removeFields:(NSSet *)values;

@end
