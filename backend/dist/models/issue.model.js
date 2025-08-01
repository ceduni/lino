"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const issueSchema = new mongoose_1.default.Schema({
    username: { type: String, required: true },
    email: { type: String, required: true },
    bookboxId: { type: String, required: true },
    subject: { type: String, required: true },
    description: { type: String, required: true },
    status: { type: String, enum: ['open', 'in_progress', 'resolved'], default: 'open' },
    reportedAt: { type: Date, default: Date.now },
    resolvedAt: { type: Date, default: null },
});
// Add indexes for faster querying
issueSchema.index({ status: 1 });
issueSchema.index({ reportedAt: -1 });
// Delete resolved issues after 7 days
issueSchema.index({ resolvedAt: 1 }, { expireAfterSeconds: 604800 });
const Issue = mongoose_1.default.model('Issue', issueSchema, "issues");
exports.default = Issue;
