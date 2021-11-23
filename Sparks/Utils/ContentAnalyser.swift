//
//  ContentAnalyser.swift
//  CrossChat
//
//  Created by Mahmoud Abdurrahman on 7/11/18.
//  Copyright © 2018 Crossover. All rights reserved.
//

import Foundation

enum ContentEntityType: String, Codable {
    case mention
    case emoticon
    case url
    case hashtag
}

struct ContentEntity: Codable {
    var start: Int
    var end: Int
    var value: String
    var type: ContentEntityType
}

class ContentAnalyser {
    
    /**
     * Extract @mentions, {emoticons}, and URLs from a given message text.
     * @param text text of message
     * @return list of extracted entities values
     */
    static func extractEntities(from text: String?) throws -> [String] {
        let entities = try? extractEntitiesWithIndices(from: text)
        
        return entities?.map { $0.value } ?? []
    }
    
    /**
     * Extract @mentions, {emoticons}, and URLs from a given message text.
     * @param text text of message
     * @return list of extracted entities
     */
    static func extractEntitiesWithIndices(from text: String?) throws -> [ContentEntity] {
        var entities = [ContentEntity]()
        
        do {
            try entities.append(contentsOf: extractMentionsWithIndices(from: text))
            try entities.append(contentsOf: extractEmoticonsWithIndices(from: text))
            try entities.append(contentsOf: extractURLsWithIndices(from: text))
            try entities.append(contentsOf: extractHashtagsWithIndices(from: text))
        } catch let error {
            throw error
        }
        
        return entities.removeOverlapping()
    }
    
    /**
     * Extract @mention references from a given text. A mention is an occurrence
     * of @mention anywhere in a message text.
     *
     * @param text of the message from which to extract mentions
     * @return List of mentions referenced (without the leading @ sign)
     */
    static func extractMentions(from text: String?) throws -> [String] {
        guard let text = text else {
            return []
        }
        let entities = try? extractMentionsWithIndices(from: text)
        
        return entities?.map { $0.value } ?? []
    }
    
    /**
     * Extract @mention references from a given text. A mention is an occurrence of
     * @mention anywhere in a message text.
     *
     * @param text of the message from which to extract mentions
     * @return List of {@link ContentEntity} of type {@link ContentEntityType}, having
     * info about start index, end index, and value of the referenced mention (without the leading
     * @ sign)
     */
    static func extractMentionsWithIndices(from text: String?) throws -> [ContentEntity] {
        return try extractMentionsWithIndices(from: text, with: "@", regex: ContentRegex.VALID_MENTION, contentEntityType: .mention)
    }
    
    /**
     * Extract #hashtag references from a given text. A hashtag is an occurrence
     * of #hashtag anywhere in a message text.
     *
     * @param text of the message from which to extract hashtag
     * @return List of hashtags referenced (without the leading # sign)
     */
    static func extractHashtags(from text: String?) throws -> [String] {
        guard let text = text else {
            return []
        }
        let entities = try? extractHashtagsWithIndices(from: text)
        
        return entities?.map { $0.value } ?? []
    }
    
    /**
     * Extract #hashtag references from a given text. A hashtag is an occurrence of
     * @hashtag anywhere in a message text.
     *
     * @param text of the message from which to extract hashtag
     * @return List of {@link ContentEntity} of type {@link ContentEntityType}, having
     * info about start index, end index, and value of the referenced hashtag (without the leading
     * # sign)
     */
    static func extractHashtagsWithIndices(from text: String?) throws -> [ContentEntity] {
        return try extractMentionsWithIndices(from: text, with: "#", regex: ContentRegex.VALID_HASHTAG, contentEntityType: .hashtag)
    }
    
