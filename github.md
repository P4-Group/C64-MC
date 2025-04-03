# Common commandline commands:
| Command                          | Description                          | Example Usage                              |
|----------------------------------|--------------------------------------|-------------------------------------------|
| **Clone a repository**           | Clone a remote repository            | `git clone <repository-url>`              |
| **Check repository status**      | Check the status of your repository  | `git status`                              |
| **Stage changes**                | Add changes to the staging area      | `git add <file-name>`                     |
| **Unstage changes**              | Remove changes from the staging area | `git reset <file-name>`                   |
| **Commit changes**               | Commit staged changes with a message | `git commit -m "Commit message"`          |
| **Push changes to remote**       | Push local changes to the remote repo| `git push origin <branch-name>`           |
| **Pull latest changes**          | Pull updates from the remote repo    | `git pull origin <branch-name>`           |
| **Create a new branch**          | Create and switch to a new branch    | `git checkout -b <branch-name>`           |
| **Switch to an existing branch** | Switch to a specific branch          | `git checkout <branch-name>`              |
| **View commit history**          | View the commit history of the repo  | `git log`                                 |
| **Stash changes**                | Save changes temporarily             | `git stash`                               |
| **Apply stashed changes**        | Apply the latest stashed changes     | `git stash apply`                         |
| **List stashed changes**         | View all stashed changes             | `git stash list`                          |
| **Drop a stash**                 | Remove a specific stash              | `git stash drop <stash-id>`               |

# Branch do's and dont's



## Trunk Workflow Rules:
| Rule                     | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| **Single Source of Truth** | `trunk` is the main branch; always deployable.                             |
| **Feature Development**   | Use feature branches for isolated work.                                    |
| **Code Reviews**          | All changes require peer review before merging.                            |
| **Continuous Integration**| CI pipelines must pass before merging.                                     |
| **Frequent Integration**  | Merge small, frequent changes to avoid conflicts.                          |
| **Conflict Resolution**   | Resolve conflicts in feature branches before merging.                      |
| **Release Management**    | Create releases and tag versions from `trunk`.                             |
| **Rollback Strategy**     | Plan for quick rollbacks using tags or commit hashes.                      |
| **Documentation**         | Document significant changes in commits or changelogs.                     |

## Extended Explanation
1. **Single Source of Truth**  
    - The `trunk` branch is the main branch where all changes are integrated.  
    - It must always remain in a deployable state.  

2. **Feature Development**  
    - Developers should create feature branches from the `trunk` branch.  
    - These branches are used to isolate work on specific tasks or features.  

3. **Code Reviews**  
    - All changes must undergo a peer review process before merging into `trunk`.  
    - Code reviews ensure quality and adherence to project standards.  

4. **Continuous Integration (CI)**  
    - CI pipelines must pass successfully before merging into `trunk`.  
    - These pipelines include automated tests, linting, and other quality checks to maintain stability.  

5. **Frequent Integration**  
    - Developers should integrate changes into `trunk` frequently to avoid large, complex merges.  
    - Smaller, incremental changes are easier to review and test.  

6. **Conflict Resolution**  
    - Resolve merge conflicts in feature branches before merging into `trunk`.  
    - Ensure the `trunk` branch remains conflict-free at all times.  

7. **Release Management**  
    - Releases are created directly from the `trunk` branch.  
    - Tag the `trunk` branch with version numbers for each release.  

8. **Rollback Strategy**  
    - Plan for quick rollbacks in case of issues by reverting the `trunk` branch to a stable state.  
    - Use version tags or commit hashes for efficient rollbacks.  

9. **Documentation**  
    - Document all significant changes in commit messages or a changelog.  
    - Ensure the `trunk` branch reflects the latest project state and is well-documented.  