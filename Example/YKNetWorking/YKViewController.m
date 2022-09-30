//
//  YKViewController.m
//  YKNetWorking
//
//  Created by edwardyyk on 09/30/2022.
//  Copyright (c) 2022 edwardyyk. All rights reserved.
//

#import "YKViewController.h"
#import <YKNetWorking/YKNetWorking.h>


@interface YKNetworkingTestModel : NSObject
///
@property (nonatomic, copy, readwrite) NSString *name;
///
@property (nonatomic, copy, readwrite) void(^todo)(void);
@end

@implementation YKNetworkingTestModel

- (instancetype)initWithName:(NSString *)name todoCallBack:(void(^)(void))todoCallback
{
    self = [super init];
    if (self) {
        self.name = name;
        self.todo = todoCallback;
    }
    return self;
}

+ (YKNetworkingTestModel *)createModel:(NSString *)name todoCallBack:(void(^)(void))todoCallback
{
    return [[YKNetworkingTestModel alloc] initWithName:name todoCallBack:todoCallback];
}

@end

@interface YKViewController ()<UITableViewDelegate,UITableViewDataSource>
///
@property (nonatomic, strong, readwrite) UITableView *tableView;
///
@property (nonatomic, strong, readwrite) NSMutableArray<YKNetworkingTestModel *> *dataSource;
@end

@implementation YKViewController

- (void)demo_execute
{
    YKNetWorking *networking = [[YKNetWorking alloc] init];
    
    networking = networking.get(@"https://static-page.yauui.cn/protocol/xm/protocol.html");
    
    networking = networking.params(@{});
    
    networking = networking.headers(@{});
    
    networking = networking.responseType(YKNetworkResponseTypeHTTP);
    
    networking = networking.downloadDestPath(@"/desc/");
    
    [networking executeDownloadRequest:^(YKNetworkResponse * _Nonnull response, YKNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        NSLog(@"%@",response.rawData);
    }];
}


- (void)reloadDataSource
{
    [self.dataSource removeAllObjects];
    
    __weak typeof(self) weakSelf = self;
    [self.dataSource addObject:[YKNetworkingTestModel createModel:@"请求" todoCallBack:^{
//        NSLog(@"点击");
        [weakSelf demo_execute];
    }]];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    [self reloadDataSource];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    YKNetworkingTestModel *model = self.dataSource[indexPath.row];
    tableViewCell.textLabel.text = model.name;
    
    return tableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YKNetworkingTestModel *model = self.dataSource[indexPath.row];
    model.todo();
}



- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
        self.tableView.frame = CGRectMake(0, safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height - safeAreaInsets.top - safeAreaInsets.bottom);
    } else {
        // Fallback on earlier versions
        CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height;
        self.tableView.frame = CGRectMake(0, height, self.view.bounds.size.width, self.view.bounds.size.height - height);
    }
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    }
    return _tableView;
}

- (NSMutableArray<YKNetworkingTestModel *> *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
