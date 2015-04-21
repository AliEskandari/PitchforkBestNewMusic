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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    // POPULATING
    self.artistLabel.text = [self.o[@"artist"] lowercaseString];
    self.albumLabel.text = self.o[@"album"];
    self.scoreLabel.text = [NSString stringWithFormat:@"%.1f", round(100 * [[self.o objectForKey:@"score"] floatValue] ) / 100];
    
    // AUTOLAYOUT
//    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // NAVIGATION CONTROLLER
    self.navigationController.hidesBarsOnSwipe = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.containerView.frame = CGRectMake(0, 206, self.view.frame.size.width, self.view.frame.size.height+ 500);
    
    NSLog(@"%f %f", self.containerView.frame.origin.x, self.containerView.frame.origin.y);
    NSLog(@"%f %f", self.view.frame.size.height, self.view.frame.size.width);
    NSLog(@"content size in detail %f %f", self.articleVC.scrollView.contentSize.height, self.articleVC.view.frame.size.height);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ContainerSegue"]) {
        self.articleVC = segue.destinationViewController;
        self.articleVC.o = self.o;
    }
    
}


@end
