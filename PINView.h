/**
 * This header is generated by class-dump-z 0.2-0.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/Preferences.framework/Preferences
 */

#import "PINEntryView.h"
#import "Preferences-Structs.h"
#import <UIKit/UIView.h>

@class FailureBarView, UILabel;

@interface PINView : UIView <PINEntryView> {
	UILabel* _titleLabel;
	UILabel* _errorTitleLabel;
	FailureBarView* _failureView;
	UILabel* _pinPolicyLabel;
	BOOL _error;
	id _delegate;
}
-(void)showError:(id)error animate:(BOOL)animate;
-(void)setPINPolicyString:(id)string visible:(BOOL)visible;
-(void)hideError;
-(void)hidePasscodeField:(BOOL)field;
-(void)setTitle:(id)title font:(id)font;
-(id)stringValue;
-(void)setStringValue:(id)value;
-(void)deleteLastCharacter;
-(void)appendString:(id)string;
-(BOOL)becomeFirstResponder;
-(void)setDelegate:(id)delegate;
-(void)showFailedAttempts:(int)attempts;
-(void)hideFailedAttempts;
-(void)dealloc;
-(void)setBlocked:(BOOL)blocked;
@end

