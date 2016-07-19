//
//  ULKLayoutViewController.m
//  UILayoutKit
//
//  Created by Tom Quist on 23.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKLayoutViewController.h"
#import "ULKLayoutInflater.h"

@implementation ULKLayoutViewController {
    NSURL *_layoutUrl;
}

@dynamic view;

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (nibBundleOrNil == nil) {
            nibBundleOrNil = [NSBundle mainBundle];
        }
        if (nibNameOrNil != nil) {
            _layoutUrl = [nibBundleOrNil URLForResource:nibNameOrNil withExtension:@"xml"];
        }
    }
    return self;
}

- (instancetype)initWithLayoutName:(NSString *)layoutNameOrNil bundle:(NSBundle *)layoutBundleOrNil {
    self = [self initWithNibName:layoutNameOrNil bundle:layoutBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithLayoutURL:(NSURL *)layoutURL {
    self = [super init];
    if (self) {
        _layoutUrl = layoutURL;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView {
    ULKLayoutBridge *bridge = [[ULKLayoutBridge alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    bridge.resizeOnKeyboard = TRUE;
    bridge.scrollToTextField = TRUE;
    bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (_layoutUrl != nil) {
        ULKLayoutInflater *inflater = [[ULKLayoutInflater alloc] init];
        inflater.actionTarget = self;
        [inflater inflateURL:_layoutUrl intoRootView:bridge attachToRoot:TRUE];
    }
    self.view = bridge;
}

- (ULKLayoutBridge *)view {
    return (ULKLayoutBridge *)super.view;
}

@end
