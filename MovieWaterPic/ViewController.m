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

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSArray *arr = @[@"gif水印",@"镂空图片水印",@"多个图片水印"];
    cell.textLabel.text = arr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MovieViewController *movie = [MovieViewController new];
    movie.picType = indexPath.row;
    [self presentViewController:movie animated:YES completion:nil];
}


@end
