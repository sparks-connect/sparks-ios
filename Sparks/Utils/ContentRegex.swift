//
//  ContentRegex.swift
//  CrossChat
//
//  Created by Mahmoud Abdurrahman on 7/11/18.
//  Copyright © 2018 Crossover. All rights reserved.
//

import Foundation

class ContentRegex {
    
    private static let URL_VALID_GTLD =
        "(?:(?:" +
            TldLists.GTLDS.joined(separator:"|") +
    ")(?=[^\\p{Alnum}@]|$))"
    
    private static let URL_VALID_CCTLD =
        "(?:(?:" +
            TldLists.CTLDS.joined(separator:"|") +
    ")(?=[^\\p{Alnum}@]|$))"
    
    private static let UNICODE_SPACES = "[" +
        "\\u0009-\\u000d" +     //  # White_Space # Cc   [5] <control-0009>..<control-000D>
        "\\u0020" +             // White_Space # Zs       SPACE
        "\\u0085" +             // White_Space # Cc       <control-0085>
        "\\u00a0" +             // White_Space # Zs       NO-BREAK SPACE
        "\\u1680" +             // White_Space # Zs       OGHAM SPACE MARK
        "\\u180E" +             // White_Space # Zs       MONGOLIAN VOWEL SEPARATOR
        "\\u2000-\\u200a" +     // # White_Space # Zs  [11] EN QUAD..HAIR SPACE
        "\\u2028" +             // White_Space # Zl       LINE SEPARATOR
        "\\u2029" +             // White_Space # Zp       PARAGRAPH SEPARATOR
        "\\u202F" +             // White_Space # Zs       NARROW NO-BREAK SPACE
        "\\u205F" +             // White_Space # Zs       MEDIUM MATHEMATICAL SPACE
        "\\u3000" +             // White_Space # Zs       IDEOGRAPHIC SPACE
    "]"
    
    private static let CYRILLIC_CHARS = "\\u0400-\\u04FF" // Cyrillic
    
    private static let LATIN_ACCENTS_CHARS =
        // Latin-1
        "\\u00c0-\\u00d6\\u00d8-\\u00f6\\u00f8-\\u00ff" +
            // Latin Extended A and B
            "\\u0100-\\u024f" +
            // IPA Extensions
            "\\u0253\\u0254\\u0256\\u0257\\u0259\\u025b\\u0263\\u0268\\u026f\\u0272\\u0289\\u028b" +
            // Hawaiian
            "\\u02bb" +
            // Combining diacritics
            "\\u0300-\\u036f" +
            // Latin Extended Additional (mostly for Vietnamese)
    "\\u1e00-\\u1eff"
    
    /* URL related hash regex collection */
    private static let URL_VALID_PRECEEDING_CHARS = "(?:[^A-Z0-9@＠$#＃\\u202A-\\u202E]|^)"
    
    private static let URL_VALID_CHARS = "[\\p{Alnum}" + LATIN_ACCENTS_CHARS + "]"
    private static let URL_VALID_SUBDOMAIN = "(?>(?:" + URL_VALID_CHARS
    + "[" + URL_VALID_CHARS + "\\-_]*)?" + URL_VALID_CHARS + "\\.)"
    private static let URL_VALID_DOMAIN_NAME = "(?:(?:" + URL_VALID_CHARS
    + "[" + URL_VALID_CHARS + "\\-]*)?" + URL_VALID_CHARS + "\\.)"
    
    /*
     * Any non-space, non-punctuation characters. \p{Z} = any kind of whitespace or invisible
     * separator.
     */
    private static let URL_VALID_UNICODE_CHARS =
    "[.[^\\p{Punct}\\s\\p{Z}\\p{InGeneralPunctuation}]]"
    private static let URL_PUNYCODE = "(?:xn--[0-9a-z]+)"
    private static let SPECIAL_URL_VALID_CCTLD =
    "(?:(?:" + "co|tv" + ")(?=[^\\p{Alnum}@]|$))"
    
