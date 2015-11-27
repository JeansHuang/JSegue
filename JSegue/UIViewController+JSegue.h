//
//  UIViewController+JSegue.h
//  JSegueDemo
//
//  Created by Jeans Huang on 11/20/15.
//  Copyright © 2015 gzhu. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 *  @brief  传参方式
 */
typedef NS_ENUM(NSInteger,JSegueParamType) {
    /*!
     *  【默认】只使用js_parameter传参
     */
    JSegueParamTypeOnlyDictionary   = 1 << 0,
    /*!
     *  只使用Property设置参数
     */
    JSegueParamTypeOnlyProperty     = 1 << 1,
    /*!
     *  使用js_parameter、Property设置参数。优先设置Property，若不存在则设置js_parameter
     */
    JSegueParamTypeAll              = JSegueParamTypeOnlyDictionary | JSegueParamTypeOnlyProperty
};

@interface UIViewController (JSegue)

#pragma mark - properties

//! 参数字典
@property (nonatomic, strong) NSMutableDictionary *js_parameter;

//! 页面跳转是否有动画
@property (nonatomic, assign) BOOL js_animated;

//! 将要显示vc的block，不支持模态显示
@property (nonatomic, copy) void(^js_willShowViewControllerBlock)();

//! 已经显示vc的block
@property (nonatomic, copy) void(^js_didShowViewControllerBlock)();

#pragma mark -
#pragma mark - methods

#pragma mark - 普通push
/*!
 *  @brief  push页面
 *
 *  @param aVC VC的字符串名称，VC的实例，VC在Storyboard中的id
 */
- (void)js_push:(id)aVC;

/*!
 *  @brief  push页面
 *
 *  @param aVC   VC的字符串名称，VC的实例，VC在Storyboard中的id
 *  @param param 传递的参数，使用self.js_parameter获取。可以[self js_setParamType:JSegueParamType]修改支持实例的property变量设置
 */
- (void)js_push:(id)aVC param:(NSDictionary*)param;

#pragma mark - push或pop到指定页面

/*!
 *  @brief  push页面，若页面存在则pop到该页面
 *
 *  @param aVC VC的字符串名称，VC的实例，VC在Storyboard中的id
 */
- (void)js_pushOrPopTo:(id)aVC;

/*!
 *  @brief  push页面，若页面存在则pop到该页面
 *
 *  @param aVC   VC的字符串名称，VC的实例，VC在Storyboard中的id
 *  @param param 传递的参数，使用self.js_parameter获取。可以[self js_setParamType:JSegueParamType]修改支持实例的property变量设置
 */
- (void)js_pushOrPopTo:(id)aVC param:(NSDictionary*)param;


#pragma mark - push页面，并且移除前面的页面

/*!
 *  @brief  push页面，并且移除前面的页面
 *
 *  @param aVC   VC的字符串名称，VC的实例，VC在Storyboard中的id
 *  @param count -1表示清空前面所有vc，并且设置当前页面为rootVC；0表示不清除前面页面；>0表示清除前面count个vc；若count > 所有vc数量，则效果同-1
 */
- (void)js_push:(id)aVC removePrior:(NSInteger)count;

/*!
 *  @brief  push页面，并且移除前面的页面
 *
 *  @param aVC   VC的字符串名称，VC的实例，VC在Storyboard中的id
 *  @param count -1表示清空前面所有vc，并且设置当前页面为rootVC；0表示不清除前面页面；>0表示清除前面count个vc；若count > 所有vc数量，则效果同-1
 *  @param param 传递的参数，使用self.js_parameter获取。可以[self js_setParamType:JSegueParamType]修改支持实例的property变量设置
 */
- (void)js_push:(id)aVC removePrior:(NSInteger)count param:(NSDictionary*)param;

/*!
 *  @brief  pop页面
 */
- (void)js_pop;

#pragma mark - 模态显示

/*!
 *  @brief  模态显示页面,并且新建一个UINavigationController，显示的页面作为rootViewController
 *
 *  @param aVC VC的字符串名称，VC的实例，VC在Storyboard中的id
 */
- (void)js_present:(id)aVC;

/*!
 *  @brief  模态显示页面,并且新建一个UINavigationController，显示的页面作为rootViewController
 *
 *  @param aVC   aVC VC的字符串名称，VC的实例，VC在Storyboard中的id
 *  @param param 传递的参数，使用self.js_parameter获取。可以[self js_setParamType:JSegueParamType]修改支持实例的property变量设置
 */
- (void)js_present:(id)aVC param:(NSDictionary*)param;

/*!
 *  @brief  模态消失页面
 */
- (void)js_dismiss;

#pragma mark - class methods for preferences

/*!
 *  @brief  设置跳转页面是需要查找的Storyboard
 *
 *  @param sbNames Storyboard名称，使用逗号间隔，如 @"Main,Other"
 */
+ (void)js_setStoryboardNames:(NSString *)sbNames;

/*!
 *  @brief  设置自定义的UINavigationController类名，因为在模态显示中需要创建一个UINavigationController
 *
 *  @param name 自定义的UINavigationController
 */
+ (void)js_setCustomNavigationControllerClassName:(NSString *)name;

/*!
 *  @brief  设置自定义的navigationBarClass，toolbarClass，因为在模态显示中需要创建一个UINavigationController
 *
 *  @param barClassName     自定义的navigationBarClass
 *  @param toolbarClassName 自定义的toolbarClass
 */
+ (void)js_setNavigationBarClassName:(NSString *)barClassName toolbarClassName:(NSString *)toolbarClassName;

/*!
 *  @brief  设置页面传参时的模式
 *
 *  @param type 设置传参模式
 */
+ (void)js_setParamType:(JSegueParamType)type;

@end

#pragma mark - UINavigationController (JSegue)

@interface UINavigationController (JSegue)

- (void(^)())js_nav_willShowViewControllerBlock;
- (void(^)())js_nav_didShowViewControllerBlock;
- (void)js_nav_remove_js_nav_willShowViewControllerBlock;
- (void)js_nav_remove_js_nav_didShowViewControllerBlock;

@end
