//
// Created by Makar Stetsenko on 13.10.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSGeneralDescriptionVC.h"
#import "PSParty.h"
#import "SZTextView.h"
#import "PSPriceDescriptionVC.h"
#import "PSAppDelegate.h"
#import "PSUserFeedVC.h"

static NSString *GA_SCREEN_NAME = @"Party Create - description";

@interface PSGeneralDescriptionVC () {

}

@property (weak, nonatomic) IBOutlet SZTextView *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@end

@implementation PSGeneralDescriptionVC {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textField.placeholderTextColor = [UIColor lightGrayColor];
//    self.textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];

    [self.textField setPlaceholder:@"Расскажите нам о своей вечеринке и ее особенностях! Знаменитые гости? Незабываемые конкурсы? Взрывная атмосфера и лучшие миксы? Дресс-код? Напишите все, что делает Вашу вечеринку уникальной!\n"
            "\n"
            "О чем не стоит говорить:\n"
            "\t- Цена\n"
            "\t- Контактные данные\n"
            "\n"
            "Эту информацию Вы укажите позже.\n"
            "\t\n"
            " "];

    [self.textField becomeFirstResponder];

    self.nextButton.enabled = [self.party.generalDescription length] > 0;

//    NSLog(@"[self.party.description length] = %u", [self.party.description length]);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    NSLog(@"%s", sel_getName(_cmd));

    if (self.party.generalDescription) {
        [self.textField setText:self.party.generalDescription];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [((PSAppDelegate *)[[UIApplication sharedApplication] delegate]) trackScreen:GA_SCREEN_NAME];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.party.generalDescription = self.textField.text;

    PSPriceDescriptionVC *vc = segue.destinationViewController;
    [vc setParty:self.party];
    vc.delegate = self.delegate;
}


#pragma mark - Text View Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSMutableString *descr = [textView.text mutableCopy];
    [descr replaceCharactersInRange:range withString:text];
    NSString *trimmedDescr = [descr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    self.nextButton.enabled = trimmedDescr.length != 0;

    [self.party setGeneralDescription:trimmedDescr];

    return YES;
}


@end