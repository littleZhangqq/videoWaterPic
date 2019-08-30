//
//  MovieViewController.m
//  MovieWaterPic
//
//  Created by admin on 2019/8/28.
//  Copyright © 2019 admin. All rights reserved.
//

#import "MovieViewController.h"
#import "GPUImage.h"
#import "Masonry.h"
#import "CameraButton.h"

#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenWidth [UIScreen mainScreen].bounds.size.width

@interface MovieViewController ()

@property(nonatomic, strong) GPUImageUIElement *uiElement;
@property(nonatomic, strong) GPUImageBrightnessFilter *brightFilter;
@property(nonatomic, strong) GPUImageAlphaBlendFilter *blendFliter;
@property(nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property(nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property(nonatomic, strong) GPUImageView *filterView;
@property(nonatomic, strong) NSURL * currentMovieURL;
@property(nonatomic, unsafe_unretained) BOOL currentVideoType;
@property (nonatomic, retain) CameraButton * cameraPlayButton;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCamera];
    [self initViews];
}

-(void)initCamera{
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    
    _filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    _filterView.fillMode = kGPUImageFillModePreserveAspectRatio;
    [self.view addSubview:_filterView];
    
    _filter = [[GPUImageSepiaFilter alloc] init];
    [(GPUImageSepiaFilter *)_filter setIntensity:0];
    
    _brightFilter = [[GPUImageBrightnessFilter alloc] init];
    _brightFilter.brightness = 0.0f;
    
    _blendFliter = [[GPUImageAlphaBlendFilter alloc] init];
    _blendFliter.mix = 1.0;
    
    UIImageView *imv1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 200)];
    UIImageView *imv2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenHeight-200, screenWidth, 200)];
    UIView *cotentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    cotentView.backgroundColor = [UIColor clearColor];
    [cotentView addSubview:imv1];
    [cotentView addSubview:imv2];
    
    __block NSInteger index = 0;
    NSArray *gifImages = [NSArray array];
    if (self.picType == AddMovieWaterPicTypeGif) {
        imv2.hidden = YES;
        gifImages = [NSArray arrayWithArray:[self imagesWithGif:@"002fig"]];
        imv1.image = gifImages[index];
    }else if(self.picType == AddMovieWaterPicTypeEmptyPic){
        imv1.image = [UIImage imageNamed:@"001"];
        imv1.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        imv2.hidden = YES;
    }else{
        imv1.image = [UIImage imageNamed:@"banner"];
        imv2.image = [UIImage imageNamed:@"youhuijiayou_banner"];
        imv2.hidden = NO;
    }
    
    _uiElement = [[GPUImageUIElement alloc] initWithView:cotentView];
    [_videoCamera addTarget:_filter];
    [_filter addTarget:_brightFilter];
    [_brightFilter addTarget:_blendFliter];
    [_uiElement addTarget:_blendFliter];
    [_blendFliter addTarget:_filterView];
    [_videoCamera startCameraCapture];
    [_blendFliter useNextFrameForImageCapture];
    [_brightFilter useNextFrameForImageCapture];
    
    __weak typeof(self) weakSelf = self;
    [_brightFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime Time) {
        if (self.picType == AddMovieWaterPicTypeGif) {
            dispatch_async(dispatch_get_main_queue(), ^{
                index ++;
                imv1.image = gifImages[index];
                if (index == gifImages.count -1) {
                    index = 0;
                }
                [weakSelf.uiElement updateWithTimestamp:Time];
            });
        }else{
                [weakSelf.uiElement update];
        }
    }];
}

- (void)initViews{
    [self.view addSubview:self.cameraPlayButton];
}

- (CameraButton *)cameraPlayButton
{
    if (_cameraPlayButton == nil) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _cameraPlayButton = [[CameraButton alloc] initWithFrame:CGRectMake((screenSize.width - 80)/2, screenSize.height - 80 - 80, 80, 80)];
        [_cameraPlayButton setType:CameraButtonTypeVideo];
        __weak typeof(self) weakSelf = self;
        [_cameraPlayButton setClickedBlock:^(CameraButton *button) {
            [weakSelf takePhotoClick:button];
        }];
    }
    return _cameraPlayButton;
}

-(void)takePhotoClick:(CameraButton *)sender{
    if (_currentVideoType == NO) {
        NSLog(@"开始拍摄");
        _currentVideoType = YES;
        NSString *fileName = [NSString stringWithFormat:@"video_%ld",time(NULL)];
        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Movie_%@.mp4",fileName]];
        unlink([pathToMovie UTF8String]);
        NSURL * movieURL = [NSURL fileURLWithPath:pathToMovie];
        _currentMovieURL = movieURL;
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720, 1280)];
        _movieWriter.encodingLiveVideo = YES;
        _movieWriter.shouldPassthroughAudio = YES;//是否使用源音源
        _videoCamera.audioEncodingTarget = _movieWriter;//加入声音
        [_blendFliter addTarget:_movieWriter];
        double delayToStartRecording = 0.1;
        __weak typeof(self) weakSelf = self;
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
        dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.movieWriter startRecording];
        });
    }else {
        _currentVideoType = NO;
        [self stopVideoCamera:_currentMovieURL];
    }
}

- (void)stopVideoCamera:(NSURL *)movieURL {
    [_filter removeTarget:_movieWriter];
    _videoCamera.audioEncodingTarget = nil;
    [_movieWriter finishRecording];
    UISaveVideoAtPathToSavedPhotosAlbum(movieURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

- (BOOL)checkCameraPermission{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        NSLog(@"请打开相机权限");
        return NO;
    }
    return YES;
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    NSLog(@"保存完成");
    NSLog(@"%@",videoPath);
}

#pragma mark 部分通用方法
//取出gif图的每帧图片放入数组
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

//GIF图的完整运行时间
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
