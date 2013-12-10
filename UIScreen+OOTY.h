//
//  UIScreen+OOTY.h
//  secchi
//
//  Created by Nicholas Outram on 24/10/2012.
//  Copyright (c) 2012 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIScreenDeviceClassiPhone4SAspect1p5  0
#define UIScreenDeviceClassiPhone5Aspect1p775 1

@interface UIScreen (OOTY)

+(float)aspectRatio;
+(NSUInteger)deviceClass;

@end
