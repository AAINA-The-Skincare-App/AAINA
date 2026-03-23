//
//  NotesEditorViewController.swift
//  JournalUI
//

import UIKit

class NotesEditorViewController: UIViewController {

    // MARK: - Public
    var initialText: String?

    // MARK: - Views
    private let textView = UITextView()
    private let placeholder = UILabel()
    private let toolbar = UIView()
    private var toolbarBottomConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyAINABackground()
        setupNavBar()
        setupTextView()
        setupToolbar()
        subscribeToKeyboard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAINABackground()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let text = initialText, !text.isEmpty {
            textView.text = text
            placeholder.isHidden = true
        } else {
            textView.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Navigation bar

    private func setupNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.hidesBackButton = true

        let backBtn = makeNavButton(icon: "chevron.left", action: #selector(backTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)

        let shareBtn = makeNavButton(icon: "square.and.arrow.up", action: #selector(shareTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
    }

    private func makeNavButton(icon: String, action: Selector) -> UIView {
        let glass = UIVisualEffectView(effect: UIGlassEffect())
        glass.layer.cornerRadius = 18
        glass.clipsToBounds = true
        glass.frame = CGRect(x: 0, y: 0, width: 36, height: 36)

        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: icon), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: action, for: .touchUpInside)
        glass.contentView.addSubview(btn)

        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: glass.contentView.topAnchor),
            btn.bottomAnchor.constraint(equalTo: glass.contentView.bottomAnchor),
            btn.leadingAnchor.constraint(equalTo: glass.contentView.leadingAnchor),
            btn.trailingAnchor.constraint(equalTo: glass.contentView.trailingAnchor)
        ])
        return glass
    }

    // MARK: - Text view

    private func setupTextView() {
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 17)
        textView.textColor = .label
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 24, left: 16, bottom: 100, right: 16)
        textView.keyboardDismissMode = .interactive
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        placeholder.text = "How is your skin feeling today? Any changes or observations? — better, worse, or just different?\nAttach photos to visually track your skin's journey and progress."
        placeholder.font = .systemFont(ofSize: 17)
        placeholder.textColor = .tertiaryLabel
        placeholder.numberOfLines = 0
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholder)

        NSLayoutConstraint.activate([
            placeholder.topAnchor.constraint(equalTo: textView.topAnchor, constant: 24),
            placeholder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            placeholder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Bottom toolbar

    private func setupToolbar() {
        toolbar.layer.cornerRadius = 24
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        toolbar.applyGlass(cornerRadius: 24)

        let playBtn   = makeToolbarButton(systemName: "play.fill",    tint: .ainaDustyRose)
        let clipBtn   = makeToolbarButton(systemName: "paperclip",    tint: .secondaryLabel)
        let labelBtn  = makeToolbarButton(systemName: "tag",          tint: .secondaryLabel)

        let stack = UIStackView(arrangedSubviews: [playBtn, clipBtn, labelBtn])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(stack)

        toolbarBottomConstraint = toolbar.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)

        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toolbarBottomConstraint,
            toolbar.heightAnchor.constraint(equalToConstant: 48),

            stack.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -12),
            stack.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor)
        ])
    }

    private func makeToolbarButton(systemName: String, tint: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: systemName), for: .normal)
        btn.tintColor = tint
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return btn
    }

    // MARK: - Keyboard handling

    private func subscribeToKeyboard() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc private func keyboardWillChange(_ note: Notification) {
        guard
            let info = note.userInfo,
            let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let keyboardHeight = max(0, view.bounds.maxY - keyboardFrame.minY)
        let safeBottom = view.safeAreaInsets.bottom
        let offset: CGFloat = keyboardHeight > 0
            ? -(keyboardHeight - safeBottom + 12)
            : -12

        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.toolbarBottomConstraint.constant = offset
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func shareTapped() {
        let text = textView.text ?? ""
        guard !text.isEmpty else { return }
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(vc, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension NotesEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = !textView.text.isEmpty
    }
}
