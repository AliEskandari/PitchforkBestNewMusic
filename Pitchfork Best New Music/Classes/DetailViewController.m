//
//  DetailViewController.m
//  Pitchfork Best New Music
//
//  Created by Ali Eskandari on 4/17/15.
//  Copyright (c) 2015 Ali. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@end

@implementation DetailViewController

ArticleView *articleView;
UIPanGestureRecognizer *articleViewFramePanGestureRecognizer;

// reference variables for sliding article view
static CGRect topFrame;
static CGRect initialFrame;
static CGRect bottomFrame;
static int const ARTICLE_VIEW_TOP_SPACE = 210;
static int const ARTICLE_VIEW_BOTTOM_STATE_HEIGHT = 120;
static int ARTICLE_VIEW_BOTTOM_STATE_Y;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //================================================================
    // Navigation Controller Settings
    //================================================================
    self.navigationController.hidesBarsOnSwipe = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //================================================================
    // Populate Header Labels
    //================================================================
    self.artistLabel.text = [self.o[@"artist"] lowercaseString];
    self.albumLabel.text = self.o[@"album"];
    self.scoreLabel.text = [NSString stringWithFormat:@"%.1f", round(100 * [[self.o objectForKey:@"score"] floatValue] ) / 100];
    
    //===============================================================
    // Prepare Spotify Player
    //================================================================
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    // create uri from album's spotify id
    NSString *str = [NSString stringWithFormat:@"spotify:album:%@", self.o[@"spotify_id"]];
    
    // request track provider and pass result to player
    [SPTRequest requestItemAtURI:[NSURL URLWithString:str]
                     withSession:auth.session
                        callback:^(NSError *error, id object) {
                            
                            if (error != nil) {
                                NSLog(@"*** Album lookup got error %@", error);
                                return;
                            }

                            [self.player playTrackProvider:(id<SPTTrackProvider>)object callback:^(NSError *error) {
                                [self.player setIsPlaying:NO callback:nil];
                            }];
                        }];
    
    //================================================================
    // Create Article View
    //================================================================
    articleView = [[ArticleView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 self.view.frame.size.width,
                                                                 self.view.frame.size.height)];
    [self.view addSubview:articleView];
    
    // turn off scrolling on start
    articleView.scrollEnabled = false;
    
    // must set these to NO to use autolayout code
    [articleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [articleView.albumArtImgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [articleView.firstParaLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // autolayout with VFL
    NSDictionary* elemDict = NSDictionaryOfVariableBindings(articleView);
    NSDictionary *metrics = @{@"topspace":[NSNumber numberWithInt:ARTICLE_VIEW_TOP_SPACE]};
    
    // article view width matches parent view
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[articleView]|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:metrics
                                                                       views:elemDict]];
    // start with article view shifted down
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topspace)-[articleView]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:metrics
                                                                        views:elemDict]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:articleView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:-ARTICLE_VIEW_TOP_SPACE]];
    
    [articleView layoutIfNeeded];
    
    // set bottom state y position to parent height minus bottom state height
    ARTICLE_VIEW_BOTTOM_STATE_Y = self.view.frame.size.height - ARTICLE_VIEW_BOTTOM_STATE_HEIGHT;
    
    // set reference frames for use in sliding animations
    initialFrame = CGRectMake(0, ARTICLE_VIEW_TOP_SPACE, articleView.frame.size.width, articleView.frame.size.height);
    topFrame = CGRectMake(0, 0, articleView.frame.size.width, articleView.frame.size.height);
    bottomFrame = CGRectMake(0, ARTICLE_VIEW_BOTTOM_STATE_Y, CGRectGetWidth(articleView.frame), articleView.frame.size.height);
    
    //================================================================
    // Create Article View Frame Pan Gesture Recognizer
    //================================================================
    
    // create pan gesture recognizer to handle sliding article view frame
    articleViewFramePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    articleViewFramePanGestureRecognizer.delegate = self;
    
    // append new recognizer to article view's recognizers.
    // recognizer will be activated only when its associated view is interacted with
    articleView.gestureRecognizers = @[articleView.panGestureRecognizer, articleViewFramePanGestureRecognizer];
    
    //================================================================
    // Load Album Art in Article View
    //================================================================
    articleView.albumArtImgView.file = (PFFile *)[self.o objectForKey:@"album_art_large"];
    [articleView.albumArtImgView loadInBackground];
    
    //================================================================
    // Init Core Motion and Timer to slide Album Art
    //================================================================
    self.mm = [[CMMotionManager alloc] init];
    
    // start getting motion updates if available
    if ([self.mm isDeviceMotionAvailable]) {
        NSLog(@"Device Motion Available");
        [self.mm setDeviceMotionUpdateInterval:1.0/10.0];
        // Pull mechanism is used
        [self.mm startDeviceMotionUpdates];
    }
    
    // easy access to atitude
    self.atitude = self.mm.deviceMotion.attitude;
    
    // timer animates album art based on phone orientation
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    //================================================================
    // Article View Paragraphs - Style and Setup
    //================================================================
    NSMutableArray* paras = [NSMutableArray arrayWithArray:[self.o[@"article_text"] componentsSeparatedByString:@"\n"]];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;
    [style setAlignment:NSTextAlignmentJustified];
    [style setFirstLineHeadIndent:0.001f]; // needed for justified text to work
    NSDictionary *attributes = @{NSParagraphStyleAttributeName : style,};
    
    CGSize labelSize = [articleView.firstParaLabel.text sizeWithFont:articleView.firstParaLabel.font
                                            constrainedToSize:articleView.firstParaLabel.frame.size
                                                lineBreakMode:articleView.firstParaLabel.lineBreakMode];
    articleView.firstParaLabel.frame = CGRectMake(
                                           articleView.firstParaLabel.frame.origin.x,
                                           articleView.firstParaLabel.frame.origin.y,
                                           articleView.firstParaLabel.frame.size.width,
                                           labelSize.height);
    articleView.firstParaLabel.numberOfLines = 0;
    
    
    articleView.firstParaLabel.attributedText = [[NSAttributedString alloc]
                                                  initWithString:paras[0]
                                                  attributes:attributes];
    
    labelSize = [articleView.articleTextLabel.text sizeWithFont:articleView.articleTextLabel.font
                                       constrainedToSize:articleView.articleTextLabel.frame.size
                                           lineBreakMode:articleView.articleTextLabel.lineBreakMode];
    articleView.articleTextLabel.frame = CGRectMake(
                                             articleView.articleTextLabel.frame.origin.x,
                                             articleView.articleTextLabel.frame.origin.y,
                                             articleView.articleTextLabel.frame.size.width,
                                             labelSize.height);
    articleView.articleTextLabel.numberOfLines = 0;
    
    [paras removeObjectAtIndex:0];
    NSString *articleText = [paras componentsJoinedByString:@"\n\t"];
    articleView.articleTextLabel.attributedText = [[NSAttributedString alloc] initWithString:articleText
                                                                           attributes:attributes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons

- (IBAction)onPlayButtonPressed:(id)sender {
    if (self.player.isPlaying) {
        [self.playButton setImage:[UIImage imageNamed:@"PlaySmall.png"] forState:UIControlStateNormal];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"PauseSmall.png"] forState:UIControlStateNormal];
    }
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
}

