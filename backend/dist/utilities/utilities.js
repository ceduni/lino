"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.newErr = newErr;
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
