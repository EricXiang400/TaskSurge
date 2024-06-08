//
//  NoSeperatorList.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 8/2/23.
//

import Foundation
import SwiftUI
struct NoSeparatorList: UIViewRepresentable {
    typealias UIViewType = UITableView
    
    var data: [String]
    var onDelete: ((Int) -> Void)?

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .none
        return tableView
    }

    func updateUIView(_ uiView: UITableView, context: Context) {
        uiView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITableViewDelegate, UITableViewDataSource {
        var parent: NoSeparatorList
        
        init(_ parent: NoSeparatorList) {
            self.parent = parent
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parent.data.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = parent.data[indexPath.row]
            return cell
        }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                parent.onDelete?(indexPath.row)
            }
        }
    }
}
