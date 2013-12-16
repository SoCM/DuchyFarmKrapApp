//
//  Photo.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 16/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpreadingEvent;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) SpreadingEvent *spreadingEvent;

@end
