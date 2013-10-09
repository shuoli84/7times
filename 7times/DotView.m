//
// Created by Li Shuo on 13-9-12.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DotView.h"

@interface DotView()
@property (nonatomic, strong) NSArray* colorArray;
@end

@implementation DotView {
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self){
        _colorArray = @[
            [UIColor colorWithRed:231.f/255.f green:76/255.f blue:60/255.f alpha:1.f],
            [UIColor colorWithRed:255.f/255.f green:128/255.f blue:0/255.f alpha:1.f],
            [UIColor colorWithRed:241.f/255.f green:196/255.f blue:15/255.f alpha:1.f],
            [UIColor colorWithRed:39.f/255.f green:174/255.f blue:96/255.f alpha:1.f],
            [UIColor colorWithRed:52.f/255.f green:73/255.f blue:94/255.f alpha:1.f],
            [UIColor colorWithRed:52.f/255.f green:152/255.f blue:219/255.f alpha:1.f],
            [UIColor colorWithRed:155.f/255.f green:89/255.f blue:182/255.f alpha:1.f],
        ];
    }

    return self;
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    float dotRadius = _dotRadius;
    if(dotRadius == 0.f){
        dotRadius = 3.f;
    }
    float spaceBetween = _spaceBetween;
    if(spaceBetween == 0.f){
        spaceBetween = 3.f;
    }

    int dotNumber = MIN(self.dotNumber, 7);
    float x = _leftMargin;
    float y = self.bounds.size.height / 2 - self.dotRadius;
    for (unsigned int i = 0; i < dotNumber; i++){
        [_colorArray[i] setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, dotRadius * 2, dotRadius * 2)] fill];
        x+= dotRadius * 2 + spaceBetween;
    }

    if(7 > dotNumber){
        for (int i = dotNumber; i < 7; i++){
            [[UIColor lightGrayColor] setFill];
            [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, (dotRadius) * 2, (dotRadius) * 2)] fill];
            x += dotRadius * 2 + spaceBetween;
        }
    }
}
@end