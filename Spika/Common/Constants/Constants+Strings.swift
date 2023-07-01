//
//  Constants+Strings.swift
//  Spika
//
//  Created by Vedran Vugrin on 13.12.2022..
//

import Foundation

public extension Constants {
    enum Strings : String, CaseIterable {
        // MARK: - Common
        case appName = "Spika"
        case cancel = "Cancel"
        case done = "Done"
        case next = "Next"
        case showMore = "Show more"
        case showLess = "Show less"
        case members = "Members"
        case details = "Details"
        case shared = "shared"
        case delete = "Delete"
        case edit = "Edit"
        case ok = "Ok"
        case you = "You"
        case yes = "Yes"
        
        // MARK: - CountryPickerViewController
        case search = "Search"
        case allCountries = "ALL COUNTRIES"
        
        // MARK: - EnterNumberViewController
        case couldNotAuthUser = "Could not auth user"
        case enterYourPhoneToUserSpika = "Enter your phone number to start using Spika"
        case eg98726 = "Eg. 98726123"
        case phoneNumber = "Phone number"
        case weSentYou6DigitOn = "We sent you 6 digit verification code on";
        
        // MARK: - EnterUsernameViewController
        case username = "Username"
        case enterUsername = "Enter username"
        case takeAPhoto = "Take a photo"
        case chooseFromGallery = "Choose from gallery"
        case removePhoto = "Remove photo"
        
        // MARK: - EnterVerifyCodeView
        case weSentYou6DigitCode = "We sent you 6 digit verification code."
        case resendCode = "Resend code"
        
        // MARK: - HomeViewController
        case chat = "Chat"
        case callHistory = "Call History"
        case contacts = "Contacts"
        case settings = "Settings"
        
        // MARK: - ChatDetailsViewController
        case group = "Group"
        case sharedMediaLinksDocs = "Shared Media, Links and Docs"
        case chatSearch = "Chat search"
        case notes = "Notes"
        case favorites = "Favorites"
        case pinchat = "Pin chat"
        case mute = "Mute"
        case block = "Block"
        case report = "Report"
        case admin = "Admin"
        case areYouSureYoutWantToDeleteGroup = "Are you sure you want to delete group?"
        case areYouSureYoutWantToExitGroup = "Are you sure you want to exit group?"
        case somethingWentWrongDeletingTheRoom = "Something went wrong deleting the room"
        case somethingWentWrongAddingUsers = "Something went wrong trying to add new users"
        case somethingWentWrongMutingRoom = "Something went wrong muting the room"
        case somethingWentWrongUnmutingRoom = "Something went wrong unmuting the room"
        

        // MARK: - ContactsViewController

        case youBlockedTheContact = "You blocked the contact"
        case newContact = "New contact, do you wish to continue the conversation"
        case unblock = "Unblock"
        case searchForContactsMessages = "Search for contact,message, file..."
        
        // MARK: - SharedViewController
        case media = "Media"
        case links = "Links"
        case docs = "Docs"
        
        // MARK: - UserSelectionViewController
        case selected = "selected"
        case selectUsers = "Select users"
        case searchForContact = "Search for contact"
        case searchByGroupOrContactName = "Search by group or contact name"
        
        // MARK: - MessageDetailsViewController
        case readBy = "Read by"
        case deliveredTo = "Delivered to"
        case sentTo = "Sent to"
        case waiting = "waiting"
        case senderActions = "Sender actions"
        
        // MARK: - NewGroupChatViewController
        case create = "Create"
        case peopleSelected = "people selected"
        case newGroup = "New Group"
        case groupName = "Group name..."
        
        // MARK: - AllChatsViewController
        case title = "Title"
        case noName = "noname"
        
        
        // MARK: - CurrentChatViewController
        case unknown = "Unknown"
        case today = "Today"
        
        case youAreNoLongerMember = "You are no longer a member of this group"
        
        // MARK: - SelectUsersViewController
        case newChat = "New chat"
        case newGroupChat = "New group chat"
        case newPrivateChat = "New private chat"
        
        // MARK: - DetailsViewController
        case exitGroup = "Exit group"
        case nameAndSurname = "Name and Surname"
        case favoriteMessages = "Favorite messages"
        
        // MARK: - Reactions
        case reactions = "Reactions"
        
        // MARK: - Message Actions
        case reply = "Reply"
        case forward = "Forward"
        case copy = "Copy"
        case favorite = "Favorite"
        case deleteForMe = "Delete for me"
        case deleteForEveryone = "Delete for everyone"

        // MARK: - Settings
        case privacy = "Privacy"
        case appereance = "Appereance"
        case darkMode = "Force Dark mode"
        case lightMode = "Force Light mode"
        case systemMode = "Use System mode"
        case blockedUsers = "Blocked users"
        case somethingWentWrongFetchingBlockedUsers = "Something went wrong fetching blocked users"
        case somethingWentWrongUnblockingUser = "Something went wrong unblocking the contact"
        
        // MARK: - UIImage status
        case pleaseSelectSquare = "Please select a square"
        case pleaseSelectLargerImage = "Please select a larger image"
        case selectedImageIsTooBig = "Selected image is too big"
        case unsupportedFormat = "Unsupported format"
        case allOk = "All ok."

    }
}
