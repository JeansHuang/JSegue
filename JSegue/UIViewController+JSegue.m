//
//  UIViewController+JSegue.m
//  JSegueDemo
//
//  Created by Jeans Huang on 11/20/15.
//  Copyright © 2015 gzhu. All rights reserved.
//

#import "UIViewController+JSegue.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, PushType) {
    PushTypeNormal = 1,
    PushTypePushOrPop,
    PushTypeRemovePrior
};

#pragma mark - UINavigationController (JSegue)

@interface UINavigationController()

@property (nonatomic, copy) void(^js_nav_willShowViewControllerBlock)();
@property (nonatomic, copy) void(^js_nav_didShowViewControllerBlock)();

@end

#pragma mark - UIViewController category

@interface UIViewController ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *js_parameter;

@end

#pragma mark - UIViewController category implementation

@implementation UIViewController (JSegue)
@dynamic js_willShowViewControllerBlock;
@dynamic js_didShowViewControllerBlock;

#pragma mark - properties

//传参
- (void)setJs_parameter:(NSMutableDictionary *)js_parameter{
    objc_setAssociatedObject(self, @selector(js_parameter), js_parameter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)js_parameter{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, _cmd);
    if (!dict){
        dict = [NSMutableDictionary dictionary];
        [self setJs_parameter:dict];
    }
    return dict;
}

//will show block
- (void)setJs_willShowViewControllerBlock:(void (^)())js_willShowViewControllerBlock{
    self.navigationController.js_nav_willShowViewControllerBlock = js_willShowViewControllerBlock;
}

//did show block
- (void)setJs_didShowViewControllerBlock:(void (^)())js_didShowViewControllerBlock{
    self.navigationController.js_nav_didShowViewControllerBlock = js_didShowViewControllerBlock;
}

//animated
- (void)setJs_animated:(BOOL)js_animated{
    objc_setAssociatedObject(self, @selector(js_animated), @(js_animated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)js_animated{
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (!value){
        value = @(YES);
        [self setJs_animated:value.boolValue];
    }
    return value.boolValue;
}

#pragma mark - private methods

- (void)pushViewController:(id)aVC
                     param:(NSDictionary *)param
                  pushType:(PushType)type
               removePrior:(NSInteger)removePriorCount{
    
    if (!aVC)return;
    
    if (type == PushTypePushOrPop &&
        [aVC isKindOfClass:[NSString class]]){
        
        Class vcClass = NSClassFromString(aVC);
        __block BOOL flag = NO;
        __block UIViewController *realVC = nil;
        [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:vcClass]){
                realVC = obj;
                flag = YES;
                *stop = YES;
            }
        }];
        
        if (flag){
            [self bindingViewController:realVC withParam:param];
            [self.navigationController popToViewController:realVC animated:self.js_animated];
            return;
        }
    }
    
    UIViewController *realVC = [self getRealViewController:aVC];
    if (realVC){
        //绑定参数
        [self bindingViewController:realVC withParam:param];
        
        switch (type) {
            case PushTypeRemovePrior:{
                
                __weak typeof(UINavigationController*) weakNavCtrl = self.navigationController;
                void (^oldBlock)() = weakNavCtrl.js_nav_didShowViewControllerBlock;
                void (^completionBlock)() = ^{
                    
                    if (removePriorCount == -1 ||
                        removePriorCount >= weakNavCtrl.viewControllers.count - 1){
                        //移除非栈顶viewController
                        [weakNavCtrl setViewControllers:@[weakNavCtrl.viewControllers.lastObject]
                                               animated:NO];
                        
                    }else if (removePriorCount > 0 &&
                              removePriorCount < weakNavCtrl.viewControllers.count){
                        
                        NSMutableArray *vcArray = [NSMutableArray arrayWithArray:weakNavCtrl.viewControllers];
                        [vcArray removeObjectsInRange:NSMakeRange(vcArray.count - removePriorCount - 1, removePriorCount)];
                        [weakNavCtrl setViewControllers:vcArray animated:NO];
                    }
                    
                    if (oldBlock)
                        oldBlock();
                };
                
                weakNavCtrl.js_nav_didShowViewControllerBlock = completionBlock;
            }
            case PushTypeNormal:
            case PushTypePushOrPop:{
                [self.navigationController pushViewController:realVC animated:self.js_animated];
                break;
            }
            default:
                break;
        }
        
    }
}

