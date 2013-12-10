//
//  UIScreen+OOTY.m
//  secchi
//
//  Created by Nicholas Outram on 24/10/2012.
//  Copyright (c) 2012 Plymouth University. All rights reserved.
//

#import "UIScreen+OOTY.h"

@implementation UIScreen (OOTY)

+(float)aspectRatio
{
    CGRect b = [[UIScreen mainScreen] bounds];
    float aspect = b.size.height / b.size.width;
    return aspect;
}

+(NSUInteger)deviceClass
{
    if ([UIScreen aspectRatio] <= 1.5) {
        return UIScreenDeviceClassiPhone4SAspect1p5;
    } else {
        return UIScreenDeviceClassiPhone5Aspect1p775;
    }
}
@end
