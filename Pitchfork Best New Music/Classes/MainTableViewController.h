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
#import "Config.h"
#import <Spotify/Spotify.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MainTableViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, AVAudioSessionDelegate>
- (IBAction)sortButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