- (void)presentViewController:(id)aVC
                        param:(NSDictionary *)param{
    UIViewController *realVC = [self getRealViewController:aVC];
    if (realVC){
        //绑定参数
        [self bindingViewController:realVC withParam:param];
        
        NSString *className = [UIViewController js_getNavigationControllerClassName].length > 0 ?
        [UIViewController js_getNavigationControllerClassName]:
        @"UINavigationController";
        Class class = NSClassFromString(className);
        UINavigationController *navCtrl = [class alloc];
        
        if ([UIViewController js_getNavigationBarClassName].length > 0 &&
            [UIViewController js_getToolbarClassName].length > 0){
            navCtrl = [navCtrl initWithNavigationBarClass:NSClassFromString([UIViewController js_getNavigationBarClassName])
                                             toolbarClass:NSClassFromString([UIViewController js_getToolbarClassName])];
            navCtrl.viewControllers = @[realVC];
        }else{
            navCtrl = [navCtrl initWithRootViewController:realVC];
        }

        [self presentViewController:navCtrl
                           animated:self.js_animated
                         completion:^{
                             if (self.navigationController.js_nav_didShowViewControllerBlock){
                                 self.navigationController.js_nav_didShowViewControllerBlock();
                                 self.navigationController.js_nav_didShowViewControllerBlock = nil;
                             }
                         }];
    }
}

- (UIViewController*)getRealViewController:(id)aVC{
    if (!aVC)return nil;
    
    UIViewController *realVC = nil;
    
    if ([aVC isKindOfClass:[UIViewController class]]){
        realVC = (UIViewController*)aVC;
        
    }else if ([UIViewController js_getStoryboardNames].length > 0 &&
              [aVC isKindOfClass:[NSString class]]){
        //有Storyboard则先检测
        NSArray *sbNames = [[UIViewController js_getStoryboardNames] componentsSeparatedByString:@","];
        for (NSString *sbName in sbNames){
            UIStoryboard *sb = [UIStoryboard storyboardWithName:sbName bundle:nil];
            UIViewController *vc = nil;
            @try {
                vc = [sb instantiateViewControllerWithIdentifier:aVC];
            }
            @catch (NSException *exception) {
                NSLog(@"Storyboard [%@] not found id:[%@]",sbName,aVC);
            }
            @finally {
                if (vc){
                    realVC = vc;
                    break;
                }
            }
        }
    }
    
    if (!realVC &&
        [aVC isKindOfClass:[NSString class]]){
        Class vcClass = NSClassFromString(aVC);
        id vc = [[vcClass alloc]init];
        if ([vc isKindOfClass:[UIViewController class]]){
            realVC = vc;
        }
    }
    
    return realVC;
}

- (void)bindingViewController:(UIViewController*)aVC withParam:(NSDictionary *)param{
    
    [param enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        switch ([UIViewController js_getParamType]) {
            case JSegueParamTypeOnlyDictionary: {
                [aVC.js_parameter setObject:obj forKey:key];
                break;
            }
            case JSegueParamTypeOnlyProperty: {
                //存在属性则赋值
                if ([self checkIsExistPropertyWithInstance:aVC verifyPropertyName:key]){
                    [aVC setValue:obj forKey:key];
                }else{
                    NSLog(@"property [%@] not found in [%@]",key,aVC);
                }
                break;
            }
            case JSegueParamTypeAll: {
                //存在属性则赋值
                if ([self checkIsExistPropertyWithInstance:aVC verifyPropertyName:key]){
                    [aVC setValue:obj forKey:key];
                    
                }else{
                    //添加到参数字典
                    [aVC.js_parameter setObject:obj forKey:key];
                }
                break;
            }
            default: {
                break;
            }
        }
    }];
}

- (BOOL)checkIsExistPropertyWithInstance:(id)instance verifyPropertyName:(NSString *)verifyPropertyName{
    unsigned int outCount, i;
    
    //获取对象里的属性列表
    objc_property_t * properties = class_copyPropertyList([instance class], &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //属性名转成字符串
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        //判断该属性是否存在
        if ([propertyName isEqualToString:verifyPropertyName]) {
            free(properties);
            return YES;
        }
    }
    free(properties);
    
    return NO;
}

