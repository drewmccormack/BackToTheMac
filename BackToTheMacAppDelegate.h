//
//  BackToTheMacAppDelegate.h
//  BackToTheMac
//
//  Created by Drew McCormack on 20/11/10.
//  Copyright 2010 The Mental Faculty. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MCTextFieldWebView;
@class MCBackgroundView;

@interface BackToTheMacAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet MCTextFieldWebView *webView;
    IBOutlet NSTextField *textField;
    IBOutlet MCBackgroundView *backgroundView;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)extractHTML:(id)sender;

@end
