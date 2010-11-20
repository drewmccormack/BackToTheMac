//
//  MCTextFieldWebView.h
//  BackToTheMac
//
//  Created by Drew McCormack on 15/11/10.
//  Copyright 2010 The Mental Faculty. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@class MCTextFieldWebView;


@protocol MCTextFieldWebViewDelegate <NSObject>


@optional
 
-(void)textFieldWebViewHTMLContentDidChange:(MCTextFieldWebView *)webView;
-(void)textFieldWebViewDidBeginEditing:(MCTextFieldWebView *)webView;
-(void)textFieldWebViewDidEndEditing:(MCTextFieldWebView *)webView;

@end



@interface MCTextFieldWebView : WebView {
    BOOL finishedLoading;
    BOOL failedLoad;
    CGFloat fontSize;
    IBOutlet __weak id <MCTextFieldWebViewDelegate> textFieldDelegate;
}

@property (nonatomic, copy) NSString *htmlString;
@property (nonatomic, readonly) NSString *plainString;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, copy) NSString *fontFamily;
@property (nonatomic, retain) NSColor *textColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) IBOutlet __weak id <MCTextFieldWebViewDelegate> textFieldDelegate;

@end
