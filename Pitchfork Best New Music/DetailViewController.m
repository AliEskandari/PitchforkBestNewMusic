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

ArticleView *_articleView;
UIPanGestureRecognizer *_panGestureRecognizer;
CGRect topFrame;
CGRect initialFrame;
CGRect bottomFrame;

static int const ARTICLE_VIEW_TOP_SPACE = 210;
static int const ARTICLE_VIEW_BOTTOM_STATE_HEIGHT = 120;
static int ARTICLE_VIEW_BOTTOM_STATE_Y;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //==============================================ARTICLE VIEW
    ARTICLE_VIEW_BOTTOM_STATE_Y = self.view.frame.size.height - ARTICLE_VIEW_BOTTOM_STATE_HEIGHT;
    _articleView = [[ArticleView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 self.view.frame.size.width,
                                                                 self.view.frame.size.height)];
    [self.view addSubview:_articleView];
    [_articleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_articleView.albumArtImgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_articleView.firstParaLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary* elemDict = NSDictionaryOfVariableBindings(_articleView);
    NSDictionary *metrics = @{@"topspace":[NSNumber numberWithInt:ARTICLE_VIEW_TOP_SPACE]};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_articleView]|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:metrics
                                                                       views:elemDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topspace)-[_articleView]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:metrics
                                                                        views:elemDict]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_articleView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:-ARTICLE_VIEW_TOP_SPACE]];
    
    [_articleView layoutIfNeeded];
    
    
    //==============================================PAN GESTURE RECOGNIZER
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGestureRecognizer.delegate = self;
    
    _articleView.panGestureRecognizer.delegate = _articleView;
    _articleView.panGestureRecognizer.enabled = false;
    _articleView.gestureRecognizers = @[_articleView.panGestureRecognizer, _panGestureRecognizer];
    
    initialFrame = CGRectMake(0, ARTICLE_VIEW_TOP_SPACE, _articleView.frame.size.width, _articleView.frame.size.height);
    topFrame = CGRectMake(0, 0, _articleView.frame.size.width, _articleView.frame.size.height);
    bottomFrame = CGRectMake(0, ARTICLE_VIEW_BOTTOM_STATE_Y, CGRectGetWidth(_articleView.frame), _articleView.frame.size.height);
    
    _articleView.scrollEnabled = false;
    
    //==============================================POPULATING
    self.artistLabel.text = [self.o[@"artist"] lowercaseString];
    self.albumLabel.text = self.o[@"album"];
    self.scoreLabel.text = [NSString stringWithFormat:@"%.1f", round(100 * [[self.o objectForKey:@"score"] floatValue] ) / 100];
    
    
    //==============================================NAVIGATION CONTROLLER
    self.navigationController.hidesBarsOnSwipe = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
    //==============================================CORE MOTION
    self.mm = [[CMMotionManager alloc] init];
    
    if ([self.mm isDeviceMotionAvailable]) {
        NSLog(@"Device Motion Available");
        [self.mm setDeviceMotionUpdateInterval:1.0/10.0];
        // Pull mechanism is used
        [self.mm startDeviceMotionUpdates];
    }
    
    CMDeviceMotion *devMotion = self.mm.deviceMotion;
    self.atitude = devMotion.attitude;

    
    //==============================================TIMER
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    
    //==============================================POPULATING
    _articleView.albumArtImgView.file = (PFFile *)[self.o objectForKey:@"album_art_large"];
    [_articleView.albumArtImgView loadInBackground];
    
    
    //==============================================PARAGRAPHS
    NSMutableArray* paras = [NSMutableArray arrayWithArray:[self.o[@"article_text"] componentsSeparatedByString:@"\n"]];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;
    [style setAlignment:NSTextAlignmentJustified];
    [style setFirstLineHeadIndent:0.001f];
    NSDictionary *attributes = @{NSParagraphStyleAttributeName : style,};
    
    CGSize labelSize = [_articleView.firstParaLabel.text sizeWithFont:_articleView.firstParaLabel.font
                                            constrainedToSize:_articleView.firstParaLabel.frame.size
                                                lineBreakMode:_articleView.firstParaLabel.lineBreakMode];
    _articleView.firstParaLabel.frame = CGRectMake(
                                           _articleView.firstParaLabel.frame.origin.x,
                                           _articleView.firstParaLabel.frame.origin.y,
                                           _articleView.firstParaLabel.frame.size.width,
                                           labelSize.height);
    _articleView.firstParaLabel.numberOfLines = 0;
    
    
    _articleView.firstParaLabel.attributedText = [[NSAttributedString alloc]
                                                  initWithString:paras[0]                                                                         attributes:attributes];
    
    labelSize = [_articleView.articleTextLabel.text sizeWithFont:_articleView.articleTextLabel.font
                                       constrainedToSize:_articleView.articleTextLabel.frame.size
                                           lineBreakMode:_articleView.articleTextLabel.lineBreakMode];
    _articleView.articleTextLabel.frame = CGRectMake(
                                             _articleView.articleTextLabel.frame.origin.x,
                                             _articleView.articleTextLabel.frame.origin.y,
                                             _articleView.articleTextLabel.frame.size.width,
                                             labelSize.height);
    _articleView.articleTextLabel.numberOfLines = 0;
    
    [paras removeObjectAtIndex:0];
    NSString *articleText = [paras componentsJoinedByString:@"\n\t"];
    _articleView.articleTextLabel.attributedText = [[NSAttributedString alloc] initWithString:articleText
                                                                           attributes:attributes];
    //==============================================AUTOLAYOUT
    //    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
    //                                                          attribute:NSLayoutAttributeBottom
    //                                                          relatedBy:NSLayoutRelationEqual
    //                                                             toItem:_articleView.firstParaLabel
    //                                                          attribute:NSLayoutAttributeBottom
    //                                                         multiplier:1
    //                                                           constant:0]];
    

    
