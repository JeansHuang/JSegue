//
//  XibViewController.m
//  JSegueDemo
//
//  Created by Jeans Huang on 11/27/15.
//  Copyright © 2015 gzhu. All rights reserved.
//

#import "XibViewController.h"
#import "UIViewController+JSegue.h"

@interface XibViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (nonatomic, strong) NSString *privateProperty;

@end

@implementation XibViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"NoXibViewController received:%@",self.js_parameter);
    
    NSLog(@"publicProperty:%@",self.publicProperty);
    
    NSLog(@"privateProperty:%@",self.privateProperty);
    
    self.label.text = self.js_parameter[@"customDictParam"];
}



@end