- (IBAction)onNextButtonPressed:(id)sender {
    [self.player skipNext:nil];
}

#pragma mark - Core Motion Sliding Album Art Animation

// updates album art horizontal position based on phone orientation
- (void)update {
    
    // change in x position to be applied
    int deltaX = 0;
    
    // phone's current roll position
    double roll = self.mm.deviceMotion.attitude.roll;
    
    // if album art is already at the edge of the screen, don't move it off screen = just return
    if ((roll < 0 && articleView.albumArtImgView.frame.origin.x < 0)
        || (roll > 0 && articleView.albumArtImgView.frame.origin.x + articleView.albumArtImgView.frame.size.width > self.view.frame.size.width)) {
        return;
    }
    
    // if rolling left, move left one
    if (roll < -0.1) {
        deltaX = -1;
    }
    // else if roll isn't big enough, don't move
    else if (roll < 0.1) {
        deltaX = 0;
    }
    // else move right one
    else {
        deltaX = 1;
    }
    
    // run animation to move album art
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         articleView.albumArtImgView.frame  = CGRectMake(articleView.albumArtImgView.frame.origin.x + deltaX,
                                                                  articleView.albumArtImgView.frame.origin.y,
                                                                  articleView.albumArtImgView.frame.size.width,
                                                                  articleView.albumArtImgView.frame.size.height);}
                     completion:nil];
    
}