//    self.containerView.frame = CGRectMake(0, 206, self.view.frame.size.width, self.view.frame.size.height+ 500);
//    
//    NSLog(@"%f %f", self.containerView.frame.origin.x, self.containerView.frame.origin.y);
//    NSLog(@"%f %f", self.view.frame.size.height, self.view.frame.size.width);
//    NSLog(@"content size in detail %f %f", self.articleVC.scrollView.contentSize.height, self.articleVC.view.frame.size.height);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}
*/

- (void)update {
    //    NSLog(@"%f, %f, %f", self.mm.deviceMotion.attitude.pitch, self.mm.deviceMotion.attitude.roll, self.mm.deviceMotion.attitude.yaw);
    
    int i = 0;
    double r = self.mm.deviceMotion.attitude.roll;
    
    if ((r < 0 && _articleView.albumArtImgView.frame.origin.x < 0)
        || (r > 0 && _articleView.albumArtImgView.frame.origin.x + _articleView.albumArtImgView.frame.size.width > self.view.frame.size.width)) {
        return;
    }
    
    if (r < -0.1) {
        i = -1;
    } else if (r < 0.1) {
        i = 0;
    } else {
        i = 1;
    }
    
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _articleView.albumArtImgView.frame  = CGRectMake(_articleView.albumArtImgView.frame.origin.x + i,
                                                                  _articleView.albumArtImgView.frame.origin.y,
                                                                  _articleView.albumArtImgView.frame.size.width,
                                                                  _articleView.albumArtImgView.frame.size.height);}
                     completion:nil];
    
}


- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGRect toFrame;
        CGPoint translation = [recognizer translationInView:self.view];
        int new_y = recognizer.view.frame.origin.y + translation.y;
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        
        if (velocity.y > 0) { // Going down
            if (new_y < 30) {
                toFrame = topFrame;
                _articleView.scrollEnabled = true;
                [self.navigationController setNavigationBarHidden:YES animated:YES];
            } else if (new_y < 250) {
                toFrame = initialFrame;
                _articleView.scrollEnabled = false;
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            } else {
                toFrame = bottomFrame;
                _articleView.scrollEnabled = false;
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            }
        } else { // Going up
            if (new_y > 550) {
                toFrame = bottomFrame;
                _articleView.scrollEnabled = false;
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            } else if (new_y > 170) {
                toFrame = initialFrame;
                _articleView.scrollEnabled = false;
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            } else {
                toFrame = topFrame;
                _articleView.scrollEnabled = true;
                [self.navigationController setNavigationBarHidden:YES animated:YES];
            }
        }
        
//        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
//        CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor),
//                                         recognizer.view.center.y + (velocity.y * slideFactor));
//        
//        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
//        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height);
        
        
        [UIView animateWithDuration:1.0/5.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.frame = toFrame;
        } completion:nil];
        
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:self.view];
        int new_y = recognizer.view.frame.origin.y + translation.y;
        
        if (new_y <= 0) { // Slide all the way up
            new_y = 0;
            _articleView.scrollEnabled = true;
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        } else if (new_y >= ARTICLE_VIEW_BOTTOM_STATE_Y) { // Slide all the way down
            new_y = ARTICLE_VIEW_BOTTOM_STATE_Y;
            _articleView.scrollEnabled = false;
        }
        
        recognizer.view.frame = CGRectMake(recognizer.view.frame.origin.x,
                                           new_y,
                                           recognizer.view.frame.size.width,
                                           recognizer.view.frame.size.height);
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if (velocity.y > 0 && _articleView.frame.origin.y == 0) {
        // Swiping down when article view is at the top...
        if (_articleView.contentOffset.y == 0) {
            _articleView.scrollEnabled = false;
            return true;
        } else {
            return false;
        }
    } else if (velocity.y < 0 && _articleView.frame.origin.y == 0) {
        // Swiping up when article view is at top
        return false;
    }
    
    return true;
}

@end
