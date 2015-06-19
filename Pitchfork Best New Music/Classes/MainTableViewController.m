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
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) SPTAudioStreamingController *player;
@end

@implementation MainTableViewController

// array of results from queries, list of PFObjects
static NSArray* data;

static NSString *CellIdentifier = @"ReviewTableViewCell";

static NSArray* pickerViewNames;

// picker view autolayout contraints
static NSLayoutConstraint *alignPickerViewTopWithViewBottomConstraint;
static NSLayoutConstraint *pickerViewHeightConstraint;
static NSLayoutConstraint *alignPickerViewBottomWithViewBottomConstraint;
static NSLayoutConstraint *alignPickerViewTopWithTableViewBottomConstraint;


- (void)viewDidLoad {
    [super viewDidLoad];

    //================================================================
    // Navigation Controller Settings
    //================================================================
    [self.navigationController.navigationBar setTitleTextAttributes:@{[UIFont fontWithName:@"Arial" size:0.0]:NSFontAttributeName}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.navigationBar
    setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    //================================================================
    // Create Picker View, add as subview
    //================================================================
    self.pickerView = [[UIPickerView alloc] init];
    
    pickerViewNames = @[@"Score", @"Year",@"Album"];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.hidden = YES;
    
    self.pickerView.frame = CGRectMake(0,
                                    self.view.frame.size.height,
                                    self.view.frame.size.width,
                                    self.pickerView.frame.size.height);

    [self.view addSubview:self.pickerView];

    //================================================================
    // Create Autolayout Constraints for PickerView
    //================================================================
    
    // these need to be set to NO to use autolayout
    [self.pickerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.pickerView selectRow:1 inComponent:0 animated:NO];
    
    // sets a constant picker view height
    pickerViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:self.pickerView.frame.size.height];
    
    // makes sure the table view shrinks and growns when the picker view slides up and down
    alignPickerViewTopWithTableViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.tableView
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1
                                                                                 constant:0];
    
    // used in sliding picker view down animation
    alignPickerViewTopWithViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1
                                                                constant:0];
    
    // used in sliding picker view up animation
    alignPickerViewBottomWithViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1
                                                                     constant:0];

    // adds contraints to start off with picker view off screen
    [self.view addConstraints:@[pickerViewHeightConstraint, alignPickerViewTopWithTableViewBottomConstraint, alignPickerViewTopWithViewBottomConstraint]];
    
    //================================================================
    // Register Review Table View Cell
    //================================================================
    [self.tableView registerNib:[UINib nibWithNibName:@"ReviewTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];

    //================================================================
    // Get albums sorted by year
    //================================================================
    [self getAlbumsSortedBy:@"year" ascending:NO];
    
    //================================================================
    // Handle playback commands from control center music controls
    //================================================================
    
    // Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    // create new spotify session
    [self handleNewSession];
    
    // handle specific commands
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

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.hidesBarsOnSwipe = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    // End recieving events
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

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // get cell
    ReviewTableViewCell *cell = (ReviewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // get album object
    PFObject *o = data[indexPath.row];
    
    // populate labels
    cell.albumLabel.text = [o objectForKey:@"album"];
    cell.artistLabel.text = [o objectForKey:@"artist"];
    cell.scoreLabel.text = [NSString stringWithFormat:@"%.1f", round(100 * [[o objectForKey:@"score"] floatValue] ) / 100];
    cell.yearLabel.text = [[o objectForKey:@"year"] stringValue];
    
    // load album art image
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


#pragma mark - Navigation and Buttons

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(PFObject*)sender {
    
    // Get the new view controller using [segue destinationViewController].
    DetailViewController *vc = [segue destinationViewController];
    
    // Pass the selected album's object to the new view controller.
    vc.o = sender;
    
    // Pass player to view controller
    vc.player = self.player;
}

- (IBAction)sortButtonPressed:(id)sender {
    [self bringUpPickerView];
}

#pragma mark - Picker View

// Called when sort button is pressed. Fires animation to slide PickerView up.
- (void)bringUpPickerView {
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.pickerView.hidden = NO;
         
         [self.view removeConstraint:alignPickerViewTopWithViewBottomConstraint];
         [self.view addConstraint:alignPickerViewBottomWithViewBottomConstraint];
         
         [self.view layoutIfNeeded];
     }
                     completion:nil];
}

// Called after picker view option is chosen. Fires animation to slide PickerView down.
- (void)hidePickerView {
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         [self.view removeConstraint:alignPickerViewBottomWithViewBottomConstraint];
         [self.view addConstraint:alignPickerViewTopWithViewBottomConstraint];

         [self.view layoutIfNeeded];
     }
                     completion:^(BOOL finished)
     {
         self.pickerView.hidden = YES;
     }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    switch (row) {
        case 0:
            [self getAlbumsSortedBy:@"score" ascending:NO];
            break;
        case 1:
            [self getAlbumsSortedBy:@"year" ascending:NO];
            break;
        case 2:
            [self getAlbumsSortedBy:@"album" ascending:YES];
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
    return [pickerViewNames count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = pickerViewNames[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"Arial" size:0.0]}];
    
    return attString;
}

#pragma mark - Private methods

// Helper method for executing query that retrieves and sorts albums
- (void)getAlbumsSortedBy:(NSString*)sortByfield ascending:(bool)ascending {
    
    // query from the PitchforkBestNewMusic class
    PFQuery *query = [PFQuery queryWithClassName:@"PitchforkBestNewMusic"];
    
    [query setLimit: 1000];
    
    if (ascending) {
        [query addAscendingOrder:sortByfield];
    } else {
        [query addDescendingOrder:sortByfield];
    }
    
    // execute query
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

// Handles creating a Spotify session
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
        
       //[self updateUI];
        
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
    //[self updateUI];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(@"is playing = %d", isPlaying);
}

@end

