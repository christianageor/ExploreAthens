//
//  ViewController.swift
//  explore Athens
//
//  Created by IOANNIS VOURNAS on 15/2/22.
//
import UIKit
import CoreML
import Vision
import AVFoundation
import AVKit
import SwiftUI

class ViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    // Image picker controller
    let imagePicker = UIImagePickerController()
    
    // UIOutlets
    let chooseImageBtn : UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemBlue
        btn.setTitle("Photo Library", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
    }()
    
    let imageView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(systemName: "explore_athens_logo")
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        return imgView
    }()
    
    let resultLabel : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        return lbl
    }()
    
    let descriptionLabel : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .justified
        lbl.translatesAutoresizingMaskIntoConstraints = false
       // lbl.lineBreakMode = .byWordWrapping
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byTruncatingTail // or .byWrappingWord
        lbl.minimumScaleFactor = 0.1
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        chooseImageBtn.addTarget(self, action: #selector(chooseBtnPressed), for: .touchUpInside)
        
    }
    
    @objc func chooseBtnPressed(){
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    func setupUI(){
        
        let upperView = UIView()
        let bottomView = UIView()
        
        upperView.translatesAutoresizingMaskIntoConstraints = false
        upperView.backgroundColor = .systemGray4
        
        view.addSubview(upperView)
        upperView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        upperView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        upperView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        upperView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75).isActive = true
        
        upperView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: upperView.topAnchor, constant: 20).isActive = true
        imageView.leadingAnchor.constraint(equalTo: upperView.leadingAnchor, constant: 20).isActive = true
        imageView.trailingAnchor.constraint(equalTo: upperView.trailingAnchor, constant: -20).isActive = true
        imageView.heightAnchor.constraint(equalTo: upperView.heightAnchor, multiplier: 0.6).isActive = true
        
        upperView.addSubview(resultLabel)
        resultLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        resultLabel.leadingAnchor.constraint(equalTo: upperView.leadingAnchor, constant: 0).isActive = true
        resultLabel.trailingAnchor.constraint(equalTo: upperView.trailingAnchor, constant: -0).isActive = true
        resultLabel.heightAnchor.constraint(equalTo: upperView.heightAnchor, multiplier: 0.04).isActive = true
        
        upperView.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: upperView.leadingAnchor, constant: 20).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: upperView.trailingAnchor, constant: -20).isActive = true
        descriptionLabel.heightAnchor.constraint(equalTo: upperView.heightAnchor, multiplier: 0.2).isActive = true
        
        bottomView.backgroundColor = .systemGroupedBackground
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bottomView)
        bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25).isActive = true
        
        bottomView.addSubview(chooseImageBtn)
        chooseImageBtn.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        chooseImageBtn.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        chooseImageBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        chooseImageBtn.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.6).isActive = true
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
        
        // Convert the image for CIImage
        if let ciImage = CIImage(image: image) {
            processImage(ciImage: ciImage)
        }else {
            print("CIImage convert error")
        }
        
        
    }
    
    // Process Image output
    func processImage(ciImage: CIImage){
        
        do{
            let model = try VNCoreMLModel(for: final_1().model)
            
            let request = VNCoreMLRequest(model: model) { (request, error) in
                self.processClassifications(for: request, error: error)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
                do {
                    try handler.perform([request])
                } catch {
                    
                    print("Failed to perform classification.\n\(error.localizedDescription)")
                }
            }
            
        }catch {
            print(error.localizedDescription)
        }
        
    }
    

    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("Unable to classify image.\n\(error!.localizedDescription)")
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
            
            self.resultLabel.text = classifications.first?.identifier.uppercased()
            
            if (self.resultLabel.text == "WAR MUSEUM OF ATHENS")
            {
                self.descriptionLabel.text = "The Athens War Museum includes Greek military relics and documents from many centuries, that manifest the country’s eventful military history. It was established in 1975, and aims to honor all those who fought for the country and its freedom."
                
                let utterance = AVSpeechUtterance(string: "The Athens War Museum includes Greek military relics and documents from many centuries, that manifest the country’s eventful military history. It was established in 1975, and aims to honor all those who fought for the country and its freedom.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
            }
            
            if (self.resultLabel.text == "ARCH OF HADRIAN ")
            {
                self.descriptionLabel.text = "Arch build between 131 - 132 A.C. by the Athenians in order to show their appreciation to the Roman Emperor Hadrian."
                
                let utterance = AVSpeechUtterance(string: "Arch build between 131 - 132 A.C. by the Athenians in order to show their appreciation to the Roman Emperor Hadrian.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
            }
            
            
            if (self.resultLabel.text == "PARTHENON")
            {
                self.descriptionLabel.text = "Doric temple of the 5th century B.C. dedicated to the goddess Athena who was the protector of the city of Athens. It is the most important and representative monument of the Acropolis. It was constructed between 447-439 B.C. by the architects Iktinos and Kallikratis."
                
                let utterance = AVSpeechUtterance(string: "Doric temple of the 5th century B.C. dedicated to the goddess Athena who was the protector of the city of Athens. It is the most important and representative monument of the Acropolis. It was constructed between 447-439 B.C. by the architects Iktinos and Kallikratis.")
                
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "RUNNER STATUE (DROMEAS)")
            {

                self.descriptionLabel.text = "Sculpture made by Costas Varotsos in 1988. It is 8 meters high and made out of glass. According to the artist, the Runner symbolizes the eternal traveler who always leaves a memory behind."
                
                let utterance = AVSpeechUtterance(string: "Sculpture made by Costas Varotsos in 1988. It is 8 meters high and made out of glass. According to the artist, the Runner symbolizes the eternal traveler who always leaves a memory behind.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "ACADEMY OF ATHENS")
            {
                self.descriptionLabel.text = "Neoclassical building, part of the architectural trilogy that includes the buildings of the Library, the University and the Academy. It was designed in 1959 by the Danish architect Theophil Hansen, who was deeply influenced by the monuments of the Acropolis and especially the Erechtheion. "
                
                let utterance = AVSpeechUtterance(string: "Neoclassical building, part of the architectural trilogy that includes the buildings of the Library, the University and the Academy. It was designed in 1959 by the Danish architect Theophil Hansen, who was deeply influenced by the monuments of the Acropolis and especially the Erechtheion.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "NATIONAL GALLERY OF ATHENS")
            {
                self.descriptionLabel.text = "With more than 20,000 artworks, the National Gallery in Athens was established in 1900 and is considered the most important art museum in Greece. It is devoted to Greek and European art from the 14th century to the 20th century."
                
                let utterance = AVSpeechUtterance(string: "With more than 20,000 artworks, the National Gallery in Athens was established in 1900 and is considered the most important art museum in Greece. It is devoted to Greek and European art from the 14th century to the 20th century.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "ZAPPEION")
            {
                self.descriptionLabel.text = "The Zappeion Megaron is a part of national heritage of Greek civilization, designed by T. Hansen (1874-1888) and has been an active part of Greece's history and that of Hellenism, for the last 130 years. Cultural events of great importance take place within the precinct."
                
                let utterance = AVSpeechUtterance(string: "The Zappeion Megaron is a part of national heritage of Greek civilization, designed by T. Hansen (1874-1888) and has been an active part of Greece's history and that of Hellenism, for the last 130 years. Cultural events of great importance take place within the precinct.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "ODEON OF HERODES ATTICUS")
            {
                self.descriptionLabel.text = "The Odeon of Herodes Atticus - known as the Herodeon -  is a stone Roman theatre that hosts Greek and international performances under the Athenian sky. It is located on the southwest slope of the Acropolis. The building was completed in AD 161 and then renovated in 1950."
                
                let utterance = AVSpeechUtterance(string: "The Odeon of Herodes Atticus - known as the Herodeon -  is a stone Roman theatre that hosts Greek and international performances under the Athenian sky. It is located on the southwest slope of the Acropolis. The building was completed in AD 161 and then renovated in 1950.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "KOLOKOTRONIS STATUE")
            {
                self.descriptionLabel.text = "One of the most important works of modern Greek sculpture, both regarding its aesthetics and its history. The bronze statue was made in 1894. It was constructed by the material from the canons of the Revolution that were inside the castle of Palamidi."
                
                let utterance = AVSpeechUtterance(string: "One of the most important works of modern Greek sculpture, both regarding its aesthetics and its history. The bronze statue was made in 1894. It was constructed by the material from the canons of the Revolution that were inside the castle of Palamidi.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "NATIONAL ARCHAELOGICAL MUSEUM")
            {
                self.descriptionLabel.text = "The Archaeological Museum was founded in 1960. Its collections, numbering more than 11,000 exhibits, offer the visitor a panorama of ancient Greek culture from the beginning of prehistory to late antiquity."
                
                let utterance = AVSpeechUtterance(string: "The Archaeological Museum was founded in 1960. Its collections, numbering more than 11,000 exhibits, offer the visitor a panorama of ancient Greek culture from the beginning of prehistory to late antiquity.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "METROPOLITAN CATHEDRAL OF ATHENS")
            {
                self.descriptionLabel.text = "The Orthodox Cathedral of Athens, which is dedicated to the Annunciation of the Virgin Mary, is located in Metropolis Square on the homonymous street. Its construction began in 1842 and was completed in 1862."
                
                let utterance = AVSpeechUtterance(string: "The Orthodox Cathedral of Athens, which is dedicated to the Annunciation of the Virgin Mary, is located in Metropolis Square on the homonymous street. Its construction began in 1842 and was completed in 1862.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "TEMPLE OF OLYMPUS")
            {
                self.descriptionLabel.text = "The Temple of Zeus is located at the center of Athens. It was constructed between the sixth century BC and the second century AD. It was dedicated to Olympian Zeus."
                
                let utterance = AVSpeechUtterance(string: "The Temple of Zeus is located at the center of Athens. It was constructed between the sixth century BC and the second century AD. It was dedicated to Olympian Zeus.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "TEMPLE OF HEPHAESTUS")
            {
                self.descriptionLabel.text = "The Temple of Hephaestus is sizeable and is the best-preserved ancient temple in the world. It is dedicated to God Hephaestus and Goddess Athena. Its construction began in 445 by Perciles."
                
                let utterance = AVSpeechUtterance(string: "The Temple of Hephaestus is sizeable and is the best-preserved ancient temple in the world. It is dedicated to God Hephaestus and Goddess Athena. Its construction began in 445 by Perciles.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "TEMPLE OF ATHENA NIKE")
            {
                self.descriptionLabel.text = "The temple of Athena Nike was dedicated to Goddess Athena and it was designed by the architect Kallikrates. It was built between 426 and 421 BC on a bastion at the southwestern edge of the Acropolis."
                
                let utterance = AVSpeechUtterance(string: "The temple of Athena Nike was dedicated to Goddess Athena and it was designed by the architect Kallikrates. It was built between 426 and 421 BC on a bastion at the southwestern edge of the Acropolis.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "KALLIMARMARO")
            {
                self.descriptionLabel.text = "The Panathenaic Stadium also known as Kallimarmaro, following  several transformations over its long history, it eventually became the home of the first modern Olympic Games in 1896 and remains the only stadium in the world built entirely out of marble."
                
                let utterance = AVSpeechUtterance(string: "The Panathenaic Stadium also known as Kallimarmaro, following  several transformations over its long history, it eventually became the home of the first modern Olympic Games in 1896 and remains the only stadium in the world built entirely out of marble.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "THEATRE OF DIONYSUS")
            {
                self.descriptionLabel.text = "The Theatre of Dionysus was used as a theatre from the sixth century BC onwards. It was the first and largest theatre to be built in Athens and could seat up to 17,000 people."
                
                let utterance = AVSpeechUtterance(string: "The Theatre of Dionysus was used as a theatre from the sixth century BC onwards. It was the first and largest theatre to be built in Athens and could seat up to 17,000 people.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                
            }
            
            if (self.resultLabel.text == "ACROPOLIS MUSEUM")
            {
                self.descriptionLabel.text = "Devoted to the Parthenon and its surrounding temples and designed by New York’s, Bernard Tschumi, with local Greek architect Michael Photiadis, it is the perfect sanctuary for the ancient artefacts that were found in Acropolis and successfully deconstructs how the Parthenon sculptures once looked."
                
                let utterance = AVSpeechUtterance(string: "Devoted to the Parthenon and its surrounding temples and designed by New York’s, Bernard Tschumi, with local Greek architect Michael Photiadis, it is the perfect sanctuary for the ancient artefacts that were found in Acropolis and successfully deconstructs how the Parthenon sculptures once looked.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
            }
            
            if (self.resultLabel.text == "HOROLOGION OF ANDRONIKOS")
            {
                self.descriptionLabel.text = "It is an octagonal building, which incorporates a cylindrical structure on the south side. Its incised lines on the exterior of the eight sides of the edifice show that there once existed this number of sundials. It served as an astronomical and weather forecasting station."
                
                let utterance = AVSpeechUtterance(string: "It is an octagonal building, which incorporates a cylindrical structure on the south side. Its incised lines on the exterior of the eight sides of the edifice show that there once existed this number of sundials. It served as an astronomical and weather forecasting station.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
            }
            
            if (self.resultLabel.text == "PARLIAMENT")
            {
                self.descriptionLabel.text = "Constructed in 1843, the building was initially a palace for kings Othon and George. Since 1935 and after its complete renovation under the supervision of Andreas Kiriezis it has housed the Greek Parliament."
                
                let utterance = AVSpeechUtterance(string: "Constructed in 1843, the building was initially a palace for kings Othon and George. Since 1935 and after its complete renovation under the supervision of Andreas Kiriezis it has housed the Greek Parliament.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
            }
            
            if (self.resultLabel.text == "ACROPOLIS")
            {
                self.descriptionLabel.text = "A building complex of the 5th century B.C. dedicated to the goddess Athena. Comprised of shrines and other monuments it reflects the power of the city during the above time period."
                
                let utterance = AVSpeechUtterance(string: "A building complex of the 5th century B.C. dedicated to the goddess Athena. Comprised of shrines and other monuments it reflects the power of the city during the above time period.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5213

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
            }
            
            
            
        }
    }
}
