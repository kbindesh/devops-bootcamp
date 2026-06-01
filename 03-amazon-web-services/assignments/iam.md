# AWS IAM Quiz

### Scenario-1: New Joinee

The New InternAlice just joined CloudCorp as a DevOps intern. Her manager wants her to be able to view and list objects in their Amazon S3 buckets for learning purposes, but she must not be able to delete anything.</br></br>
`Question`:Question: How should the administrator configure her access?

    A) Give Alice the Root account password but ask her nicely not to delete anything.

    B) Create an IAM User for Alice and attach an AWS Managed Policy named AmazonS3ReadOnlyAccess.

    C) Create an IAM User for Alice and attach an AWS Managed Policy named AmazonS3FullAccess.

    D) Tell Alice to use a coworker's AWS login credentials for the first week.

### Scenario-2: Scaling the Team

_CloudCorp_ expands and hires 5 new data analysts on the same day. All 5 analysts need identical, unrestricted access to Amazon DynamoDB databases, but no access to any other AWS services.
</br></br>
`Question`: What is the most efficient and secure way to manage their permissions?

    A) Create 5 separate IAM users and manually copy-paste a custom inline JSON policy into each individual user account.

    B) Create 1 shared IAM User called "DataTeam", give the password to all 5 analysts, and attach the DynamoDB policy to it.

    C) Create an IAM Group named "DataAnalysts", attach the AmazonDynamoDBFullAccess policy to the group, and add all 5 new IAM users to this group.

    D) Give all 5 analysts Administrator access so they never run into permission errors.

### Scenario-3: The Accidental Administrator

Bob is a developer in the "Developers" IAM Group. The group has a policy that allows full access to Amazon EC2 (AmazonEC2FullAccess). However, the administrator accidentally attached a separate policy directly to Bob's individual IAM user profile that explicitly denies all EC2 actions (Deny on ec2:\*).
</br></br>
`Question`: What happens when Bob tries to launch a new EC2 instance?

    A) Bob can launch the instance because the Group's "Allow" permission overrides his individual profile.

    B) Bob can launch the instance because "Allow" always takes priority over "Deny" in AWS.

    C) Bob's request is denied because an explicit "Deny" always overrides an "Allow" in AWS IAM.

    D) AWS will crash because conflicting policies create an infinite loop error.

### Scenario-4: The Locked Storage

Charlie is trying to access an S3 bucket named company-financials. The administrator created a custom policy to let Charlie access it, but Charlie keeps getting an "Access Denied" error. The administrator reviews the JSON policy attached to Charlie's user account:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::company-marketing"
    }
  ]
}
```

</br>

`Question`: Why is Charlie getting an Access Denied error when trying to view company-financials?

    A) The policy uses an old version date (2012-10-17) that is expired.

    B) The Resource field in the policy specifies the company-marketing bucket, not the company-financials bucket.

    C) The Action should be s3:ViewObject instead of s3:GetObject.

    D) S3 buckets cannot be accessed using IAM policies.

### Scenario-5: Leaving the Company

Dave, a senior cloud engineer, is leaving CloudCorp to join a new company. He has an IAM User account with multiple custom policies attached, active access keys used in terminal scripts, and a virtual MFA device on his phone.
</br></br>
`Question`: To follow security best practices, what should the administrator do immediately on Dave's last day?

    A) Leave the account active in case Dave needs to log in from his new job to help with transition questions.

    B) Just change Dave's console login password and leave his access keys and MFA active.

    C) Delete or deactivate Dave's IAM User, deactivate his access keys, and remove him from all IAM groups.

    D) Delete the entire AWS Root account to ensure Dave cannot log in.
