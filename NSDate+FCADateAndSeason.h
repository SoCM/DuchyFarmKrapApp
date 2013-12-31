//
//  NSDate+FCADateAndSeason.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 31/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+NSDateUOPCategory.h"

typedef enum {AUTUMN, WINTER, SPRING, SUMMER} SEASON;

@interface NSDate (FCADateAndSeason)
-(SEASON)season;
-(NSString*)seasonString;
@end
