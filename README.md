#Apigee API Proxy to GitHub Automation

Bash script to extract an API Proxy from Edge to a local Git repository, then upload to remove GitHub repository.

Uses curl and Apigee Management API.

###Usage
* Clone this repository
* Copy ```cp ops-env.sh-dist ops-env.sh``` and adjust to your environment.
* Run interactively:
	* Example: ```/ops-get-api.sh -n apitest -R .```
* Run in silent mode:
	* Example: ```/ops-get-api.sh -s -n apitest -r 6 -R . -c "Comment for commit goes here"```

#####Usage:
```
Required options: -n apiname -R repository

Usage: ops-get-api.sh [-h] [-v] [-n <apiname>] [-r <apirevision>] [-R <local_git_repository>]
                      [-s (silent)] [-c <comment_for_commit>]
```
