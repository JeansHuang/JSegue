//
//  JSegueNavigationController.m
//  JSegueDemo
//
//  Created by Jeans Huang on 11/24/15.
//  Copyright © 2015 gzhu. All rights reserved.
//

#import "JSegueNavigationController.h"
#import "UIViewController+JSegue.h"

@interface JSegueNavigationController ()

@end

@implementation JSegueNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

//如果子类继承重写，必须调用super
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.js_nav_willShowViewControllerBlock){
        self.js_nav_willShowViewControllerBlock();
        [self js_nav_remove_js_nav_willShowViewControllerBlock];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.js_nav_didShowViewControllerBlock){
        self.js_nav_didShowViewControllerBlock();
        [self js_nav_remove_js_nav_didShowViewControllerBlock];
    }
}

@end
