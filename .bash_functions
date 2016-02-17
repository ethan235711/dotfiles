#!/bin/sh

# Bash Functions, sourced by .bashrc

vgrep() # Grep in src/vim/cmds for lines matching key word provided
{
if [ -f ~/src/vim/cmds ]; then
    grep -i ${1} ~/src/vim/cmds
else
    echo "Cannot find cmd source file at ~/src/vim/cmds."
fi
}
lb() # set $SCHRODINGER to local installation
{

if [ $PLAT == "Linux" ]; then
	export SCHRODINGER=/scr/schrod_20${2:-$BRANCH}_${1:-$BUILD}

elif [ $PLAT == "Darwin" ]; then
	export SCHRODINGER=/opt/schrodinger/suites20${2:-$BRANCH}

else
	echo "Unable to match platform, \$SCHRODINGER not set";
	return 1;
fi

echo "Setting \$SCHRODINGER=$SCHRODINGER"

}


ob() # set $SCHRODINGER to OB on the zones
{
BUILD_DIR=/builds/OB/20${2:-$BRANCH}/build${1:-$BUILD}

if [ $PLAT == "Linux" ]; then
	export SCHRODINGER=/nfs$BUILD_DIR/Linux-x86_64/
elif [ $PLAT == "Darwin" ]; then
	export SCHRODINGER=/Volumes$BUILD_DIR/MacOSX/
elif [ $PLAT == "bob" ]; then
	export SCHRODINGER=/nfs/working$BUILD_DIR/
else
	echo "Unable to match platform, \$SCHRODINGER not set";
	return 1;
fi

echo "Setting \$SCHRODINGER=$SCHRODINGER"
}


mae() # launch Maestro as long as $SCHRODINGER is set appropriately
{
if [ "$SCHRODINGER" ]; then
	"$SCHRODINGER"/maestro
else
	echo "Unable to launch Maestro, \$SCHRODINGER is not set";
	return 1;
fi
}

can() # launch Canvas as long as $SCHRODINGER is set appropriately
{
if [ "$SCHRODINGER" ]; then
	"$SCHRODINGER"/canvas;
else
	echo "Unable to launch Canvas, \$SCHRODINGER is not set";
	return 1;
fi
}

elem() # launch Maestro Elements as long as $SCHRODINGER is set appropriately
{
if [ "$SCHRODINGER" ]; then
	"$SCHRODINGER"/maestro -profile Elements;
else
	echo "Unable to launch Elements, \$SCHRODINGER is not set";
	return 1;
fi
}

jc()
{
# help message [h] or when more than 2 arguments are supplied to jc
if [ $# -gt "2" ] || ([ $# -gt "0" ] && [ $1 == "h" ]); then
	echo "Usage jc [a]|[sh {#}], more than 3 arguments is not valid"
	echo "[a] lists all , [sh] {job#} show all jobs or ordinal job specified."
    echo "[] lists active jobs"
	return 1;
fi

# the first argument to jc may be either 'a', 'sh [#]', or '* = anything/nothing'
case "$1" in
	a)
		"$SCHRODINGER"/jobcontrol -list all
		;;
	sh) # this will either show all active jobs or only the ordinal job specified
		jblist="";
		# i will increment through the current active jobs
		i=1;
		for jobname in `jc | grep ^[a-z] | awk '{print $1}'`; do
			# check to see if # has been supplied after sh
			if [ $# -ne "2" ]; then
				# then compile jblist with space delimited list of all active jobs
				jblist=$jblist" "$jobname;
			else
				# test for which ordinal job, i.e. 1st, 2nd, 3rd, etc, was requested
				if [ $2 -eq $i ]; then
					# only put the requested job on the joblist fed to jc
					jblist=$jblist" "$jobname;				
				fi
			fi
			# increment i
			let "i+=1";
		done
		let "i+=-1";
		echo "Active Jobs = $i"
		"$SCHRODINGER"/jobcontrol -show $jblist
		;;
    k) # this will either kill all active jobs or only the ordinal job specified
        jblist="";
        # i will increment through the current active jobs
        i=1;
        for jobname in `jc | grep ^[a-z] | awk '{print $1}'`; do
            # check to see if # has been supplied after k
            if [ $# -ne "2" ]; then
                # then compile jblist with space delimited list of all active jobs
                jblist=$jblist" "$jobname;
            else
                # test for which ordinal job, i.e. 1st, 2nd, 3rd, etc, was requested
                if [ $2 -eq $i ]; then
                    # only put the requested job on the joblist fed to jc
                    jblist=$jblist" "$jobname;              
                fi
            fi
            # increment i
            let "i+=1";
        done
        echo "Killing Jobs = $jblist"
        "$SCHRODINGER"/jobcontrol -kill $jblist
        ;;
	*)
		"$SCHRODINGER"/jobcontrol -list
