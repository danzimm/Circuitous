/**
 * This header is generated by class-dump-z 0.2-0.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/Preferences.framework/Preferences
 */

#import "Preferences-Structs.h"
#import "PSViewController.h"

@class PSEditingPane;

@interface PSDetailController : PSViewController {
	PSEditingPane* _pane;
}
@property(assign, nonatomic) PSEditingPane* pane;
-(id)init;
-(void)loadView;
-(void)viewDidUnload;
-(void)dealloc;
-(CGRect)paneFrame;
-(void)willRotateToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
-(void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
-(void)didRotateFromInterfaceOrientation:(int)interfaceOrientation;
-(void)viewWillAppear:(BOOL)view;
-(void)viewDidAppear:(BOOL)view;
-(void)saveChanges;
-(void)suspend;
-(void)viewWillDisappear:(BOOL)view;
@end

