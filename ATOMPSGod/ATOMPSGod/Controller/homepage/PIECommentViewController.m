//
//  CommentViewController.m
//  Messenger
//
//  Created by Ignacio Romero Zurbuchen on 8/15/14.
//  Copyright (c) 2014 Slack Technologies, Inc. All rights reserved.
//

#import "PIECommentViewController.h"
#import "PIECommentTableCell.h"
#import "PIECommentTextView.h"
#import "PIECommentVM.h"

#import "PIEFriendViewController.h"
#import "PIECommentModel.h"
#import "PIECommentManager.h"
#import "PIEEntityCommentReply.h"
#import "PIECommentHeaderView.h"
#import "PIEShareView.h"
#import "PIEActionSheet_PS.h"
#import "DDCollectManager.h"
#import "PIEModelImage.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "KVCMutableArray.h"
#import "PIEReplyCollectionViewController.h"
#import "PIEPageManager.h"


#define DEBUG_CUSTOM_TYPING_INDICATOR 0

static NSString *MessengerCellIdentifier = @"MessengerCell";

@interface PIECommentViewController ()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,PIEShareViewDelegate,JTSImageViewControllerInteractionsDelegate>

@property (nonatomic, strong) NSMutableArray *source_hotComment;
@property (nonatomic, strong) KVCMutableArray *source_newComment;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UITapGestureRecognizer *tapCommentTableGesture;
@property (nonatomic, assign) BOOL canRefreshFooter;
@property (nonatomic, strong) PIECommentVM *targetCommentVM;
@property (nonatomic, strong) NSIndexPath *selectedIndexpath;
@property (nonatomic, strong) PIEShareView *shareView;
@property (nonatomic, strong)  PIEActionSheet_PS * psActionSheet;
@property (nonatomic, assign)  BOOL isFirstLoading;


/**
    全局状态量：标记用户是否有发出评论；用于退出navigationcontroller的stack之后
            判断上一个控制器是否有需要重新刷新评论列表（目前用于PIEChannelTutorialDetailsViewController)
 
    初始状态：NO
    sendComment -> YES
    
    用于-dismiss方法中是否要通知代理
 
 */
@property (nonatomic, assign) BOOL hasSentComment;

@end

@implementation PIECommentViewController

- (id)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder
{
    return UITableViewStylePlain;
}

- (void)commonInit
{
    _shouldShowHeaderView = YES;
    
    // Register a SLKTextView subclass, if you need any special appearance and/or behavior customisation.
    [self registerClassForTextView:[PIECommentTextView class]];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    _isFirstLoading = YES;
    [self setupNavBar];
    
    [self setupData];
    
    [self configTableView];
    [self configFooterRefresh];
    [self configTextInput];
    [self addGestureToCommentTableView];
    [self getDataSource];

}


- (void)setupData
{
    _hasSentComment = NO;
}

