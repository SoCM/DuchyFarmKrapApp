//
//  NSDate+NSDateUOPCategory.m
//  secchi
//
//  Created by Nicholas Outram on 27/07/2012.
//  Copyright (c) 2012 Plymouth University. All rights reserved.
//

#import "NSDate+NSDateUOPCategory.h"

@implementation NSDate (NSDateUOPCategory)

-(NSDictionary*)dateComponentsAsDictionaryUsingGMT:(BOOL)usingGMT
{
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit cu = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit;
    
    if (usingGMT) {
        [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];        
    }
    
    NSDateComponents *components = [cal components:cu fromDate:self];
    
    NSDictionary* dict = @{
    @"year" : [NSNumber numberWithInteger:components.year],
    @"month" : [NSNumber numberWithInteger:components.month],
    @"day" : [NSNumber numberWithInteger:components.day],
    @"hour" : [NSNumber numberWithInteger:components.hour],
    @"minute" : [NSNumber numberWithInteger:components.minute],
    @"second" : [NSNumber numberWithInteger:components.second],
    @"timeZone" : [components.timeZone abbreviation]
    };
    
    return dict;
}

-(NSString*)filenameFriendlyDescription
{
    NSMutableString* newDesc = [[NSMutableString alloc] initWithString:self.description];
    NSRange r = NSMakeRange(0, newDesc.length);
    [newDesc replaceOccurrencesOfString:@":" withString:@"_" options:0 range:r];
    return newDesc;
}
//String as DD/MM/YYYY
-(NSString*)stringForUKShortFormatUsingGMT:(BOOL)usingGMT
{
    NSString *dd   = [[self dateComponentsAsDictionaryUsingGMT:usingGMT] objectForKey:@"day"];
    NSString *mm   = [[self dateComponentsAsDictionaryUsingGMT:usingGMT] objectForKey:@"month"];
    NSString *yyyy = [[self dateComponentsAsDictionaryUsingGMT:usingGMT] objectForKey:@"year"];
    NSString *result = [NSString stringWithFormat:@"%@/%@/%@", dd, mm, yyyy];
    return result;
}
+(NSDate*)dateWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* dc = [[NSDateComponents alloc] init];
    dc.day = day;
    dc.year = year;
    dc.month = month;
    return [cal dateFromComponents:dc];
}
@end
