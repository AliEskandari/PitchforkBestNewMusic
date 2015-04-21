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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Instantiate a referenced view (assuming outlet has hooked up in XIB).
    _articleView = [[ArticleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_articleView];
    [_articleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary* elemDict = NSDictionaryOfVariableBindings(_articleView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_articleView]|"
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil
                                                                       views:elemDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(205)-[_articleView]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:elemDict]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_articleView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:-205]];
    
    // Controller's outlet has been bound during nib loading, so we can access view trough the outlet.

        
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
    
    NSLog(@"%@", paras[0]);
    
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
    _articleView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [_articleView layoutIfNeeded];
    //==============================================AUTOLAYOUT
    [_articleView.albumArtImgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_articleView.firstParaLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
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
    
    if ((r < 0 && _articleView.albumArtImgView.frame.origin.x < 0) || (r > 0 && _articleView.albumArtImgView.frame.origin.x + _articleView.albumArtImgView.frame.size.width > self.view.frame.size.width)) {
        return;
    }
    
    if (r < -0.1) {
        i = -1;
    } else if (r < 0.1) {
        i = 0;
    } else {
        i = 1;
    }
    
    [UIView animateWithDuration:1.0/10.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _articleView.albumArtImgView.frame  = CGRectMake(_articleView.albumArtImgView.frame.origin.x + i,
                                                                  _articleView.albumArtImgView.frame.origin.y,
                                                                  _articleView.albumArtImgView.frame.size.width,
                                                                  _articleView.albumArtImgView.frame.size.height);}
                     completion:nil];
    
}


@end
