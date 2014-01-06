//
//  NSDate+NSDateUOPCategory.h
//  secchi
//
//  Created by Nicholas Outram on 27/07/2012.
//  Copyright (c) 2012 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateUOPCategory)

-(NSDictionary*)dateComponentsAsDictionaryUsingGMT:(BOOL)usingGMT;
-(NSString*)filenameFriendlyDescription;
-(NSString*)stringForUKShortFormatUsingGMT:(BOOL)usingGMT;
+(NSDate*)dateWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day;

@end
