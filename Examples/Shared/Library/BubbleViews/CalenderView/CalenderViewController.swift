//
//  CalenderViewController.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 7/13/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
protocol calenderSelectDelegate {
    func optionsButtonTapAction(text:String)
}
class CalenderViewController: UIViewController {

    var dataString: String!
    var messageId: String!
    var kreMessage: KREMessage!
    var selectedFromDate : String?
    var selectedToDate : String?
    var comp = NSDateComponents()
    var viewDelegate: calenderSelectDelegate?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var fromYearLabel: UILabel!
    @IBOutlet weak var fromDateLabel: UILabel!
    
    
    @IBOutlet weak var dateRangeView: UIView!
    @IBOutlet weak var dateRangeSubView: UIView!
    @IBOutlet weak var fromDateButton: UIButton!
    @IBOutlet weak var toDateButton: UIButton!
    
    @IBOutlet weak var fromDateRangeLabel: UILabel!
    @IBOutlet weak var toDateRangeLabel: UILabel!
    
    var templateType : String?
    var startdateString : String?
    var endDateString : String?
    let dateFormatter = DateFormatter()
    
    // MARK: init
       init(dataString: String, chatId: String, kreMessage: KREMessage) {
           super.init(nibName: "CalenderViewController", bundle: nil)
           self.dataString = dataString
           self.messageId = chatId
           self.kreMessage = kreMessage
       }
    
    required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        datePicker.addTarget(self, action: #selector(CalenderViewController.datePickerChanged(datePicker:)), for: UIControl.Event.valueChanged)
        dateRangeSubView.layer.cornerRadius = 5.0
        dateRangeSubView.clipsToBounds = true
        dateRangeSubView.layer.borderWidth = 1.0
        dateRangeSubView.layer.borderColor = UIColor.lightGray.cgColor
        getData()
    }

    @IBAction func clickOnCloseButton(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    func getData(){
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
            let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                                        return
            }
        
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let todayDate = dateFormatter.string(from: Date())
        
        headingLabel.text = allItems.title ?? "Please Choose"
        endDateString = allItems.endDate ?? todayDate
        templateType = allItems.template_type ?? ""
        startdateString = allItems.startDate ?? todayDate
        endDateString = allItems.endDate ?? todayDate

        let startDate = dateFormatter.date(from: startdateString!)
        let endDate = dateFormatter.date(from: endDateString!)
        print(startDate as Any)
        
        if templateType == "daterange" {
            datePickerOfMinimumMaximum(minimumdate: endDate ?? Date(), maximumDate: endDate ?? Date())
            clickOnFromDateRangeViewButton(fromDateButton as Any)
            dateRangeView.isHidden = false
        }else{
            datePickerTemplateOfMinimumMaximum(minimumdate: startDate ?? Date(), maximumDate: startDate ?? Date())
            dateRangeView.isHidden = true
            fromDateButton.isUserInteractionEnabled = false
            fromYearLabel.textAlignment = .left
            fromDateLabel.textAlignment = .left
        }
       
    }
    
    @objc func datePickerChanged(datePicker:UIDatePicker){
       selectDate(datePicker: datePicker)
    }
    func selectDate(datePicker:UIDatePicker){
        let dayOfweek = datePicker.date.dayOfWeek()! as String
        let year = datePicker.date.year()! as String
        let day = datePicker.date.day()! as String
        let monthName = datePicker.date.monthName()! as String
        
        if templateType == "daterange" {
            if fromDateButton.isSelected {
                fromDateRangeLabel.text = "Start: \(monthName) \(day), \(year)"
                selectedFromDate = datePicker.date.currentDate()! as Any as? String
            }else{
                toDateRangeLabel.text = "End: \(monthName) \(day), \(year)"
                selectedToDate = datePicker.date.currentDate()! as Any as? String
            }
        }else{
            fromYearLabel.text = year
            fromDateLabel.text = "\(dayOfweek), \(monthName) \(day)"
            selectedFromDate = datePicker.date.currentDate()! as Any as? String
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func clickOnFromDateRangeViewButton(_ sender: Any) {
        fromDateButton.isSelected = true
        toDateButton.isSelected = false
        fromDateButton.backgroundColor = UIColor.systemBlue
        toDateButton.backgroundColor = .clear
        fromDateRangeLabel.textColor = .white
        toDateRangeLabel.textColor = .black
    
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let startDate = dateFormatter.date(from: (endDateString!))
        print(startDate as Any)
        datePickerOfMinimumMaximum(minimumdate: startDate ?? Date(), maximumDate: startDate ?? Date())
    }
    
    @IBAction func clickOnToDateRangeViewButton(_ sender: Any) {
        fromDateButton.isSelected = false
        toDateButton.isSelected = true
        toDateButton.backgroundColor = UIColor.systemBlue
        fromDateButton.backgroundColor = .clear
        fromDateRangeLabel.textColor = .black
        toDateRangeLabel.textColor = .white
        
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let startDate = dateFormatter.date(from: selectedFromDate!)
        let endDate = dateFormatter.date(from: endDateString!)
        print(startDate as Any)
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: 0, to: startDate!)
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to:endDate!)
        datePicker.setDate(Date(), animated: true)
        selectDate(datePicker: datePicker)
    }
    @IBAction func clickConfirmBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if templateType == "daterange" {
            let selectedDates = ("\(selectedFromDate!) to \(selectedToDate!)")
            self.viewDelegate?.optionsButtonTapAction(text: selectedDates)
        }else{
            self.viewDelegate?.optionsButtonTapAction(text: selectedFromDate!)
        }
    }
    func datePickerOfMinimumMaximum(minimumdate: Date, maximumDate: Date){
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -10, to: minimumdate)
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: maximumDate)
        datePicker.setDate(Date(), animated: true)
        selectDate(datePicker: datePicker)
    }
    
    func datePickerTemplateOfMinimumMaximum(minimumdate: Date, maximumDate: Date){
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: 0, to: minimumdate)
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 10, to: maximumDate)
        datePicker.setDate(Date(), animated: true)
        selectDate(datePicker: datePicker)
    }
}
extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter.string(from: self).capitalized
    }
    func year() -> String? {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy"
           return dateFormatter.string(from: self).capitalized
       }
    func day() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self).capitalized
    }
    func monthName() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self).capitalized
    }
    func currentDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: self).capitalized
    }
}
