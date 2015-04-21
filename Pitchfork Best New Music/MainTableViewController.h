//
//  MainTableViewController.h
//  Pitchfork Best New Music
//
//  Created by Ali Eskandari on 4/15/15.
//  Copyright (c) 2015 Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "DetailViewController.h"

@interface MainTableViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>
- (IBAction)sortButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