esac
}

jira_platTest()
{
# This function tests the current platform and sets $PATHTOJIRA accordingly
PLAT=$(uname)
if [ $PLAT == "Linux" ]; then
  PATHTOJIRA=/home/share/jira/jira.sh
elif [ $PLAT == "Darwin" ]; then
  PATHTOJIRA=/Volumes/home/share/jira/jira.sh
else
    echo "Unable to match platform, Exiting";
    return 1;
fi
}

jirastatus()
{
# Feed this $PRODUCT, 'string' = the raw cut and paste info from a column of your checklist enclosed in ''
PRODUCT=$1
COLDATA=$2

# test platform and set $PATHTOJIRA
if jira_platTest; then :; else return 1; fi

for issue in `echo $COLDATA | grep -io "$PRODUCT-[0-9][0-9]*" | sort -u`; do
  printf "%s\t" $issue; $PATHTOJIRA -a getIssue --issue $issue | grep -i status | awk -F":" '{print $2}';
done
}

jiraFindIssueCreators()
{
project = "MAE"
# First call to jira.sh generates a list of all project names to $project
#for project in `$PATHTOJIRA -a getProjectList | awk -F'"' '{print $2}' | grep [A-Z]`; do 
#  printf "%s\t" $project; 
  # Second call to jira.sh yields check of the component info; redirects stderr to null to clean up output from jira
  $PATHTOJIRA -a getIssueList --outputFormat "4" --search \
  "issuetype = bug AND created >= 2013-01-01 AND created <= 2013-06-30 AND project = MAE" 2>dev/null \
  | grep -o '^\"\([A-Z][A-Z]*-[0-9][0-9]*\)'
  $PATHTOJIRA -a getIssueList --outputFormat "4" --search \
  "issuetype = bug AND created >= 2013-07-01 AND project = MAE" 2>dev/null \
  | grep -o '^\"\([A-Z][A-Z]*-[0-9][0-9]*\)'

#  echo
#done

}

jira_compLead()
{
# test platform and set $PATHTOJIRA
if jira_platTest; then :; else return 1; fi

# First call to jira.sh generates a list of all project names to $project
for project in `$PATHTOJIRA -a getProjectList | awk -F'"' '{print $2}' | grep [A-Z]`; do 
  printf "%s\t" $project; 
  # Second call to jira.sh yields check of the component info; redirects stderr to null to clean up output from jira
  $PATHTOJIRA -a getComponent --project $project --component Testing 2>/dev/null | grep Lead;
  echo
done
}

jiralinkedIssuesInQuery()
{
# Usage: jiralinkedIssuesInQuery $USER $PASSWORD
PATHTOJIRA=/home/share/jira/jira.sh
# Generate list of issues whose linked cases are of interest
SEARCH1=`$PATHTOJIRA $1 $2 -a getIssueList --outputFormat "4" \
        --search "project = CONFGEN and status not in (closed, resolved)" 2>/dev/null \
        | grep -o '"[A-Z][A-Z]*-[0-9][0-9]*"'`

SEARCH2=''
# Generate list of all issues linked to issues from first list
for issue in $SEARCH1; do
    SEARCH2+=`$PATHTOJIRA $1 $2 -a getIssueList --outputFormat "4" \
    --search "issue in linkedIssues($issue)" 2>/dev/null \
    | grep -o '"[A-Z][A-Z]*-[0-9][0-9]*"' \
    | grep 'SUPPORT'`; # Filter linked issues by project
    SEARCH2+=" ";
done

RESULT=`echo $SEARCH2 | sed 's: :, :g'`  # Add commas
echo "issue in("$RESULT")"
}
