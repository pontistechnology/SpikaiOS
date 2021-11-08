//
//  CountryPickerViewController.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import UIKit

protocol CountryPickerViewDelegate: AnyObject {
    func countryPickerViewDelegate(_ countryPickerViewController: CountryPickerViewController, didSelectCountry country: Country)
}

class CountryPickerViewController: BaseViewController {
    
    let countryPickerView = CountryPickerView()
    var viewModel: CountryPickerViewModel!
    weak var delegate: CountryPickerViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(countryPickerView)
        setupBindings()
    }
    
    override func setupView(_ view: UIView) {
        super.setupView(view)
        countryPickerView.countriesTableView.delegate = self
        countryPickerView.countriesTableView.dataSource = self
        countryPickerView.searchBar.delegate = self
    }
    
    func setupBindings() {
        countryPickerView.cancelButton.tap().sink { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }.store(in: &subscriptions)
    }
    
}

extension CountryPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countryPickerView.filteredCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryTableViewCell.cellIdentifier, for: indexPath) as! CountryTableViewCell
        cell.setup(with: countryPickerView.filteredCountries[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.countryPickerViewDelegate(self, didSelectCountry: countryPickerView.filteredCountries[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension CountryPickerViewController: SearchBarDelegate {
    func searchBar(_ searchBar: SearchBar, valueDidChange value: String?) {
        if let value = value {
            countryPickerView.filterCountries(filter: value) 
        }
    }
    
    func searchBar(_ searchBar: SearchBar, didPressCancel value: Bool) {
        
    }
    
}