- (void)setupNavBar {
    
    UIButton *buttonLeft = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
    buttonLeft.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [buttonLeft setImage:[UIImage imageNamed:@"PIE_icon_back"] forState:UIControlStateNormal];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonLeft];
    self.navigationItem.leftBarButtonItem =  buttonItem;

    if (self.navigationController.viewControllers.count <= 1) {
        [buttonLeft addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [buttonLeft addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    }
}


- (void) dismiss {
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)popSelf {
    
    if (_delegate != nil &&
        _hasSentComment == YES &&
        [_delegate respondsToSelector:@selector(ATOMViewControllerPopedFromNavAfterSendingCommment)]) {
        
        [_delegate ATOMViewControllerPopedFromNavAfterSendingCommment];
    }
   
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getVMSource {
    NSMutableDictionary* param = [NSMutableDictionary new];
    [param setObject:@(_vm.ID) forKey:@"id"];
    [param setObject:@(_vm.type) forKey:@"type"];
    [param setObject:@(SCREEN_WIDTH_RESOLUTION) forKey:@"width"];

    [PIEPageManager getPageSource:param block:^(PIEPageVM *remoteVM) {
//        [self removeKVO];
        _vm = remoteVM;
//        [self addKVO];
        if (_vm.type == PIEPageTypeAsk) {
            self.headerView.vm = _vm;
        } else {
            self.headerView_reply.vm = _vm;
        }
        [self resizeHeaderView];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    [MobClick beginLogPageView:@"进入浏览图片页"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset < - 90) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void)dealloc {
//    [self removeKVO];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isFirstLoading&&!_shouldShowHeaderView) {
        [self.textView becomeFirstResponder];
        //        [self scrollElegant];
        _isFirstLoading = NO;
    }
    

}
- (void)scrollElegant {
    
    [UIView animateWithDuration:0.7 animations:^{
        self.tableView.contentOffset = CGPointMake(0, self.tableView.tableHeaderView.frame.size.height - 52);
    } completion:^(BOOL finished) {
    }];
    
}
-(BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - Overriden Methods

//don't ignore babe --peiwei.
- (BOOL)ignoreTextInputbarAdjustment
{
    [super ignoreTextInputbarAdjustment];
    return NO;
}

- (void)didChangeKeyboardStatus:(SLKKeyboardStatus)status
{
    // Notifies the view controller that the keyboard changed status.
}

- (void)textWillUpdate
{
    // Notifies the view controller that the text will update.
    
    [super textWillUpdate];
}

- (void)textDidUpdate:(BOOL)animated
{
    // Notifies the view controller that the text did update.
    
    [super textDidUpdate:animated];
}

- (void)didPressLeftButton:(id)sender
{
    // Notifies the view controller when the left button's action has been triggered, manually.
    
    [super didPressLeftButton:sender];
}

- (void)didPressRightButton:(id)sender
{
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    [self sendComment];
    [super didPressRightButton:sender];
}

-(void)sendComment {
    
    [self.textView resignFirstResponder];
    self.textView.placeholder = @"添加评论";
    
    
    
    PIECommentVM *commentVM = [PIECommentVM new];
    
    commentVM.model = [PIECommentModel new];
    
    
    
    commentVM.username = [DDUserManager currentUser].nickname;
    commentVM.uid = [DDUserManager currentUser].uid;
    commentVM.avatar = [DDUserManager currentUser].avatar;
    commentVM.originText = self.textView.text;
    commentVM.time = @"刚刚";
    
    commentVM.model.uid = [DDUserManager currentUser].uid;
    commentVM.model.avatar = [DDUserManager currentUser].avatar;
    
//    NSString* commentToShow;
    //回复评论
    if (_targetCommentVM) {
        [commentVM.replyArray addObjectsFromArray:_targetCommentVM.replyArray];
//        //所要回复的评论只有一个回复人，也就是我要回复的评论已经有两个人。
//        if (commentVM.replyArray.count <= 1) {
//            commentToShow = [NSString stringWithFormat:@"%@//@%@:%@",self.textView.text,_targetCommentVM.username,_targetCommentVM.text];
//        }
//        //所要回复的评论多于一个回复人，也就是我要回复的评论已经多于两个人。
//        else {
//            PIEEntityCommentReply* reply1 = commentVM.replyArray[0];
//            commentToShow = [NSString stringWithFormat:@"%@//@%@:%@",self.textView.text,_targetCommentVM.username,_targetCommentVM.originText];
//            commentToShow = [NSString stringWithFormat:@"%@//@%@:%@",commentToShow,reply1.username,reply1.text];
//        }
        commentVM.text = self.textView.text;
        
        PIEEntityCommentReply* reply = [PIEEntityCommentReply new];
        reply.uid = _targetCommentVM.uid;
        reply.username = _targetCommentVM.username;
        reply.text = _targetCommentVM.originText;
        reply.ID = _targetCommentVM.ID;
        [commentVM.replyArray insertObject:reply atIndex:0];
    }
    //第一次评论
    else {
        commentVM.text  = self.textView.text;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.source_newComment insertObject:commentVM inArrayAtIndex:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    // Fixes the cell from blinking (because of the transform, when using translucent cells)
    // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
    //    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:self.textView.text forKey:@"content"];
    [param setObject:@(_vm.type) forKey:@"type"];
    [param setObject:@(_vm.ID) forKey:@"target_id"];
    if (_targetCommentVM) {
        [param setObject:@(_targetCommentVM.ID) forKey:@"for_comment"];
    }
    PIECommentManager *showDetailOfComment = [PIECommentManager new];
    [showDetailOfComment SendComment:param withBlock:^(NSInteger comment_id, NSError *error) {
        if (comment_id) {
            commentVM.ID = comment_id;
            self.vm.model.totalCommentNumber++;
            
            _hasSentComment = YES;
        }
    }];
    self.textView.text = @"";
    _targetCommentVM = nil;
    
}

- (NSString *)keyForTextCaching
{
    return [[NSBundle mainBundle] bundleIdentifier];
}


- (void)willRequestUndo
{
    // Notifies the view controller when a user did shake the device to undo the typed text
    [super willRequestUndo];
}

- (void)didCommitTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the right "Accept" button for commiting the edited text
    
    [super didCommitTextEditing:sender];
}

- (void)didCancelTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the left "Cancel" button
    
    [super didCancelTextEditing:sender];
}
-(void)didPasteMediaContent:(NSDictionary *)userInfo {
}
- (BOOL)canPressRightButton
{
    return [super canPressRightButton];
}

- (BOOL)canShowTypingIndicator
{
#if DEBUG_CUSTOM_TYPING_INDICATOR
    return YES;
#else
    return [super canShowTypingIndicator];
#endif
}

-(void)didPressReturnKey:(id)sender {
    [self sendComment];
    [super didPressReturnKey:sender];
}



#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    if (section == 0) {
    //        return _commentsHot.count;
    //    } else if (section == 1) {
    return _source_newComment.array.count;
    //    } else {
    //        return 0;
    //    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView == tableView) {
        static NSString *CellIdentifier = @"CommentCell";
        PIECommentTableCell *cell = (PIECommentTableCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
        if (!cell) {
            cell = [[PIECommentTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        //        if (indexPath.section == 0) {
        //            [cell getSource:_commentsHot[indexPath.row]];
        //        } else if (indexPath.section == 1) {
        [cell getSource:_source_newComment.array[indexPath.row]];
        //        }
        // Cells must inherit the table view's transform
        // This is very important, since the main table view may be inverted
        //        cell.transform = self.tableView.transform;
        return cell;
    }
    return nil;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        PIECommentVM* vm;
        //        if (indexPath.section == 0) {
        //            vm = _commentsHot[indexPath.row];
        //        } else if (indexPath.section == 1) {
        vm = _source_newComment.array[indexPath.row];
        //        }
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                     NSParagraphStyleAttributeName: paragraphStyle};
        
        CGFloat width = CGRectGetWidth(tableView.frame)-kMessageTableViewCellAvatarHeight - kPadding15*3;
        
        CGRect titleBounds = [vm.username boundingRectWithSize:CGSizeMake(width-100, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        CGRect bodyBounds = [vm.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        
        CGFloat height = CGRectGetHeight(titleBounds);
        height += CGRectGetHeight(bodyBounds);
        height += 30.0;
        
        if (height < kMessageTableViewCellMinimumHeight) {
            height = kMessageTableViewCellMinimumHeight;
        }
        
        return height;
    }
    return 0;
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UIScrollViewDelegate Methods



#pragma mark init and config

-(void)configTableView {
    _source_hotComment = [NSMutableArray new];
    _source_newComment = [KVCMutableArray new];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag|UIScrollViewKeyboardDismissModeInteractive;
    [self.tableView registerClass:[PIECommentTableCell class] forCellReuseIdentifier:MessengerCellIdentifier];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithHex:0x000000 andAlpha:0.1];
    
    

    if (_shouldShowHeaderView) {
        self.title = @"浏览图片";
        if (_vm.type == PIEPageTypeAsk) {
            self.tableView.tableHeaderView = self.headerView;
        } else {
            self.tableView.tableHeaderView = self.headerView_reply;
        }
        [self resizeHeaderView];
//        [self addKVO];

    } else {
        self.title = @"全部评论";
    }

}

- (void)resizeHeaderView {
    UIView *header = self.tableView.tableHeaderView;
    [header setNeedsLayout];
    [header layoutIfNeeded];
    CGFloat height = [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = header.frame;
    frame = CGRectMake(0, 0, SCREEN_WIDTH, height);

    header.frame = frame;
    self.tableView.tableHeaderView = header;
}



-(void)configTextInput {
    self.bounces = NO;
    self.shakeToClearEnabled = NO;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = NO;
    [self.rightButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.maxCharCount = 128;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    self.textInputbar.counterPosition = SLKCounterPositionTop;
    self.shouldClearTextAtRightButtonPress = YES;
}
- (void)configFooterRefresh {
    
    NSMutableArray *animatedImages = [NSMutableArray array];
    for (int i = 1; i<=6; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"pie_loading_%d", i]];
        [animatedImages addObject:image];
    }
    
    MJRefreshAutoGifFooter *footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    footer.refreshingTitleHidden = YES;
    footer.stateLabel.hidden = YES;
    
    [footer setImages:animatedImages duration:0.5 forState:MJRefreshStateRefreshing];
    
    self.tableView.mj_footer = footer;
    
    _canRefreshFooter = NO;
}


#pragma mark - tap Event

- (void)tapCommentTable:(UITapGestureRecognizer *)gesture {
    
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    if (indexPath) {
        //        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        PIECommentTableCell *cell = (PIECommentTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        //        DDCommentVM *model = (section == 0) ? _commentsHot[row] : _source_newComment.array[row];
        PIECommentVM *model =  _source_newComment.array[row];
        
        CGPoint p = [gesture locationInView:cell];
        if (CGRectContainsPoint(cell.avatarView.frame, p)) {
            PIEFriendViewController *opvc = [PIEFriendViewController new];
            PIEPageVM* vm = [[PIEPageVM alloc]initWithCommentModel:model.model];;
            opvc.pageVM = vm;
            [self.navigationController pushViewController:opvc animated:YES];
        }
        else if (CGRectContainsPoint(cell.usernameLabel.frame, p)) {
            PIEFriendViewController *opvc = [PIEFriendViewController new];
            PIEPageVM* vm = [[PIEPageVM alloc]initWithCommentModel:model.model];;
            vm.userID = model.uid;
            vm.username = model.username;
            opvc.pageVM = vm;
            [self.navigationController pushViewController:opvc animated:YES];
        } else if (CGRectContainsPoint(cell.receiveNameLabel.frame, p)) {
            PIEFriendViewController *opvc = [PIEFriendViewController new];
            opvc.uid = cell.receiveNameLabel.tag;
            [self.navigationController pushViewController:opvc animated:YES];
        } else {
            NSInteger row = indexPath.row;
            _targetCommentVM = _source_newComment.array[row];
            self.textView.placeholder = [NSString stringWithFormat:@"@%@:",_targetCommentVM.username];
            [self.textView becomeFirstResponder];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }

    }
}


#pragma mark Refresh

- (void)loadMoreData {
    if (_canRefreshFooter) {
        [self getMoreDataSource];
    } else {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

#pragma mark - GetDataSource

- (void)getDataSource {
    WS(ws);
    
    _currentPage = 1;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@(_vm.ID) forKey:@"target_id"];
    [param setObject:@(_vm.type) forKey:@"type"];
    [param setObject:@(_currentPage) forKey:@"page"];
    [param setObject:@(10) forKey:@"size"];
    
    PIECommentManager *commentManager = [PIECommentManager new];
    [commentManager ShowDetailOfComment:param withBlock:^(NSMutableArray *hotCommentArray, NSMutableArray *recentCommentArray, NSError *error) {
        ws.source_newComment.array = recentCommentArray;
        ws.source_hotComment = hotCommentArray;
        
        if (recentCommentArray.count > 0) {
            _canRefreshFooter = YES;
        }
        [self.tableView reloadData];
    }];
}

- (void)getMoreDataSource {
    WS(ws);
    _currentPage++;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@(_vm.ID) forKey:@"target_id"];
    [param setObject:@(_vm.type) forKey:@"type"];
    [param setObject:@(_currentPage) forKey:@"page"];
    [param setObject:@(10) forKey:@"size"];
    PIECommentManager *commentManager = [PIECommentManager new];
    [commentManager ShowDetailOfComment:param withBlock:^(NSMutableArray *hotCommentArray, NSMutableArray *recentCommentArray, NSError *error) {
        [self.source_newComment willChangeValueForKey:@"array"];
        [ws.source_newComment addArrayObject: recentCommentArray];
        [self.source_newComment didChangeValueForKey:@"array"];
        [ws.source_hotComment addObjectsFromArray: hotCommentArray];
        
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        if (recentCommentArray.count == 0) {
            ws.canRefreshFooter = NO;
        } else {
            ws.canRefreshFooter = YES;
        }
    }];
}


#pragma mark - DZNEmptyDataSetSource
-(UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"pie_empty"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"快来抢第一个坐上沙发";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
-(BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return !_shouldShowHeaderView;
}
-(BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}
-(CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -100;
}
#pragma mark - headerView

-(PIECommentTableHeaderView_Ask *)headerView {
    if (!_headerView) {
        _headerView = [PIECommentTableHeaderView_Ask new];
        _headerView.vm = _vm;
        UITapGestureRecognizer* tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap1)];
        UITapGestureRecognizer* tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap2)];
        
        UITapGestureRecognizer* tap5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap5)];
        UITapGestureRecognizer* tap6 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapHelp)];
        [_headerView.avatarView addGestureRecognizer:tap1];
        [_headerView.usernameLabel addGestureRecognizer:tap2];
        [_headerView.shareButton addGestureRecognizer:tap5];
        [_headerView.bangView addGestureRecognizer:tap6];
    }
    return _headerView;
}

