#Apigee API Proxy to GitHub Automation

Bash script to extract an API Proxy from Edge to a local Git repository, then upload to remote GitHub repository.

Uses curl and Apigee Management API.

Requires you to setup your own GitHub repository, unless you want to share your proxies with me.

###Usage
* Create your own GitHub repository and clone it (not mine) to your local repository.
* Copy the scripts to your local repository or your local bin.
* Set your parameters: ```cp ops-env.sh-dist ops-env.sh``` and adjust to your environment.
* Run interactively:
	* Example: ```/ops-get-api.sh -n apitest -R .```
* Run in silent mode:
	* Example: ```/ops-get-api.sh -s -n apitest -r 6 -R . -c "Comment for commit goes here"```

#####Usage:
```
Usage: ops-get-api.sh [-h (help)] [-v (verbose)] [-n <apiname>] [-r <apirevision>] [-R <local_git_repository>]
                      [-s (silent)] [-c <comment_for_commit>]

Required options: -n apiname -R repository

Silent mode required options: -s -n apiname -r apirevision -R repository -c comment-for-commit
```

TODO:
* Make fully interactive, prompt for local repository and if no ```apiname``` then curl to get list from Edge.
* Support ```[-A (all)]``` mode, to download all proxies in one pass.
