//
//  ArticleViewController.h
//  Pitchfork Best New Music
//
//  Created by Ali Eskandari on 4/20/15.
//  Copyright (c) 2015 Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ArticleViewController : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *firstParaLabel;
@property (weak, nonatomic) IBOutlet PFImageView *albumArtImgView;
@property (weak, nonatomic) IBOutlet UILabel *articleTextLabel;
@property NSTimer *timer;
@property CMAttitude *atitude;
@property CMMotionManager *mm;
@property PFObject* o;
@property UIScrollView* scrollView;
-(void)update;
@end
