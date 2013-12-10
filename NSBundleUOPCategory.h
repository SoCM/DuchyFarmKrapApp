//
//  NSBundleUOPCategory.h
//  DocCategory
//
//  Created by noutram on 09/04/2010.
//  Copyright 2010 University of Plymouth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSBundle.h>

@interface NSBundle (NSBundleUOPCategory)  

+(NSString*) pathToDocumentsFolder;
+(NSString*) pathToFileInDocumentsFolder:(NSString*)filename;

@end
