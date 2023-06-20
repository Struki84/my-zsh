# FUNCTIONS
#############################################

# Custom function for showing hidden files in Finder
# Made by GPT-4
ShowHiddenFiles() {
    if [[ "$1" == "on" ]]; then
        defaults write com.apple.finder AppleShowAllFiles -bool true
        killall Finder
        echo "Hidden files are now visible."
    elif [[ "$1" == "off" ]]; then
        defaults write com.apple.finder AppleShowAllFiles -bool false
        killall Finder
        echo "Hidden files are now hidden."
    else
        echo "Please specify 'on' or 'off' as an argument."
    fi
}

# Custom function wrapping curl for downloading source code 
# from remote repositories, made by GPT-4
function download() {
  if [ $# -lt 1 ]; then
    echo "Usage: download <source_url> [destination]"
    return 1
  fi

  local source_url="$1"
  local destination="${2:-$(pwd)}"

  if [ ! -d "$destination" ]; then
    echo "Error: Destination directory does not exist."
    return 1
  fi

  local filename=$(basename "$source_url")
  local destination_file="$destination/$filename"
  local file_extension="${filename##*.}"

  echo "Downloading source code from $source_url to $destination_file..."

  if [[ "$source_url" =~ ^https://github.com/ ]]; then
    curl -sS -L -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" -o "$destination_file" "$source_url"
  elif [[ "$source_url" =~ ^https://gitlab.com/ || "$source_url" =~ ^https://gitlab.sintezis.co/ ]]; then
    # Extract project path and branch from the source URL
    local project_path=$(echo "$source_url" | sed -E 's|https://[^/]+/(.+)/-/archive/.+|\1|')
    local branch=$(echo "$source_url" | sed -E 's|https://[^/]+/.+/-/archive/(.+)/.+|\1|')
    local api_url="https://gitlab.sintezis.co/api/v4/projects/$(echo "$project_path" | sed 's|/|%2F|g')/repository/archive.tar?sha=$branch"
    curl -sS -L -H "PRIVATE-TOKEN: $GITLAB_PERSONAL_ACCESS_TOKEN" -o "$destination_file" "$api_url"
  else
    curl -sS -L -o "$destination_file" "$source_url"
  fi

  local download_status=$?

  if [ $download_status -eq 0 ]; then
    echo "Download complete."

    case "$file_extension" in
      zip)
        if ditto -V -x -k --sequesterRsrc --rsrc "$destination_file" "$destination" 2>/dev/null; then
          echo "Extracting .zip file..."
        else
          echo "Error: Downloaded file is not a valid .zip archive. Please check the source URL and your personal access tokens."
          return 1
        fi
        ;;
      tar)
        echo "Extracting .tar file..."
        tar -xf "$destination_file" -C "$destination"
        ;;
      gz|tgz)
        echo "Extracting .tar.gz file..."
        tar -zxf "$destination_file" -C "$destination"
        ;;
      bz2|tbz)
        echo "Extracting .tar.bz2 file..."
        tar -jxf "$destination_file" -C "$destination"
        ;;
      xz)
        echo "Extracting .tar.xz file..."
        tar -Jxf "$destination_file" -C "$destination"
        ;;
      *)
        echo "Error: Unsupported file format."
        return 1
        ;;
    esac

  else
    echo "Error: Download failed with status code $download_status. Please check the source URL and your personal access tokens."
    return 1
  fi
}

