protocol SectionEditorInputViewsSource: class {
    var inputViewController: UIInputViewController? { get }
}

class SectionEditorInputViewsController: SectionEditorInputViewsSource {
    let webView: SectionEditorWebViewWithEditToolbar

    let textFormattingInputViewController = TextFormattingInputViewController.wmf_viewControllerFromStoryboardNamed("TextFormatting")
    let defaultEditToolbarView = DefaultEditToolbarView.wmf_viewFromClassNib()
    let contextualHighlightEditToolbarView = ContextualHighlightEditToolbarView.wmf_viewFromClassNib()

    init(webView: SectionEditorWebViewWithEditToolbar) {
        defer {
            inputAccessoryViewType = .default
        }

        self.webView = webView

        textFormattingInputViewController.delegate = self
        defaultEditToolbarView?.delegate = self
        contextualHighlightEditToolbarView?.delegate = self

        setInputViewTypes(inputViewType: nil, inputAccessoryViewType: .default)

        NotificationCenter.default.addObserver(self, selector: #selector(textSelectionDidChange(_:)), name: Notification.Name.WMFSectionEditorSelectionChangedNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func textSelectionDidChange(_ notification: Notification) {
        guard inputViewController == nil else {
            return
        }
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let message = userInfo[SectionEditorWebViewConfiguration.WMFSectionEditorSelectionChanged] as? SelectionChangedMessage else {
            return
        }
        if message.selectionIsRange {
            inputAccessoryViewType = .highlight
        } else {
            inputAccessoryViewType = .default
        }
    }

    var inputViewType: TextFormattingInputViewController.InputViewType?

    var inputViewController: UIInputViewController? {
        guard let inputViewType = inputViewType else {
            return nil
        }
        textFormattingInputViewController.inputViewType = inputViewType
        return textFormattingInputViewController
    }

    private enum InputAccessoryViewType {
        case `default`
        case highlight
    }

    private var previousInputAccessoryViewType: InputAccessoryViewType?
    private var inputAccessoryViewType: InputAccessoryViewType? {
        didSet {
            previousInputAccessoryViewType = oldValue
        }
    }

    private var inputAccessoryView: (UIView & Themeable)? {
        guard let inputAccessoryViewType = inputAccessoryViewType else {
            return nil
        }

        let maybeView: Any?

        switch inputAccessoryViewType {
        case .default:
            maybeView = defaultEditToolbarView
        case .highlight:
            maybeView = contextualHighlightEditToolbarView
        }

        guard let inputAccessoryView = maybeView as? UIView & Themeable else {
            assertionFailure("Couldn't get preferredInputAccessoryView")
            return nil
        }

        return inputAccessoryView
    }

    private func setInputViewTypes(inputViewType: TextFormattingInputViewController.InputViewType?, inputAccessoryViewType: InputAccessoryViewType?) {
        self.inputViewType = inputViewType
        self.inputAccessoryViewType = inputAccessoryViewType

        webView.setInputAccessoryView(inputAccessoryView)
    }
}

// MARK: TextFormattingDelegate

extension SectionEditorInputViewsController: TextFormattingDelegate {
    func textFormattingProvidingDidTapTextStyleFormatting() {
        setInputViewTypes(inputViewType: .textStyle, inputAccessoryViewType: nil)
    }

    func textFormattingProvidingDidTapTextFormatting() {
        setInputViewTypes(inputViewType: .textFormatting, inputAccessoryViewType: nil)
    }

    func textFormattingProvidingDidTapClose() {
        setInputViewTypes(inputViewType: nil, inputAccessoryViewType: previousInputAccessoryViewType)
    }

    func textFormattingProvidingDidTapHeading(depth: Int) {
        webView.setHeadingSelection(depth: depth)
    }

    func textFormattingProvidingDidTapBold() {
        webView.toggleBoldSelection()
    }

    func textFormattingProvidingDidTapItalics() {
        webView.toggleItalicSelection()
    }

    func textFormattingProvidingDidTapUnderline() {
        webView.toggleUnderline()
    }

    func textFormattingProvidingDidTapStrikethrough() {
        webView.toggleStrikethrough()
    }

    func textFormattingProvidingDidTapReference() {
        webView.toggleReferenceSelection()
    }

    func textFormattingProvidingDidTapTemplate() {
        webView.toggleTemplateSelection()
    }

    func textFormattingProvidingDidTapComment() {
        webView.toggleComment()
    }

    func textFormattingProvidingDidTapLink() {
        //
    }

    func textFormattingProvidingDidTapIncreaseIndent() {
        webView.increaseIndentDepth()
    }

    func textFormattingProvidingDidTapDecreaseIndent() {
        webView.decreaseIndentDepth()
    }

    func textFormattingProvidingDidTapOrderedList() {
        webView.toggleOrderedListSelection()
    }

    func textFormattingProvidingDidTapUnorderedList() {
        webView.toggleUnorderedListSelection()
    }

    func textFormattingProvidingDidTapSuperscript() {
        webView.toggleSuperscript()
    }

    func textFormattingProvidingDidTapSubscript() {
        webView.toggleSubscript()
    }
}
