//
//  WallGalleryTableViewController.swift
//  Wall
//
//  Created by Nicolai Garcia on 11/27/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import UIKit

class WallGalleryTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate,
    WallGalleryTableViewCellDelegate, WallViewControllerDelegate {
    
    func saveWall(wall: Wall, at index: Int) {
        wallGallery.walls[index] = wall
        saveWallGalleryDocument()
    }
    
    func saveWallGalleryDocument() {
        document?.wallGallery = wallGallery
        document?.save(to: documentURL!, for: .forOverwriting, completionHandler: nil)
    }
    
    @IBAction func addWall(_ sender: Any) {
        performSegue(withIdentifier: "popoverSegue", sender: sender)
        /*
        var wall = Wall()
        wall.name = "NEW WALL"
        wallGallery.walls.append(wall)
        saveWallGalleryDocument()
        tableView.reloadData()
 */
    }
    
    var document: WallGalleryDocument?
    var documentURL: URL?
    var ubiquityURL: URL?
    var metaDataQuery: NSMetadataQuery?
    
    var wallGallery: WallGallery = WallGallery()
    
    var selectedWall: Wall?
    
    func openDocument(query: NSMetadataQuery) {
        if query.resultCount == 1 {
            if let resultURL = query.value(ofAttribute: NSMetadataItemURLKey,
                                           forResultAt: 0) as? URL {
                document = WallGalleryDocument(fileURL: resultURL)
                document?.open(completionHandler: { (success) in
                    if success {
                        print("iCloud File Open Ok!")
                        self.wallGallery = (self.document?.wallGallery)!
                        self.ubiquityURL = resultURL
                    } else {
                        print("iCloud File Open Failed!")
                    }
                })
            }
        } else {
            document = WallGalleryDocument(fileURL: ubiquityURL!)
            
            document?.save(to: ubiquityURL!,
                        for: .forCreating,
                        completionHandler: { success in
                            if success {
                                print("iCloud create ok")
                            } else {
                                print("iCloud create failed")
                            }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileManager = FileManager.default
        
        let dirPaths = fileManager.urls(for: .documentDirectory,
                                        in: .userDomainMask)
        documentURL = dirPaths[0].appendingPathComponent(WallGalleryTableViewController.constants.fileName)
        document = WallGalleryDocument(fileURL: documentURL!)
        
        if fileManager.fileExists(atPath: (documentURL?.path)!) {
            document?.open(completionHandler: { (success) in
                if success {
                    self.wallGallery = (self.document?.wallGallery)!
                    self.tableView.reloadData()
                }
            })
        } else {
            document?.save(to: documentURL!, for: .forCreating, completionHandler: nil)
        }
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        self.tableView.rowHeight = self.view.frame.size.height/WallGalleryTableViewController.constants.heightDivider
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallGallery.walls.count
    }
    
    func fetchImage(imageURL: URL) -> UIImage? {
        do {
            let contents = try Data(contentsOf: imageURL)
            return UIImage(data: contents)
        } catch {
            return nil
        }
    }
    
    func findHeader(wall: Wall) -> UIImage {
        let voidImage = UIImage()
        for post in wall.posts {
            if post.data != nil {
                return UIImage(data: post.data!) ?? voidImage
            } else if post.url != nil {
                let image = fetchImage(imageURL: post.url!)
                return image ?? voidImage
            }
        }
        return voidImage
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wall = wallGallery.walls[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "wallGalleryCell", for: indexPath)

        if let wallCell = cell as? WallGalleryTableViewCell {
            wallCell.delegate = self
            wallCell.headerImage.image = findHeader(wall: wall)
            wallCell.textField.text = wall.name
            wallCell.textView.text = wall.description
        }

        return cell
    }

    // Override to support editing the table.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            wallGallery.walls.remove(at: indexPath.row)
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
            saveWallGalleryDocument()
        }
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let wallView = segue.destination as? WallViewController {
            wallView.wall = selectedWall
            wallView.delegate = self
        } else if let popMenuViewController = segue.destination as? PopMenuTableViewController {
            popMenuViewController.modalPresentationStyle = .popover
            popMenuViewController.popoverPresentationController?.delegate = self
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - Table View Cell Delegate Methods
    
    func longPress(longPressDelegatedFrom cell: WallGalleryTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        cell.resignationHandler = { [weak self, unowned cell] in
            if let updatedName = cell.textField.text {
                self?.wallGallery.walls[(indexPath?.row)!].name = updatedName
                self?.saveWallGalleryDocument()
            }
        }
    }
    
    func tap(tapDelegatedFrom cell: WallGalleryTableViewCell) {
        if let index = tableView.indexPath(for: cell)?.row {
            selectedWall = wallGallery.walls[index]
            selectedWall!.wallIndex = index
            performSegue(withIdentifier: "showWall", sender: self)
        }
    }
    
    func descriptionEdited(descriptionEditedOn cell: WallGalleryTableViewCell) {
        if let index = tableView.indexPath(for: cell)?.row {
            wallGallery.walls[index].description = cell.textView.text
            saveWall(wall: wallGallery.walls[index], at: index)
        }
    }

}

extension WallGalleryTableViewController {
    private struct constants {
        static let fileName: String = "wallgalleryfile.json"
        static let heightDivider: CGFloat = 2.5
    }
}

