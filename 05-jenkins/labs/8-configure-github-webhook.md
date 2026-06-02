# Configure GitHub Webhook

## Prerequisites

- GitHub Account
- Jenkins Server

## Step-01: Configure the Webhook in GitHub

### 1.1: Create a GitHub Webhook to notify Jenkins

- Navigate to your repository on GitHub.
- Click on the **Settings** tab (the gear icon on the top menu bar).
- Select **Webhooks** from the left-hand navigation sidebar.
- Click the **Add webhook** button on the top right.
- Configure the following required form values:
  - **Payload URL**: Enter your Jenkins root URL followed exactly by /github-webhook/

    ```
    http://<your-jenkins-public-ip-or-domain>:8080/github-webhook/
    ```

  - `NOTE`: The trailing slash "/" at the end of the URL is strictly mandatory. Jenkins will throw a 404 error if it is missing.

  - **Content type**: Select **application/json**.
  - **Secret**: Leave blank unless you have configured a global GitHub Personal Access Token webhook secret inside your global Jenkins settings.
  - **Which events would you like to trigger this webhook?**: Just the push event.

- Click **Add webhook**

### 1.2: Verify the Connection

- Look at your GitHub **Webhooks** list page.

- If the integration was successful, you will see a **green checkmark** next to your payload URL.
- If you see a red warning sign, click **Edit** on the webhook, scroll down to **Recent Deliveries**, and inspect the response code (e.g., HTTP 403 or 404) to diagnose security blockages.
