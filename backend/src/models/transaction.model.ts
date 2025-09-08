import mongoose from 'mongoose';

const transactionSchema = new mongoose.Schema({
    username: { type: String, required: true },
    action: { type: String, required: true, enum: ['added', 'took'] },
    isbn: { type: String, required: true },
    bookboxId: { type: String, required: true },
    bookTitle: { type: String, required: true },
    timestamp: { type: Date, default: Date.now }
}); 

const Transaction = mongoose.model('Transaction', transactionSchema, "transactions");

export default Transaction;
