//
//  ARAutocompleteTextView.m
//  alexruperez
//
//  Created by Alejandro Rupérez on 11/29/12.
//  Inspired by DOautocompleteTextView by DoAT.
//
//  Copyright (c) 2013 alexruperez. All rights reserved.
//

#import "ARAutocompleteTextView.h"

static NSObject<ARAutocompleteDataSource> *DefaultAutocompleteDataSource = nil;

@interface ARAutocompleteTextView ()

@property (nonatomic, strong) NSString *autocompleteString;

@end

@implementation ARAutocompleteTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupAutocompleteTextView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupAutocompleteTextView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

- (void)setupAutocompleteTextView
{
    super.delegate = self;
    
    self.autocompleteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.autocompleteLabel.font = self.font;
    self.autocompleteLabel.backgroundColor = [UIColor clearColor];
    self.autocompleteLabel.textColor = [UIColor lightGrayColor];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    NSLineBreakMode lineBreakMode = NSLineBreakByClipping;
#else
    UILineBreakMode lineBreakMode = UILineBreakModeClip;
#endif
    
    self.autocompleteLabel.lineBreakMode = lineBreakMode;
    self.autocompleteLabel.hidden = YES;
    [self addSubview:self.autocompleteLabel];
    [self bringSubviewToFront:self.autocompleteLabel];

    self.autocompleteString = @"";
    
    self.ignoreCase = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ar_textDidChange:) name:UITextViewTextDidChangeNotification object:self];
}

#pragma mark - Configuration

+ (void)setDefaultAutocompleteDataSource:(id)dataSource
{
    DefaultAutocompleteDataSource = dataSource;
}

- (void)setFont:(UIFont *)font
{
    super.font = font;
    (self.autocompleteLabel).font = font;
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate
{
    self.innerTextViewDelegate = delegate;
}

#pragma mark - UIResponder

- (BOOL)becomeFirstResponder
{
    if (!self.autocompleteDisabled)
    {
        self.autocompleteLabel.hidden = NO;
    }

    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    if (!self.autocompleteDisabled)
    {
        self.autocompleteLabel.hidden = YES;

        if ([self commitAutocompleteText]) {
            // Only notify if committing autocomplete actually changed the text.
        

            // This is necessary because committing the autocomplete text changes the text field's text, but for some reason UITextView doesn't post the UITextViewTextDidChangeNotification notification on its own
            [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
        }
    }
    return [super resignFirstResponder];
}

#pragma mark - Autocomplete Logic

- (CGRect)autocompleteRectForBounds:(CGRect)bounds
{
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start];
    
    CGRect returnRect = CGRectMake(caretRect.origin.x + 1.0f, caretRect.origin.y, self.frame.size.width, caretRect.size.height);
    
    return returnRect;
}

- (void)ar_textDidChange:(NSNotification*)notification
{
    [self refreshAutocompleteText];
}

- (void)updateAutocompleteLabel
{
    (self.autocompleteLabel).text = self.autocompleteString;
    [self.autocompleteLabel sizeToFit];
    (self.autocompleteLabel).frame = [self autocompleteRectForBounds:self.bounds];
	
	if ([self.autoCompleteTextViewDelegate respondsToSelector:@selector(autoCompleteTextView:didChangeAutocompleteText:)]) {
		[self.autoCompleteTextViewDelegate autoCompleteTextView:self didChangeAutocompleteText:self.autocompleteString];
	}
}

- (void)refreshAutocompleteText
{
    if (!self.autocompleteDisabled)
    {
        id <ARAutocompleteDataSource> dataSource = nil;
        
        if ([self.autocompleteDataSource respondsToSelector:@selector(textView:completionForPrefix:ignoreCase:)])
        {
            dataSource = (id <ARAutocompleteDataSource>)self.autocompleteDataSource;
        }
        else if ([DefaultAutocompleteDataSource respondsToSelector:@selector(textView:completionForPrefix:ignoreCase:)])
        {
            dataSource = DefaultAutocompleteDataSource;
        }
        
        if (dataSource)
        {
            NSString *lastChar =@"";
            if ([self.text substringFromIndex: (self.text).length - 1]) { // Gets last character of the text view's text
           
                 // Gets the text view's text and fills an array with all strings seperated by a space in text view's text, basically all the words
                lastChar = [self.text substringFromIndex:(self.text).length - 1];
                
            }
            self.autocompleteString = [dataSource textView:self completionForPrefix:lastChar ignoreCase:self.ignoreCase];

            if (self.autocompleteString.length > 0)
            {
                if ([self.text hasSuffix:@" "]) {
                self.text = [self.text substringToIndex:(self.text).length - 1];
                    [self autocompleteText:self];
                }
            }
            
            [self updateAutocompleteLabel];
        }
    }
}

- (BOOL)commitAutocompleteText
{
    NSString *currentText = self.text;
    if (self.autocompleteString && [self.autocompleteString isEqualToString:@""] == NO
        && self.autocompleteDisabled == NO)
    {
        self.text = [NSString stringWithFormat:@"%@%@", self.text, self.autocompleteString];
        
        self.autocompleteString = @"";
        [self updateAutocompleteLabel];
		
		if ([self.autoCompleteTextViewDelegate respondsToSelector:@selector(autoCompleteTextViewDidAutoComplete:)]) {
			[self.autoCompleteTextViewDelegate autoCompleteTextViewDidAutoComplete:self];
		}
    }
    return ![currentText isEqualToString:self.text];
}

- (void)forceRefreshAutocompleteText
{
    [self refreshAutocompleteText];
}

#pragma mark - UITextView Delegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@". "]) return NO;
    if (self.innerTextViewDelegate && [self.innerTextViewDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return [self.innerTextViewDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    if (self.innerTextViewDelegate && [self.innerTextViewDelegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)]) {
        return [self.innerTextViewDelegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if (self.innerTextViewDelegate && [self.innerTextViewDelegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)]) {
        return [self.innerTextViewDelegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.innerTextViewDelegate && [self.innerTextViewDelegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        [self.innerTextViewDelegate textViewDidBeginEditing:textView];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.innerTextViewDelegate && [self.innerTextViewDelegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.innerTextViewDelegate textViewDidChange:textView];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (self.innerTextViewDelegate && [self.innerTextViewDelegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [self.innerTextViewDelegate textViewDidChangeSelection:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.innerTextViewDelegate && [self.innerTextViewDelegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
        [self.innerTextViewDelegate textViewDidEndEditing:textView];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.innerTextViewDelegate && [self.innerTextViewDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        return [self.innerTextViewDelegate textViewShouldBeginEditing:textView];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (self.innerTextViewDelegate && [self.innerTextViewDelegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
        return [self.innerTextViewDelegate textViewShouldEndEditing:textView];
    }
    return YES;
}

#pragma mark - Accessors

- (void)setAutocompleteString:(NSString *)autocompleteString
{
    _autocompleteString = autocompleteString;
}

#pragma mark - Private Methods

- (void)autocompleteText:(id)sender
{
    if (!self.autocompleteDisabled)
    {
        self.autocompleteLabel.hidden = NO;
        
        [self commitAutocompleteText];
        
        // This is necessary because committing the autocomplete text changes the text field's text, but for some reason UITextView doesn't post the UITextViewTextDidChangeNotification notification on its own
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
    }
}

@end
