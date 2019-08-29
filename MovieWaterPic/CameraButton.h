//
//  CameraButton.h
//  MovieWaterPic
//
//  Created by admin on 2019/8/29.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CameraButtonTypeCamera,
    CameraButtonTypeVideo,
}CameraButtonType;

typedef enum {
    CameraButtonStateNormal,
    CameraButtonStateSelected
}CameraButtonState;

@class CameraButton;

typedef  void(^ClickedBlock)(CameraButton *button);

@interface CameraButton : UIView

@property (nonatomic,assign) CameraButtonType type;
@property (nonatomic,assign) CameraButtonState state;
@property (nonatomic,strong) void (^clickedBlock)(CameraButton *button);

@end