#pragma mark - public methods

//normal
- (void)js_push:(id)aVC{
    [self js_push:aVC param:nil];
}
- (void)js_push:(id)aVC param:(NSDictionary*)param{
    [self pushViewController:aVC param:param pushType:PushTypeNormal removePrior:0];
}

//push or pop
- (void)js_pushOrPopTo:(id)aVC{
    [self js_pushOrPopTo:aVC param:nil];
}
- (void)js_pushOrPopTo:(id)aVC param:(NSDictionary*)param{
    [self pushViewController:aVC param:param pushType:PushTypePushOrPop removePrior:0];
}

//remove prior
- (void)js_push:(id)aVC removePrior:(NSInteger)count{
    [self js_push:aVC removePrior:count param:nil];
}
- (void)js_push:(id)aVC removePrior:(NSInteger)count param:(NSDictionary*)param{
    [self pushViewController:aVC param:param pushType:PushTypeRemovePrior removePrior:count];
}

- (void)js_pop{
    [self.navigationController popViewControllerAnimated:self.js_animated];
}

- (void)js_present:(id)aVC{
    [self js_present:aVC param:nil];
}
- (void)js_present:(id)aVC param:(NSDictionary*)param{
    [self presentViewController:aVC param:param];
}

- (void)js_dismiss{
    [self dismissViewControllerAnimated:self.js_animated completion:nil];
}

#pragma mark - public class methods
+ (void)js_setStoryboardNames:(NSString*)sbNames {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:sbNames forKey:@"js_sotryboard_names"];
    [defaults synchronize];
}

+ (void)js_setCustomNavigationControllerClassName:(NSString*)name{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:name forKey:@"js_navigation_controller_name"];
    [defaults synchronize];
}

+ (void)js_setNavigationBarClassName:(NSString *)barClassName
                    toolbarClassName:(NSString *)toolbarClassName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:barClassName forKey:@"js_navigation_bar_name"];
    [defaults setValue:toolbarClassName forKey:@"js_toolbar_name"];
    [defaults synchronize];
}

+ (void)js_setParamType:(JSegueParamType)type{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(type) forKey:@"js_param_type"];
    [defaults synchronize];
}

#pragma mark - private class methods

+ (NSString*)js_getStoryboardNames{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"js_sotryboard_names"];
}

+ (NSString*)js_getNavigationControllerClassName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"js_navigation_controller_name"];
}

+ (NSString*)js_getNavigationBarClassName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"js_navigation_bar_name"];
}

+ (NSString*)js_getToolbarClassName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"js_toolbar_name"];
}

+ (JSegueParamType)js_getParamType{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *type = [defaults valueForKey:@"js_param_type"];
    if (!type){
        type = @(JSegueParamTypeOnlyDictionary);
        [self js_setParamType:JSegueParamTypeOnlyDictionary];
    }
    return (JSegueParamType)type.integerValue;
}

@end

#pragma mark - UINavigationController(JSegue) implementation

@implementation UINavigationController(JSegue)

#pragma mark - properties
//will show block
- (void)setJs_nav_willShowViewControllerBlock:(void (^)())js_nav_willShowViewControllerBlock{
    objc_setAssociatedObject(self, @selector(js_nav_willShowViewControllerBlock), js_nav_willShowViewControllerBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)())js_nav_willShowViewControllerBlock{
    return objc_getAssociatedObject(self, _cmd);
}

//did show block
- (void)setJs_nav_didShowViewControllerBlock:(void (^)())js_nav_didShowViewControllerBlock{
    objc_setAssociatedObject(self, @selector(js_nav_didShowViewControllerBlock), js_nav_didShowViewControllerBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)())js_nav_didShowViewControllerBlock{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)js_nav_remove_js_nav_willShowViewControllerBlock{
    [self setJs_nav_willShowViewControllerBlock:nil];
}
- (void)js_nav_remove_js_nav_didShowViewControllerBlock{
    [self setJs_nav_didShowViewControllerBlock:nil];
}

@end
