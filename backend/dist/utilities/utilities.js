"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.newErr = newErr;
exports.levenshteinDistance = levenshteinDistance;
exports.calculateSimilarity = calculateSimilarity;
exports.isFuzzyMatch = isFuzzyMatch;
class CustomError extends Error {
    constructor(message, statusCode) {
        super(message);
        this.statusCode = statusCode;
        Error.captureStackTrace(this, this.constructor);
    }
}
function newErr(statusCode, message) {
    return new CustomError(message, statusCode);
}
// Levenshtein distance algorithm for fuzzy string matching
function levenshteinDistance(str1, str2) {
    const matrix = [];
    // Create matrix
    for (let i = 0; i <= str2.length; i++) {
        matrix[i] = [i];
    }
    for (let j = 0; j <= str1.length; j++) {
        matrix[0][j] = j;
    }
    // Fill matrix
    for (let i = 1; i <= str2.length; i++) {
        for (let j = 1; j <= str1.length; j++) {
            if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
                matrix[i][j] = matrix[i - 1][j - 1];
            }
            else {
                matrix[i][j] = Math.min(matrix[i - 1][j - 1] + 1, // substitution
                matrix[i][j - 1] + 1, // insertion
                matrix[i - 1][j] + 1 // deletion
                );
            }
        }
    }
    return matrix[str2.length][str1.length];
}
// Calculate similarity ratio between two strings (0-1, where 1 is identical)
function calculateSimilarity(str1, str2) {
    const normalizedStr1 = str1.toLowerCase().trim();
    const normalizedStr2 = str2.toLowerCase().trim();
    if (normalizedStr1 === normalizedStr2)
        return 1;
    const maxLength = Math.max(normalizedStr1.length, normalizedStr2.length);
    if (maxLength === 0)
        return 1;
    const distance = levenshteinDistance(normalizedStr1, normalizedStr2);
    return (maxLength - distance) / maxLength;
}
// Check if two book titles are similar enough (fuzzy match)
function isFuzzyMatch(bookTitle1, bookTitle2, threshold = 0.8) {
    return calculateSimilarity(bookTitle1, bookTitle2) >= threshold;
}