    private static let URL_VALID_DOMAIN =
    "(?:" +                                                   // subdomains + domain + TLD
    URL_VALID_SUBDOMAIN + "+" + URL_VALID_DOMAIN_NAME +   // e.g. www.twitter.com, foo.co.jp, bar.co.uk
    "(?:" + URL_VALID_GTLD + "|" + URL_VALID_CCTLD + "|" + URL_PUNYCODE + ")" +
    ")" +
    "|(?:" +                                                  // domain + gTLD + some ccTLD
    URL_VALID_DOMAIN_NAME +                                 // e.g. twitter.com
    "(?:" + URL_VALID_GTLD + "|" + URL_PUNYCODE + "|" + SPECIAL_URL_VALID_CCTLD + ")" +
    ")" +
    "|(?:" + "(?<=https?://)" +
    "(?:" +
    "(?:" + URL_VALID_DOMAIN_NAME + URL_VALID_CCTLD + ")" +  // protocol + domain + ccTLD
    "|(?:" +
    URL_VALID_UNICODE_CHARS + "+\\." +                     // protocol + unicode domain + TLD
    "(?:" + URL_VALID_GTLD + "|" + URL_VALID_CCTLD + ")" +
    ")" +
    ")" +
    ")" +
    "|(?:" +                                                  // domain + ccTLD + '/'
    URL_VALID_DOMAIN_NAME + URL_VALID_CCTLD + "(?=/)" +     // e.g. t.co/
    ")"
    
    private static let URL_VALID_PORT_NUMBER = "[0-9]++"
    
    private static let URL_VALID_GENERAL_PATH_CHARS =
    "[a-z" + CYRILLIC_CHARS + "0-9!\\*':=\\+,.\\$/%#\\[\\]\\-_~\\|&@"
    + LATIN_ACCENTS_CHARS + "]"
    /*
     * Allow URL paths to contain up to two nested levels of balanced parentheses
     *  1. Used in Wikipedia URLs like /Primer_(film)
     *  2. Used in IIS sessions like /S(dfd346)/
     *  3. Used in Rdio URLs like /track/We_Up_(Album_Version_(Edited))/
     */
    private static let URL_BALANCED_PARENS =
    "\\(" +
    "(?:" +
    URL_VALID_GENERAL_PATH_CHARS + "+" +
    "|" +
    // allow one nested level of balanced parentheses
    "(?:" +
    URL_VALID_GENERAL_PATH_CHARS + "*" +
    "\\(" +
    URL_VALID_GENERAL_PATH_CHARS + "+" +
    "\\)" +
    URL_VALID_GENERAL_PATH_CHARS + "*" +
    ")" +
    ")" +
    "\\)"
    
    /** Valid end-of-path characters (so /foo. does not gobble the period).
     *   2. Allow =&# for empty URL parameters and other URL-join artifacts
     **/
    private static let URL_VALID_PATH_ENDING_CHARS = "[a-z" + CYRILLIC_CHARS
    + "0-9=_#/\\-\\+" + LATIN_ACCENTS_CHARS + "]|(?:" + URL_BALANCED_PARENS + ")"
    
    private static let URL_VALID_PATH =
    "(?:" +
    "(?:" +
    URL_VALID_GENERAL_PATH_CHARS + "*" +
    "(?:" + URL_BALANCED_PARENS + URL_VALID_GENERAL_PATH_CHARS + "*)*" +
    URL_VALID_PATH_ENDING_CHARS +
    ")" +
    "|" +
    "(?:@" +
    URL_VALID_GENERAL_PATH_CHARS +
    "+)" +
    ")"
    
    private static let URL_VALID_URL_QUERY_CHARS =
    "[a-z0-9!?\\*'\\(\\):&=\\+\\$/%#\\[\\]\\-_\\.,~\\|@]"
    private static let URL_VALID_URL_QUERY_ENDING_CHARS = "[a-z0-9_&=#/]"
    
    private static let VALID_URL_PATTERN_STRING =
    "(" +                                                      //  $1 total match
    "(" + URL_VALID_PRECEEDING_CHARS + ")" +               //  $2 Preceeding chracter
    "(" +                                                  //  $3 URL
    "(https?://)?" +                                   //  $4 Protocol (optional)
    "(" + URL_VALID_DOMAIN + ")" +                     //  $5 Domain(s)
    "(?::(" + URL_VALID_PORT_NUMBER + "))?" +          //  $6 Port number (optional)
    "(/" +
    URL_VALID_PATH + "*+" +
    ")?" +                                             //  $7 URL Path and anchor
    "(\\?" + URL_VALID_URL_QUERY_CHARS + "*" +         //  $8 Query String
    URL_VALID_URL_QUERY_ENDING_CHARS + ")?" +
    ")" +
    ")"
    
