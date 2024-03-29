//
//  BBRootVC.m
//  BroBox
//
//  Created by Tanguy Hélesbeux on 23/01/2015.
//  Copyright (c) 2015 Brobox. All rights reserved.
//

#import "BBRootVC.h"

// Navigation Controllers
#import "BBMapNavigationController.h"
#import "BBMissionListNavigationController.h"
#import "BBCreateMissionNavigationController.h"

// Controllers
#import "BBLogoutVC.h"
#import "BBSettingsVC.h"

@interface BBRootVC ()

@property (strong, nonatomic) UIViewController * mapVC;
@property (strong, nonatomic) UIViewController * missionsVC;
@property (strong, nonatomic) UIViewController * createVC;
@property (strong, nonatomic) UIViewController * notificationVC;
@property (strong, nonatomic) UIViewController * settingsVC;

@end

@implementation BBRootVC

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mapVC = [BBMapNavigationController new];
        self.mapVC.tabBarItem.image = [UIImage imageNamed:@"map.png"];
        
        self.missionsVC = [BBMissionListNavigationController new];
        self.missionsVC.tabBarItem.image = [UIImage imageNamed:@"list.png"];
        
        self.createVC = [BBCreateMissionNavigationController new];
        self.createVC.tabBarItem.image = [UIImage imageNamed:@"mission.png"];
        
        self.notificationVC = [UIViewController new];
        self.notificationVC.view.backgroundColor = [UIColor redColor];
        self.notificationVC.title = @"Notifs";
        self.notificationVC.tabBarItem.image = [UIImage imageNamed:@"alert.png"];
        
        self.settingsVC = [[BBNavigationController alloc] initWithRootViewController:[BBSettingsVC new]];
        self.settingsVC.title = @"Settings";
        self.settingsVC.tabBarItem.image = [UIImage imageNamed:@"settings.png"];
        
        [self setViewControllers:@[
                                   self.mapVC,
                                   self.missionsVC,
                                   self.createVC,
                                   self.notificationVC,
                                   self.settingsVC
                                   ]];
        self.tabBar.translucent = NO;
        
        [self setUpAppearance];
    }
    return self;
}

#pragma mark - Appearance

- (void)setUpAppearance {
    self.tabBar.tintColor = [UIColor colorWithRed:0.89f green:0.40f blue:0.00f alpha:1.00f];
}

@end
