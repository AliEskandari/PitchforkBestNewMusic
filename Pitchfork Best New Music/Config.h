//
//  Config.h
//  Pitchfork Best New Music
//
//  Created by Ali Eskandari on 4/22/15.
//  Copyright (c) 2015 Ali. All rights reserved.
//


#ifndef Pitchfork_Best_New_Music_Config_h
#define Pitchfork_Best_New_Music_Config_h

// #warning Please update these values to match the settings for your own application as these example values could change at any time.
// For an in-depth auth demo, see the "Basic Auth" demo project supplied with the SDK.
// Don't forget to add your callback URL's prefix to the URL Types section in the target's Info pane!

// Your client ID
#define kClientId "19b6fa16c893441f8aa82815931d7e78"

// Your applications callback URL
#define kCallbackURL "pitchforkbestnewmusic://callback"

// The URL to your token swap endpoint
// If you don't provide a token swap service url the login will use implicit grant tokens, which means that your user will need to sign in again every time the token expires.

#define kTokenSwapServiceURL "http://stormy-springs-1644.herokuapp.com/swap"

// The URL to your token refresh endpoint
// If you don't provide a token refresh service url, the user will need to sign in again every time their token expires.

#define kTokenRefreshServiceURL "http://stormy-springs-1644.herokuapp.com/refresh"


#define kSessionUserDefaultsKey "SpotifySession"

#endif
