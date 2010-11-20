//
//  MCBackgroundView.h
//  BackToTheMac
//
//  Created by Drew McCormack on 20/11/10.
//  Copyright 2010 The Mental Faculty. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MCBackgroundView : NSView {
	NSImage *image;
}

@property (nonatomic, retain) NSImage *image;

@end
