//
//  ModalViewController.m
//  JSegueDemo
//
//  Created by Jeans Huang on 11/27/15.
//  Copyright © 2015 gzhu. All rights reserved.
//

#import "ModalViewController.h"
#import "UIViewController+JSegue.h"

@interface ModalViewController ()

@end

@implementation ModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
}

- (IBAction)dismiss:(id)sender {
    
    [self js_dismiss];
    
    //or
//    [self dismissViewControllerAnimated:YES
//                             completion:^{
//        
//    }];
}

@end
