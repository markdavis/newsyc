//
//  CommentListController.m
//  Orangey
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HNKit.h"

#import "CommentListController.h"
#import "CommentTableCell.h"
#import "SlidingHeaderView.h"
#import "HeaderContainerView.h"
#import "DetailsHeaderView.h"
#import "SubmissionDetailsHeaderView.h"
#import "CommentDetailsHeaderView.h"
#import "EntryActionsView.h"
#import "ProfileController.h"
#import "BrowserController.h"

@implementation CommentListController

- (void)submissionDetailsViewWasTapped:(UIView *)view {
    BrowserController *controller = [[BrowserController alloc] initWithURL:[(HNEntry *) source destination]];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

- (void)entryActionsView:(EntryActionsView *)eav didSelectItem:(EntryActionsViewItem)item {
    if (item == kEntryActionsViewItemSubmitter) {
        ProfileController *controller = [[ProfileController alloc] initWithSource:[(HNEntry *) source submitter]];
        [controller setTitle:@"Profile"];
        [[self navigationController] pushViewController:[controller autorelease] animated:YES];
    } // XXX: handle others
}

- (void)dealloc {
    [headerContainerView release];
    [super dealloc];
}

- (void)finishedLoading {
    if ([source isKindOfClass:[HNEntry class]]) {
        headerContainerView = [[HeaderContainerView alloc] initWithEntry:(HNEntry *) source widthWidth:[[self view] bounds].size.width];
        [headerContainerView setClipsToBounds:YES];
        [headerContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
        [[headerContainerView entryActionsView] setDelegate:self];
        [[headerContainerView detailsHeaderView] setDelegate:self];
        
        UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(-50.0f, [headerContainerView bounds].size.height, [[self view] bounds].size.width + 100.0f, 1.0f)];
        CALayer *layer = [shadow layer];
        [layer setShadowOffset:CGSizeMake(0, -2.0f)];
        [layer setShadowRadius:5.0f];
        [layer setShadowColor:[[UIColor blackColor] CGColor]];
        [layer setShadowOpacity:1.0f];
        [shadow setBackgroundColor:[UIColor grayColor]];
        [shadow setClipsToBounds:NO];
        
        UIView *container = [[UIView alloc] initWithFrame:[headerContainerView bounds]];
        [container setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [container setBackgroundColor:[UIColor clearColor]];
        [container addSubview:headerContainerView];
        [container addSubview:[shadow autorelease]];
        [container setClipsToBounds:NO];
        
        [tableView setTableHeaderView:[container autorelease]];
        
        suggestedHeaderHeight = [headerContainerView bounds].size.height;
    }

    [super finishedLoading];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = [scrollView contentOffset].y;
    if (suggestedHeaderHeight < 280.0f || offset > suggestedHeaderHeight - 280.0f) {
        CGRect frame = [headerContainerView frame];
        if (suggestedHeaderHeight - 280.0f > 0) offset -= suggestedHeaderHeight - 280.0f;
        frame.origin.y = offset;
        frame.size.height = suggestedHeaderHeight - offset;
        [headerContainerView setFrame:frame];
    }
}

- (void)loadView {
    [super loadView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return [source loaded] ? 1 : 0;
}

- (HNEntry *)entryAtIndexPath:(NSIndexPath *)indexPath {
    if ([source isKindOfClass:[HNEntry class]]) {
        return [[(HNEntry *) source children] objectAtIndex:[indexPath row]];
    } else {
        return [[(HNEntryList *) source entries] objectAtIndex:[indexPath row]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([source isKindOfClass:[HNEntry class]]) {
        return [[(HNEntry *) source children] count];
    } else {
        return [[(HNEntryList *) source entries] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    return [CommentTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableCell *cell = (CommentTableCell *) [tableView dequeueReusableCellWithIdentifier:@"comment"];
    if (cell == nil) cell = [[[CommentTableCell alloc] initWithReuseIdentifier:@"comment"] autorelease];
    
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    [cell setComment:entry];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    
    CommentListController *controller = [[CommentListController alloc] initWithSource:entry];
    [controller setTitle:@"Comments"];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

@end