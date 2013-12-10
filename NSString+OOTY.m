//
//  NSString+OOTY.m
//  secchi
//
//  Created by Nicholas Outram on 18/09/2012.
//  Copyright (c) 2012 Plymouth University. All rights reserved.
//

#import "NSString+OOTY.h"

@implementation NSString (OOTY)

+(NSString*)CGRectAsString:(CGRect)r
{
    return [NSString stringWithFormat:@"origin:%@\tsize:%@", [NSString CGPointAsString:r.origin],[NSString CGSizeAsString:r.size] ];
}
+(NSString*)CGSizeAsString:(CGSize)s
{
    return [NSString stringWithFormat:@"(w=%f,h=%f)", s.width, s.height];
}
+(NSString*)CGPointAsString:(CGPoint)p
{
    return [NSString stringWithFormat:@"(x=%f,y=%f)", p.x,p.y];
}


@end
