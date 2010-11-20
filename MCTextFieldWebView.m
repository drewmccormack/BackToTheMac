//
//  MCTextFieldWebView.m
//  BackToTheMac
//
//  Created by Drew McCormack on 15/11/10.
//  Copyright 2010 The Mental Faculty. All rights reserved.
//

#import "MCTextFieldWebView.h"


@implementation MCTextFieldWebView

@synthesize textFieldDelegate;
@synthesize fontSize;

-(id)initWithFrame:(NSRect)frameRect
{
	NSString *frameName = [NSString stringWithFormat:@"Frame for MCTextFieldWebView %p", self];
    NSString *groupName = [NSString stringWithFormat:@"Group for MCTextFieldWebView %p", self];
    if ( (self = [super initWithFrame:frameRect frameName:frameName groupName:groupName]) ) {
    	// Paths to files
    	NSString *pathToResources = [[NSBundle bundleForClass:[self class]] pathForResource:@"MCTextFieldWebView Resources" ofType:@""];
        NSString *pathToHTML = [pathToResources stringByAppendingPathComponent:@"main.html"];
        NSString *skeletonHTML = [NSString stringWithContentsOfFile:pathToHTML usedEncoding:nil error:NULL];
        NSURL *baseURL = [NSURL fileURLWithPath:pathToHTML];
        
        // Initialize web view
        self.drawsBackground = NO;
        
        // Begin load
        finishedLoading = NO;
        failedLoad = NO;
        self.frameLoadDelegate = self;
        self.editingDelegate = self;
        self.policyDelegate = self;
        [self.mainFrame loadHTMLString:skeletonHTML baseURL:baseURL];
        
        // Wait for load to complete
        while ( !finishedLoading ) {
        	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
        }
        
        // Handle failed load
        if ( failedLoad ) {
            self = nil;
        }
        else {
            self.fontSize = 16.0;
            self.fontFamily = @"Helvetica";
            self.textAlignment = NSLeftTextAlignment;
            self.textColor = [NSColor blackColor];
        }
    }

	return self;
}

#pragma mark Loading Delegate Methods

-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    finishedLoading = YES;
}

-(void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	NSLog(@"MCTextFieldWebView did fail load: %@", error);
    finishedLoading = YES;
    failedLoad = YES;
}

#pragma mark Editing Delegate Methods

-(void)webViewDidBeginEditing:(NSNotification *)notif
{
    if ( [textFieldDelegate respondsToSelector:@selector(textFieldWebViewDidBeginEditing:)] ) {
        [textFieldDelegate textFieldWebViewDidBeginEditing:self];
    }
}

-(void)webViewDidChange:(NSNotification *)notif
{
    if ( [textFieldDelegate respondsToSelector:@selector(textFieldWebViewHTMLContentDidChange:)] ) {
        [textFieldDelegate textFieldWebViewHTMLContentDidChange:self];
    }
}

-(void)webViewDidEndEditing:(NSNotification *)notif
{
    if ( [textFieldDelegate respondsToSelector:@selector(textFieldWebViewDidEndEditing:)] ) {
        [textFieldDelegate textFieldWebViewDidEndEditing:self];
    }
}

-(void)removeFontAttributesFromDOMHTMLElement:(DOMHTMLElement *)element
{
	NSString *color = [element.style.color copy];
    [element setAttribute:@"style" value:nil];
    element.style.color = color;
}

-(BOOL)webView:(WebView *)webView shouldInsertNode:(DOMNode *)node replacingDOMRange:(DOMRange *)range givenAction:(WebViewInsertAction)action
{
	if ( action == WebViewInsertActionPasted ) {
        DOMDocumentFragment *documentFragment = (id)node;
		DOMNodeList *children = [documentFragment childNodes];
        for ( NSUInteger c = 0; c < children.length; ++c ) {
        	DOMNode *child = [children item:c];
            if ( [child isKindOfClass:[DOMHTMLElement class]] ) {
            	DOMHTMLElement *domChild = (id)child;
                [self removeFontAttributesFromDOMHTMLElement:domChild];
                DOMNodeList *elements = [domChild getElementsByTagName:@"*"];
                for ( NSUInteger i = 0; i < [elements length]; ++i ) {
                    DOMHTMLElement *el = (id)[elements item:i];
                    [self removeFontAttributesFromDOMHTMLElement:el];
                }                            
            }
        }
        [self replaceSelectionWithNode:documentFragment];
        return NO;
    }
	return YES;
}

#pragma mark Navigation Delegate Methods