    /**
     * Extract @mention references from a given text. A mention is an occurrence of
     * @mention anywhere in a message text.
     *
     * @param text of the message from which to extract mentions
     * @param mentionCharacter can be @ (mention) or # (Hashtag) as the extraction logic is exactly the same
     * @return List of {@link ContentEntity} of type {@link ContentEntityType}, having
     * info about start index, end index, and value of the referenced mention (without the leading
     * @ sign)
     */
    static func extractMentionsWithIndices(from text: String?,
                                           with mentionCharacter: String,
                                           regex: NSRegularExpression,
                                           contentEntityType: ContentEntityType) throws -> [ContentEntity] {
        guard let text = text else {
            return []
        }
        
        // Performance optimization.
        // If text doesn't contain mentionCharacter at all, the text doesn't
        // contain mention. So we can simply return an empty list.
        if (text.isEmpty || !text.contains(mentionCharacter)) {
            return []
        }
        var extracted = [ContentEntity]()
        let matches = regex.matches(in: text, range: NSMakeRange(0, text.utf16.count))
        for match in matches {
            if (match.numberOfRanges < ContentRegex.VALID_MENTION_GROUP_USERNAME + 1) {
                continue
            }
            
            // Getting mentioned username
            let usernameRange = match.range(at: ContentRegex.VALID_MENTION_GROUP_USERNAME)
            if usernameRange.location == NSNotFound {
                continue
            }

            let usernameStart = String.Index(utf16Offset: usernameRange.lowerBound, in : text)
            let usernameEnd = String.Index(utf16Offset: usernameRange.upperBound, in: text)

            let username = String(text.utf16[usernameStart..<usernameEnd])!
            if username == "" { // Empty string is returned when @ or # is followed by space
                continue
            }
            
            // Getting the full pattern start/end
            let atCharacterRange = match.range(at: ContentRegex.VALID_MENTION_GROUP_AT)

            let start = String.Index(utf16Offset: atCharacterRange.lowerBound, in : text)
            let end = String.Index(utf16Offset: atCharacterRange.upperBound, in: text)

            let mentionEntity = ContentEntity(start: start.utf16Offset(in: text), end: end.utf16Offset(in: text), value: username, type: contentEntityType)
            extracted.append(mentionEntity)
        }
        
        return extracted
    }
    
    /**
     * Extract (emoticons) references from a given text. An emoticon is an occurrence of (emoticon)
     * anywhere in a message text.
     *
     * @param text of the message from which to extract emoticons
     * @return List of emoticons referenced (without the wrapping () parentheses)
     */
    static func extractEmoticons(from text: String?) throws -> [String] {
        guard let text = text else {
            return []
        }
        let entities = try? extractEmoticonsWithIndices(from: text)
        
        return entities?.map { $0.value } ?? []
    }
    
    /**
     * Extract (emoticons) references from a given text. An emoticon is an occurrence of (emoticon)
     * anywhere in a message text.
     *
     * @param text of the message from which to extract emoticons
     * @return List of {@link ContentEntity} of type {@link ContentEntity.Type#EMOTICON}, having
     * info about start index, end index, and value of the referenced emoticon (without the wrapping
     * () parentheses)
     */
    static func extractEmoticonsWithIndices(from text: String?) throws -> [ContentEntity] {
        guard let text = text else {
            return []
        }
    
        // Performance optimization.
        // If text doesn't contain both ( and ) at all, the text doesn't
        // contain (emoticon). So we can simply return an empty list.
        if (text.isEmpty || !text.contains("(") || !text.contains(")")) {
            return []
        }
    
        var extracted = [ContentEntity]()
        let matches = ContentRegex.VALID_EMOTICON.matches(in: text,
                                                         range: NSMakeRange(0, text.utf16.count))
        for match in matches {
            if (match.numberOfRanges < ContentRegex.VALID_EMOTICON_GROUP_RIGHT_PAREN + 1) {
                continue
            }
            
            let emoticonRange = match.range(at: ContentRegex.VALID_EMOTICON_GROUP_VALUE)
            let leftParenRange = match.range(at: ContentRegex.VALID_EMOTICON_GROUP_LEFT_PAREN)
            let rightParenRange = match.range(at: ContentRegex.VALID_EMOTICON_GROUP_RIGHT_PAREN)

            let emoticonStart = String.Index(utf16Offset: emoticonRange.lowerBound, in : text)
            let emoticonEnd = String.Index(utf16Offset: emoticonRange.upperBound, in: text)

            let start = String.Index(utf16Offset: leftParenRange.lowerBound, in : text)
            let end = String.Index(utf16Offset: rightParenRange.upperBound, in: text)

            let emoticon = String(text.utf16[emoticonStart..<emoticonEnd])!
            
            let emoticonEntity = ContentEntity(start: start.utf16Offset(in: text), end: end.utf16Offset(in: text), value: emoticon, type: .emoticon)
            extracted.append(emoticonEntity)
        }
        
        return extracted
    }
    