    private static let RTL_CHARS = "\\u0600-\\u06FF\\u0750-\\u077F\\u0590-\\u05FF\\uFE70-\\uFEFF"
    private static let AT_SIGNS_CHARS_MENTION = "@"
    private static let AT_SIGNS_CHARS_HASHTAG = "#"
    
    /* Begin public constants */
    public static let RTL_CHARACTERS = try! NSRegularExpression(pattern: "[" + RTL_CHARS + "]", options: [])
    
    public static let AT_SIGNS_MENTION = try! NSRegularExpression(pattern: "[" + AT_SIGNS_CHARS_MENTION + "]", options: [])
    public static let AT_SIGNS_HASHTAG = try! NSRegularExpression(pattern: "[" + AT_SIGNS_CHARS_HASHTAG + "]", options: [])
    
    /**
     * As per requirement @mention and #hashtag extractions are based on the same logic,
     * the only difference was the character itself. So the function VALID_MENTIONF will return
     * correct regular expression object based on the passed 'specialCharacter' parameter
     */
    private static func VALID_MENTIONF(for specialCharacter: String) throws -> NSRegularExpression {
        let regex = "([^a-z0-9_!#$/%&*\(specialCharacter)]|^|(?:^|[^a-z0-9_+~.-])RT:?)([\(specialCharacter)]+)([a-z0-9_]*)?"
        return try! NSRegularExpression(pattern: regex, options: .caseInsensitive)
    }
    
    public static let VALID_MENTION = try! VALID_MENTIONF(for: AT_SIGNS_CHARS_MENTION)
    public static let VALID_MENTION_GROUP_BEFORE = 1
    public static let VALID_MENTION_GROUP_AT = 2
    public static let VALID_MENTION_GROUP_USERNAME = 3
    
    public static let VALID_EMOTICON = try! NSRegularExpression(pattern: "(\\()([a-z0-9]{1,15})(\\))", options: .caseInsensitive)
    public static let VALID_EMOTICON_GROUP_LEFT_PAREN = 1
    public static let VALID_EMOTICON_GROUP_VALUE = 2
    public static let VALID_EMOTICON_GROUP_RIGHT_PAREN = 3
    
    public static let VALID_HASHTAG = try! VALID_MENTIONF(for: AT_SIGNS_CHARS_HASHTAG)
    
    /**
     * Regex to extract URL (it also includes the text preceding the url).
     *
     * This regex does not reflect its name and {@link ContentRegex#VALID_URL_GROUP_URL} match
     * should be checked in order to match a valid url. This is not ideal, but the behavior is
     * being kept to ensure backwards compatibility. Ideally this regex should be
     * implemented with a negative lookbehind as opposed to a negated character class
     * but lack of JS support increases main overhead if the logic is different by
     * platform.
     */
    
    public static let VALID_URL = try! NSRegularExpression(pattern: VALID_URL_PATTERN_STRING, options: .caseInsensitive)
    public static let VALID_URL_GROUP_ALL          = 1
    public static let VALID_URL_GROUP_BEFORE       = 2
    public static let VALID_URL_GROUP_URL          = 3
    public static let VALID_URL_GROUP_PROTOCOL     = 4
    public static let VALID_URL_GROUP_DOMAIN       = 5
    public static let VALID_URL_GROUP_PORT         = 6
    public static let VALID_URL_GROUP_PATH         = 7
    public static let VALID_URL_GROUP_QUERY_STRING = 8
    
    public static let INVALID_URL_WITHOUT_PROTOCOL_MATCH_BEGIN = try! NSRegularExpression(pattern: "[-_./]$", options: [])
    
    public static let VALID_DOMAIN = try! NSRegularExpression(pattern: URL_VALID_DOMAIN, options: .caseInsensitive)
    
}