#pragma mark - headerView

-(PIECommentTableHeaderView_Reply *)headerView_reply {
    if (!_headerView_reply) {
        _headerView_reply = [PIECommentTableHeaderView_Reply new];
        _headerView_reply.vm = _vm;
        UITapGestureRecognizer* tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap1)];
        UITapGestureRecognizer* tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap2)];
        UITapGestureRecognizer* tap5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap5)];
        UITapGestureRecognizer* tap6 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAllWorkButton)];
        UITapGestureRecognizer* tap7 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapLike)];
        UILongPressGestureRecognizer* longpress7 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(didLongpressLike)];
        [_headerView_reply.avatarView addGestureRecognizer:tap1];
        [_headerView_reply.usernameLabel addGestureRecognizer:tap2];
        [_headerView_reply.shareButton addGestureRecognizer:tap5];
        [_headerView_reply.likeButton addGestureRecognizer:longpress7];
        [_headerView_reply.likeButton addGestureRecognizer:tap7];
        [_headerView_reply.moreWorkButton addGestureRecognizer:tap6];
    }
    return _headerView_reply;
}

- (void) didTapAllWorkButton {
    PIEReplyCollectionViewController* vc = [PIEReplyCollectionViewController new];
    vc.pageVM = _vm;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void) didTap1 {
    PIEFriendViewController *opvc = [PIEFriendViewController new];
    opvc.pageVM = _vm;
    [self.navigationController pushViewController:opvc animated:YES];
}
- (void) didTap2 {
    PIEFriendViewController *opvc = [PIEFriendViewController new];
    opvc.pageVM = _vm;
    [self.navigationController pushViewController:opvc animated:YES];
}

