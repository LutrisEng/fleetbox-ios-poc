import React, { useState } from "react";
import useAsyncEffect from "use-async-effect";
import { Octokit } from "@octokit/rest";
import classNames from "classnames";
import styles from "./styles.module.css";

const octokit = new Octokit();
const owner = "LutrisEng";
const repo = "fleetbox";

type Issue = Awaited<ReturnType<typeof octokit.rest.issues.get>>;

function formatIssueURL(issue: number): string {
  return `https://github.com/${owner}/${repo}/issues/${issue}`;
}

export interface Props {
  issue: number;
  placeholderTitle?: string;
}

export default function GitHubIssue(props: Props) {
  const [issue, setIssue] = useState<Issue | null>(null);
  useAsyncEffect(async () => {
    setIssue(
      await octokit.rest.issues.get({
        owner,
        repo,
        issue_number: props.issue,
      })
    );
  });
  const title = issue?.data.title ?? props.placeholderTitle;
  const status = issue?.data.state;
  return (
    <a
      className={classNames(
        styles.issueLink,
        status === "open" && styles.open,
        status === "closed" && styles.closed
      )}
      href={formatIssueURL(props.issue)}
    >
      GitHub Issue #{props.issue}
      {title == null ? "" : `: ${title}`}
    </a>
  );
}
