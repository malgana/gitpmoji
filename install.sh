#!/bin/bash

#script for installing gitpmoji. oneliner

CURRENT_DIR=$(pwd)
echo "gitpmoji will be installed in $CURRENT_DIR"

#download from github
curl -o prepare-commit-msg.sh https://raw.githubusercontent.com/Fl0p/gitpmoji/main/prepare-commit-msg.sh
curl -o gpt.sh https://raw.githubusercontent.com/Fl0p/gitpmoji/main/gpt.sh

#make executable
chmod +x prepare-commit-msg.sh
chmod +x gpt.sh

ask_api_key() {
    read -p "Enter your OpenAI API key (https://platform.openai.com/account/api-keys): " api_key
    echo "export GITPMOJI_API_KEY=\"$api_key\"" > .gitpmoji.env
}

ask_prefix() {
    read -p "Enter prefix (sed RegExp) for commit messages which will be untouched as first keyword for each message: " prefix
    echo "export GITPMOJI_PREFIX_RX=\"$prefix\"" >> .gitpmoji.env
}

ask_api_key
ask_prefix

echo "Add file .gitpmoji.env to .gitignore if you want to keep your API key secret"

TOP_LEVEL_GIT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

HOOKS_DIR="$TOP_LEVEL_GIT_DIR/.git/hooks"
echo "hooks_dir: $HOOKS_DIR"


# Get absolute path of the hooks directory
SOURCE="$(cd "$HOOKS_DIR"; pwd)"

# Get absolute path of the current directory
TARGET="$(cd "$CURRENT_DIR"; pwd)"

relative_path() {
    local common_part="$SOURCE" # for now
    local result="" # for now

    while [[ "${TARGET#"$common_part"}" == "${TARGET}" ]]; do
        # no match, means that candidate common part is not correct
        common_part="$(dirname "$common_part")"
        result="../${result}" # move to parent dir in relative path
    done

    if [[ "$common_part" == "/" ]]; then
        # special case for root (no common path)
        result="$result/"
    fi

    # since we now have identified the common part,
    # compute the non-common part
    local forward_part="${TARGET#"$common_part"}"

    # and now stick all parts together
    result="${result}${forward_part}"
    echo "$result"
}

RELATIVE_PATH=$(relative_path "$SOURCE" "$TARGET")

# echo "RELATIVE_PATH: $RELATIVE_PATH"

cd $HOOKS_DIR
ln -s $RELATIVE_PATH/prepare-commit-msg.sh prepare-commit-msg

cd $CURRENT_DIR
echo "done"