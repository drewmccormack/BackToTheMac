//
//  MCBackgroundView.m
//  BackToTheMac
//
//  Created by Drew McCormack on 20/11/10.
//  Copyright 2010 The Mental Faculty. All rights reserved.
//

#import "MCBackgroundView.h"
#import "MCImage.h"


@implementation MCBackgroundView

@synthesize image;

-(void)setImage:(NSImage *)newImage
{
    if ( newImage != image ) {
        image = newImage;
        [self setNeedsDisplay:YES];
    }
}

-(void)drawRect:(NSRect)dirtyRect
{
	[image drawInRect:self.bounds];
}

-(void)setSize:(NSSize)newSize
{	
    NSRect superBounds = [[self superview] bounds];    
    NSRect newFrame = self.frame;
    newFrame.size = newSize;
    if ( self.superview ) {
        newFrame.origin.x += NSMidX(superBounds) - NSMidX(newFrame);
        newFrame.origin.x = MAX(newFrame.origin.x, 0.0f);
        newFrame.origin.y += NSMidY(superBounds) - NSMidY(newFrame);
        newFrame.origin.y -= MAX(0.0f, NSMaxY(newFrame) - NSMaxY(superBounds));
    }
    newFrame.origin.x = roundf(newFrame.origin.x);
    newFrame.origin.y = roundf(newFrame.origin.y);
    [self setFrame:newFrame];   
}   

-(void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize {
	[self setSize:self.frame.size];
}

@end
