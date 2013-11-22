//
//  AppDelegate.m
//  Beacon
//
//  Created by Joshua Barrow on 11/22/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setMainWindowController:[[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"]];
    
    [[[self mainWindowController] window] makeKeyAndOrderFront:nil];
}

@end
