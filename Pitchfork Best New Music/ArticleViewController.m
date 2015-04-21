//
//  ArticleViewController.m
//  Pitchfork Best New Music
//
//  Created by Ali Eskandari on 4/20/15.
//  Copyright (c) 2015 Ali. All rights reserved.
//

#import "ArticleViewController.h"

@interface ArticleViewController ()

@end

@implementation ArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // CORE MOTION
    self.mm = [[CMMotionManager alloc] init];
    
    if ([self.mm isDeviceMotionAvailable]) {
        NSLog(@"Device Motion Available");
        [self.mm setDeviceMotionUpdateInterval:1.0/10.0];
        // Pull mechanism is used
        [self.mm startDeviceMotionUpdates];
    }
    
    CMDeviceMotion *devMotion = self.mm.deviceMotion;
    self.atitude = devMotion.attitude;
    
    // SCROLLVIEW
    _scrollView = (UIScrollView *) self.view;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 600);
    _scrollView.alwaysBounceHorizontal = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // TIMER
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    // POPULATING
    self.albumArtImgView.file = (PFFile *)[self.o objectForKey:@"album_art_large"];
    [self.albumArtImgView loadInBackground];
    
    // PARAGRAPHS
    NSMutableArray* paras = [NSMutableArray arrayWithArray:[self.o[@"article_text"] componentsSeparatedByString:@"\n"]];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;
    [style setAlignment:NSTextAlignmentJustified];
    [style setFirstLineHeadIndent:0.001f];
    NSDictionary *attributes = @{NSParagraphStyleAttributeName : style,};
    
    CGSize labelSize = [self.firstParaLabel.text sizeWithFont:self.firstParaLabel.font
                                            constrainedToSize:self.firstParaLabel.frame.size
                                                lineBreakMode:self.firstParaLabel.lineBreakMode];
    self.firstParaLabel.frame = CGRectMake(
                                           self.firstParaLabel.frame.origin.x,
                                           self.firstParaLabel.frame.origin.y,
                                           self.firstParaLabel.frame.size.width,
                                           labelSize.height);
    self.firstParaLabel.numberOfLines = 0;
    
    
    self.firstParaLabel.attributedText = [[NSAttributedString alloc] initWithString:paras[0]
                                                                         attributes:attributes];
    
    labelSize = [self.articleTextLabel.text sizeWithFont:self.articleTextLabel.font
                                       constrainedToSize:self.articleTextLabel.frame.size
                                           lineBreakMode:self.articleTextLabel.lineBreakMode];
    self.articleTextLabel.frame = CGRectMake(
                                             self.articleTextLabel.frame.origin.x,
                                             self.articleTextLabel.frame.origin.y,
                                             self.articleTextLabel.frame.size.width,
                                             labelSize.height);
    self.articleTextLabel.numberOfLines = 0;
    
    [paras removeObjectAtIndex:0];
    NSString *articleText = [paras componentsJoinedByString:@"\n\t"];
    self.articleTextLabel.attributedText = [[NSAttributedString alloc] initWithString:articleText
                                                                           attributes:attributes];
    
    // AUTOLAYOUT
    [self.albumArtImgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.articleTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
//                                                          attribute:NSLayoutAttributeBottom
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.articleTextLabel
//                                                          attribute:NSLayoutAttributeBottom
//                                                         multiplier:1
//                                                           constant:0]];
    
    NSLog(@"content size : %f %f", _scrollView.contentSize.height, self.view.frame.size.height);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"%f", scrollView.contentOffset.y);
}

/*
#pragma mark - Navigation

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
    
    
    if ((r < 0 && self.albumArtImgView.frame.origin.x < 0) || (r > 0 && self.albumArtImgView.frame.origin.x + self.albumArtImgView.frame.size.width > self.view.frame.size.width)) {
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
                         self.albumArtImgView.frame  = CGRectMake(self.albumArtImgView.frame.origin.x + i,
                                                                  self.albumArtImgView.frame.origin.y,
                                                                  self.albumArtImgView.frame.size.width,
                                                                  self.albumArtImgView.frame.size.height);}
                     completion:nil];
    
}

@end
