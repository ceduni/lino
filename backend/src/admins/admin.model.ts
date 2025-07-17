import mongoose from 'mongoose';

const adminSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    createdAt: { type: Date, default: Date.now },
});

const Admin = mongoose.model('Admin', adminSchema, "admins");

export default Admin;
