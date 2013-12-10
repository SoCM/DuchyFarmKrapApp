//
//  FCAFieldCell.h
//  FarmKrappApp
//
//  Created by Nicholas Outram on 10/12/2013.
//  Copyright (c) 2013 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCAFieldCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *spreadingEventLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@end
