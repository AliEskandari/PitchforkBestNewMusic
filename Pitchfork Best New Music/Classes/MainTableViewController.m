//
//  MainTableViewController.m
//  Pitchfork Best New Music
//
//  Created by Ali Eskandari on 4/15/15.
//  Copyright (c) 2015 Ali. All rights reserved.
//

#import "MainTableViewController.h"
#import "ReviewTableViewCell.h"
#import <Spotify/SPTDiskCache.h>


@interface MainTableViewController () <SPTAudioStreamingDelegate>
@property NSInteger toggle;
@property (strong, nonatomic) UIPickerView *pickerView;
@property NSArray* pickerViewNames;
@property (nonatomic, strong) SPTAudioStreamingController *player;

// contraints
@property NSLayoutConstraint *alignTableViewTopViewTopContraint;
@property NSLayoutConstraint *alignPickerViewTopViewBottomConstraint;
@property NSLayoutConstraint *pickerViewHeightConstraint;
@property NSLayoutConstraint *alignPickerViewBottomViewBottomConstraint;
@property NSLayoutConstraint *alignPickerViewTopTableViewBottomConstraint;
@end

@implementation MainTableViewController
{
    NSArray* data;
}

@synthesize pickerView = _pickerView, tableView = _tableView;

static NSString *CellIdentifier = @"ReviewTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    // NAVIGATION CONTROLLER
    [self.navigationController.navigationBar setTitleTextAttributes:@{[UIFont fontWithName:@"Arial" size:0.0]:NSFontAttributeName}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.navigationBar
    setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    // PICKERVIEW
    self.pickerView = [[UIPickerView alloc] init];
    
    [self.view addSubview:_pickerView];
    
    self.pickerViewNames = @[@"Score", @"Year",@"Album"];
    self.toggle = 0;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.hidden = YES;
    
     _pickerView.frame = CGRectMake(0,
                                    self.view.frame.size.height,
                                    self.view.frame.size.width,
                                    _pickerView.frame.size.height);

    // AUTOLAYOUT
    [self.pickerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.pickerView selectRow:1 inComponent:0 animated:NO];
    
    // NSDictionary *elementsDict = NSDictionaryOfVariableBindings(_pickerView, _tableView);

     _alignTableViewTopViewTopContraint = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1
                                                                         constant:0];
    
    _alignPickerViewTopTableViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.tableView
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1
                                                                                 constant:0];
    
    _alignPickerViewTopViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1
                                                                constant:0];
    _alignPickerViewBottomViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1
                                                                     constant:0];
    _pickerViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:_pickerView.frame.size.height];

    [self.view addConstraints:@[_pickerViewHeightConstraint, _alignPickerViewTopTableViewBottomConstraint, _alignPickerViewTopViewBottomConstraint]];
    
    // TABLEVIEW CELL
    [self.tableView registerNib:[UINib nibWithNibName:@"ReviewTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];

    // QUERY
    [self query:@"year" ascending:NO];
    

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        // Begin playing the current track.
        [self.player setIsPlaying:YES callback:nil];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        // Begin playing the current track.
        [self.player setIsPlaying:NO callback:nil];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        // Begin playing the current track.
        [self.player skipNext:nil];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        // Begin playing the current track.
        [self.player skipPrevious:nil];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

    
//    MPNowPlayingInfoCenter* info = [MPNowPlayingInfoCenter defaultCenter];
//    NSMutableDictionary* newInfo = [NSMutableDictionary dictionary];
//    NSSet* itemProperties = [NSSet setWithObjects:MPMediaItemPropertyTitle,
//                             MPMediaItemPropertyArtist,
//                             MPMediaItemPropertyPlaybackDuration,
//                             MPNowPlayingInfoPropertyElapsedPlaybackTime,
//                             nil];
//    
//    newInfo = @{MPMediaItemPropertyTitle: @"Hello", MPMediaItemPropertyArtist: @"Beyonce", MPMediaItemPropertyPlaybackDuration:@30, MPNowPlayingInfoPropertyElapsedPlaybackTime: @30};
//    
//    info.nowPlayingInfo = newInfo;
    
    
}

//- (void) remoteControlReceivedWithEvent: (UIEvent*) event
//{
//    // see [event subtype] for details
//    if (event.type == UIEventTypeRemoteControl) {
//        // We may be receiving an event from the lockscreen
//        switch (event.subtype) {
//            case UIEventSubtypeRemoteControlTogglePlayPause:
//            case UIEventSubtypeRemoteControlPlay:
//            case UIEventSubtypeRemoteControlPause:
//                // User pressed play or pause from lockscreen
//                NSLog(@"af");
//                break;
//                
//            case UIEventSubtypeRemoteControlNextTrack:
//                // User pressed FFW from lockscreen
//                break;
//                
//            case UIEventSubtypeRemoteControlPreviousTrack:
//                // User pressed rewind from lockscreen
//                break;
//                
//            default:
//                break;
//        }
//    }
//}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    self.navigationController.hidesBarsOnSwipe = YES;
    
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    [self handleNewSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    //End recieving events
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ReviewTableViewCell *cell = (ReviewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *o = data[indexPath.row];
    cell.albumLabel.text = [o objectForKey:@"album"];
    cell.artistLabel.text = [o objectForKey:@"artist"];
    cell.scoreLabel.text = [NSString stringWithFormat:@"%.1f", round(100 * [[o objectForKey:@"score"] floatValue] ) / 100];
    cell.yearLabel.text = [[o objectForKey:@"year"] stringValue];
    
    cell.albumartImgView.file = (PFFile *)[o objectForKey:@"album_art"];
    [cell.albumartImgView loadInBackground];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *o = data[indexPath.row];
    [self performSegueWithIdentifier:@"ShowDetail" sender:o];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(PFObject*)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DetailViewController *vc = [segue destinationViewController];
    vc.o = sender;
    vc.player = self.player;
}

- (IBAction)sortButtonPressed:(id)sender {
    [self bringUpPickerView];
}

#pragma mark - Picker View

- (void)bringUpPickerView {
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.pickerView.hidden = NO;
         
         [self.view removeConstraint:_alignPickerViewTopViewBottomConstraint];
         [self.view addConstraint:_alignPickerViewBottomViewBottomConstraint];
         
         [self.view layoutIfNeeded];
     }
                     completion:nil];
}

