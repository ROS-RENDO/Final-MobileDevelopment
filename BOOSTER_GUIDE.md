# GitHub Contribution Booster & Auto-Pusher

An all-in-one Windows batch script (`push.bat` / `push_contributions.bat`) to automate Git commits and push them directly to [**ROS-RENDO/Final-MobileDevelopment**](https://github.com/ROS-RENDO/Final-MobileDevelopment) to maintain your GitHub contribution graph activity (the green squares).

- **Target Repository**: `https://github.com/ROS-RENDO/Final-MobileDevelopment.git`
- **Default Branch**: `main`
- **Author**: `ROS-RENDO <rousrendo@gmail.com>`

---

## Quick Start (1-Click)

1. **Double-click** [`push.bat`](file:///d:/Git-Pushing/push.bat) (or run `.\push.bat` in your terminal).
2. Choose an option from the interactive menu:
   - **`[1] Rapid Burst for Today`** &rarr; Push `X` commits for today's streak (e.g. 10, 20, 50).
   - **`[2] Fill History (Green Squares)`** &rarr; Backdate commits across past days (30, 90, 180, 365 days) with natural timestamp distributions.
   - **`[3] Custom Date Range`** &rarr; Backdate commits between any start date and end date (`YYYY-MM-DD`).
   - **`[4] Express 1-Click Boost`** &rarr; Instant 15 commits for today + automatic push.
   - **`[5] Setup / Change Remote URL`** &rarr; Connect to your GitHub repository URL.
   - **`[6] Push Pending Commits Now`** &rarr; Sync local commits to GitHub.
   - **`[7] View Recent Commit Log`** &rarr; Inspect your recent commits.
   - **`[8] Configure Git Name & Email`** &rarr; Ensure author email matches your GitHub account.

---

## Command Line Usage

You can also run commands directly with arguments:

```cmd
# Push 20 commits for today and sync to GitHub
push.bat 20

# Fill past 30 days of contribution history
push.bat --days 30

# Push any pending local commits to GitHub
push.bat --push

# Show help
push.bat --help
```

---

## 3 Critical GitHub Rules for Contributions to Appear

For your GitHub contribution graph to register the commits and turn green:

### 1. Email Matching
Your Git author email must match one of the verified emails on your GitHub account.
- **Current configured author**: `ROS-RENDO <rousrendo@gmail.com>`
- Verify on GitHub: Go to **GitHub &rarr; Settings &rarr; Emails** and ensure `rousrendo@gmail.com` is listed.
- If you use a different email, select **Option `[8]`** in `push.bat` to change it.

### 2. Default Branch
GitHub only counts contributions pushed to the repository's default branch (configured as `main`).

### 3. Private vs Public Repository
- **If your GitHub repo is Public**: Contributions appear automatically.
- **If your GitHub repo is Private**: You must enable private contributions in your profile:
  1. Open your GitHub profile page (`https://github.com/ROS-RENDO`).
  2. Click **Contribution settings** (drop-down above the contribution calendar).
  3. Check **"Include private contributions on my profile"**.

> **Note**: GitHub typically takes 1 to 5 minutes to re-index and refresh your contribution squares after pushing.

---

## Connecting to Your GitHub Repository

If you haven't linked a GitHub repository yet:

1. Go to [GitHub.com](https://github.com) and create a new repository (e.g., `contributions` or `activity-log`).
2. Copy the repository URL (e.g., `https://github.com/ROS-RENDO/contributions.git`).
3. Run [`push.bat`](file:///d:/Git-Pushing/push.bat) and choose **Option `[5]`**.
4. Paste your repository URL.
5. All past and future commits will automatically push to your GitHub repo!
