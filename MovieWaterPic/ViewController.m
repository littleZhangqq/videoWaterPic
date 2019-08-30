//
//  ViewController.m
//  MovieWaterPic
//
//  Created by admin on 2019/8/28.
//  Copyright © 2019 admin. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "MovieViewController.h"
#import "LocalMovieViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) NSArray *arr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.arr = @[@"gif水印(拍摄)",@"镂空图片水印(拍摄)",@"多个图片水印(拍摄)",@"gif水印(本地选取)",@"镂空图片水印(本地选取)",@"多个图片水印(本地选取)",@"GPUimage的各种滤镜效果"];
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:table];
    
    [table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.arr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < 3) {
        MovieViewController *movie = [MovieViewController new];
        movie.picType = indexPath.row;
        [self presentViewController:movie animated:YES completion:nil];
    }else if(indexPath.row < 6){
        LocalMovieViewController *local = [LocalMovieViewController new];
        local.picType = indexPath.row -3;
        [self presentViewController:local animated:YES completion:nil];
    }else{
        [self presentViewController:[NSClassFromString(@"FilterEffectViewController") new] animated:YES completion:nil];
    }
}


@end
