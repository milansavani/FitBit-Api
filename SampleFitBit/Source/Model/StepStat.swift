//
//  StepStat.swift
//  SampleFitBit
//
//  Created by mobiiworld on 27/06/19.
//  Copyright © 2019 mobiiworld. All rights reserved.
//
import Foundation

extension String {
    func date(withFormat format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    func dateComponents(withFormat format: String = "yyyy-MM-dd", components: Set<Calendar.Component> = [.day, .month, .year]) -> DateComponents? {
        return self.date(withFormat: format)?.dateComponents(components: components)
    }
}

extension Date {
    func dateComponents(components: Set<Calendar.Component> = [.day, .month, .year]) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents(components, from: self)
    }
    
    func dateString(withFormat format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}


struct StepStat {

	let day: DateComponents
	let steps: UInt
	
	init?(withJSON json: String) {
		guard let jsonData = json.data(using: .utf8) else {
			return nil
		}
		self.init(withJSON: jsonData)
	}
	
	init?(withJSON jsonData: Data) {
		guard let data = (try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)) as? [String: Any] else {
			return nil
		}
		self.init(withDictionary: data)
	}
	
	init?(withDictionary data: [String: Any]) {
		guard let dateTime = data["dateTime"] as? String,
			let dateComponents = dateTime.dateComponents() else {
				return nil
		}
		
		guard let stepCount = (data["value"] as? NSNumber)?.uintValue ?? UInt((data["value"] as? String) ?? "") else {
			return nil
		}
		
		day = dateComponents
		steps = stepCount
	}

}
