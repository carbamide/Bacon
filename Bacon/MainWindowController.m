//
//  MainWindowController.m
//  Beacon
//
//  Created by Joshua Barrow on 11/22/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "MainWindowController.h"
#import <IOBluetooth/IOBluetooth.h>
#import "AdvertisementData.h"
#import <ObjectiveRecord/ObjectiveRecord.h>
#import "BeaconCell.h"
#import "Beacon.h"
#import "CNSplitView.h"
#import "ProjectHandler.h"

@interface MainWindowController () <CBPeripheralManagerDelegate, CNSplitViewToolbarDelegate>
@property (strong, nonatomic) CBPeripheralManager *manager;
@property (strong, nonatomic) NSMutableArray *beacons;
@property (strong, nonatomic) CNSplitViewToolbar *toolbar;
@property (strong, nonatomic) CNSplitViewToolbarButton *removeButton;
@property (strong, nonatomic) CNSplitViewToolbarButton *addButton;
@property (strong, nonatomic) CNSplitViewToolbarButton *exportButton;
@property (strong, nonatomic) Beacon *currentBeacon;
@property (nonatomic) NSInteger currentIndex;

-(void)setupSplitviewController;
-(void)addBeacon:(id)sender;
-(void)removeBeacon:(id)sender;
-(void)exportBeacon:(id)sender;
-(void)selectBeacon:(Beacon *)beacon;
@end

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[self beaconTableView] registerForDraggedTypes:@[NSFilenamesPboardType, NSFilesPromisePboardType, @"beacon"]];
    [[self beaconTableView] setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
    [self setupSplitviewController];
    
    [self setBeacons:[[Beacon all] mutableCopy]];
    [[self beaconTableView] reloadData];
    
    [self setManager:[[CBPeripheralManager alloc] initWithDelegate:self queue:nil]];
    
    [[self beaconToggleButton] setEnabled:NO];
    [[self nameTextField] setEnabled:NO];
    [[self majorTextField] setEnabled:NO];
    [[self minorTextField] setEnabled:NO];
    [[self powerTextField] setEnabled:NO];
    [[self UUIDTextField] setEnabled:NO];
    
    [[self beaconStatusLabel] setAttributedStringValue:[[NSAttributedString alloc] initWithString:@"Beacon Off" attributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:13]}]];
}

#pragma mark -
#pragma mark Methods

-(void)setupSplitviewController
{
    [self setToolbar:[[CNSplitViewToolbar alloc] init]];
    
    _addButton = [[CNSplitViewToolbarButton alloc] init];
    [[self addButton] setImageTemplate:CNSplitViewToolbarButtonImageTemplateAdd];
    [[self addButton] setTarget:self];
    [[self addButton] setAction:@selector(addBeacon:)];
    
    _removeButton = [[CNSplitViewToolbarButton alloc] init];
    [[self removeButton] setImageTemplate:CNSplitViewToolbarButtonImageTemplateRemove];
    [[self removeButton] setTarget:self];
    [[self removeButton] setAction:@selector(removeBeacon:)];
    [[self removeButton] setEnabled:NO];
    
    _exportButton = [[CNSplitViewToolbarButton alloc] init];
    [[self exportButton] setImageTemplate:CNSplitViewToolbarButtonImageTemplateShare];
    [[self exportButton] setTarget:self];
    [[self exportButton] setAction:@selector(exportBeacon:)];
    [[self exportButton] setEnabled:NO];
    
    [[self toolbar] addItem:[self addButton] align:CNSplitViewToolbarItemAlignLeft];
    [[self toolbar] addItem:[self removeButton] align:CNSplitViewToolbarItemAlignLeft];
    [[self toolbar] addItem:[self exportButton] align:CNSplitViewToolbarItemAlignRight];

    [[self splitView] setToolbarDelegate:self];
    [[self splitView] attachToolbar:[self toolbar] toSubViewAtIndex:0 onEdge:CNSplitViewToolbarEdgeBottom];
    
    [[self splitView] showToolbarAnimated:NO];
    
}

-(void)addBeacon:(id)sender
{
    Beacon *newBeacon = [Beacon create];
    
    [newBeacon setName:@"New Beacon"];
    [newBeacon setUuid:[NSString string]];
    [newBeacon setMajor:[NSString string]];
    [newBeacon setMinor:[NSString string]];
    [newBeacon setPower:[NSString string]];
    [newBeacon setStatus:@"Beacon Off"];
    
    if (![newBeacon save]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"There was an error saving the Beacon."];
        
        [alert beginSheetModalForWindow:[self window] completionHandler:nil];
    }
    
    [[self beacons] addObject:newBeacon];
    
    [[self beaconToggleButton] setEnabled:YES];
    [[self nameTextField] setEnabled:YES];
    [[self majorTextField] setEnabled:YES];
    [[self minorTextField] setEnabled:YES];
    [[self powerTextField] setEnabled:YES];
    [[self UUIDTextField] setEnabled:YES];
    
    [[self beaconTableView] insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[[self beacons] count]] withAnimation:NSTableViewAnimationEffectFade];
    
    [[self beaconTableView] selectRowIndexes:[NSIndexSet indexSetWithIndex:[[self beacons] count]] byExtendingSelection:NO];
}