    /**
     * Extract URL references from a given text.
     *
     * @param text of the message from which to extract URLs
     * @return List of URLs referenced.
     */
    static func extractURLs(from text: String?) throws -> [String] {
        guard let text = text else {
            return []
        }
        let entities = try? extractURLsWithIndices(from: text)
        
        return entities?.map { $0.value } ?? []
    }
    
    /**
     * Extract URL references from a given text.
     *
     * @param text of the message from which to extract URLs
     * @return List of {@link ContentEntity} of type {@link ContentEntity.Type#URL}, having info
     *  about start index, end index, and value of the referenced URL
     */
    class func extractURLsWithIndices(from text: String?) throws -> [ContentEntity] {
        guard let text = text else {
            return []
        }

        // Performance optimization.
        // If text doesn't contain '.' at all, text doesn't contain URL,
        // so we can simply return an empty list.
        if (text.isEmpty || !text.contains(".")) {
            return []
        }

        var extracted = [ContentEntity]()
        let matches = ContentRegex.VALID_URL.matches(in: text,
                                                     range: NSMakeRange(0, text.utf16.count))

        for match in matches {
            // skip if URL has no protocol and is preceded by invalid character.
            let protocolRange = match.range(at: ContentRegex.VALID_URL_GROUP_PROTOCOL)
            if protocolRange.location == NSNotFound {
                let beforeUrlRange = match.range(at: ContentRegex.VALID_URL_GROUP_BEFORE)

                let beforeUrlStart = String.Index(utf16Offset: beforeUrlRange.lowerBound, in: text)
                let beforeUrlEnd = String.Index(utf16Offset: beforeUrlRange.upperBound, in: text)

                let beforeUrl = String(text.utf16[beforeUrlStart..<beforeUrlEnd])!
                let invalidUrlBeginMatches = ContentRegex.INVALID_URL_WITHOUT_PROTOCOL_MATCH_BEGIN.matches(in: beforeUrl,
                                                                                                           range: NSMakeRange(0, beforeUrl.utf16.count))
                if invalidUrlBeginMatches.count > 0 {
                    continue
                }
            }

            let urlRange = match.range(at: ContentRegex.VALID_URL_GROUP_URL)

            let start = String.Index(utf16Offset: urlRange.lowerBound, in : text)
            let end = String.Index(utf16Offset: urlRange.upperBound, in: text)

            let url = String(text.utf16[start..<end])!

            let urlEntity = ContentEntity(start: start.utf16Offset(in: text), end: end.utf16Offset(in: text), value: url, type: .url)
            extracted.append(urlEntity)
        }

        return extracted
    }
}

extension Array where Iterator.Element == ContentEntity {
    func removeOverlapping() -> [Element] {
        // if source array is empty or only has single element, then nothing to remove,
        // we just return self
        if (isEmpty || count == 1) {
            return self
        }
        
        // sort by start index asc
        let sorted = self.sorted {
            return $0.start < $1.start
        }
        
        // Remove overlapping entities.
        // Two entities overlap only when one is URL and the other is mention/emoticon
        // which is a part of the URL. When it happens, we choose URL over mention/emoticon
        // by selecting the one with smaller start index.
        var results = [ContentEntity]()
        
        var prev: ContentEntity?
        for (i, curr) in sorted.enumerated() {
            if i > 0 && prev?.end ?? -1 > curr.start {
                prev = curr
                continue
            }
            
            prev = curr
            results.append(curr)
        }
        
        return results
    }
}
