//
//  FCADataViewAdapter.h
//  FarmCrapApp
//
//  Created by Nicholas Outram on 11/04/2014.
//  Copyright (c) 2014 Plymouth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCADataModel.h"

@interface FCADataViewAdapter : NSObject {
    //Public iVars
}

//Public method declarations
@property(readwrite,nonatomic, weak) SpreadingEvent* spreadingEvent;

//Initialisation
-(id)initWithSpreadingEvent:(SpreadingEvent*)se;

//UI attributes
-(void)updateAttributesOfSlider:(UISlider *)slider andLabel:(UILabel*)label;
-(void)updateAttributesOfLabel:(UILabel *)label;

//Model attributes
-(void)updateModelFromSlider:(UISlider*)slider;

@end