-(void)removeBeacon:(id)sender
{
    NSInteger selectedRow = [[self beaconTableView] selectedRow];
    
    Beacon *beacon = [self beacons][selectedRow];
    
    if (beacon == [self currentBeacon]) {
        [self setCurrentIndex:-1];
        [self setCurrentBeacon:nil];
        
        [[self beaconToggleButton] setEnabled:NO];
        [[self nameTextField] setEnabled:NO];
        [[self majorTextField] setEnabled:NO];
        [[self minorTextField] setEnabled:NO];
        [[self powerTextField] setEnabled:NO];
        [[self UUIDTextField] setEnabled:NO];
        
        [[self nameTextField] setStringValue:[NSString string]];
        [[self majorTextField] setStringValue:[NSString string]];
        [[self minorTextField] setStringValue:[NSString string]];
        [[self powerTextField] setStringValue:[NSString string]];
        [[self UUIDTextField] setStringValue:[NSString string]];
    }
    
    [beacon delete];
    
    [[self beacons] removeObject:beacon];
    
    [[self beaconTableView] removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] withAnimation:NSTableViewAnimationEffectFade];
}

-(void)selectBeacon:(Beacon *)theBeacon
{
    [[self exportButton] setEnabled:YES];

    [self setCurrentBeacon:theBeacon];
    
    if ([[theBeacon status] isEqualToString:@"Beacon Off"]) {
        [[self beaconToggleButton] setEnabled:YES];
        [[self beaconToggleButton] setTitle:@"Turn Beacon On"];
        
        [[self nameTextField] setEnabled:YES];
        [[self majorTextField] setEnabled:YES];
        [[self minorTextField] setEnabled:YES];
        [[self powerTextField] setEnabled:YES];
        [[self UUIDTextField] setEnabled:YES];
    }
    else {
        [[self beaconToggleButton] setEnabled:YES];
        [[self beaconToggleButton] setTitle:@"Turn Beacon Off"];

        [[self nameTextField] setEnabled:NO];
        [[self majorTextField] setEnabled:NO];
        [[self minorTextField] setEnabled:NO];
        [[self powerTextField] setEnabled:NO];
        [[self UUIDTextField] setEnabled:NO];
    }
    
    [[self nameTextField] setStringValue:[theBeacon name] ? [theBeacon name] : [NSString string]];
    [[self UUIDTextField] setStringValue:[theBeacon uuid] ? [theBeacon uuid] : [NSString string]];
    [[self majorTextField] setStringValue:[theBeacon major] ? [theBeacon major] : [NSString string]];
    [[self minorTextField] setStringValue:[theBeacon minor] ? [theBeacon minor] : [NSString string]];
    [[self powerTextField] setStringValue:[theBeacon power] ? [theBeacon power] : [NSString string]];
}

-(void)exportBeacon:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    Beacon *beacon = [self beacons][[[self beaconTableView] selectedRow]];
    
    if (!beacon) {
        beacon = [self currentBeacon];
    }
    
    NSAssert(beacon, @"beacon cannot be nil in %s", __FUNCTION__);
    
    [savePanel setTitle:@"Export"];
    [savePanel setNameFieldStringValue:[[beacon name] stringByAppendingPathExtension:@"beacon"]];
    
    [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSError *error = nil;
            
            [ProjectHandler exportBeacon:beacon toUrl:[savePanel URL] error:&error];
            
            if (error) {
                [savePanel endSheet:[self window]];
                
                NSAlert *alert = [NSAlert alertWithError:error];
                
                [alert beginSheetModalForWindow:[self window] completionHandler:nil];
            }
        }
    }];
}

#pragma mark -
#pragma mark IBActions

-(IBAction)toggleBeaconAction:(id)sender
{
    if ([[self manager] isAdvertising]) {
        [[self beaconStatusLabel] setAttributedStringValue:[[NSAttributedString alloc] initWithString:@"Beacon Off" attributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:13]}]];
        
        [[self beaconToggleButton] setTitle:@"Turn Beacon On"];
        [[self nameTextField] setEnabled:YES];
        [[self majorTextField] setEnabled:YES];
        [[self minorTextField] setEnabled:YES];
        [[self powerTextField] setEnabled:YES];
        [[self UUIDTextField] setEnabled:YES];
        
        [[self manager] stopAdvertising];
        
        [[self currentBeacon] setStatus:@"Beacon Off"];
        [[self currentBeacon] save];
        
        [[self beaconTableView] reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self currentIndex]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
    else {
        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:[[self UUIDTextField] stringValue]];
        
        if (!proximityUUID) {
            NSAlert *error = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"A UUID must be specified."];
            
            [error beginSheetModalForWindow:[self window] completionHandler:nil];
            
            return;
        }
        
        AdvertisementData *beaconData = [[AdvertisementData alloc] initWithProximityUUID:proximityUUID
                                                                                   major:[[self majorTextField] integerValue]
                                                                                   minor:[[self minorTextField] integerValue]
                                                                           measuredPower:[[self powerTextField] integerValue]];
        
        [[self beaconStatusLabel] setAttributedStringValue:[[NSAttributedString alloc] initWithString:@"Beacon On" attributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:13]}]];
        
        [[self manager] startAdvertising:[beaconData beaconAdvertisement]];
        
        [[self beaconToggleButton] setTitle:@"Turn Beacon Off"];
        [[self nameTextField] setEnabled:NO];
        [[self majorTextField] setEnabled:NO];
        [[self minorTextField] setEnabled:NO];
        [[self powerTextField] setEnabled:NO];
        [[self UUIDTextField] setEnabled:NO];
        
        
        [[self currentBeacon] setStatus:@"Beacon On"];
        [[self currentBeacon] save];
        
        [[self beaconTableView] reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self currentIndex]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
}

