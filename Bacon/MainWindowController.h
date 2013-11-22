//
//  MainWindowController.h
//  Beacon
//
//  Created by Joshua Barrow on 11/22/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CNSplitView;

@interface MainWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>

@property (strong) IBOutlet NSTableView *beaconTableView;
@property (strong) IBOutlet NSButton *beaconToggleButton;
@property (strong) IBOutlet NSButton *generateUUIDButton;
@property (strong) IBOutlet NSTextField *nameTextField;
@property (strong) IBOutlet NSTextField *UUIDTextField;
@property (strong) IBOutlet NSTextField *majorTextField;
@property (strong) IBOutlet NSTextField *minorTextField;
@property (strong) IBOutlet NSTextField *powerTextField;
@property (strong) IBOutlet NSTextField *beaconStatusLabel;
@property (strong) IBOutlet CNSplitView *splitView;

-(IBAction)toggleBeaconAction:(id)sender;
-(IBAction)generateUUIDAction:(id)sender;

@end
