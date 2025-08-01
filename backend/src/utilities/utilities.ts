
class CustomError extends Error {
    public statusCode: number;
    constructor(message : string, statusCode : number   ) {
        super(message);
        this.statusCode = statusCode;
        Error.captureStackTrace(this, this.constructor);
    }
}

export function newErr(statusCode: number, message: string): CustomError {
    return new CustomError(message, statusCode);
}

