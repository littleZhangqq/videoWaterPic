//
//  MovieViewController.h
//  MovieWaterPic
//
//  Created by admin on 2019/8/28.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum: NSUInteger{
    AddMovieWaterPicTypeGif,
    AddMovieWaterPicTypeEmptyPic,
    AddMovieWaterPicTypeManyPic
}AddMovieWaterPicType;

@interface MovieViewController : UIViewController

@property(nonatomic, unsafe_unretained) AddMovieWaterPicType picType;

@end

NS_ASSUME_NONNULL_END
