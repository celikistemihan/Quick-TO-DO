//
//  ViewController.swift
//  ShoppingList
//
//  Created by İstemihan Çelik on 25.04.2021.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

    var shoppingItems = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Shopping List"
        
        
    }
//    @IBAction func clearTapped(_ sender: Any) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return}
//        let managedContext = appDelegate.persistentContainer
//       
//        let entityNames = managedContext.managedObjectModel.entities.map({$0.name!})
//        entityNames.forEach { [weak self] entityName in
//            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Bag")
//            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
//            
//            do {
//                try managedContext.viewContext.execute(deleteRequest)
//                shoppingItems.removeAll()
//                
//                try managedContext.viewContext.save()
//                try self?.tableView.reloadData()
//                try managedContext.viewContext.save()
//
//            }
//            catch {
//                print("Cant be deleted all")
//            }
//        }
//        
//        
//    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else { return UITableViewCell() }
        cell.textLabel?.text = shoppingItems[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shoppingItems.count
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // Sola kaydırdığımızda sağ kısımda çıkacak aksiyonu soruyor. Buna Delete adını vereceğimiz bir UIContextualAction aksiyonu vereceğiz ve içinde silme fonksiyonumuzu çağıracağız.
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, UIView, (Bool) -> Void) in
            self.removeItem(listItem: self.shoppingItems[indexPath.row])
            self.shoppingItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    //sağa kaydırdığımızda solda duracak aksiyonu verecek. Buraya da Update işlemini koyacağız.
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let update = UIContextualAction(style: .normal, title: "Update") { (action, UIView, (Bool) -> Void) in
            self.updateItem(listItem: self.shoppingItems[indexPath.row])
            self.fetchItems()
            tableView.reloadData()
        }
        update.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        return UISwipeActionsConfiguration(actions: [update])
    }
    func removeItem(listItem: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bag")
        //Memory filtering yapiyo NSPredicate
        fetchRequest.predicate = NSPredicate(format: "item = %@", listItem)
        
        if let result = try? managedContext.fetch(fetchRequest) {
            for item in result {
                managedContext.delete(item)
            }
            do {
                try managedContext.save()
            } catch {
                print("Cannot be deleted \(error)")
            }
        }
    }
    func updateItem(listItem: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bag")
        fetchRequest.predicate = NSPredicate(format: "item = %@", listItem)
        
        let popup = UIAlertController(title: "Update Item", message: "Update the item on your bag", preferredStyle: .alert)
        popup.addTextField { (textField) in
            textField.placeholder = "Item"
        }
        let saveAction = UIAlertAction(title: "Add", style: .default) { (_) in
            do {
                let result = try managedContext.fetch(fetchRequest)
                let item = result[0]
                item.setValue(popup.textFields?.first?.text ?? "Error", forKey: "item")
            } catch {
                print("Cannot be updated \(error)")
            }
            self.fetchItems()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        popup.addAction(saveAction)
        popup.addAction(cancelAction)
        present(popup, animated: true)
    }
   
    func createItem(listItem: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Bag", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        
        item.setValue(listItem, forKey: "item")
        
        do {
            try managedContext.save()
        } catch {
            print("Item cannot be created \(error)")
        }
    }
    func fetchItems(){
        shoppingItems.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bag")
        
        do {
            let fetchResult = try managedContext.fetch(fetchRequest)
            for item in fetchResult as! [NSManagedObject] {
                shoppingItems.append(item.value(forKey: "item") as! String)
            }
            self.tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Add Item", message: "Time to go shopping", preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "Item"
        }
        let saveAction = UIAlertAction(title: "Add", style: .default) {_ in
            self.createItem(listItem: ac.textFields?.first?.text ?? "Error")
            self.fetchItems()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(saveAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchItems()
    }
    
}

