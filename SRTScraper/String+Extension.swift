//
//  String+Extension.swift
//  SRTScraper
//
//  Created by Shibo Tong on 13/8/2023.
//

import Foundation

extension String {
    // Function to calculate the
    // Jaro Similarity of two strings
    func distance(_ text: String) -> Double {
        // If the strings are equal
        //if s1 == s2 {
        //    return 1.0
        //}
        
        // Length of two strings
        let len1 = self.count,
            len2 = text.count
        //
        if len1 == 0 || len2 == 0 {
            return 0.0
        }
        
        // Maximum distance upto which matching
        // is allowed
        let maxDist = max(len1, len2) / 2 - 1
        
        // Count of matches
        var match = 0
        
        // Hash for matches
        var hashS1: [Int] = Array(repeating: 0, count: self.count)
        var hashS2: [Int] = Array(repeating: 0, count: text.count)
        
        let s2Array = Array(text)
        // Traverse through the first string
        for (i, ch1) in self.enumerated() {
            
            // Check if there is any matches
            if max(0, i - maxDist) > min(len2 - 1, i + maxDist) {
                continue
            }
            for j in max(0, i - maxDist)...min(len2 - 1, i + maxDist) {
                
                // If there is a match
                if ch1 == s2Array[j] &&
                    hashS2[j] == 0 {
                    hashS1[i] = 1
                    hashS2[j] = 1
                    match += 1
                    break
                }
            }
        }
        
        // If there is no match
        if match == 0 {
            return 0.0
        }
        
        // Number of transpositions
        var t: Double = 0
        
        var point = 0
        
        // Count number of occurances
        // where two characters match but
        // there is a third matched character
        // in between the indices
        for (i, ch1) in self.enumerated() {
            if hashS1[i] == 1 {
                
                // Find the next matched character
                // in second string
                while hashS2[point] == 0 {
                    point += 1
                }
                
                if ch1 != s2Array[point] {
                    t += 1
                }
                point += 1
            }
        }
        t /= 2
        print(self.count, text.count, match, t)
        
        // Return the Jaro Similarity
        return (Double(match) / Double(len1)
                    + Double(match) / Double(len2)
                    + (Double(match) - t) / Double(match))
            / 3.0
    }
}
