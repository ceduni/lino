"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.newErr = newErr;
exports.reinitDatabase = reinitDatabase;
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
function createAdminUser(server) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield server.inject({
                method: 'POST',
                url: '/users/register',
                payload: {
                    username: process.env.ADMIN_USERNAME,
                    password: process.env.ADMIN_PASSWORD,
                    email: process.env.ADMIN_EMAIL,
                },
            });
            const response = yield server.inject({
                method: 'POST',
                url: '/users/login',
                payload: {
                    identifier: process.env.ADMIN_USERNAME,
                    password: process.env.ADMIN_PASSWORD,
                },
            });
            return response.json().token;
        }
        catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Unknown error';
            if (errorMessage.includes('already taken')) {
                console.log('Admin user already exists.');
            }
            else {
                throw err;
            }
            return '';
        }
    });
}
function reinitDatabase(server) {
    return __awaiter(this, void 0, void 0, function* () {
        const token = yield createAdminUser(server);
        yield server.inject({
            method: 'DELETE',
            url: '/users/clear',
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        yield server.inject({
            method: 'DELETE',
            url: '/books/clear',
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        yield server.inject({
            method: 'DELETE',
            url: '/threads/clear',
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        console.log('Database reinitialized.');
        return token;
    });
}
