//
//  TaskDetailViewInput.swift
//  Todos
//
//  Created by Malik Timurkaev on 04.06.2025.
//

import UIKit

protocol TaskDetailViewInput: AnyObject {
    var presenter: TaskDetailViewOutput? { get set }
    func showTask(_ task: TaskDTO)
}

protocol TaskDetailViewOutput: AnyObject {
    func viewDidLoad()
    func updateTask(title: String, description: String)
}

final class TaskDetailView: UIViewController, TaskDetailViewInput {
    
    var presenter: TaskDetailViewOutput?
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .bold34()
        textField.textColor = .appWhite
        textField.tintColor = .appYellow
        textField.backgroundColor = .appBlack
        textField.delegate = self
        textField.placeholder = "Title"
        
        return textField
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .regular12()
        label.textColor = .appGrayDark
        
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .regular16()
        textView.textColor = .appWhite
        textView.tintColor = .appYellow
        textView.backgroundColor = .appBlack
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        setupUI()
        setupToolBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let title = convertToValidText(titleTextField.text ?? "")
        let description = convertToValidText(descriptionTextView.text ?? "")
        
        presenter?.updateTask(title: title, description: description)
    }
    
    func showTask(_ task: TaskDTO) {
        titleTextField.text = task.title
        descriptionTextView.text = task.todo
        dateLabel.text = CustomDateFormatter.shared.string(from: task.createdAt)
    }
    
    private func convertToValidText(_ text: String) -> String {
        
        if !text.filter({ $0 != Character(" ") }).isEmpty {
            text.trimmingCharacters(in: .whitespaces)
        } else {
            ""
        }
    }
        
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension TaskDetailView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 30
        
        let currentString = (textField.text ?? "") as NSString
        
        let newString = currentString.replacingCharacters(in: range, with: string).trimmingCharacters(in: .newlines)
        
        guard newString.count <= maxLength else {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

private extension TaskDetailView {
    func setupUI() {
        view.backgroundColor = .appBlack
        
        view.addSubview(titleTextField)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
    
        let sidePadding = CGFloat.defaultMargin
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupToolBar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.items = [flexSpace, doneButton]
        descriptionTextView.inputAccessoryView = toolbar
    }
}
