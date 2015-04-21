//
//  DetailViewController.h
//  Pitchfork Best New Music
//
//  Created by Ali Eskandari on 4/17/15.
//  Copyright (c) 2015 Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <CoreMotion/CoreMotion.h>
#import "ArticleView.h"

@interface DetailViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property PFObject* o;

@property NSTimer *timer;
@property CMAttitude *atitude;
@property CMMotionManager *mm;

//@property ArticleView* articleView;

@end
