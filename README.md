# JSegue
极其简单易用的ViewController push 传参 封装类别；  
UIViewController push pop modal simple category.

###方便的页面跳转，只需一行代码###
支持Storyboard，xib，无view

```objective-c
/*!
 *  @brief  push页面
 *
 *  @param aVC VC的字符串名称，VC的实例，VC在storyboard中的id
 */
- (void)js_push:(id)aVC;
```

**`example:`**  

```objective-c
//a ViewController name
[self js_push:@"ViewController"];

//a ViewController ID in Stroyboard
[UIViewController js_setStoryboardNames:@"Main"];
[self js_push:@"VC_ID"];

//a instance of UIViewController
UIViewController *vc = [UIViewController new];
[self js_push:vc];
```

`other methods:`  

```objective-c
/*!
 *  @brief  push页面，若页面存在则pop到该页面
 *
 *  @param aVC VC的字符串名称，VC的实例，VC在Storyboard中的id
 */
- (void)js_pushOrPopTo:(id)aVC;

/*!
 *  @brief  push页面，并且移除前面的页面
 *
 *  @param aVC   VC的字符串名称，VC的实例，VC在Storyboard中的id
 *  @param count -1表示清空前面所有vc，并且设置当前页面为rootVC；0表示不清除前面页面；>0表示清除前面count个vc；若count > 所有vc数量，则效果同-1
 */
- (void)js_push:(id)aVC removePrior:(NSInteger)count;
```
`...`

###方便的页面传参###
可以直接设置目标页面的property，或者传递字典。  
在目标页面只需self.js_parameter[@"key"]即可获得传值。  

```objective-c
/*!
 *  @brief  push页面
 *
 *  @param aVC   VC的字符串名称，VC的实例，VC在Storyboard中的id
 *  @param param 传递的参数，使用self.js_parameter获取。可以[self js_setParamType:JSegueParamType]修改支持实例的property变量设置
 */
- (void)js_push:(id)aVC param:(NSDictionary*)param;
```

**`example:`**  

```objective-c
@interface XibViewController : UIViewController

@property (nonatomic, strong) NSString *publicProperty;

@end

//push and send param
NSDictionary *paramDict = @{@"publicProperty":@"hello public property",
                                @"privateProperty":@"hello private property",
                                @"customDictParam":@"hello custom dict param"};

[self js_push:@"XibViewController" param: paramDict];


//receive
@implementation XibViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"NoXibViewController received:%@",self.js_parameter);
    
    NSLog(@"publicProperty:%@",self.publicProperty);
    
    NSLog(@"privateProperty:%@",self.privateProperty);
    
    self.label.text = self.js_parameter[@"customDictParam"];
}


```

`other methods:`  
`...in demo`

###使用CocoaPods添加###
`pod 'JSegue'`
