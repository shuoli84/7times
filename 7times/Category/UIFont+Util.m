//
// Created by Li Shuo on 13-11-29.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "UIFont+Util.h"


@implementation UIFont (Util)

+ (CGFloat)preferredFontSize{
    // choose the font size
    CGFloat fontSize = 16.0;
    NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;

    if ([contentSize isEqualToString:UIContentSizeCategoryExtraSmall]) {
        fontSize = 12.0;

    } else if ([contentSize isEqualToString:UIContentSizeCategorySmall]) {
        fontSize = 14.0;

    } else if ([contentSize isEqualToString:UIContentSizeCategoryMedium]) {
        fontSize = 16.0;

    } else if ([contentSize isEqualToString:UIContentSizeCategoryLarge]) {
        fontSize = 18.0;

    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraLarge]) {
        fontSize = 20.0;

    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
        fontSize = 22.0;

    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
        fontSize = 24.0;
    }

    return fontSize;
}

@end