-(void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id <WebPolicyDecisionListener>)listener
{
	NSNumber *navType = [actionInformation objectForKey:WebActionNavigationTypeKey];
    if ( [navType integerValue] == WebNavigationTypeLinkClicked ) {
        [listener ignore];
        [[NSWorkspace sharedWorkspace] openURL:request.URL];
    }
    else {
        [listener use];
    }
}

#pragma mark Accessors

-(void)setHtmlString:(NSString *)newString
{
	DOMHTMLElement *textContainerElement = (id)[self.mainFrame.DOMDocument getElementById:@"textcontainer"];
    textContainerElement.innerHTML = [newString copy];
}

-(NSString *)htmlString
{
	DOMHTMLElement *textContainerElement = (id)[self.mainFrame.DOMDocument getElementById:@"textcontainer"];
    return textContainerElement.innerHTML;
}

-(NSString *)plainString
{
    DOMHTMLElement *textContainerElement = (id)[self.mainFrame.DOMDocument getElementById:@"textcontainer"];
    return textContainerElement.innerText;
}

-(void)setFontFamily:(NSString *)newFamily
{
    DOMHTMLElement *textContainerElement = (id)[self.mainFrame.DOMDocument getElementById:@"textcontainer"];
    DOMCSSStyleDeclaration *style = textContainerElement.style;
	[style setFontFamily:[newFamily copy]];
}

-(NSString *)fontFamily
{
    DOMHTMLElement *textContainerElement = (id)[self.mainFrame.DOMDocument getElementById:@"textcontainer"];
    DOMCSSStyleDeclaration *style = textContainerElement.style;
	return [style fontFamily];
}

-(void)updateFontSize
{
    DOMHTMLElement *textContainerElement = (id)[self.mainFrame.DOMDocument getElementById:@"textcontainer"];
    DOMCSSStyleDeclaration *style = textContainerElement.style;
    [style setFontSize:[NSString stringWithFormat:@"%fpx", fontSize]];
}

-(void)setFontSize:(CGFloat)size
{
	fontSize = size;
    [self updateFontSize];
}

-(void)setTextColor:(NSColor *)newColor
{
	if  ( !newColor ) newColor = [NSColor blackColor];
    NSColor *rgbColor = [newColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat red = [rgbColor redComponent];
    CGFloat green = [rgbColor greenComponent];
    CGFloat blue = [rgbColor blueComponent];
	NSString *colorString = [NSString stringWithFormat:@"rgb(%d,%d,%d)", (int)(red * 255), (int)(green * 255), (int)(blue * 255)];
    DOMHTMLElement *textContainerElement = (id)[self.mainFrame.DOMDocument getElementById:@"textcontainer"];
    DOMCSSStyleDeclaration *style = textContainerElement.style;
    style.color = colorString;
}

-(NSColor *)textColor
{
    DOMHTMLElement *textContainerElement = (id)[self.mainFrame.DOMDocument getElementById:@"textcontainer"];
    DOMCSSStyleDeclaration *style = textContainerElement.style;
    NSString *colorString = style.color;
    NSScanner *scanner = [NSScanner scannerWithString:colorString];
    NSCharacterSet *skipSet = [NSCharacterSet characterSetWithCharactersInString:@"rgb(, "];
    float red, green, blue;
    [scanner setCharactersToBeSkipped:skipSet];
    [scanner scanFloat:&red];
    [scanner scanFloat:&green];
    [scanner scanFloat:&blue];
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0f];
}

-(void)setTextAlignment:(NSTextAlignment)newAlignment
{
    DOMHTMLElement *textContainerElement = (id)[self.mainFrame.DOMDocument getElementById:@"textcontainer"];
    DOMCSSStyleDeclaration *style = textContainerElement.style;
    
    NSString *alignString;
    switch ( newAlignment ) {
        case NSLeftTextAlignment:
            alignString = @"left";
            break;
        case NSRightTextAlignment:
            alignString = @"right";
            break;
        case NSCenterTextAlignment:
            alignString = @"center";
            break;
        default:
        	alignString = @"center";
            break;
    }
	style.textAlign = alignString;
}

-(NSTextAlignment)textAlignment
{
    DOMHTMLElement *textContainerElement = (id)[self.mainFrame.DOMDocument getElementById:@"textcontainer"];
    DOMCSSStyleDeclaration *style = textContainerElement.style;
    NSString *alignString = style.textAlign;
    
    NSTextAlignment alignment = NSCenterTextAlignment;
    if ( [alignString isEqualToString:@"left"] ) 
    	alignment = NSLeftTextAlignment;
    else if ( [alignString isEqualToString:@"center"] ) 
    	alignment = NSCenterTextAlignment;
    else if ( [alignString isEqualToString:@"right"] ) 
    	alignment = NSRightTextAlignment;
    
    return alignment;
}

@end
