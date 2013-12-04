//
// Created by Li Shuo on 13-9-12.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface DotView : UIView
@property (nonatomic, assign) int dotNumber;
@property (nonatomic, assign) BOOL showPlaceHolder;
@property (nonatomic, assign) int numberOfPlacesHolder;
@property (nonatomic, assign) int maxDotNumber;
@property (nonatomic, assign) float dotRadius;
@property (nonatomic, assign) float spaceBetween;
@property (nonatomic, assign) float leftMargin;
@end