import { newErr } from "../services/utilities";
import { AuthenticatedRequest } from "../types";
import Issue from "./issue.model";

const IssueService = {
    async createIssue(
        request: AuthenticatedRequest & { body: { bookboxId: string; subject: string; description: string } }
    ) {
        const { bookboxId, subject, description } = request.body;
        const username = request.user.username;

        const issue = new Issue({
            username,
            bookboxId,
            subject,
            description
        });
        await issue.save();
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
    }
};

export default IssueService;