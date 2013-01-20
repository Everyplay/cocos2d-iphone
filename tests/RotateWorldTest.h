#import "cocos2d.h"
#import <Everyplay/Everyplay.h>

@class CCLabel;

//CLASS INTERFACE
@interface AppController : NSObject <EveryplayDelegate, UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
    UIWindow *window;
}
@property (nonatomic, retain) UIWindow *window;
@end

@interface SpriteLayer: CCLayer
{
}
@end

@interface TextLayer: CCLayer
{
}
@end

@interface MainLayer : CCLayer
{
}
@end
