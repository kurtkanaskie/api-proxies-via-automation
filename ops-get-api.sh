# /bin/bash
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${MYDIR}/ops-env.sh

# Parse the parameters
# ======================================================
# Initialize our own variables:
VERBOSE=0
SILENT=0
API=""
REVISION=""
REPO=""

function usage {
	echo; echo 	"Usage: `basename $0` [-h] [-v] [-n <apiname>] [-r <apirevision>] [-R <local_git_repository>]"
	echo 		"                      [-s (silent)] [-c <comment_for_commit>]"
	echo
        exit 1
}
function goodbye {
	echo "Goodbye"
        exit 0
}

while getopts "hvsc:n:r:R:" opt; do
  case $opt in
    h)
	usage
	;;
    v)
	VERBOSE=1
	;;
    n)
	API=$OPTARG
	;;
    r)
	REVISION=$OPTARG
	;;
    s)
	SILENT=1
	;;
    c)
	COMMENT=$OPTARG
	;;
    R)
	REPO=$OPTARG
	;;
    \?)
	echo "Invalid option: -$OPTARG" >&2
	usage
	;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Check parameters
# ======================================================
if [ $SILENT = 1 ]
then
	if [ "$API" = "" ] || [ "$REVISION" = "" ] || [ "$REPO" = "" ] || [ "$COMMENT" = "" ]; then
		echo; echo "Silent mode required options: -s -n apiname -r apirevision -R repository -c comment-for-commit" 
		usage
	fi
fi

if [ $VERBOSE = 1 ]; then
	echo; echo "RUNNING: `basename $0` $*"
fi

# Get the REPO if not specified
# ======================================================
while [ "$REPO" = "" ]; do
	echo; echo ===================
	echo -n "Enter the local repository name: "; read REPO

	# Check that the REPO exists and is a git repo
	# ======================================================
	if [ -d "$REPO" ]
	then
		cd $REPO
		if git rev-parse --git-dir > /dev/null 2>&1;
		then
			cd $MYDIR
		else 
			echo; echo "ERROR: \"$REPO\" must be a GitHub local repository"
			REPO="";
		fi
	else
		echo; echo "ERROR: \"$REPO\" must exist and be a GitHub local repository"
		REPO="";
	fi
done

# Get the APIs if not specified
# ======================================================
while [ "$API" = "" ]; do
	echo; echo ===================
	echo "No API was specified, getting APIs from \"$MGMTSVR\""
	if [ $VERBOSE = 1 ]; then
		echo "curl -k -s -u $UNPW $MGMTSVR/v1/o/$ORG/apis"
	fi
	APIS=`curl -k -s -u $UNPW $MGMTSVR/v1/o/$ORG/apis`
	echo "$APIS"
	echo; echo ===================
	echo -n "Which API do you want: "; read API

	if [ $VERBOSE = 1 ]; then
		echo "curl -k -s -u $UNPW $MGMTSVR/v1/o/$ORG/apis/$API"
	fi
	curl -k -s -u $UNPW $MGMTSVR/v1/o/$ORG/apis/$API
	echo; echo; echo ===================
	echo -n "Is that the right API? y|(n): "; read R
	if [ "$R" != "y" ]; 
		then API="";
	fi
done

# Get the revisions detail for the API if not specified
# ======================================================
while [ "$REVISION" = "" ]; do
	echo; echo ===================
	echo "No revision was specified, getting API revisions for API \"$API\""
	if [ $VERBOSE = 1 ]; then
		echo "curl -k -s -u $UNPW $MGMTSVR/v1/o/$ORG/apis/$API"
	fi
	DETAILS=`curl -k -s -u $UNPW $MGMTSVR/v1/o/$ORG/apis/$API`
	echo "API \"$API\" has the following details:"
	echo "$DETAILS"
	echo; echo ===================
	echo -n "Which revision do you want: "; read REVISION

	if [ $VERBOSE = 1 ]; then
		echo "curl -k -s -u $UNPW $MGMTSVR/v1/o/$ORG/apis/$API/revisions/$REVISION"
	fi
	curl -k -s -u $UNPW $MGMTSVR/v1/o/$ORG/apis/$API/revisions/$REVISION 
	echo; echo; echo ===================
	echo -n "Is that the right revision? y|(n): "; read R
	if [ "$R" != "y" ]; 
		then REVISION="";
	fi
done


# Get API as zipfile and unzip to loca repo
# ======================================================
echo; echo ===================
echo "Getting apiproxy zip bundle to: $REPO/apiproxy-$API-$REVISION.zip"
if [ $VERBOSE = 1 ]; then
	echo "curl -k -s -u $UNPW $MGMTSVR/v1/o/$ORG/apis/$API/revisions/$REVISION?format=bundle -o $REPO/apiproxy-$API-$REVISION.zip"
fi
curl -k -s -u $UNPW $MGMTSVR/v1/o/$ORG/apis/$API/revisions/$REVISION?format=bundle -o $REPO/apiproxy-$API-$REVISION.zip

echo; echo ===================
echo "Unzipping"
rm -rf $REPO/apiproxy-$API-$REVISION
unzip $REPO/apiproxy-$API-$REVISION.zip -d $REPO/apiproxy-$API-$REVISION

# Push to GitHub
# ======================================================
if [ $SILENT = 0 ] 
then
	echo; echo ===================
	echo -n "OK to add and commit \"apiproxy-$API-$REVISION\" and push to GitHub? y|(n): "; read R
	if [ "$R" != "y" ]; then goodbye; fi

	cd $REPO
	echo "git status shows:"
	echo 
	git status
	echo; echo ===================
	if [ "$COMMENT" = "" ]
	then
		echo -n "Enter comment for commit (50 chars max): "; read COMMENT
	else
		echo -n "COMMENT=\"$COMMENT\", OK (enter) or enter new (50 chars max): "; read NEWCOMMENT
		if [ "$NEWCOMMENT" != "" ]; then
			COMMENT=$NEWCOMMENT
		fi
	fi

	if [ $VERBOSE = 1 ]; then
		echo "Git commands to execute:"
		echo "	git add apiproxy-$API-$REVISION"
		echo "	git commit -m "$COMMENT""
		echo "	git push"
		echo -n "Still OK? y|(n): "; read R
		if [ "$R" != "y" ]; then goodbye; fi
	fi
fi

git add apiproxy-$API-$REVISION
git commit -m "$COMMENT"
git push
cd $MYDIR

echo "All done"
exit 0
