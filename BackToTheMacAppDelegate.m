//
//  BackToTheMacAppDelegate.m
//  BackToTheMac
//
//  Created by Drew McCormack on 20/11/10.
//  Copyright 2010 The Mental Faculty. All rights reserved.
//

#import "BackToTheMacAppDelegate.h"
#import "MCImage.h"
#import "MCBackgroundView.h"
#import "MCTextFieldWebView.h"

@implementation BackToTheMacAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSImage *backgroundImage = [[NSImage imageNamed:@"Background"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:22.0f];
	backgroundView.image = backgroundImage;

}

-(IBAction)extractHTML:(id)sender
{
    textField.stringValue = webView.htmlString;
}

@end
