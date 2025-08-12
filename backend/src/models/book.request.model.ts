import mongoose from "mongoose";

const requestSchema = new mongoose.Schema({
    username: { type : String, required : true },
    bookTitle: { type : String, required : true },
    timestamp: { type : Date, default : Date.now },
    upvoters: { type : [String], default : [] }, // List of users who upvoted the request
    nbPeopleNotified: { type : Number, default : 0 }, 
    bookboxIds: { type : [String], default : [] },
    customMessage: { type : String },
    isSolved: { type : Boolean, default : false }
});

const Request = mongoose.model('Request', requestSchema, "requests");

export default Request;