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
const utilities_1 = require("../utilities/utilities");
const models_1 = require("../models");
const IssueService = {
    createIssue(_a) {
        return __awaiter(this, arguments, void 0, function* ({ username, email, bookboxId, subject, description }) {
            const issue = new models_1.Issue({
                username,
                email,
                bookboxId,
                subject,
                description
            });
            yield issue.save();
            // Increment the number of issues reported by the user
            const user = yield models_1.User.findOne({ email });
            if (user) {
                user.numIssuesReported += 1;
                yield user.save();
            }
            return issue;
        });
    },
    getIssue(issueId) {
        return __awaiter(this, void 0, void 0, function* () {
            const issue = yield models_1.Issue.findById(issueId);
            if (!issue) {
                throw (0, utilities_1.newErr)(404, 'Issue not found');
            }
            return issue;
        });
    },
    investigateIssue(issueId) {
        return __awaiter(this, void 0, void 0, function* () {
            const issue = yield models_1.Issue.findById(issueId);
            if (!issue) {
                throw (0, utilities_1.newErr)(404, 'Issue not found');
            }
            issue.status = 'in_progress';
            yield issue.save();
            return issue;
        });
    },
    closeIssue(issueId) {
        return __awaiter(this, void 0, void 0, function* () {
            const issue = yield models_1.Issue.findById(issueId);
            if (!issue) {
                throw (0, utilities_1.newErr)(404, 'Issue not found');
            }
            issue.status = 'resolved';
            issue.resolvedAt = new Date();
            yield issue.save();
            return issue;
        });
    },
    reopenIssue(issueId) {
        return __awaiter(this, void 0, void 0, function* () {
            const issue = yield models_1.Issue.findById(issueId);
            if (!issue) {
                throw (0, utilities_1.newErr)(404, 'Issue not found');
            }
            if (issue.status !== 'resolved') {
                throw (0, utilities_1.newErr)(400, 'Issue is not resolved');
            }
            issue.status = 'open';
            issue.resolvedAt = null;
            yield issue.save();
            return issue;
        });
    }
};
exports.default = IssueService;