- (void) didTap5 {
    [self.textView resignFirstResponder];

    [self showShareView:_vm];
}
- (void) didTapHelp {
    [self.psActionSheet showInView:[AppDelegate APP].window animated:YES];
}
- (void) didTapLike {
    [_vm love:NO];
}
- (void) didLongpressLike {
    [_vm love:YES];
}

#pragma mark - <PIEShareViewDelegate>

- (void)shareViewDidShare:(PIEShareView *)shareView
{
}

- (void)shareViewDidCancel:(PIEShareView *)shareView
{
    [shareView dismiss];
}


#pragma mark - Gesture methods
- (void)addGestureToCommentTableView {
    _tapCommentTableGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCommentTable:)];
    _tapCommentTableGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:_tapCommentTableGesture];
}
- (void)showShareView:(PIEPageVM *)pageVM {
    [self.shareView show:pageVM];
}
-(void)collect {
    NSMutableDictionary *param = [NSMutableDictionary new];
    _vm.collected = !_vm.collected;
    if (_vm.collected) {
        //收藏
        [param setObject:@(1) forKey:@"status"];
    } else {
        //取消收藏
        [param setObject:@(0) forKey:@"status"];
    }
    [DDCollectManager toggleCollect:param withPageType:_vm.type withID:_vm.ID  withBlock:^(NSError *error) {
        if (!error) {
            if (  _vm.collected ) {
                [Hud textWithLightBackground:@"收藏成功"];
            } else {
                [Hud textWithLightBackground:@"取消收藏成功"];
            }
        }   else {
            _vm.collected = !_vm.collected;
        }
    }];
}
- (PIEActionSheet_PS *)psActionSheet {
    if (!_psActionSheet) {
        _psActionSheet = [PIEActionSheet_PS new];
        _psActionSheet.vm = _vm;
    }
    return _psActionSheet;
}

-(PIEShareView *)shareView {
    if (!_shareView) {
        _shareView = [PIEShareView new];
        _shareView.delegate = self;
    }
    return _shareView;
}


@end