- (void)hidePickerView {
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         [self.view removeConstraint:_alignPickerViewBottomViewBottomConstraint];
         [self.view addConstraint:_alignPickerViewTopViewBottomConstraint];

         [self.view layoutIfNeeded];
     }
                     completion:^(BOOL finished)
     {
         self.pickerView.hidden = YES;
     }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.toggle = 0;
    switch (row) {
        case 0:
            [self query:@"score" ascending:NO];
            break;
        case 1:
            [self query:@"year" ascending:NO];
            break;
        case 2:
            [self query:@"album" ascending:YES];
            break;
        default:
            break;
    }
    [self hidePickerView];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerViewNames count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = self.pickerViewNames[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"Arial" size:0.0]}];
    
    return attString;
}

#pragma mark - Private methods

- (void)query:(NSString*) sortByfield ascending:(bool) ascending {
    PFQuery *query = [PFQuery queryWithClassName:@"PitchforkBestNewMusic"];
    [query setLimit: 1000];
    if (ascending) {
        [query addAscendingOrder:sortByfield];
    } else {
        [query addDescendingOrder:sortByfield];
    }

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            
            data = objects;
            [self.tableView reloadData];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)handleNewSession {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    [self.player loginWithSession:auth.session callback:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        
//        [self updateUI];
        
    }];
}

#pragma mark - Track Player Delegates

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri {
    NSLog(@"failed to play track: %@", trackUri);
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    NSLog(@"track changed = %@", [trackMetadata valueForKey:SPTAudioStreamingMetadataTrackURI]);
//    [self updateUI];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(@"is playing = %d", isPlaying);
}

#pragma mark - Control Center

//- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
//    
//    if (receivedEvent.type == UIEventTypeRemoteControl) {
//        switch (receivedEvent.subtype) {
//            case UIEventSubtypeRemoteControlPlay:
//                [self.player setIsPlaying:YES callback:nil];
//                break;
//            case UIEventSubtypeRemoteControlPause:
//                [self.player setIsPlaying:NO callback:nil];
//                break;
//            case UIEventSubtypeRemoteControlTogglePlayPause:
//                [self.player setIsPlaying:!self.player.isPlaying callback:nil];
//                break;
//            default:
//                break;
//        }
//    }
//}

@end

