//
// Created by Makar Stetsenko on 13.10.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSGeneralDescriptionVC.h"
#import "PSParty.h"
#import "SZTextView.h"

@interface PSGeneralDescriptionVC () {

}

@property (weak, nonatomic) IBOutlet SZTextView *textField;

@end

@implementation PSGeneralDescriptionVC {

    NSString *_placeholderText;

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textField.placeholderTextColor = [UIColor lightGrayColor];
//    self.textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];

    [self.textField setPlaceholder:@"Теперь расскажите нам о своей вечеринке и ее  особенностях! Знаменитые гости? Незабываемые конкурсы? Взрывная атмосфера и лучшие миксы? Дресс-код? Напишите все, что делает Вашу вечеринку уникальной!\n"
            "\n"
            "О чем не стоит говорить:\n"
            "\t- Цена\n"
            "\t- Контактные данные\n"
            "\n"
            "Эту информацию Вы укажите позже.\n"
            "\t\n"
            " "];

    [self.textField becomeFirstResponder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.textField becomeFirstResponder];
}


#pragma mark - UI Text View Delegate

@end