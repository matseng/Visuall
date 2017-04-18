//
//  ViewController+Menus.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/11/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (Menus) <UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TopMenuProtocol, UIPopoverPresentationControllerDelegate, UITextViewDelegate>  // added UINavigationControllerDelegate to suppress a warning

- (void) createTopMenu;

- (void) addSubmenu;

- (void) addSecondSubmenu;

- (BOOL) isEditModeOn;

- (BOOL) isDrawGroupButtonSelected;

- (BOOL) isNoteButtonSelected;

- (BOOL) isPointerButtonSelected;

- (BOOL) isDrawButtonSelected;

- (BOOL) trashButtonHitTest: (UIGestureRecognizer *) gesture;

- (void) highlightTrashButton;

- (void) normalizeTrashButton;

- (BOOL) isArrowButtonSelected;

- (void) switchChanged:(id) sender;

@end
