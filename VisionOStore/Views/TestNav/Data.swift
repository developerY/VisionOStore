//
//  Data.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/28/25.
//
import Foundation
struct Person: Identifiable {
     let id = UUID()
     var name: String
     var phoneNumber: String
 }


var staff = [
    Person(name: "Juan Chavez", phoneNumber: "(408) 555-4301"),
    Person(name: "Mei Chen", phoneNumber: "(919) 555-2481")
]


struct Department: Identifiable {
    let id = UUID()
    var name: String
    var staff: [Person]
}


struct Company {
    var departments: [Department]
}


var company = Company(departments: [
    Department(name: "Sales", staff: [
        Person(name: "Juan Chavez", phoneNumber: "(408) 555-4301"),
        Person(name: "Mei Chen", phoneNumber: "(919) 555-2481"),
        // ...
    ]),
    Department(name: "Engineering", staff: [
        Person(name: "Bill James", phoneNumber: "(408) 555-4450"),
        Person(name: "Anne Johnson", phoneNumber: "(417) 555-9311"),
        // ...
    ]),
    // ...
])
