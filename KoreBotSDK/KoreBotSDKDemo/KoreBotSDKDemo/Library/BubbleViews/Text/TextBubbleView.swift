//
//  TextBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import KoreTextParser

class TextBubbleView : BubbleView {
    var onChange: ((_ reload: Bool) -> ())!
    func kTextColor() -> UIColor {
        return (self.tailPosition == BubbleMaskTailPosition.left ? Common.UIColorRGB(0x484848) : Common.UIColorRGB(0xFFFFFF))
    }
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    var textLabel: KREAttributedLabel!
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.textLabel.textColor = self.kTextColor()
        }
    }
    
    override func initialize() {
        super.initialize()
        
        self.textLabel = KREAttributedLabel(frame: CGRect.zero)
        self.textLabel.textColor = Common.UIColorRGB(0x444444)
        self.textLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.contentMode = UIViewContentMode.topLeft
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.imageDetectionBlock = {[weak self] (reload) in
            self?.onChange(reload)
        }

        self.addSubview(self.textLabel)
        
        let views: [String: UIView] = ["textLabel": textLabel]
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[textLabel]-10-|", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel(>=textLabelMinWidth,<=textLabelMaxWidth)]-10-|", options: [], metrics: metrics, views: views))
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            
            if ((component.componentDesc) != nil) {
                let string: String = component.componentDesc! as String
                let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        let textSize: CGSize = self.textLabel.sizeThatFits(limitingSize)
        return CGSize(width: textSize.width + 20, height: textSize.height + 20)
    }
}

class QuickReplyBubbleView : TextBubbleView {
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }

            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary

                let string: String = jsonObject["text"] as! String
                let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
            }
        }
    }
}

class ErrorBubbleView : TextBubbleView {
    var textColor: UIColor = Common.UIColorRGB(0x484848)
    
    override func kTextColor() -> UIColor {
        return textColor
    }
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                
                let string: String = jsonObject["text"] as! String
                let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                
                if var colorString: String = jsonObject["color"] as? String {
                    if(colorString.hasPrefix("#")){
                        colorString = String(colorString.characters.dropFirst())
                    }
                    self.textColor = Common.UIColorRGB(Int(colorString, radix: 16)!)
                }
            }
        }
    }
}
