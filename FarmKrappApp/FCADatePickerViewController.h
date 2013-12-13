//
//  FCADatePickerViewController.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 13/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCADatePickerViewController : UIViewController
@property(readwrite, nonatomic, copy) void(^callBackWithDate)(NSDate*);
@property (readwrite, nonatomic, strong) NSDate* initialDate;
@end
