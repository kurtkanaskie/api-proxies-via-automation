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
else
	if [ "$API" = "" ] || [ "$REPO" = "" ]; then
		echo; echo "Required options: -n apiname -R repository" 
		usage
	fi
fi

if [ $VERBOSE = 1 ]; then
	echo; echo "COMMAND TO RUN: `basename $0` $*"
fi

# Check that the REPO exists and is a git repo
# ======================================================
if [ -d "$REPO" ]
then
	cd $REPO
	if git rev-parse --git-dir > /dev/null 2>&1;
	then
		cd $MYDIR
	else 
		echo; echo "ERROR: "\REPO" must be a GitHub local repository"
		usage
	fi
else
	echo; echo "ERROR: "\REPO" must exist and be a GitHub local repository"
	usage
fi

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
	echo -n "Is that's the right revision, OK? y|(n): "; read R
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
