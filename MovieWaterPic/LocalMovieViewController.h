//
//  LocalMovieViewController.h
//  MovieWaterPic
//
//  Created by admin on 2019/8/29.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum: NSUInteger{
    LocalMovieWaterPicTypeGif,
    LocalMovieWaterPicTypeEmptyPic,
    LocalMovieWaterPicTypeManyPic
}LocalMovieWaterPicType;

////本地选取视频添加水印
@interface LocalMovieViewController : UIViewController

@property(nonatomic, unsafe_unretained) LocalMovieWaterPicType picType;

@end

NS_ASSUME_NONNULL_END