#pragma mark - Pan Gesture Animation

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {

    // If user finished swiping and lifted finger, move article view to correct reference frame
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        // final frame Article View will move to
        CGRect toFrame;
        
        // translation since last update
        CGPoint translation = [recognizer translationInView:self.view];
        
        // resulting new y position of view after translation
        int new_y = recognizer.view.frame.origin.y + translation.y;
        
        // velocity of pan
        CGPoint velocity = [recognizer velocityInView:self.view];
        
        // if user was swiping down...
        if (velocity.y > 0) {
            if (new_y < 30) {
                toFrame = topFrame;
            } else if (new_y < 250) {
                toFrame = initialFrame;
            } else {
                toFrame = bottomFrame;
            }
        }
        // if user was swiping up...
        else {
            if (new_y > 550) {
                toFrame = bottomFrame;
            } else if (new_y > 170) {
                toFrame = initialFrame;
            } else {
                toFrame = topFrame;
            }
        }
        
        // disable scrolling and hide nav bar if necessary
        if (CGRectEqualToRect(toFrame, topFrame)) {
            articleView.scrollEnabled = true;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        } else {
            articleView.scrollEnabled = false;
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
        
        // animate to final frame
        [UIView animateWithDuration:1.0/5.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.frame = toFrame;
        } completion:nil];
    }
    
    // if user is currently swiping, update article view's position to align with swipe
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:self.view];
        int new_y = recognizer.view.frame.origin.y + translation.y;
        
        /** Cover top and bottom boundaries **/
        // If new y is past the top, set new y equal to top
        if (new_y <= 0) {
            new_y = 0;
        }
        // else if new y is past bottom state requirement, set new y equal to bottom state y position
        else if (new_y >= ARTICLE_VIEW_BOTTOM_STATE_Y) {
            new_y = ARTICLE_VIEW_BOTTOM_STATE_Y;
        }
        
        // update article view frame
        recognizer.view.frame = CGRectMake(recognizer.view.frame.origin.x,
                                           new_y,
                                           recognizer.view.frame.size.width,
                                           recognizer.view.frame.size.height);
        
        // reset translation
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }
}

// Determines whether articleViewFramePanGestureRecognizer should process swipe (move article frame) or not.
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    // if swiping down and article view frame is at the top...
    if (velocity.y > 0 && articleView.frame.origin.y == 0) {
        // AND article content is scrolled to the top...
        if (articleView.contentOffset.y == 0) {
            // ...turn off scrolling and process swipe to pull down frame
            articleView.scrollEnabled = false;
            return true;
        }
        // Otherwise, don't process swipe and allow other gesture recognizer to scroll content
        else {
            return false;
        }
    }
    // else if swiping up when article view is at the top,
    // don't process swipe and allow other recognizer to scroll content
    else if (velocity.y < 0 && articleView.frame.origin.y == 0) {
        return false;
    }
    
    return true;
}
@end
