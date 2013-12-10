//
//  PhotoViewController.m
//  secchi
//
//  Created by Nicholas Outram on 17/07/2012.
//  Copyright (c) 2012 Plymouth University. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()
@property (readwrite, nonatomic, strong) UIImagePickerController* imagePicker;
@end

@implementation PhotoViewController {
    
}
@synthesize saveButton = _saveButton;
@synthesize cameraImageView = _cameraImageView;
@synthesize cameraBarButtonItem = _cameraBarButtonItem;
@synthesize imageView = _imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.saveButton.enabled = NO;    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO) {
        self.cameraImageView.alpha = 0.25;
        self.cameraBarButtonItem.enabled = NO;
    }

    if (self.image) {
        self.imageView.image = self.image;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setCameraImageView:nil];
    [self setCameraBarButtonItem:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}
- (IBAction)doTakePhoto:(id)sender {

    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO) {
        return;
    }
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imgPicker.allowsEditing = YES;
    imgPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    imgPicker.showsCameraControls = YES;
    imgPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imgPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    imgPicker.delegate = self;
    [self presentViewController:imgPicker animated:YES completion:^(){}];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [self dismissViewControllerAnimated:YES completion:^(){}];
    
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
//    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        
    // Handle a still image capture
    self.image = (UIImage *) [info objectForKey: UIImagePickerControllerEditedImage];
  
    //Choose the image
    if (self.image == nil) {
        self.image = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:^(){
        //Update screen
        self.cameraImageView.image = self.image;
        self.saveButton.enabled = YES;
    }];
}

- (IBAction)doSave:(id)sender {
    if (self.image) {
        // Save the new image (original or edited) to the Camera Roll
        BOOL saveToPhotoAlbum = [[NSUserDefaults standardUserDefaults] boolForKey:@"saveToPhotoAlbum"];
        if (saveToPhotoAlbum) {
            UIImageWriteToSavedPhotosAlbum (self.image, nil, nil , nil);
        }
        
        //Push back the information to the main view controller
        [self.delegate saveImage:self.image];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
