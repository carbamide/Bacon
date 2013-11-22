//
//  BeaconCell.m
//  Bacon
//
//  Created by Joshua Barrow on 11/22/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "BeaconCell.h"

@implementation BeaconCell

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if ([[[self statusTextField] stringValue] isEqualToString:@"Beacon Off"]) {
        [[self statusImageView] setImage:[NSImage imageNamed:@"not_transmitting"]];
    }
    else {
        [[self statusImageView] setImage:[NSImage imageNamed:@"transmitting"]];
    }
}

@end

