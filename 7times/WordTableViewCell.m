//
// Created by Li Shuo on 13-11-23.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <SLFlexibleView/FVDeclaration.h>
#import <SLFlexibleView/FVDeclareHelper.h>
#import <BlocksKit/UIControl+BlocksKit.h>
#import "WordTableViewCell.h"
#import "Word.h"
#import "DotView.h"


@interface WordTableViewCell()

@property (nonatomic, strong) UILabel *wordLabel;
@property (nonatomic, strong) UIButton *ignoreButton;
@property (nonatomic, strong) DotView *dotView;

@property (nonatomic, strong) FVDeclaration *declaration;
@end

@implementation WordTableViewCell {

}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.declaration = [dec(@"root") $:@[
            dec(@"word", CGRectMake(10, FVCenter, FVT(80), 30), self.wordLabel = ^{
                UILabel *label = [[UILabel alloc] init];
                label.font = [UIFont boldSystemFontOfSize:18];
                label.textColor = [UIColor blackColor];
                label.backgroundColor = [UIColor clearColor];

                return label;
            }()),
            dec(@"dotView", CGRectMake(FVT(80), FVCenter, 75, 25), self.dotView = ^{
                DotView *dotView = [[DotView alloc]init];
                dotView.backgroundColor = [UIColor clearColor];
                dotView.leftMargin = 1.f;
                dotView.dotRadius = 3.f;
                dotView.spaceBetween = 3.f;
                return dotView;
            }()),
        ]];

        [self.declaration setupViewTreeInto:self];
    }

    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];

    self.declaration.unExpandedFrame = self.bounds;
    [self.declaration updateViewFrame];
}

-(void)setWord:(Word *)word {
    _word = word;

    self.wordLabel.text = word.word;
    self.dotView.dotNumber = word.checkNumber.integerValue;

    if(word.postNumber.integerValue > 0){
        self.dotView.showPlaceHolder = YES;
    }
    else{
        self.dotView.showPlaceHolder = NO;
    }
    [self.dotView setNeedsDisplay];
}
@end