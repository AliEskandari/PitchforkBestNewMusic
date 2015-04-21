//
//  ArticleView.h
//  Pitchfork Best New Music
//
//  Created by Ali Eskandari on 4/20/15.
//  Copyright (c) 2015 Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface ArticleView : UIScrollView <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *firstParaLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleTextLabel;
@property (weak, nonatomic) IBOutlet PFImageView *albumArtImgView;
@end
