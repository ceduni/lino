import { newErr } from "../utilities/utilities";
import { User, Issue } from "../models";

const IssueService = {
    async createIssue({
        username,
        email,
        bookboxId,
        subject,
        description
    } : {
        username: string,
        email: string,
        bookboxId: string,
        subject: string,
        description: string
    }) {

        const issue = new Issue({
            username,
            email,
            bookboxId,
            subject,
            description
        });
        await issue.save();

        // Increment the number of issues reported by the user
        const user = await User.findOne({ email });
        if (user) {
            user.numIssuesReported += 1;
            await user.save();
        }
        
        return issue;
    },

    async getIssue(issueId: string) {
        const issue = await Issue.findById(issueId);
        if (!issue) {
            throw newErr(404, 'Issue not found');
        }
        return issue;
    },

    async investigateIssue(issueId: string) {
        const issue = await Issue.findById(issueId);
        if (!issue) {
            throw newErr(404, 'Issue not found');
        }
        issue.status = 'in_progress';
        await issue.save();
        return issue;
    },

    async closeIssue(issueId: string) {
        const issue = await Issue.findById(issueId);
        if (!issue) {
            throw newErr(404, 'Issue not found');
        }
        issue.status = 'resolved';
        issue.resolvedAt = new Date();
        await issue.save();
        return issue;
    },

    async reopenIssue(issueId: string) {
        const issue = await Issue.findById(issueId);
        if (!issue) {
            throw newErr(404, 'Issue not found');
        }   

        if (issue.status !== 'resolved') {
            throw newErr(400, 'Issue is not resolved');
        }
        issue.status = 'open';
        issue.resolvedAt = null as any;
        await issue.save();
        return issue;
    }
};

export default IssueService;
