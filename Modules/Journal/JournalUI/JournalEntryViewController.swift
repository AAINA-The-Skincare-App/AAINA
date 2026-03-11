//
//  JournalEntryViewController.swift
//  JournalUI
//
//  Created by GEU on 11/02/26.
//

import UIKit

class JournalEntryViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
        
        var selectedDate: String = ""

        override func viewDidLoad() {
            super.viewDidLoad()

            setupEditor()
            loadSavedDraft()
            title = selectedDate   // show date at top
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            textView.becomeFirstResponder()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            saveDraft()
        }

        // MARK: Editor Setup
        private func setupEditor() {
            textView.font = UIFont.systemFont(ofSize: 17)
            textView.delegate = self
        }

        // MARK: Save per date
        private func saveDraft() {
            let key = "journal_entry_" + selectedDate
            UserDefaults.standard.set(textView.text, forKey: key)
        }

        private func loadSavedDraft() {
            let key = "journal_entry_" + selectedDate
            textView.text = UserDefaults.standard.string(forKey: key)
        }

        // MARK: TextView Delegate
        func textViewDidChange(_ textView: UITextView) {
            saveDraft()
        }
    }
