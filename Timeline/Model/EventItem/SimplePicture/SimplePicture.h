//
//  SimplePicture.h
//  Timeline
//
//  Created by Alessandro Boron on 04/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventItem.h"

@interface SimplePicture : EventItem

@property (strong, nonatomic) UIImage *image;

//The designated initializer
- (id)initSimplePictureWithImage:(UIImage *)image eventItemCreator:(NSString *)eventCreator;

@end
