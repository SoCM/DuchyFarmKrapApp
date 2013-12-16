//
//  SpreadingEvent.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 16/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Field, ManureQuality, ManureType, Photo;

@interface SpreadingEvent : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * density;
@property (nonatomic, retain) Field *field;
@property (nonatomic, retain) ManureQuality *manureQuality;
@property (nonatomic, retain) ManureType *manureType;
@property (nonatomic, retain) NSSet *photos;
@end

@interface SpreadingEvent (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
