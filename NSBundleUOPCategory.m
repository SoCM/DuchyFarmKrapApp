//
//  NSBundleUOPCategory.m
//  DocCategory
//
//  Created by noutram on 09/04/2010.
//  Copyright 2010 University of Plymouth. All rights reserved.
//

#import "NSBundleUOPCategory.h"


@implementation NSBundle (NSBundleUOPCategory)

+(NSString*) pathToDocumentsFolder
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;	
}
+(NSString*) pathToFileInDocumentsFolder:(NSString*)filename
{
	NSString *pathToDoc = [NSBundle pathToDocumentsFolder];
	return [pathToDoc stringByAppendingPathComponent:filename];
}

@end
