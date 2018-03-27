//
//  QuranTextView.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/27/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit


fileprivate enum TextType {
    case header, subheader, normal
}

fileprivate struct AyahIndex {
    var ayah: Int
    var surah: Int
    
    init (string: String) {
        let arr = string.split(separator: ",")
        self.ayah = Int(arr[1])!
        self.surah = Int(arr[0])!
    }
    
    init(ayah: Int, surah: Int) {
        self.ayah = ayah
        self.surah = surah
    }
}

class QuranTextView: UITextView {

    
    fileprivate var allSurah: [Surah] = []
    
    fileprivate let surahStart: String = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
    fileprivate let invisibleSign: String = "\u{200B}"
    
    fileprivate var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    fileprivate let INDEX_ATTRIBUTE: String = "AyahIndex"
    fileprivate let SELECTED_ATTRIBUTE: String = "SelectedAyah"
    fileprivate let mainFont: UIFont = UIFont(name: "KFGQPCUthmanTahaNaskh-Bold", size: isIpadScreen ? 42 : 21)!
    fileprivate let subFont: UIFont = UIFont(name: "KFGQPCUthmanTahaNaskh-Bold", size: isIpadScreen ? 34 : 17)!
    
    
    func initWith(surah: [Surah]) {
        self.allSurah = surah
        
        initTextView()
    }
    
    func preapareForReuse() {
        allSurah.removeAll()
        attributedString = NSMutableAttributedString(string: "")
        self.attributedText = attributedString
    }
}

//MARK: - Helpers
extension QuranTextView {
    
    fileprivate func initTextView() {
        self.isEditable = false
        self.isSelectable = false
        
        for (index, sura) in allSurah.enumerated() {
            add(surah: sura, atIndex: index)
        }
        
//        let gesure = UITapGestureRecognizer(target: self, action: #selector(self.textViewTapHandler(_:)))
//        gesure.delegate = self
//        gesure.accessibilityLabel = "userTaps"
//        self.addGestureRecognizer(gesure)
    }
    
    fileprivate func getStyle(forType type: TextType) -> NSMutableParagraphStyle {
        let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = type == .normal ? .right : .center
        style.lineBreakMode = .byWordWrapping
        style.lineSpacing = 4
        return style
    }
    
    fileprivate func add(surah: Surah, atIndex surahIndex: Int) {
        for (index, ayah) in surah.allAyah.enumerated() {
            //check for the first ayah
            if ayah.id == 1 {
                //add the surah name
                attributedString.append(NSAttributedString(string: "سورة " + surah.name, attributes: getAttributes(forType: .header, atIndex: AyahIndex(ayah: 0, surah: surahIndex))))
                attributedString.append(NSAttributedString(string: "\n"))
                
                //check if it's for first surah in quran
                if surah.id == 1 {
                    attributedString.append(NSAttributedString(string: invisibleSign + ayah.content + invisibleSign, attributes: getAttributes(forType: .normal, atIndex: AyahIndex(ayah: index, surah: surahIndex))))
                }else {
                    //it's not the first surah, so we need to split the surah start from it
                    attributedString.append(NSAttributedString(string: invisibleSign + surahStart + invisibleSign, attributes: getAttributes(forType: .subheader, atIndex: AyahIndex(ayah: index, surah: surahIndex))))
                    attributedString.append(NSAttributedString(string: "\n"))
                    attributedString.append(NSAttributedString(string: invisibleSign + String(ayah.content.dropFirst(surahStart.count + 1)) + invisibleSign, attributes: getAttributes(forType: .normal, atIndex: AyahIndex(ayah: index, surah: surahIndex))))
                }
            }else {
                // it's not the first ayah
                attributedString.append(NSAttributedString(string: invisibleSign + ayah.content + invisibleSign, attributes: getAttributes(forType: .normal, atIndex: AyahIndex(ayah: index, surah: surahIndex))))
            }
            //adding the ayah number
            attributedString.append(NSAttributedString(string: " (\(ayah.id)) ", attributes: getAttributes(forType: .header, atIndex: AyahIndex(ayah: index, surah: surahIndex))))
        }
        
        self.attributedText = attributedString
    }
    
    fileprivate func getAttributes(forType type: TextType, atIndex index: AyahIndex) -> [NSAttributedStringKey: Any] {
        if type == .header {
            return [NSAttributedStringKey.font: mainFont, NSAttributedStringKey.paragraphStyle: getStyle(forType: type)]
        }
        
        return [NSAttributedStringKey.font: subFont, NSAttributedStringKey.paragraphStyle: getStyle(forType: type), NSAttributedStringKey.init(INDEX_ATTRIBUTE): "\(index.surah),\(index.ayah)"]
    }
    
    
    fileprivate func chageAyahColor(atIndex index: AyahIndex) {
        //remove old color
        attributedString.removeAttribute(NSAttributedStringKey.foregroundColor, range: NSMakeRange(0, attributedString.string.count))
        
        var range: NSRange!
        
        if index.surah != 1 && index.ayah == 1 {
            range = (attributedString.string as NSString).range(of: invisibleSign + String(allSurah[Int(index.surah)].allAyah[0].content.dropFirst(surahStart.count + 1)) + invisibleSign)
        }else {
            range = (attributedString.string as NSString).range(of: invisibleSign + String(allSurah[Int(index.surah)].allAyah[Int(index.ayah)].content) + invisibleSign)
        }
        
        attributedString.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.brown], range: range)
        
        self.attributedText = attributedString
    }
}

//MARK: - GestureRecognizer
extension QuranTextView: UIGestureRecognizerDelegate {
    
    @objc fileprivate func textViewTapHandler(_ sender: UITapGestureRecognizer) {
        
        let layoutManager = self.layoutManager
        
        // location of tap in self coordinates and taking the inset into account
        var location = sender.location(in: self)
        location.x -= self.textContainerInset.left;
        location.y -= self.textContainerInset.top;
        
        // character index at tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // if index is valid then do something.
        if characterIndex < self.textStorage.length {
            
            // print the character index
            print("character index: \(characterIndex)")
            
            // print the character at the index
            let myRange = NSRange(location: characterIndex, length: 1)
            let substring = (self.attributedText.string as NSString).substring(with: myRange)
            print("character at index: \(substring)")
            
            // check if the tap location has a certain attribute
            let attributeValue = self.attributedText.attribute(NSAttributedStringKey.init(INDEX_ATTRIBUTE), at: characterIndex, effectiveRange: nil) as? String
            if let value = attributeValue {
                print("You tapped on ayah number: \(value)")
                chageAyahColor(atIndex: AyahIndex(string: value))
            }
        }
    }
}
