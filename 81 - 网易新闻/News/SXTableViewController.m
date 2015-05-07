//
//  SXTableViewController.m
//  81 - 网易新闻
//
//  Created by 董 尚先 on 15-1-22.
//  Copyright (c) 2015年 ShangxianDante. All rights reserved.
//

#import "SXTableViewController.h"
#import "SXDetailController.h"
#import "SXPhotoSetController.h"
#import "SXNewsCell.h"
#import "SXNetworkTools.h"
#import "MJRefresh.h"

@interface SXTableViewController ()

@property(nonatomic,strong) NSArray *arrayList;

@end

#define EALog(s,...) NSLog(@"<%@: 行 %d> %@ %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithUTF8String:__PRETTY_FUNCTION__], [NSString stringWithFormat:(s), ##__VA_ARGS__]);



@implementation SXTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    [self loadData];
    [self.tableView addHeaderWithTarget:self action:@selector(loadData)];
    
//    self.tableView.headerHidden = NO;
}

- (void)setArrayList:(NSArray *)arrayList
{
    _arrayList = arrayList;
    
    [self.tableView reloadData];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    [self loadData];
//    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    EALog(@"bbbb");
    [self.tableView headerBeginRefreshing];
    [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:@"contentStart" object:nil]];
}

#pragma mark - /************************* 刷新数据 ***************************/
- (void)loadData
{
    // http://c.m.163.com//nc/article/headline/T1348647853363/0-30.html
    EALog(@"%@",self.urlString);
    [[[SXNetworkTools sharedNetworkTools]GET:self.urlString parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary* responseObject) {
        
        NSString *key = [responseObject.keyEnumerator nextObject];
        
        NSArray *temArray = responseObject[key];
        
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:temArray.count];
        [temArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            SXNewsModel *news = [SXNewsModel newsModelWithDict:obj];
            [arrayM addObject:news];
        }];
        self.arrayList = arrayM;
        [self.tableView headerEndRefreshing];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        EALog(@"%@",error);
    }] resume];

}

#pragma mark - /************************* tbv数据源方法 ***************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SXNewsModel *newsModel = self.arrayList[indexPath.row];
    
    NSString *ID = [SXNewsCell idForRow:newsModel];
    
    SXNewsCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    cell.NewsModel = newsModel;
    
    return cell;
    
}

#pragma mark - /************************* tbv代理方法 ***************************/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SXNewsModel *newsModel = self.arrayList[indexPath.row];
    
    return [SXNewsCell heightForRow:newsModel];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 刚选中又马上取消选中，格子不变色
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = [[UIViewController alloc]init];
    vc.view.backgroundColor = [UIColor yellowColor];
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SXDetailController class]]) {
        
        NSInteger x = self.tableView.indexPathForSelectedRow.row;
        SXDetailController *dc = segue.destinationViewController;
        dc.newsModel = self.arrayList[x];
        dc.index = self.index;
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else{
        NSInteger x = self.tableView.indexPathForSelectedRow.row;
        SXPhotoSetController *pc = segue.destinationViewController;
        pc.newsModel = self.arrayList[x];
        
        
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
}

@end