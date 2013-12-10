//
//  PhotoViewController.h
//  secchi
//
//  Created by Nicholas Outram on 17/07/2012.
//  Copyright (c) 2012 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SECCHIMeasurementProtocol.h"
@protocol PhotoViewControllerDelegateProtocol <NSObject>
-(void)saveImage:(UIImage*)image;
@end

@interface PhotoViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    
}

@property (nonatomic, strong) UIImage* image;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraBarButtonItem;

@property (weak, nonatomic) id<PhotoViewControllerDelegateProtocol>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)doTakePhoto:(id)sender;
- (IBAction)doSave:(id)sender;



@end
 