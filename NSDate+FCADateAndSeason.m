//
//  NSDate+FCADateAndSeason.m
//  FarmKrappApp
//
//  Created by Nicholas Outram on 31/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import "NSDate+FCADateAndSeason.h"

@implementation NSDate (FCADateAndSeason)
-(SEASON)season
{
    //Get the season
    SEASON _season;
    NSString* month = [[self dateComponentsAsDictionaryUsingGMT:YES] valueForKey:@"month"];
    NSUInteger uMonth = [month intValue];
    switch (uMonth) {
        case 8:
        case 9:
        case 10:
            _season = AUTUMN;
            break;
        case 11:
        case 12:
        case 1:
            _season = WINTER;
            break;
        case 2:
        case 3:
        case 4:
            _season = SPRING;
            break;
        case 5:
        case 6:
        case 7:
            _season = SUMMER;
            break;
        default:
            //OOPS
            _season = -1;
            break;
    }
    return _season;
}
-(NSString*)seasonString
{
    SEASON _season = [self season];
    switch (_season) {
        case AUTUMN:
            return @"AUTUMN";
            break;
        case WINTER:
            return @"WINTER";
            break;
        case SUMMER:
            return @"SUMMER";
            break;
        case SPRING:
            return @"SPRING";
            break;
        default:
            return nil;
            break;
    }
}
@end
