//
//  ViewController.swift
//  OpenAI
//
//  Created by Zero IT Solutions on 20/12/22.
//

import UIKit
import OpenAISwift
import Lottie

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ApiGenerateView: UIView!
    @IBOutlet weak var Btnsavekey: UIButton!
    @IBOutlet weak var BtnGenerateKey: UIButton!
    @IBOutlet weak var ApiKeyTxtField: UITextField!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var btnGo: UIButton!
    @IBOutlet weak var writetxtField: UITextField!
    var ApiKey = UserDefaults.standard.string(forKey: "APIKey")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Btnsavekey.backgroundColor = .systemGreen
        self.Btnsavekey.backgroundColor = .systemGreen
        ApiKeyTxtField.delegate = self
        writetxtField.delegate = self
        ShowCustomLoaderView(isSecondLaunch: false)
        if (ApiKey == nil){
            self.ApiGenerateView.isHidden = false
        } else {
            self.ApiGenerateView.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func ActionGetKey(_ sender: Any) {
        if let url = URL(string: "https://beta.openai.com/account/api-keys") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func ActionSaveKey(_ sender: Any) {
        ApiKeyTxtField.resignFirstResponder()
        if ApiKeyTxtField.text?.count ?? 0 > 50 {
            UserDefaults.standard.set(self.ApiKeyTxtField.text!, forKey: "APIKey")
            self.ApiKey = UserDefaults.standard.string(forKey: "APIKey")
            self.ApiGenerateView.isHidden = true
            self.ApiKeyTxtField.text = ""
            ShowCustomLoaderView(isSecondLaunch: true)
        } else {
            alertPopUp(msg: "API Key not valid, please try again")
        }
    }
    
    @IBAction func ActionGo(_ sender: Any) {
        writetxtField.resignFirstResponder()
        if (ApiKey == nil){
            alertPopUp(msg: "API Key not Found, please try again or re-generate key")
        } else {
            let openAPI = OpenAISwift(authToken: ApiKey ?? "")
            if writetxtField.text != "" {
                showLoader()
                openAPI.sendCompletion(with: self.writetxtField.text!) { result in // Result<OpenAI, OpenAIError>
                    DispatchQueue.main.async {
                        self.resultLbl.text = ""
                        let fetchResult = (try? result.get().choices)
                        if fetchResult?.count ?? 0 > 0 {
                            for datta in fetchResult ?? [] {
                                self.resultLbl.text = datta.text
                            }
                        }
                        self.writetxtField.text = ""
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self.resultLbl.text = ""
            }
        }
    }
    
    @IBAction func ActionRegenrateKey(_ sender: Any) {
        if(ApiKey != nil){
            UserDefaults.standard.removeObject(forKey: "APIKey")
            ApiKey = ""
        }
        self.ApiGenerateView.isHidden = false
    }
    
}

extension ViewController {
    
    func ShowCustomLoaderView(isSecondLaunch: Bool){
        if isSecondLaunch == true {
            self.animationView.isHidden = false
        }
        self.animationView.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.animationView.isHidden = true
        }
    }
    func alertPopUp(msg: String){
        let alert = UIAlertController(title: "🤖", message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func showLoader(){
        let alert = UIAlertController(title: "Hold on please...", message: "", preferredStyle: .alert )
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
}

