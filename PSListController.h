/**
 * This header is generated by class-dump-z 0.2-0.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/Preferences.framework/Preferences
 */

#import <UIKit/UITableViewDelegate.h>
#import <UIKit/UITableViewDataSource.h>
#import <UIKit/UIActionSheetDelegate.h>
#import "Preferences-Structs.h"
#import "PSViewController.h"

@class NSMutableDictionary, NSArray, NSMutableArray, NSString, UIActionSheet, UIAlertView, UIKeyboard, UIPopoverController, PreferencesTable, SnapshotView;

@interface PSListController : PSViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	NSMutableDictionary* _cells;
	BOOL _cachesCells;
	PreferencesTable* _table;
	SnapshotView* _snapshotTable;
	NSArray* _specifiers;
	NSMutableDictionary* _specifiersByID;
	NSMutableArray* _groups;
	NSString* _specifierID;
	NSMutableArray* _bundleControllers;
	BOOL _bundlesLoaded;
	BOOL _showingSetupController;
	UIActionSheet* _actionSheet;
	UIAlertView* _alertView;
	BOOL _keyboardWasVisible;
	UIKeyboard* _keyboard;
	UIPopoverController* _popupStylePopoverController;
	BOOL _popupStylePopoverShouldRePresent;
	BOOL _popupIsModal;
	BOOL _popupIsDismissing;
	BOOL _hasAppeared;
}
+(BOOL)displaysButtonBar;
-(void)clearCache;
-(void)setCachesCells:(BOOL)cells;
-(id)description;
-(id)table;
-(id)bundle;
-(id)specifier;
-(id)loadSpecifiersFromPlistName:(id)plistName target:(id)target;
-(id)specifiers;
-(void)_addIdentifierForSpecifier:(id)specifier;
-(void)_removeIdentifierForSpecifier:(id)specifier;
-(void)_setSpecifiers:(id)specifiers;
-(void)setSpecifiers:(id)specifiers;
-(id)indexPathForIndex:(int)index;
-(int)indexForIndexPath:(id)indexPath;
-(void)beginUpdates;
-(void)endUpdates;
-(void)reloadSpecifierAtIndex:(int)index animated:(BOOL)animated;
-(void)reloadSpecifierAtIndex:(int)index;
-(void)reloadSpecifier:(id)specifier animated:(BOOL)animated;
-(void)reloadSpecifier:(id)specifier;
-(void)reloadSpecifierID:(id)anId animated:(BOOL)animated;
-(void)reloadSpecifierID:(id)anId;
-(int)indexOfSpecifierID:(id)specifierID;
-(int)indexOfSpecifier:(id)specifier;
-(BOOL)containsSpecifier:(id)specifier;
-(int)indexOfGroup:(int)group;
-(int)numberOfGroups;
-(id)specifierAtIndex:(int)index;
-(BOOL)getGroup:(int*)group row:(int*)row ofSpecifierID:(id)specifierID;
-(BOOL)getGroup:(int*)group row:(int*)row ofSpecifier:(id)specifier;
-(BOOL)_getGroup:(int*)group row:(int*)row ofSpecifierAtIndex:(int)index groups:(id)groups;
-(BOOL)getGroup:(int*)group row:(int*)row ofSpecifierAtIndex:(int)index;
-(int)rowsForGroup:(int)group;
-(id)specifiersInGroup:(int)group;
-(void)insertSpecifier:(id)specifier atIndex:(int)index animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier afterSpecifier:(id)specifier2 animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier afterSpecifierID:(id)anId animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier atEndOfGroup:(int)group animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier atIndex:(int)index;
-(void)insertSpecifier:(id)specifier afterSpecifier:(id)specifier2;
-(void)insertSpecifier:(id)specifier afterSpecifierID:(id)anId;
-(void)insertSpecifier:(id)specifier atEndOfGroup:(int)group;
-(void)_insertContiguousSpecifiers:(id)specifiers atIndex:(int)index animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers atIndex:(int)index animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifier:(id)specifier animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifierID:(id)anId animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers atEndOfGroup:(int)group animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers atIndex:(int)index;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifier:(id)specifier;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifierID:(id)anId;
-(void)insertContiguousSpecifiers:(id)specifiers atEndOfGroup:(int)group;
-(void)addSpecifier:(id)specifier;
-(void)addSpecifier:(id)specifier animated:(BOOL)animated;
-(void)addSpecifiersFromArray:(id)array;
-(void)addSpecifiersFromArray:(id)array animated:(BOOL)animated;
-(void)removeSpecifier:(id)specifier animated:(BOOL)animated;
-(void)removeSpecifierID:(id)anId animated:(BOOL)animated;
-(void)removeSpecifierAtIndex:(int)index animated:(BOOL)animated;
-(void)removeSpecifier:(id)specifier;
-(void)removeSpecifierID:(id)anId;
-(void)removeSpecifierAtIndex:(int)index;
-(void)removeLastSpecifier;
-(void)removeLastSpecifierAnimated:(BOOL)animated;
-(void)_removeContiguousSpecifiers:(id)specifiers animated:(BOOL)animated;
-(void)removeContiguousSpecifiers:(id)specifiers animated:(BOOL)animated;
-(void)removeContiguousSpecifiers:(id)specifiers;
-(void)replaceContiguousSpecifiers:(id)specifiers withSpecifiers:(id)specifiers2;
-(void)replaceContiguousSpecifiers:(id)specifiers withSpecifiers:(id)specifiers2 animated:(BOOL)animated;
-(void)_loadBundleControllers;
-(void)_unloadBundleControllers;
-(void)dealloc;
-(id)init;
-(id)initForContentSize:(CGSize)contentSize;
-(void)loadView;
-(id)_createGroupIndices:(id)indices;
-(void)createGroupIndices;
-(void)loseFocus;
-(void)reload;
-(void)reloadSpecifiers;
-(void)setSpecifierID:(id)anId;
-(id)specifierID;
-(void)setTitle:(id)title;
-(int)numberOfSectionsInTableView:(id)tableView;
-(int)tableView:(id)view numberOfRowsInSection:(int)section;
-(id)cachedCellForSpecifier:(id)specifier;
-(id)cachedCellForSpecifierID:(id)specifierID;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
-(float)tableView:(id)view heightForRowAtIndexPath:(id)indexPath;
-(id)tableView:(id)view titleForHeaderInSection:(int)section;
-(id)tableView:(id)view titleForFooterInSection:(int)section;
-(int)tableView:(id)view titleAlignmentForHeaderInSection:(int)section;
-(int)tableView:(id)view titleAlignmentForFooterInSection:(int)section;
-(id)_customViewForSpecifier:(id)specifier class:(Class)aClass isHeader:(BOOL)header;
-(float)_tableView:(id)view heightForCustomInSection:(int)section isHeader:(BOOL)header;
-(id)_tableView:(id)view viewForCustomInSection:(int)section isHeader:(BOOL)header;
-(float)tableView:(id)view heightForHeaderInSection:(int)section;
-(id)tableView:(id)view viewForHeaderInSection:(int)section;
-(float)tableView:(id)view heightForFooterInSection:(int)section;
-(id)tableView:(id)view viewForFooterInSection:(int)section;
-(void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
-(void)didRotateFromInterfaceOrientation:(int)interfaceOrientation;
-(void)viewWillAppear:(BOOL)view;
-(BOOL)shouldSelectResponderOnAppearance;
-(id)findFirstVisibleResponder;
-(void)viewDidLoad;
-(void)viewDidAppear:(BOOL)view;
-(void)formSheetViewWillDisappear;
-(void)popupViewWillDisappear;
-(void)_returnKeyPressed:(id)pressed;
-(BOOL)performActionForSpecifier:(id)specifier;
-(void)showConfirmationViewForSpecifier:(id)specifier;
-(void)showConfirmationSheetForSpecifier:(id)specifier;
-(void)confirmationViewAcceptedForSpecifier:(id)specifier;
-(void)alertView:(id)view clickedButtonAtIndex:(int)index;
-(void)actionSheet:(id)sheet clickedButtonAtIndex:(int)index;
-(id)controllerForRowAtIndexPath:(id)indexPath;
-(void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath;
-(id)specifierForID:(id)anId;
-(void)pushController:(id)controller animate:(BOOL)animate;
-(BOOL)popoverControllerShouldDismissPopover:(id)popoverController;
-(void)popoverController:(id)controller animationCompleted:(int)completed;
-(void)dismissPopover;
-(void)pushController:(id)controller;
-(void)handleURL:(id)url;
-(void)reloadIconForSpecifierForBundle:(id)bundle;
-(void)showKeyboardWithKeyboardType:(int)keyboardType;
-(float)_getKeyboardIntersectionHeight;
-(void)_setContentInset:(float)inset;
-(void)_keyboardWillShow:(id)_keyboard;
-(void)_keyboardWillHide:(id)_keyboard;
-(void)selectRowForSpecifier:(id)specifier;
@end

