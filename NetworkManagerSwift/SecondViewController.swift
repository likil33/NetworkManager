//
//  SecondViewController.swift
//  NetworkManagerSwift
//
//  Created by Santhosh K on 15/08/22.
//

import UIKit
import PDFKit


class SecondViewController: UIViewController {
    
    let pdfView = PDFView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.savePdf(urlString: "https://api.sit.goemapp.com/emapp/file/2259", fileName: "")
    }
    
    
    
}

//MARK:- PDF viewer
extension SecondViewController  {
    func savePdf(urlString:String, fileName:String) {
        
        

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        
       // CustomLoader.instance.showLoaderView()
        DispatchQueue.main.async {
            let url = URL(string: urlString)
            let pdfData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "MYDOC_\(UUID()).pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            do {
               // CustomLoader.instance.hideLoaderView()
                try pdfData?.write(to: actualPath, options: .atomic)
                print(actualPath)
                print("pdf successfully saved!")
                if let document = PDFDocument(url: actualPath) {
                    self.pdfView.document = document
                }
            } catch {
               // CustomLoader.instance.hideLoaderView()
                print("Pdf could not be saved")
            }
        }
    }
}
