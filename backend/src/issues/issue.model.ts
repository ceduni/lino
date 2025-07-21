import mongoose from 'mongoose';

const issueSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    bookboxId: { type: String, required: true },
    subject: { type: String, required: true },
    description: { type: String, required: true },
    status: { type: String, enum: ['open', 'in_progress', 'resolved'], default: 'open' },
    reportedAt: { type: Date, default: Date.now },
    resolvedAt: { type: Date, default: null },
});

// Add indexes for faster querying
issueSchema.index({ username: 1, bookboxId: 1 }, { unique: true });
issueSchema.index({ status: 1 });
issueSchema.index({ reportedAt: -1 }); 

// Delete resolved issues after 7 days
issueSchema.index({ resolvedAt: 1 }, { expireAfterSeconds: 604800 });

const Issue = mongoose.model('Issue', issueSchema, "issues");

export default Issue;
