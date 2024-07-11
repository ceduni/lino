import mongoose from "mongoose";

const requestSchema = new mongoose.Schema({
    username: { type : String, required : true },
    bookTitle: { type : String, required : true },
    timestamp: { type : Date, default : Date.now },
    customMessage: { type : String},
    isFulfilled: { type : Boolean, default : false }
});

// Create a text index on the bookTitle field
requestSchema.index({ bookTitle: 'text' });

const Request = mongoose.model('Request', requestSchema, "requests");

export default Request;