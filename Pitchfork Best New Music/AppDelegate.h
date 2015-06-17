//
//  AppDelegate.h
//  Pitchfork Best New Music
//
//  Created by Ali Eskandari on 4/15/15.
//  Copyright (c) 2015 Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

// Constants
static NSString * const kClientId = @"19b6fa16c893441f8aa82815931d7e78";
static NSString * const kCallbackURL = @"pitchforkbestnewmusic://callback";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;

@end

