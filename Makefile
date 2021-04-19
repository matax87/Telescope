# Configuration variables:
.DEFAULT_GOAL := git_setup
	
format:
	swiftformat .
	swiftlint autocorrect

# Install dependencies, download build resources and add pre-commit hook
setup:
	brew update
	brew bundle
	make git_setup

git_setup:
	eval "$$add_pre_commit_script"

# Define pre commit script to auto lint and format the code
define _add_pre_commit
SWIFTLINT_PATH=`which swiftlint`
SWIFTFORMAT_PATH=`which swiftformat`
if [ -d ".git" ]; then
if [ ! -d ".git/hooks" ]; then
  mkdir -p ".git/hooks"
fi
cat > .git/hooks/pre-commit << ENDOFFILE
#!/bin/sh
FILES=\$(git diff --cached --name-only --diff-filter=ACMR "*.swift" | sed 's| |\\ |g')
[ -z "\$FILES" ] && exit 0
# Format
${SWIFTFORMAT_PATH} \$FILES

# Lint
${SWIFTLINT_PATH} autocorrect \$FILES
${SWIFTLINT_PATH} lint \$FILES
# Add back the formatted/linted files to staging
echo "\$FILES" | xargs git add

exit 0
ENDOFFILE

chmod +x .git/hooks/pre-commit
fi
endef
export add_pre_commit_script = $(value _add_pre_commit)
