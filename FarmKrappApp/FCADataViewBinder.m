//
//  FCADataViewAdapter.m
//  FarmCrapApp
//
//  Created by Nicholas Outram on 11/04/2014.
//  Copyright (c) 2014 Plymouth University. All rights reserved.
//

#import "FCADataViewBinder.h"

//Private methods
@interface FCADataViewBinder ()
@property(readonly) BOOL isMetric;
@property(readonly) BOOL isSlurry;
@property(readonly) BOOL isPoultryLitter;
@property(readonly) NSDictionary* dictionaryOfExtents;
@property(readonly) NSString* rateUnitsAsString;
@end


@implementation FCADataViewBinder {
    //Private instance variables
    BOOL _isMetric;
    dispatch_once_t pred;
}

//Public method implementations
@synthesize spreadingEvent = _spreadingEvent;
@synthesize isSlurry = _isSlurry;
@synthesize isPoultryLitter = _isPoultryLitter;
@synthesize dictionaryOfExtents = _dictionaryOfExtents;
@synthesize rateUnitsAsString = _rateUnitsAsString;

//Returns a BOOL indicating if the data input/output is metric or imperial
-(BOOL)isMetric
{
    void(^doOnceBlock)(void) = ^(void) {
        _isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"Metric"];
    };
    dispatch_once(&pred, doOnceBlock);
    return _isMetric;
}
-(BOOL)isSlurry
{
    _isSlurry = ([self.spreadingEvent.manureType.stringID isEqualToString:@"CattleSlurry"] || [self.spreadingEvent.manureType.stringID isEqualToString:@"PigSlurry"]) ? YES : NO;
    return _isSlurry;
}
-(BOOL)isPoultryLitter
{
    _isPoultryLitter = ([self.spreadingEvent.manureType.stringID isEqualToString:@"PoultryLitter"])  ? YES : NO;
    return _isPoultryLitter;
}
-(NSDictionary *)dictionaryOfExtents
{
    if (!_dictionaryOfExtents) {
        if (self.isMetric) {
            _dictionaryOfExtents = @{@"CattleSlurry" :   @{@"MAX" : @100, @"STEP" : @1},
                                     @"FarmyardManure" : @{@"MAX" : @100, @"STEP" : @1},
                                     @"PigSlurry" :      @{@"MAX" : @100, @"STEP" : @1},
                                     @"PoultryLitter" :  @{@"MAX" : @15,  @"STEP" : @0.5}
                                     };
        } else {
            _dictionaryOfExtents = @{@"CattleSlurry" :   @{@"MAX" : @10000, @"STEP" : @50},
                                     @"FarmyardManure" : @{@"MAX" : @100,   @"STEP" : @1},
                                     @"PigSlurry" :      @{@"MAX" : @10000, @"STEP" : @50},
                                     @"PoultryLitter" :  @{@"MAX" : @10,    @"STEP" : @0.5}
                                     };
        }
    }
    return _dictionaryOfExtents;
}

//The units for a given spreading event
-(NSString*)rateUnitsAsString
{
    NSString *units;
    
    //Now derive the label based on metric/imperial setting
    if (self.isMetric) {
        if (self.isSlurry) {
            units = @"m3/ha";
        } else {
            units = @"tonnes/ha";
        }
    } else {
        if (self.isSlurry) {
            units = @"gallons/acre";
        } else {
            units = @"tons/acre";
        }
    }
    return units;
}

-(id)initWithSpreadingEvent:(SpreadingEvent *)se
{
    self = [super init];
    if (self) {
        self.spreadingEvent = se;
    }
    return self;
}

-(void)updateAttributesOfLabel:(UILabel *)label
{
    
}

//Update the maxium value of the slider and the value itself
-(void)updateAttributesOfSlider:(UISlider *)slider andLabel:(UILabel*)label
{
    NSString* manureType = self.spreadingEvent.manureType.stringID;
    NSDictionary* metrics = [self.dictionaryOfExtents objectForKey:manureType];
    
    //Maximim value of slider
    double sliderMax = ((NSNumber*)[metrics objectForKey:@"MAX"]).doubleValue;
    double sliderInc = ((NSNumber*)[metrics objectForKey:@"STEP"]).doubleValue;
    sliderMax /= sliderInc;
    sliderMax = round(sliderMax);
    
    if (slider.maximumValue != sliderMax) {
        slider.maximumValue = sliderMax;
    }
    
    //
    //Update value of slider and label
    //
    double rate = self.spreadingEvent.density.doubleValue;  //true rate as metric
    
    //Conditionally scale to imperial
    if (self.isMetric == NO) {
        if (self.isSlurry) {
            rate *= km3PerHa_to_GalPerAcre;     //m3/ha -> Gal/Acre
        } else {
            rate *= kTonnesPerHa_to_TonPerAcre; //tonnes/ha -> ton/acre
        }
    }
    
    //Update Label
    rate = sliderInc*round(rate/sliderInc);
    if (sliderInc < 1.0) {
        label.text = [NSString stringWithFormat:@"%4.1f %@", rate, self.rateUnitsAsString];
    } else {
        label.text = [NSString stringWithFormat:@"%4.0f %@", rate, self.rateUnitsAsString];
    }

    //Update slider value
    slider.value = round(rate / sliderInc);
}

//Convert the slider value back to metric, round and store in model
-(void)updateModelFromSlider:(UISlider *)slider
{
    //Cludge - slider value should always be an integer
    slider.value = round(slider.value);
    
    NSString* manureType = self.spreadingEvent.manureType.stringID;
    NSDictionary* metrics = [self.dictionaryOfExtents objectForKey:manureType];
    
    //Increment of slider (value per unit on the slider)
    double sliderInc = ((NSNumber*)[metrics objectForKey:@"STEP"]).doubleValue;
    
    double rate = slider.value * sliderInc;
    if (self.isMetric) {
        self.spreadingEvent.density = [NSNumber numberWithDouble:rate];
    } else {
        if (self.isSlurry) {
            //Gal/Acre -> m3/ha
            self.spreadingEvent.density = [NSNumber numberWithDouble:rate*kGalPerAcre_to_m3Perha];
        } else {
            //Ton/acre -> Tonnes/ha
            self.spreadingEvent.density = [NSNumber numberWithDouble:rate*kTonPerAcre_to_TonnesPerHa];
        }
    }
}

@end
