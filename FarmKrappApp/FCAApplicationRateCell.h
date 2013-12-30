//
//  FCAApplicationRateCell.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 16/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCAApplicationRateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *NitrogenLabel;
@property (weak, nonatomic) IBOutlet UILabel *PhosphateLabel;
@property (weak, nonatomic) IBOutlet UILabel *PotassiumLabel;

@end
