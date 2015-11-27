//
//  ViewController.m
//  JSegueDemo
//
//  Created by Jeans Huang on 11/20/15.
//  Copyright © 2015 gzhu. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+JSegue.h"
#import "NoXibViewController.h"

@implementation ViewController

//push Storyboard 中 的 viewController，使用 id
- (IBAction)pushWithStoryboardID:(id)sender {
    
    //如果使用storyboard，需要先设置storyboard文件名才能查找
    //初始化项目的时候设置一次即可
    [UIViewController js_setStoryboardNames:@"Main"];
    
    [self js_push:@"sbID"];
}

//push 无 xib 的 viewController
- (IBAction)pushWithClassNameNoXib:(id)sender {
    
    NSInteger test = 2;
    
    switch (test) {
            
        case 1://直接使用类名
            
            [self js_push:@"NoXibViewController"];
            break;
            
        case 2:{//创建实例
            
            NoXibViewController *vc = [[NoXibViewController alloc]init];
            [self js_push:vc];
            
        }
            break;
        default:
            break;
    }
    
}

//push 有 xib 的 viewController
- (IBAction)pushWithClassNameWithXib:(id)sender {
    
    NSDictionary *paramDict = @{@"publicProperty":@"hello public property",
                                @"privateProperty":@"hello private property",
                                @"customDictParam":@"hello custom dict param"};
    
    NSInteger test = 3;
    
    switch (test) {
            
        case 1:{
            
            //只设置property
            //初始化项目的时候设置一次即可
            [UIViewController js_setParamType:JSegueParamTypeOnlyProperty];
            
            break;
        }
            
        case 2:{
            
            //只设置字典,这是默认的传参方式
            //初始化项目的时候设置一次即可
            [UIViewController js_setParamType:JSegueParamTypeOnlyDictionary];
            
            break;
        }
            
        case 3:{
            
            //设置全部传参方式，优先设置property，若不存在，则设置字典
            //初始化项目的时候设置一次即可
            [UIViewController js_setParamType:JSegueParamTypeAll];
            
            break;
        }
        default:
            break;
    }
    
    [self js_push:@"XibViewController" param:paramDict];
}

//模态显示
- (IBAction)modal:(id)sender {
    
    //模态显示会创建一个导航控制器，如果有定制的导航类，需要先设置
    //初始化项目的时候设置一次即可
    [UIViewController js_setCustomNavigationControllerClassName:@"CustomNavigationController"];
    
    [self setJs_didShowViewControllerBlock:^{
        NSLog(@"modal show");
    }];
    
    [self js_present:@"ModalViewController"];
}


@end
