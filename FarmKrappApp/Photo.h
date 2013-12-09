//
//  Photo.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 09/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SpreadingEvent;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) SpreadingEvent *spreadingEvent;

@end
