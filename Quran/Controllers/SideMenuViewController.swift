//
//  SideMenuViewController.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class SideMenuViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var items: [MenuItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTableView()
    }

}

//MARK: - Helpers
extension SideMenuViewController {
    
}

//MARK: - TableView
extension SideMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SideMenuTableViewCell
        cell.initWith(item: items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.closeRight()
        }else{
            goToView(withId: self.items[indexPath.row].screenId, fromController: self)
        }
    }
    
    func initTableView() {
        tableView.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        items.append(MenuItem(title: "القرآن الكريم", icon: "book", screenId: "Home"))
        items.append(MenuItem(title: "الأجزاء", icon: "list", screenId: "JuzScreen"))
        items.append(MenuItem(title: "التلاوة", icon: "more icon", screenId: ""))
        items.append(MenuItem(title: "عن التطبيق", icon: "info", screenId: ""))
        items.append(MenuItem(title: "مشاركة التطبيق", icon: "Share 2", screenId: ""))
        items.append(MenuItem(title: "علامات الفواصل", icon: "Bookmark", screenId: ""))
        
        tableView.reloadData()
    }
}