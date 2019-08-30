//
//  FilterEffectViewController.h
//  MovieWaterPic
//
//  Created by admin on 2019/8/30.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum:NSUInteger{
    GaussiBlurt,//高斯模糊
    RGBDilation,//rgb边缘模糊
    Sketch,//素描
    Cartoon,//卡通
    Masaic,//马赛克
    DarkCorner,//暗角
    ColorPacking,//色彩丢失，类似于监控画面
    Swirl,//旋涡
    Distortion,//哈哈镜
    Refraction,//球形折射，图形倒立
    CirclePixel,//像素画
    Emboss,//浮雕效果
    Normal //正常
}FilterEffectType;

NS_ASSUME_NONNULL_BEGIN

//GPUimage的各种滤镜效果
@interface FilterEffectViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
