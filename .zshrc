# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="/Users/simun/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ls="ls -la"
alias eng="/Users/Simun/Engineering"
alias pro="/Users/Simun/Engineering/Projects"
alias libs="/Users/Simun/Engineering/Libraries"
alias tg="/Users/Simun/Engineering/TestingGrounds"


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(rbenv init - zsh)"

# GoLang Configurations
export GOPATH=$HOME/.go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export GO111MODULE=on
export GOPRIVATE=gitlab.sintezis.co

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

