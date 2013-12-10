//
//  UIImage+UOPCategory.m
//  ResizeCategory
//
//  Created by noutram on 08/04/2010.
//  Copyright 2010 University of Plymouth. All rights reserved.
//

#import "UIImageUOPCategory.h"

@implementation UIImage (UIImageUOPCategory)

-(NSData*)imageAsData
{
	return UIImagePNGRepresentation(self);
}

-(UIImage*)resizeByFactor:(float)ratio
{
	CGSize sz = self.size;
	sz.width = sz.width * ratio;									//Scale the width
	sz.height = sz.height * ratio;									//and height.
	UIGraphicsBeginImageContext(sz);								//Begin processing on a back buffer of size sz
	[self drawInRect:CGRectMake(0,0,sz.width,sz.height)];			//Draw the original image into the (resized) image buffer
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();//Get the image buffer
	UIGraphicsEndImageContext();									//End processing
	return newImage;
}

+(UIImage*)imageFromPDFWithURL:(NSURL*)url page:(NSInteger)p scaledToFitSize:(CGSize)s
{
	//NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:str withExtension:@"pdf"];	
	if (p<=0) return NULL;
	
	//Open document
	CGPDFDocumentRef document;
	document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
	
	//Get page
	NSInteger numberOfPages = CGPDFDocumentGetNumberOfPages(document);
    if (p > numberOfPages) {
        CGPDFDocumentRelease(document);
		return NULL;
	}	
		
	//Get the page
	CGPDFPageRef currentPage;
	currentPage = CGPDFDocumentGetPage(document, p);
	
	//Size of the PDF
	CGRect pageRect = CGPDFPageGetBoxRect(currentPage, kCGPDFMediaBox);
	
	//Scale to aspect-fit (either full width or full height)
	float xs = s.width/pageRect.size.width;
	float ys = s.height/pageRect.size.height;
	float scale = MIN(xs,ys);
	pageRect.size.height = pageRect.size.height * scale;
	pageRect.size.width  = pageRect.size.width  * scale;
	
	//Create context
	UIGraphicsBeginImageContext(pageRect.size);
	
	//Get context
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// First fill the background with white.
	CGContextSetRGBFillColor(ctx, 1.0,1.0,1.0,1.0);
	CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);	
//	CGContextFillRect(ctx,pageRect);						//Draw white backing
	
	//Save context
	CGContextSaveGState(ctx);
	
	//Correct user coordinate system
	CGContextTranslateCTM(ctx, 0.0, pageRect.size.height);	//Move origin
	CGContextScaleCTM(ctx, 1.0, -1.0);						//Flip vertically

	//Backing fill - white
	CGContextFillRect(ctx, pageRect);
	
	//Scaling factor for PDF
	CGContextScaleCTM(ctx, scale, scale);					//Scale to fit pageSize

	//Draw PDF
	CGContextDrawPDFPage(ctx, currentPage);					//Render PDF

	//Construct image
	UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
	
	//Restore context state
	CGContextRestoreGState(ctx);

	//End of graphics context
	UIGraphicsEndImageContext();
	
	//Tidy up
	CGPDFDocumentRelease(document);
	
	return img;
}

@end 
