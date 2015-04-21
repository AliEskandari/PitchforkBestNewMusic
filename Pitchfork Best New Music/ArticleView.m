//
//  ArticleView.m
//  Pitchfork Best New Music
//
//  Created by Ali Eskandari on 4/20/15.
//  Copyright (c) 2015 Ali. All rights reserved.
//

#import "ArticleView.h"

@implementation ArticleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code.
        //
        self = [[[NSBundle mainBundle] loadNibNamed:@"ArticleView" owner:self options:nil] objectAtIndex:0];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        NSLog(@"created nib");
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awake");
}


@end
