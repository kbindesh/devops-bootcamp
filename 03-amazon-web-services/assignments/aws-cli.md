# AWS CLI Quiz

### 1. What is the primary purpose of the AWS CLI?

    A) To host web applications in the cloud.

    B) To manage and control AWS services using a text-based terminal instead of the web
    browser.

    C) To write code for AWS Lambda functions.

    D) To scan local computers for malware.

### 2. Which command is used to configure your AWS CLI installation with your access keys, region, and output format?

    A) aws setup

    B) aws init

    C) aws configure

    D) aws login

### 3. What long-term credentials you must use to authenticate your AWS CLI from your local system?

    A) Username and Password

    B) Root Email and MFA Token

    C) Access Key ID and Secret Access Key

    D) SSH Key Pair (.pem file)

### 4. By default, what format does the AWS CLI use to return data?

    A) JSON

    B) XML

    C) CSV

    D) Plain Text

### 5. If you want to see all the files and folders inside your Amazon S3 buckets using the CLI, which command should you run?

    A) aws s3 show

    B) aws s3 ls

    C) aws s3 dir

    D) aws s3 list

### 6. What happens if you run a command like `aws s3 ls` but you haven't configured any credentials yet?

    A) The command works perfectly using guest access.

    B) The CLI prompts you to type your web console password.

    C) The command fails with an error stating "Unable to locate credentials".

    D) The CLI automatically creates a temporary AWS account for you.

### 7. How can you tell the AWS CLI to use a non-default output format (like a visual table) for just a single command?

    A) aws ec2 describe-instances --output table

    B) aws ec2 describe-instances --format table

    C) aws ec2 describe-instances --print table

    D) You cannot change the format after setup.

### 8. What is an AWS CLI "Profile"?

    A) A profile picture associated with your AWS account.

    B) A named collection of settings and credentials that allows you to quickly switch between
    different AWS accounts or users.

    C) A resume uploaded to AWS for job hunting.

    D) A specific billing plan chosen during setup.

### 9. Which command would you use to find out which version of the AWS CLI is currently installed on your computer?

    A) aws version

    B) aws --v

    C) aws --version

    D) aws check-version

### 10. If you are stuck and don't know what parameters a specific AWS CLI command accepts, what flag can you append to the end of your command to view the official documentation?

    A) --info

    B) help

    C) --help

    D) ?

### Scenario-1: The Onboarding Request

A new system administrator, Emily, has just joined your team. You need to quickly provision her identity in AWS so she can begin setting up her personal access keys.
</br></br>
`Question`: Which command should you run to create her identity via the CLI?

    A) aws iam add-user --username Emily

    B) aws iam create-user --user-name Emily

    C) aws iam new-user --name Emily

    D) aws iam register-user --user-name Emily

### Scenario-2: Standardising Permissions

Your company is auditing its access controls. Instead of attaching policies directly to individual users, the security team mandates that all developers must belong to a group named DevTeam and inherit permissions from it.
</br></br>

`Question`: Which command do you run to place the existing user Emily into the DevTeam group?

    A) aws iam add-user-to-group --user-name Emily --group-name DevTeam

    B) aws iam join-group --user Emily --group DevTeam

    C) aws iam move-user --from Emily --to DevTeam

    D) aws iam attach-group-policy --user-name Emily --group-name DevTeam

### Scenario-3: Granting Admin Powers

You need to grant the DevTeam group administrative access. AWS provides a pre-built managed policy called AdministratorAccess.
</br></br>
`Question`: Which command applies this built-in policy directly to the group?

    A) aws iam attach-group-policy --group-name DevTeam --policy-arn
    arn:aws:iam::aws:policy/AdministratorAccess

    B) aws iam apply-policy --group DevTeam --name AdministratorAccess

    C) aws iam put-group-policy --group-name DevTeam --policy-name AdministratorAccess

    D) aws iam link-policy --target DevTeam --policy AdministratorAccess

### Scenario 4: Leaked Credentials Emergency

An engineer accidentally pushes a script containing their programmatic CLI keys to a public GitHub repository. You need to immediately invalidate their keys to stop an active security breach.
</br></br>
`Question`: Which command will immediately deactivate the compromised access key
( AKIAIOSFODNN7EXAMPLE ) without deleting the user account?

    A) aws iam delete-access-key --access-key-id AKIAIOSFODNN7EXAMPLE

    B) aws iam update-access-key --access-key-id AKIAIOSFODNN7EXAMPLE --status Inactive

    C) aws iam suspend-key --key-id AKIAIOSFODNN7EXAMPLE

    D) aws iam change-key-status --id AKIAIOSFODNN7EXAMPLE --disable

<hr>

## Quiz Answer Key & Explanations

1. B — The AWS CLI allows you to control services directly from your command line terminal,
   enabling automation and scripting.

2. C — Running aws configure is the standard setup wizard that prompts you for your credentials
   step-by-step.

3. C — Programmatic access via the CLI relies on the Access Key ID (acting like a username)
   and Secret Access Key (acting like a password).

4. A — JSON is the default output format, making it easy for programming scripts to parse the
   data.

5. B — The AWS CLI uses standard Linux-like syntax for S3 operations; ls is used to list files.

6. C — The AWS CLI cannot make anonymous calls to your private cloud resources; it will throw
   an error immediately if credentials are missing.

7. A — The global --output flag overrides your default configuration settings for that specific
   command execution (options include json , table , text , and yaml ).

8. B — Profiles (e.g., using --profile production ) let you switch between multiple AWS
   environments smoothly without reconfiguring your keys every time.

9. C — Running aws --version outputs the exact engine version (e.g., AWS CLI v2) and your
   operating system details.

10. C — Appending --help opens a detailed, offline manual page explaining exactly how to
    construct that specific command.

11. Scenario-1: B — aws iam create-user --user-name Emily is the precise API call used to provision a new
    IAM user identity.

12. Scenario-2: A — aws iam add-user-to-group maps a specific user to an existing security group container.

13. Scenario-3: A — To use an AWS Managed Policy, you must target the group with attach-group-policy and
    supply the unique Amazon Resource Name (ARN) via --policy-arn .

14. Scenario-4: B — Changing the --status parameter to Inactive using update-access-key safely freezes
    the key immediately. This lets you preserve it for forensic investigation, whereas deleteaccess-
    key permanently destroys it.
