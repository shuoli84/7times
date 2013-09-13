//
// Created by Li Shuo on 13-9-12.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ContentView.h"
#import "FVDeclaration.h"
#import "FVDeclareHelper.h"

@interface ContentView ()

@property (nonatomic, strong) FVDeclaration *declaration;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation ContentView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self){
        self.declaration = [dec(@"view") $:@[
            dec(@"content", CGRectMake(0, 0, FVP(1), FVP(1)), ^{
                UITextView *textView = [[UITextView alloc] initWithFrame:self.bounds];
                textView.editable = NO;

                self.textView = textView;
                return textView;
            }())
        ]];

        [self.declaration setupViewTreeInto:self];
    }

    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];

    [self.declaration resetLayout];
    self.declaration.unExpandedFrame = self.bounds;
    [self.declaration updateViewFrame];
}

-(void)setContent:(NSString *)content {
    _content = content;
    _textView.text = content;
}

@end