//
//  NSString+OOTY.h
//  secchi
//
//  Created by Nicholas Outram on 18/09/2012.
//  Copyright (c) 2012 Plymouth University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (OOTY)
+(NSString*)CGRectAsString:(CGRect)r;
+(NSString*)CGSizeAsString:(CGSize)s;
+(NSString*)CGPointAsString:(CGPoint)p;

@end
