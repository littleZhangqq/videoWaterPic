//
//  LocalMovieViewController.m
//  MovieWaterPic
//
//  Created by admin on 2019/8/29.
//  Copyright © 2019 admin. All rights reserved.
//

#import "LocalMovieViewController.h"
#import <UIImageView+WebCache.h>
#import "HXPhotoPicker.h"
#import "GPUImage.h"
#import "SVProgressHUD.h"

#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenWidth [UIScreen mainScreen].bounds.size.width

@interface LocalMovieViewController ()

@property(nonatomic, strong) HXPhotoManager *manager;
@property (nonatomic, strong) GPUImageMovie *imageMovie;
@property (nonatomic, strong) GPUImageMovieWriter *writer;
@property(nonatomic, strong) GPUImageUIElement *uiElement;
@property(nonatomic, strong) GPUImageBrightnessFilter *brightFilter;
@property(nonatomic, strong) GPUImageNormalBlendFilter *blendFliter;

@end

@implementation LocalMovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hx_presentSelectPhotoControllerWithManager:self.manager didDone:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList, NSArray<HXPhotoModel *> *videoList, BOOL isOriginal, UIViewController *viewController, HXPhotoManager *manager) {
            if (videoList.count > 0) {
                HXPhotoModel *model = videoList.firstObject;
                [self mixFilterAndCreateWriterWith:model.fileURL];
            }
        } cancel:^(UIViewController *viewController, HXPhotoManager *manager) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    });
}

- (HXPhotoManager *)manager{
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypeVideo];
        _manager.configuration.videoCanEdit = NO;
        _manager.configuration.videoMinimumSelectDuration = 10.0;
        _manager.configuration.videoMaximumSelectDuration = 60.0;
        _manager.configuration.singleSelected = YES;
    }
    return _manager;
}

-(void)mixFilterAndCreateWriterWith:(NSURL *)videoUrl{
    __weak typeof(self) weakSelf = self;
    
    _imageMovie = [[GPUImageMovie alloc] initWithURL:videoUrl];
    _imageMovie.playAtActualSpeed = NO;
    _imageMovie.shouldRepeat = NO;
    
    //设置加滤镜视频保存路径
    NSString *fileName = [NSString stringWithFormat:@"video_%ld",time(NULL)];
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Movie_%@.mp4",fileName]];
    unlink([pathToMovie UTF8String]);
    NSURL * movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    UIImageView *imv1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 200)];
    imv1.image = [UIImage imageNamed:@"youhuijiayou_banner"];
    UIImageView *imv2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenHeight-200, screenWidth, 200)];
    imv2.image = [UIImage imageNamed:@"banner"];
    UIImageView *imv3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    imv3.image = [UIImage imageNamed:@"001"];
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [subView addSubview:imv1];
    [subView addSubview:imv2];
    [subView addSubview:imv3];
    
    __block NSInteger index = 0;
    NSArray *gifImages = [NSArray array];
    if (self.picType == LocalMovieWaterPicTypeGif) {
        imv3.hidden = YES;
        imv2.hidden = YES;
        gifImages = [NSArray arrayWithArray:[self imagesWithGif:@"002fig"]];
    }else if (self.picType == LocalMovieWaterPicTypeManyPic){
        imv3.hidden = YES;
    }else{
        imv2.hidden = YES;
        imv1.hidden = YES;
    }
    
    _uiElement = [[GPUImageUIElement alloc] initWithView:subView];
    _blendFliter = [[GPUImageNormalBlendFilter alloc] init];
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    
    _writer = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720, 1280)];
    [progressFilter addTarget:_blendFliter];
    [_imageMovie addTarget:progressFilter];
    [_uiElement addTarget:_blendFliter];
    
    _writer.shouldPassthroughAudio = YES;
    _imageMovie.audioEncodingTarget = _writer;

    [_imageMovie enableSynchronizedEncodingUsingMovieWriter:_writer];
    [_blendFliter addTarget:_writer];
    
    [_writer startRecording];
    [_imageMovie startProcessing];
    //渲染
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        if (self.picType == LocalMovieWaterPicTypeGif) {
            index ++;
            dispatch_async(dispatch_get_main_queue(), ^{
                imv1.image = gifImages[index];
            });
            if (index == gifImages.count -1) {
                index = 0;
            }
            [weakSelf.uiElement updateWithTimestamp:time];
        }else{
            [weakSelf.uiElement update];
        }
    }];
    
    [_writer setCompletionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.blendFliter removeTarget:strongSelf.writer];
            [strongSelf.writer finishRecording];
            NSLog(@"合成完成");
            UISaveVideoAtPathToSavedPhotosAlbum(movieURL.path, weakSelf, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    NSLog(@"保存完成");
    NSLog(@"%@",videoPath);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 部分通用方法
-(NSArray *)imagesWithGif:(NSString *)gifNameInBoundle {
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:gifNameInBoundle withExtension:@"gif"];
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
    size_t gifCount = CGImageSourceGetCount(gifSource);
    NSMutableArray *frames = [[NSMutableArray alloc]init];
    for (size_t i = 0; i< gifCount; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [frames addObject:image];
        CGImageRelease(imageRef);
    }
    return frames;
}

- (NSTimeInterval)durationForGifData:(NSData *)data{
    //将GIF图片转换成对应的图片源
    CGImageSourceRef gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    //获取其中图片源个数，即由多少帧图片组成
    size_t frameCout = CGImageSourceGetCount(gifSource);
    //定义数组存储拆分出来的图片
    NSMutableArray* frames = [[NSMutableArray alloc] init];
    NSTimeInterval totalDuration = 0;
    for (size_t i=0; i<frameCout; i++) {
        //从GIF图片中取出源图片
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        //将图片源转换成UIimageView能使用的图片源
        UIImage* imageName = [UIImage imageWithCGImage:imageRef];
        //将图片加入数组中
        [frames addObject:imageName];
        NSTimeInterval duration = [self gifImageDeleyTime:gifSource index:i];
        totalDuration += duration;
        CGImageRelease(imageRef);
    }
    
    //获取循环次数
    NSInteger loopCount;//循环次数
    CFDictionaryRef properties = CGImageSourceCopyProperties(gifSource, NULL);
    if (properties) {
        CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gif) {
            CFTypeRef loop = CFDictionaryGetValue(gif, kCGImagePropertyGIFLoopCount);
            if (loop) {
                //如果loop == NULL，表示不循环播放，当loopCount  == 0时，表示无限循环；
                CFNumberGetValue(loop, kCFNumberNSIntegerType, &loopCount);
            };
        }
    }
    
    CFRelease(gifSource);
    return totalDuration;
}

//获取GIF图片每帧的时长
- (NSTimeInterval)gifImageDeleyTime:(CGImageSourceRef)imageSource index:(NSInteger)index {
    NSTimeInterval duration = 0;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL);
    if (imageProperties) {
        CFDictionaryRef gifProperties;
        BOOL result = CFDictionaryGetValueIfPresent(imageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties);
        if (result) {
            const void *durationValue;
            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &durationValue)) {
                duration = [(__bridge NSNumber *)durationValue doubleValue];
                if (duration < 0) {
                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &durationValue)) {
                        duration = [(__bridge NSNumber *)durationValue doubleValue];
                    }
                }
            }
        }
    }
    
    return duration;
}

@end
