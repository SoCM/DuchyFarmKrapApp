//
//  SpreadingEvent.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 05/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Field;

@interface SpreadingEvent : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * manureType;
@property (nonatomic, retain) NSNumber * quality;
@property (nonatomic, retain) NSNumber * density;
@property (nonatomic, retain) Field *field;

@end
