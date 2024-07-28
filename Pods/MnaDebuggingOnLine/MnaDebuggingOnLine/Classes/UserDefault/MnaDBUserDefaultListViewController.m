//
//  MnaDBUserDefaultListViewController.m
//  MnaDebuggingOnLine
//
//  Created by asherluo on 2021/12/19.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDBUserDefaultListViewController.h"
#import <objc/runtime.h>
#import "MnaDBTextViewController.h"

@interface MnaDBUserDefaultListViewController ()<UITextFieldDelegate>

@property(nonatomic, strong) UITextField *searchTF;
// 存放所有的userDefault数据
@property(nonatomic, strong) NSMutableDictionary *userDefaultDataSource;

// 存放所有的keys
@property(nonatomic, strong) NSMutableArray *userDefaultAllKeys;
@property(nonatomic, strong) NSMutableArray *searchKeys;
@property(nonatomic, assign) BOOL isSearch;
@end

// UserDefault页面
@implementation MnaDBUserDefaultListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"UserDefaults";
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadData];
    
    UIView *headView = [[UIView alloc] init];
    headView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 50);
    self.searchTF = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(headView.frame) - 20, CGRectGetHeight(headView.frame))];
    self.searchTF.placeholder = @"模糊查找";
    self.searchTF.delegate = self;
    self.searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchTF.returnKeyType = UIReturnKeySearch;
    self.searchTF.layer.cornerRadius = 6;
    self.searchTF.layer.masksToBounds = YES;
    self.searchTF.layer.borderColor = [UIColor blackColor].CGColor;
    self.searchTF.layer.borderWidth = 1;
    [headView addSubview:self.searchTF];
    self.tableView.tableHeaderView = headView;
    self.searchKeys = [NSMutableArray array];
}

- (void)loadData {
    self.userDefaultDataSource = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation].mutableCopy;
    self.userDefaultAllKeys = self.userDefaultDataSource.allKeys.mutableCopy;
    
    [self.userDefaultAllKeys sortUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
        return [[obj1 lowercaseString] compare:[obj2 lowercaseString]];
    }];
}

- (void)searchWithKeyword:(NSString *)keyword {
    
    NSString *checkKeyWord = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([checkKeyWord length] <= 0) { return; }
    
    checkKeyWord = [checkKeyWord lowercaseString];
    
    self.searchTF.text = checkKeyWord;
    
    [self.searchKeys removeAllObjects];
    
    for (NSString *key in self.userDefaultAllKeys) {
        if ([[key lowercaseString] containsString:checkKeyWord]) {
            [self.searchKeys addObject:key];
        }
    }
    self.isSearch = YES;
    [self.tableView reloadData];
}

- (void)cancelSearch {
    self.isSearch = NO;
    self.searchTF.text = nil;
    if ([self.searchTF isFirstResponder]) {
        [self.searchTF resignFirstResponder];
    }
    
    [self.searchKeys removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![textField hasText]) {
        [self cancelSearch];
        return YES;
    }
    
    [textField resignFirstResponder];
    
    [self searchWithKeyword:textField.text];
    
    return YES;
}

- (NSMutableArray *)dataArray {
    return self.isSearch ? self.searchKeys : self.userDefaultAllKeys;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MnaDBUserDefaultListViewController"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MnaDBUserDefaultListViewController"];
    }
    NSString *key = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = key;
    id value = [self.userDefaultDataSource objectForKey:key];
    if (value) {
        NSString *valueClass= NSStringFromClass(object_getClass(value));
        NSString *valueDesc = [[value description] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"【%@】%@", valueClass, valueDesc];
    } else {
        cell.detailTextLabel.text = nil;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *key = [self.dataArray objectAtIndex:indexPath.row];
        [self.userDefaultDataSource removeObjectForKey:key];
        [self.dataArray removeObject:key];
        [self.userDefaultAllKeys  removeObject:key];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *key = [self.dataArray objectAtIndex:indexPath.row];
    NSObject *value = [self.userDefaultDataSource objectForKey:key];
    MnaDBTextViewController *controller = [[MnaDBTextViewController alloc] init];
    controller.title = NSStringFromClass(object_getClass(value));
    controller.content = [NSString stringWithFormat:@"%@\n%@",key,value.description];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
