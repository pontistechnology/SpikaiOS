//
//  Constants+Strings.swift
//  Spika
//
//  Created by Vedran Vugrin on 13.12.2022..
//

import Foundation

public extension Constants {
    enum Strings : String {
        //MARK: - Common
        case appName = "Spika"
        case cancel = "Cancel"
        case next = "Next"
        case showMore = "Show more"
        case showLess = "Show less"
        case members = "Members"
        case details = "Details"
        case shared = "shared"
        

        //MARK: - CountryPickerViewController
        case search = "Search"
        case allCountries = "ALL COUNTRIES"
        
        //MARK: - EnterNumberViewController
        case couldNotAuthUser = "Could not auth user"
        case enterYourPhoneToUserSpika = "Enter your phone number to start using Spika"
        case eg98726 = "Eg. 98726123"
        case phoneNumber = "Phone number"
        
        //MARK: - EnterUsernameViewController
        case username = "Username"
        case enterUsername = "Enter username"
        case takeAPhoto = "Take a photo"
        case chooseFromHallery = "Choose from gallery"
        case removePhoto = "Remove photo"
        case pleaseUserBetterQuality = "Please use better quality."
        case pleaseSelectASquare = "Please select a square"
        
        //MARK: - EnterVerifyCodeView
        case weSentYou6DigitCode = "We sent you 6 digit verification code."
        case resendCode = "Resend code"
        
        //MARK: - HomeViewController
        case chat = "Chat"
        case callHistory = "Call History"
        case contacts = "Contacts"
        case settings = "Settings"
        
        //MARK: - ChatDetailsViewController
        case group = "Group"
        case sharedMediaLinksDocs = "Shared Media, Links and Docs"
        case chatSearch = "Chat search"
        case notes = "Notes"
        case favorites = "Favorites"
        case pinchat = "Pin chat"
        case mute = "Mute"
        case block = "Block"
        case report = "Report"
        
        //MARK: - ContactsViewController
        case searchForContactsMessages = "Search for contact,message, file..."
        
        //MARK: - SharedViewController
        case media = "Media"
        case links = "Links"
        case docs = "Docs"
    }
}
