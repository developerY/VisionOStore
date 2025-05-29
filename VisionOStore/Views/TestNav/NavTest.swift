//
//  NavTest.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/28/25.
//
import SwiftUI


struct PersonRowView: View {
    var person: Person


    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(person.name)
                .foregroundColor(.primary)
                .font(.headline)
            HStack(spacing: 3) {
                Label(person.phoneNumber, systemImage: "phone")
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
        }
    }
}


struct StaffList: View {
    var body: some View {
        List {
            ForEach(staff) { person in
                PersonRowView(person: person)
            }
        }
    }
}

struct PersonDetailView: View {
    var person: Person


    var body: some View {
        VStack {
            Text(person.name)
                .foregroundColor(.primary)
                .font(.title)
                .padding()
            HStack {
                Label(person.phoneNumber, systemImage: "phone")
            }
            .foregroundColor(.secondary)
        }
    }
}



struct NavTestView: View {
    var body: some View {
        
        NavigationView {
            List {
                ForEach(company.departments) { department in
                    Section(header: Text(department.name)) {
                        ForEach(department.staff) { person in
                            NavigationLink(destination: PersonDetailView(person: person)) {
                                PersonRowView(person: person)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Staff Directory")
            
            
            // Placeholder
            Text("No Selection")
                .font(.headline)
        }
        
        
    }
        
        
        
}

#Preview(windowStyle: .automatic) {
    NavTestView()
        //.environment(AppModel())
}
