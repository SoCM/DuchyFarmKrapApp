//
//  UIImage+UOPCategory.h
//  ResizeCategory
//
//  Created by noutram on 08/04/2010.
//  Copyright 2010 University of Plymouth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//General extensions to UIImage
@interface UIImage (UIImageUOPCategory) 

-(NSData*)imageAsData;
-(UIImage*)resizeByFactor:(float)ratio;	
+(UIImage*)imageFromPDFWithURL:(NSURL*)url page:(NSInteger)p scaledToFitSize:(CGSize)s;

@end
