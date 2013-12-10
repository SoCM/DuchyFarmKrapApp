//
//  SpreadingEvent.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 10/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Field, Photo;

@interface SpreadingEvent : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * density;
@property (nonatomic, retain) NSNumber * manureType;
@property (nonatomic, retain) NSNumber * quality;
@property (nonatomic, retain) Field *field;
@property (nonatomic, retain) NSSet *photos;
@end

@interface SpreadingEvent (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
