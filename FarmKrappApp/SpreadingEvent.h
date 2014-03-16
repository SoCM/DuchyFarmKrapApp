//
//  SpreadingEvent.h
//  FarmCrapApp
//
//  Created by Nicholas Outram on 16/03/2014.
//  Copyright (c) 2014 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Field, ManureQuality, ManureType;

@interface SpreadingEvent : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * density;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) Field *field;
@property (nonatomic, retain) ManureQuality *manureQuality;
@property (nonatomic, retain) ManureType *manureType;

@end