-(IBAction)generateUUIDAction:(id)sender
{
    NSUUID *proximityUUID = [NSUUID UUID];
    
    [[self currentBeacon] setUuid:[proximityUUID UUIDString]];
    [[self currentBeacon] save];
    
    [[self UUIDTextField] setStringValue:[proximityUUID UUIDString]];
}

#pragma mark -
#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if ([peripheral state] != CBPeripheralManagerStatePoweredOn) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"There was an error when starting to advertise this Beacon."];
        
        [alert beginSheetModalForWindow:[self window] completionHandler:nil];
    }
}

#pragma mark
#pragma mark CNSplitViewToolbarDelegate

- (NSUInteger)toolbarAttachedSubviewIndex:(CNSplitViewToolbar *)theToolbar
{
    return 0;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[self beacons] count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *const identifer = @"BeaconCell";
    
    BeaconCell *cell = [tableView makeViewWithIdentifier:identifer owner:self];
    
    Beacon *beacon = [self beacons][row];
    
    [[cell nameTextField] setStringValue:[beacon name] ? [beacon name] : [NSString string]];
    [[cell statusTextField] setStringValue:[beacon status] ? [beacon status] : [NSString string]];
    
    return cell;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger selectedRow = [[self beaconTableView] selectedRow];
    
    if (selectedRow != -1) {
        [self setCurrentIndex:selectedRow];
        
        id selectedItem = [self beacons][selectedRow];
        
        [self selectBeacon:selectedItem];
        
        [[self removeButton] setEnabled:YES];
    }
}

#pragma mark
#pragma mark NSControlTextDelegate

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSLog(@"%s", __FUNCTION__);
    
    if ([notification object] == [self nameTextField]) {
        if ([[[self nameTextField] stringValue] length] > 0) {
            if ([self currentBeacon]) {
                [[self currentBeacon] setName:[[self nameTextField] stringValue]];
            }
        }
        else {
            [[self currentBeacon] setName:[NSString string]];
        }
    }
    else if ([notification object] == [self UUIDTextField]) {
        if ([[[self UUIDTextField] stringValue] length] > 0) {
            if ([self currentBeacon]) {
                [[self currentBeacon] setUuid:[[self UUIDTextField] stringValue]];
            }
        }
        else {
            [[self currentBeacon] setUuid:[NSString string]];
        }
    }
    else if ([notification object] == [self majorTextField]) {
        if ([[[self majorTextField] stringValue] length] > 0) {
            if ([self currentBeacon]) {
                [[self currentBeacon] setMajor:[[self majorTextField] stringValue]];
            }
        }
        else {
            [[self currentBeacon] setMajor:[NSString string]];
        }
    }
    else if ([notification object] == [self minorTextField]) {
        if ([[[self minorTextField] stringValue] length] > 0) {
            if ([self currentBeacon]) {
                [[self currentBeacon] setMinor:[[self minorTextField] stringValue]];
            }
        }
        else {
            [[self currentBeacon] setMinor:[NSString string]];
        }
    }
    else if ([notification object] == [self powerTextField]) {
        if ([[[self powerTextField] stringValue] length] > 0) {
            if ([self currentBeacon]) {
                [[self currentBeacon] setPower:[[self powerTextField] stringValue]];
            }
        }
        else {
            [[self currentBeacon] setPower:[NSString string]];
        }
    }
    
    [[self beaconTableView] reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self currentIndex]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    
    [[self currentBeacon] save];
}

#pragma mark - 
#pragma mark NSTableViewDelegate Drag Support

-(NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    return NSDragOperationGeneric;
}

-(BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *pasteboard = [info draggingPasteboard];
    
    NSArray *urls = [pasteboard readObjectsForClasses:@[[NSURL class]] options:0];
    
    if ([urls count] != 0) {
        for (NSURL *url in urls) {
            if ([ProjectHandler importFromPath:[url path]]) {
                [[self beacons] removeAllObjects];
                
                [self setBeacons:[[[Beacon all] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]] mutableCopy]];
                
                [[self beaconTableView] reloadData];
            }
        }
        
        return YES;
    }
    
    return NO;
}

@end
