//
//  BBChatVC.m
//  BroBox
//
//  Created by Tanguy Hélesbeux on 01/03/2015.
//  Copyright (c) 2015 Brobox. All rights reserved.
//

#import "BBChatVC.h"

// Model
#import "BBParseMessage.h"

// SLKTextViewController
#import "MessageTableViewCell.h"

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *AutoCompletionCellIdentifier = @"AutoCompletionCell";

@interface BBChatVC ()

@property (nonatomic, strong) NSArray *searchResult;

@end

@implementation BBChatVC


- (id)init {
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder {
    return UITableViewStylePlain;
}

- (void)registerToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotificationMissionMessagesFetched)
                                                 name:BBNotificationFetchedMissionMessages object:self.mission];
}

- (void)handleNotificationMissionMessagesFetched {
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Messages", @"");
    
    if (!self.mission.messages) {
        self.mission.messages = [[NSMutableArray alloc] init];
        [BBParseManager fetchMessagesForMission:self.mission withBlock:^(NSArray *objects, NSError *error) {
            [self.tableView reloadData];
        }];
    }
    
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:MessengerCellIdentifier];
    
    [self.rightButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    self.rightButton.tintColor = [UIColor colorWithRed:0.89f green:0.40f blue:0.00f alpha:1.00f];
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editortLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.textInputbar.editortRightButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.maxCharCount = 256;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    
    self.typingIndicatorView.canResignByTouch = YES;
    
    [self registerToNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


#pragma mark - Action Methods

//- (void)editCellMessage:(UIGestureRecognizer *)gesture
//{
//    MessageTableViewCell *cell = (MessageTableViewCell *)gesture.view;
//    Message *message = self.messages[cell.indexPath.row];
//    
//    [self editText:message.text];
//    
//    [self.tableView scrollToRowAtIndexPath:cell.indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//}

//- (void)editLastMessage:(id)sender
//{
//    if (self.textView.text.length > 0) {
//        return;
//    }
//    
//    NSInteger lastSectionIndex = [self.tableView numberOfSections]-1;
//    NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex]-1;
//    
//    Message *lastMessage = [self.messages objectAtIndex:lastRowIndex];
//    
//    [self editText:lastMessage.text];
//    
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//}


#pragma mark - Overriden Methods

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
    
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    
    BBParseMessage *message = [BBParseMessage object];
    message.author = [BBParseUser currentUser];
    message.content = [self.textView.text copy];
    [BBParseManager addMessage:message toMission:self.mission withBLock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Message saved");
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
    UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
    
    [self.tableView beginUpdates];
    [self.mission.messages insertObject:message atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
    
    // Fixes the cell from blinking (because of the transform, when using translucent cells)
    // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [super didPressRightButton:sender];
}

- (void)didPressArrowKey:(id)sender
{
    [super didPressArrowKey:sender];
}

- (NSString *)keyForTextCaching
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

- (void)didPasteMediaContent:(NSDictionary *)userInfo
{
    // Notifies the view controller when the user has pasted a media (image, video, etc) inside of the text view.
    
    SLKPastableMediaType mediaType = [userInfo[SLKTextViewPastedItemMediaType] integerValue];
    NSString *contentType = userInfo[SLKTextViewPastedItemContentType];
    NSData *contentData = userInfo[SLKTextViewPastedItemData];
    
    NSLog(@"%s : %@",__FUNCTION__, contentType);
    
    if ((mediaType & SLKPastableMediaTypePNG) || (mediaType & SLKPastableMediaTypeJPEG)) {
        
        BBParseMessage *message = [BBParseMessage object];
        message.author = [BBParseUser currentUser];
        message.content = @"Attachment";
        message.attachment = [UIImage imageWithData:contentData scale:[UIScreen mainScreen].scale];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
        UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
        
        [self.tableView beginUpdates];
        [self.mission.messages insertObject:message atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
        [self.tableView endUpdates];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
    }
}

- (void)willRequestUndo
{
    // Notifies the view controller when a user did shake the device to undo the typed text
    
    [super willRequestUndo];
}

- (void)didCommitTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the right "Accept" button for commiting the edited text
    
//    Message *message = [Message new];
//    message.username = [LoremIpsum name];
//    message.text = [self.textView.text copy];
//    
//    [self.messages removeObjectAtIndex:0];
//    [self.messages insertObject:message atIndex:0];
//    [self.tableView reloadData];
    
    [super didCommitTextEditing:sender];
}

- (void)didCancelTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the left "Cancel" button
    
    [super didCancelTextEditing:sender];
}

- (BOOL)canPressRightButton
{
    return [super canPressRightButton];
}

- (BOOL)canShowAutoCompletion
{
//    NSArray *array = nil;
//    NSString *prefix = self.foundPrefix;
//    NSString *word = self.foundWord;
//    
//    self.searchResult = nil;
//    
//    if ([prefix isEqualToString:@"@"] && word.length > 0) {
//        array = [self.users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@ AND self !=[c] %@", word, word]];
//    }
//    else if ([prefix isEqualToString:@"#"] && word.length > 0) {
//        array = [self.channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
//    }
//    else if ([prefix isEqualToString:@":"] && word.length > 0) {
//        array = [self.emojis filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
//    }
//    
//    if (array.count > 0) {
//        array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//    }
//    
//    self.searchResult = [[NSMutableArray alloc] initWithArray:array];
//    
//    return self.searchResult.count > 0;
    
    return NO;
}

- (CGFloat)heightForAutoCompletionView
{
    CGFloat cellHeight = [self.autoCompletionView.delegate tableView:self.autoCompletionView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cellHeight*self.searchResult.count;
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        return self.mission.messages.count;
    }
    else {
        return self.searchResult.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return [self messageCellForRowAtIndexPath:indexPath];
    }
    else {
        return [self autoCompletionCellForRowAtIndexPath:indexPath];
    }
}

- (MessageTableViewCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
    
//    if (!cell.textLabel.text) {
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editCellMessage:)];
//        [cell addGestureRecognizer:longPress];
//    }
    
    BBParseMessage *message = self.mission.messages[indexPath.row];
    
    cell.titleLabel.text = message.author.firstName;
    cell.bodyLabel.text = message.content;
    cell.tumbnailView.profileID = message.author.facebookID;
    
    if (message.attachment) {
        cell.attachmentView.image = message.attachment;
        cell.attachmentView.layer.shouldRasterize = YES;
        cell.attachmentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    
    cell.indexPath = indexPath;
    cell.usedForMessage = YES;
    
    // Cells must inherit the table view's transform
    // This is very important, since the main table view may be inverted
    cell.transform = self.tableView.transform;
    
    return cell;
}

- (MessageTableViewCell *)autoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:AutoCompletionCellIdentifier];
    cell.indexPath = indexPath;
    
    NSString *item = self.searchResult[indexPath.row];
    
    if ([self.foundPrefix isEqualToString:@"#"]) {
        item = [NSString stringWithFormat:@"# %@", item];
    }
    else if ([self.foundPrefix isEqualToString:@":"]) {
        item = [NSString stringWithFormat:@":%@:", item];
    }
    
    cell.titleLabel.text = item;
    cell.titleLabel.font = [UIFont systemFontOfSize:14.0];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        BBParseMessage *message = self.mission.messages[indexPath.row];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                     NSParagraphStyleAttributeName: paragraphStyle};
        
        CGFloat width = CGRectGetWidth(tableView.frame)-kAvatarSize;
        width -= 25.0;
        
        CGRect titleBounds = [message.author.firstName boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        CGRect bodyBounds = [message.content boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        
        if (message.content.length == 0) {
            return 0.0;
        }
        
        CGFloat height = CGRectGetHeight(titleBounds);
        height += CGRectGetHeight(bodyBounds);
        height += 40.0;
        if (message.attachment) {
            height += 80.0 + 10.0;
        }
        
        if (height < kMinimumHeight) {
            height = kMinimumHeight;
        }
        
        return height;
    }
    else {
        return kMinimumHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.autoCompletionView]) {
        UIView *topView = [UIView new];
        topView.backgroundColor = self.autoCompletionView.separatorColor;
        return topView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.autoCompletionView]) {
        return 0.5;
    }
    return 0.0;
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.autoCompletionView]) {
        
        NSMutableString *item = [self.searchResult[indexPath.row] mutableCopy];
        
        if ([self.foundPrefix isEqualToString:@"@"] || [self.foundPrefix isEqualToString:@":"]) {
            [item appendString:@":"];
        }
        
        [item appendString:@" "];
        
//        [self acceptAutoCompletionWithString:item keepPrefix:YES];
    }
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Since SLKTextViewController uses UIScrollViewDelegate to update a few things, it is important that if you ovveride this method, to call super.
    [super scrollViewDidScroll:scrollView];
}


#pragma mark - UIScrollViewDelegate Methods

/** UITextViewDelegate */
- (BOOL)textView:(SLKTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (void)textViewDidChangeSelection:(SLKTextView *)textView
{
    [super textViewDidChangeSelection:textView];
}

@end
