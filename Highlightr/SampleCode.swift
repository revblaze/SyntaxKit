//
//  SampleCode.swift
//  Highlightr
//
//  Created by Illanes, J.P. on 5/5/16.
//  SyntaxKit by Justin Bush (13/12/2019)
//

import UIKit
import Highlightr
import ActionSheetPicker_3_0

enum pickerSource : Int {
    case theme = 0
    case language
}

class SampleCode: UIViewController {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var viewPlaceholder: UIView!
    var textView: UITextView!
    @IBOutlet var textToolbar: UIToolbar!
    
    @IBOutlet weak var languageName: UILabel!
    @IBOutlet weak var themeName: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var highlightr : Highlightr!
    let textStorage = CodeAttributedString()
    
    // Updated Hidden Status Bar Functionality
    var isHidden = true {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        languageName.text = "Swift"
        themeName.text = "Pojoaque"
        
        let themeTitle = themeName.text?.replacingOccurrences(of: "-", with: " ", options: .literal, range: nil)
        navigationItem.title = languageName.text
        navigationItem.prompt = themeTitle //themeName.text
        
        textStorage.language = languageName.text?.lowercased()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: view.bounds.size)
        layoutManager.addTextContainer(textContainer)
        
        textView = UITextView(frame: viewPlaceholder.bounds, textContainer: textContainer)
        textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.autocapitalizationType = UITextAutocapitalizationType.none
        textView.textColor = UIColor(white: 0.8, alpha: 1.0)
        textView.inputAccessoryView = textToolbar
        viewPlaceholder.addSubview(textView)
        
        let code = try! String.init(contentsOfFile: Bundle.main.path(forResource: "sampleCode", ofType: "txt")!)
        textView.text = code
        
        highlightr = textStorage.highlightr
        updateColors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pickLanguage(_ sender: AnyObject) {
        let languages = highlightr.supportedLanguages().sorted()
        let indexOrNil = languages.firstIndex(of: languageName.text!.lowercased())
        let index = (indexOrNil == nil) ? 0 : indexOrNil!
        ActionSheetStringPicker.show(withTitle: "Pick a Language",
                                     rows: languages,
                                     initialSelection: index,
                                     doneBlock:
            { picker, index, value in
                let language = value! as! String
                self.textStorage.language = language
                self.languageName.text = language.capitalized
                let snippetPath = Bundle.main.path(forResource: "default", ofType: "txt", inDirectory: "Samples/\(language)", forLocalization: nil)
                let snippet = try! String(contentsOfFile: snippetPath!)
                self.textView.text = snippet
                self.updateColors()
            },
                                     cancel: nil,
                                                    origin: navigationController?.toolbar)

    }

    @IBAction func performanceTest(_ sender: AnyObject) {
        let code = textStorage.string
        let languageName = self.languageName.text
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        DispatchQueue.global(qos: .userInteractive).async {
            let start = Date()
            for _ in 0...100
            {
                _ = self.highlightr.highlight(code, as: languageName)
            }
            let end = Date()
            let time = Float(end.timeIntervalSince(start));
            
            let avg = String(format:"%0.4f", time/100)
            let total = String(format:"%0.3f", time)
            
            let alert = UIAlertController(title: "Performance Test", message: "This code was highlighted 100 times. \n It took an average of \(avg) seconds to process each time,\n with a total of \(total) seconds", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(okAction)
            
            DispatchQueue.main.async(execute: {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.present(alert, animated: true, completion: nil)
            })
        }
        
    }
    
    @IBAction func pickTheme(_ sender: AnyObject) {
        hideKeyboard(nil)
        let themes = highlightr.availableThemes()
        let indexOrNil = themes.firstIndex(of: themeName.text!.lowercased())
        let index = (indexOrNil == nil) ? 0 : indexOrNil!
        
        ActionSheetStringPicker.show(withTitle: "Pick a Theme",
                                     rows: themes,
                                     initialSelection: index,
                                     doneBlock:
            { picker, index, value in
                let theme = value! as! String
                self.textStorage.highlightr.setTheme(to: theme)
                self.themeName.text = theme.capitalized
                self.updateColors()
            },
                                     cancel: nil,
                                                    origin: navigationController?.toolbar)
    }
    
    @IBAction func hideKeyboard(_ sender: AnyObject?) {
        textView.resignFirstResponder()
    }
    
    // Update colors for theme, title and prompt
    func updateColors() {
        textView.backgroundColor = highlightr.theme.themeBackgroundColor
        navigationController?.navigationBar.barTintColor = highlightr.theme.themeBackgroundColor
        navigationController?.navigationBar.tintColor = invertColor(highlightr.theme.themeBackgroundColor)
        languageName.textColor =  invertColor(highlightr.theme.themeBackgroundColor) //navigationController?.navigationBar.tintColor
        themeName.textColor = invertColor(highlightr.theme.themeBackgroundColor).withAlphaComponent(0.5) //navigationController?.navigationBar.tintColor.withAlphaComponent(0.5)
        navigationController?.toolbar.barTintColor = highlightr.theme.themeBackgroundColor //navigationController?.navigationBar.barTintColor
        navigationController?.toolbar.tintColor = invertColor(highlightr.theme.themeBackgroundColor) //navigationController?.navigationBar.tintColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: invertColor(highlightr.theme.themeBackgroundColor) ]
        
        let themeTitle = self.themeName.text?.replacingOccurrences(of: "-", with: " ", options: .literal, range: nil)
        self.navigationItem.title = self.languageName.text
        self.navigationItem.prompt = themeTitle
        
        // Update UIColor for Prompt Label
        for view in self.navigationController?.navigationBar.subviews ?? [] {
            let subviews = view.subviews
            if subviews.count > 0, let label = subviews[0] as? UILabel {
                label.textColor = invertColor(highlightr.theme.themeBackgroundColor).withAlphaComponent(0.5)
                label.backgroundColor = UIColor.clear
            }
        }
    }
    
    func invertColor(_ color: UIColor) -> UIColor {
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        return UIColor(red:1.0-r, green: 1.0-g, blue: 1.0-b, alpha: 1)
    }
    
}

