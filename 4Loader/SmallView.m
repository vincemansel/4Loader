//
//  SmallView.m
//  4Loader
//
//  Created by waveOcean Software on 2/12/13.
//  Copyright (c) 2013 vincemansel. All rights reserved.
//

#import "SmallView.h"

@implementation SmallView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)initializeView
{
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapgr.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapgr];
    
    UITapGestureRecognizer *tapgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap2:)];
    tapgr2.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tapgr2];
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    [self.delegate viewWasSelected:self withNumberOfTaps:sender.numberOfTouches];
}

- (void)handleTap2:(UITapGestureRecognizer *)sender
{
    [self.delegate viewWasSelected:self withNumberOfTaps:sender.numberOfTouches];
}


@end
