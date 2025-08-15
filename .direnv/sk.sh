# bash completion for skaffold                             -*- shell-script -*-

__skaffold_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE:-} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__skaffold_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__skaffold_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__skaffold_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__skaffold_handle_go_custom_completion()
{
    __skaffold_debug "${FUNCNAME[0]}: cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}"

    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16

    local out requestComp lastParam lastChar comp directive args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly skaffold allows handling aliases
    args=("${words[@]:1}")
    # Disable ActiveHelp which is not supported for bash completion v1
    requestComp="SKAFFOLD_ACTIVE_HELP=0 ${words[0]} __completeNoDesc ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __skaffold_debug "${FUNCNAME[0]}: lastParam ${lastParam}, lastChar ${lastChar}"

    if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __skaffold_debug "${FUNCNAME[0]}: Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __skaffold_debug "${FUNCNAME[0]}: calling ${requestComp}"
    # Use eval to handle any environment variables and such
    out=$(eval "${requestComp}" 2>/dev/null)

    # Extract the directive integer at the very end of the output following a colon (:)
    directive=${out##*:}
    # Remove the directive
    out=${out%:*}
    if [ "${directive}" = "${out}" ]; then
        # There is not directive specified
        directive=0
    fi
    __skaffold_debug "${FUNCNAME[0]}: the completion directive is: ${directive}"
    __skaffold_debug "${FUNCNAME[0]}: the completions are: ${out}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        # Error code.  No completion.
        __skaffold_debug "${FUNCNAME[0]}: received error from custom completion go code"
        return
    else
        if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __skaffold_debug "${FUNCNAME[0]}: activating no space"
                compopt -o nospace
            fi
        fi
        if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __skaffold_debug "${FUNCNAME[0]}: activating no file completion"
                compopt +o default
            fi
        fi
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local fullFilter filter filteringCmd
        # Do not use quotes around the $out variable or else newline
        # characters will be kept.
        for filter in ${out}; do
            fullFilter+="$filter|"
        done

        filteringCmd="_filedir $fullFilter"
        __skaffold_debug "File filtering command: $filteringCmd"
        $filteringCmd
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        # Use printf to strip any trailing newline
        subdir=$(printf "%s" "${out}")
        if [ -n "$subdir" ]; then
            __skaffold_debug "Listing directories in $subdir"
            __skaffold_handle_subdirs_in_dir_flag "$subdir"
        else
            __skaffold_debug "Listing directories in ."
            _filedir -d
        fi
    else
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${out}" -- "$cur")
    fi
}

__skaffold_handle_reply()
{
    __skaffold_debug "${FUNCNAME[0]}"
    local comp
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            while IFS='' read -r comp; do
                COMPREPLY+=("$comp")
            done < <(compgen -W "${allflags[*]}" -- "$cur")
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __skaffold_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION:-}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi

            if [[ -z "${flag_parsing_disabled}" ]]; then
                # If flag parsing is enabled, we have completed the flags and can return.
                # If flag parsing is disabled, we may not know all (or any) of the flags, so we fallthrough
                # to possibly call handle_go_custom_completion.
                return 0;
            fi
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __skaffold_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions+=("${must_have_one_noun[@]}")
    elif [[ -n "${has_completion_function}" ]]; then
        # if a go completion function is provided, defer to that function
        __skaffold_handle_go_custom_completion
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    while IFS='' read -r comp; do
        COMPREPLY+=("$comp")
    done < <(compgen -W "${completions[*]}" -- "$cur")

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${noun_aliases[*]}" -- "$cur")
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        if declare -F __skaffold_custom_func >/dev/null; then
            # try command name qualified custom func
            __skaffold_custom_func
        else
            # otherwise fall back to unqualified for compatibility
            declare -F __custom_func >/dev/null && __custom_func
        fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__skaffold_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__skaffold_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
}

__skaffold_handle_flag()
{
    __skaffold_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue=""
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __skaffold_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __skaffold_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __skaffold_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __skaffold_contains_word "${words[c]}" "${two_word_flags[@]}"; then
        __skaffold_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__skaffold_handle_noun()
{
    __skaffold_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __skaffold_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __skaffold_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__skaffold_handle_command()
{
    __skaffold_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_skaffold_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __skaffold_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__skaffold_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __skaffold_handle_reply
        return
    fi
    __skaffold_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __skaffold_handle_flag
    elif __skaffold_contains_word "${words[c]}" "${commands[@]}"; then
        __skaffold_handle_command
    elif [[ $c -eq 0 ]]; then
        __skaffold_handle_command
    elif __skaffold_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __skaffold_handle_command
        else
            __skaffold_handle_noun
        fi
    else
        __skaffold_handle_noun
    fi
    __skaffold_handle_word
}

_skaffold_apply()
{
    last_command="skaffold_apply"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--cloud-run-location=")
    two_word_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location=")
    flags+=("--cloud-run-project=")
    two_word_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project=")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--iterative-status-check")
    local_nonpersistent_flags+=("--iterative-status-check")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label")
    local_nonpersistent_flags+=("--label=")
    local_nonpersistent_flags+=("-l")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    local_nonpersistent_flags+=("-n")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--rpc-http-port=")
    two_word_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port=")
    flags+=("--rpc-port=")
    two_word_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port=")
    flags+=("--status-check")
    local_nonpersistent_flags+=("--status-check")
    flags+=("--status-check-selectors=")
    two_word_flags+=("--status-check-selectors")
    local_nonpersistent_flags+=("--status-check-selectors")
    local_nonpersistent_flags+=("--status-check-selectors=")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--tail")
    local_nonpersistent_flags+=("--tail")
    flags+=("--tolerate-failures-until-deadline")
    local_nonpersistent_flags+=("--tolerate-failures-until-deadline")
    flags+=("--wait-for-connection")
    local_nonpersistent_flags+=("--wait-for-connection")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_build()
{
    last_command="skaffold_build"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--build-concurrency=")
    two_word_flags+=("--build-concurrency")
    local_nonpersistent_flags+=("--build-concurrency")
    local_nonpersistent_flags+=("--build-concurrency=")
    flags+=("--build-image=")
    two_word_flags+=("--build-image")
    two_word_flags+=("-b")
    local_nonpersistent_flags+=("--build-image")
    local_nonpersistent_flags+=("--build-image=")
    local_nonpersistent_flags+=("-b")
    flags+=("--cache-artifacts")
    local_nonpersistent_flags+=("--cache-artifacts")
    flags+=("--cache-file=")
    two_word_flags+=("--cache-file")
    local_nonpersistent_flags+=("--cache-file")
    local_nonpersistent_flags+=("--cache-file=")
    flags+=("--check-cluster-node-platforms")
    local_nonpersistent_flags+=("--check-cluster-node-platforms")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--default-repo=")
    two_word_flags+=("--default-repo")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--default-repo")
    local_nonpersistent_flags+=("--default-repo=")
    local_nonpersistent_flags+=("-d")
    flags+=("--detect-minikube")
    local_nonpersistent_flags+=("--detect-minikube")
    flags+=("--disable-multi-platform-build")
    local_nonpersistent_flags+=("--disable-multi-platform-build")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--file-output=")
    two_word_flags+=("--file-output")
    local_nonpersistent_flags+=("--file-output")
    local_nonpersistent_flags+=("--file-output=")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--insecure-registry=")
    two_word_flags+=("--insecure-registry")
    local_nonpersistent_flags+=("--insecure-registry")
    local_nonpersistent_flags+=("--insecure-registry=")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--mute-logs=")
    two_word_flags+=("--mute-logs")
    local_nonpersistent_flags+=("--mute-logs")
    local_nonpersistent_flags+=("--mute-logs=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    local_nonpersistent_flags+=("-n")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output")
    local_nonpersistent_flags+=("--output=")
    local_nonpersistent_flags+=("-o")
    flags+=("--platform=")
    two_word_flags+=("--platform")
    local_nonpersistent_flags+=("--platform")
    local_nonpersistent_flags+=("--platform=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--profile-auto-activation")
    local_nonpersistent_flags+=("--profile-auto-activation")
    flags+=("--propagate-profiles")
    local_nonpersistent_flags+=("--propagate-profiles")
    flags+=("--push")
    local_nonpersistent_flags+=("--push")
    flags+=("--quiet")
    flags+=("-q")
    local_nonpersistent_flags+=("--quiet")
    local_nonpersistent_flags+=("-q")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--rpc-http-port=")
    two_word_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port=")
    flags+=("--rpc-port=")
    two_word_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port=")
    flags+=("--skip-tests")
    local_nonpersistent_flags+=("--skip-tests")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    local_nonpersistent_flags+=("-t")
    flags+=("--toot")
    local_nonpersistent_flags+=("--toot")
    flags+=("--wait-for-connection")
    local_nonpersistent_flags+=("--wait-for-connection")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_completion()
{
    last_command="skaffold_completion"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    local_nonpersistent_flags+=("-h")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    must_have_one_noun+=("bash")
    must_have_one_noun+=("fish")
    must_have_one_noun+=("zsh")
    noun_aliases=()
}

_skaffold_config_list()
{
    last_command="skaffold_config_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    local_nonpersistent_flags+=("-a")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context=")
    local_nonpersistent_flags+=("-k")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_config_set()
{
    last_command="skaffold_config_set"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--global")
    flags+=("-g")
    local_nonpersistent_flags+=("--global")
    local_nonpersistent_flags+=("-g")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context=")
    local_nonpersistent_flags+=("-k")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_config_unset()
{
    last_command="skaffold_config_unset"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--global")
    flags+=("-g")
    local_nonpersistent_flags+=("--global")
    local_nonpersistent_flags+=("-g")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context=")
    local_nonpersistent_flags+=("-k")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_config()
{
    last_command="skaffold_config"

    command_aliases=()

    commands=()
    commands+=("list")
    commands+=("set")
    commands+=("unset")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_debug()
{
    last_command="skaffold_debug"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--auto")
    local_nonpersistent_flags+=("--auto")
    flags+=("--auto-build")
    local_nonpersistent_flags+=("--auto-build")
    flags+=("--auto-create-config")
    local_nonpersistent_flags+=("--auto-create-config")
    flags+=("--auto-deploy")
    local_nonpersistent_flags+=("--auto-deploy")
    flags+=("--auto-sync")
    local_nonpersistent_flags+=("--auto-sync")
    flags+=("--build-concurrency=")
    two_word_flags+=("--build-concurrency")
    local_nonpersistent_flags+=("--build-concurrency")
    local_nonpersistent_flags+=("--build-concurrency=")
    flags+=("--cache-artifacts")
    local_nonpersistent_flags+=("--cache-artifacts")
    flags+=("--cache-file=")
    two_word_flags+=("--cache-file")
    local_nonpersistent_flags+=("--cache-file")
    local_nonpersistent_flags+=("--cache-file=")
    flags+=("--check-cluster-node-platforms")
    local_nonpersistent_flags+=("--check-cluster-node-platforms")
    flags+=("--cleanup")
    local_nonpersistent_flags+=("--cleanup")
    flags+=("--cloud-run-location=")
    two_word_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location=")
    flags+=("--cloud-run-project=")
    two_word_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project=")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--default-repo=")
    two_word_flags+=("--default-repo")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--default-repo")
    local_nonpersistent_flags+=("--default-repo=")
    local_nonpersistent_flags+=("-d")
    flags+=("--detect-minikube")
    local_nonpersistent_flags+=("--detect-minikube")
    flags+=("--disable-multi-platform-build")
    local_nonpersistent_flags+=("--disable-multi-platform-build")
    flags+=("--enable-platform-node-affinity")
    local_nonpersistent_flags+=("--enable-platform-node-affinity")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--hydration-dir=")
    two_word_flags+=("--hydration-dir")
    local_nonpersistent_flags+=("--hydration-dir")
    local_nonpersistent_flags+=("--hydration-dir=")
    flags+=("--insecure-registry=")
    two_word_flags+=("--insecure-registry")
    local_nonpersistent_flags+=("--insecure-registry")
    local_nonpersistent_flags+=("--insecure-registry=")
    flags+=("--iterative-status-check")
    local_nonpersistent_flags+=("--iterative-status-check")
    flags+=("--keep-running-on-failure")
    local_nonpersistent_flags+=("--keep-running-on-failure")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label")
    local_nonpersistent_flags+=("--label=")
    local_nonpersistent_flags+=("-l")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--mute-logs=")
    two_word_flags+=("--mute-logs")
    local_nonpersistent_flags+=("--mute-logs")
    local_nonpersistent_flags+=("--mute-logs=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    local_nonpersistent_flags+=("-n")
    flags+=("--no-prune")
    local_nonpersistent_flags+=("--no-prune")
    flags+=("--no-prune-children")
    local_nonpersistent_flags+=("--no-prune-children")
    flags+=("--platform=")
    two_word_flags+=("--platform")
    local_nonpersistent_flags+=("--platform")
    local_nonpersistent_flags+=("--platform=")
    flags+=("--port-forward")
    local_nonpersistent_flags+=("--port-forward")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--profile-auto-activation")
    local_nonpersistent_flags+=("--profile-auto-activation")
    flags+=("--propagate-profiles")
    local_nonpersistent_flags+=("--propagate-profiles")
    flags+=("--protocols=")
    two_word_flags+=("--protocols")
    local_nonpersistent_flags+=("--protocols")
    local_nonpersistent_flags+=("--protocols=")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--resource-selector-rules-file=")
    two_word_flags+=("--resource-selector-rules-file")
    local_nonpersistent_flags+=("--resource-selector-rules-file")
    local_nonpersistent_flags+=("--resource-selector-rules-file=")
    flags+=("--rpc-http-port=")
    two_word_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port=")
    flags+=("--rpc-port=")
    two_word_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port=")
    flags+=("--skip-tests")
    local_nonpersistent_flags+=("--skip-tests")
    flags+=("--status-check")
    local_nonpersistent_flags+=("--status-check")
    flags+=("--status-check-selectors=")
    two_word_flags+=("--status-check-selectors")
    local_nonpersistent_flags+=("--status-check-selectors")
    local_nonpersistent_flags+=("--status-check-selectors=")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    local_nonpersistent_flags+=("-t")
    flags+=("--tail")
    local_nonpersistent_flags+=("--tail")
    flags+=("--tolerate-failures-until-deadline")
    local_nonpersistent_flags+=("--tolerate-failures-until-deadline")
    flags+=("--toot")
    local_nonpersistent_flags+=("--toot")
    flags+=("--trigger=")
    two_word_flags+=("--trigger")
    local_nonpersistent_flags+=("--trigger")
    local_nonpersistent_flags+=("--trigger=")
    flags+=("--wait-for-connection")
    local_nonpersistent_flags+=("--wait-for-connection")
    flags+=("--wait-for-deletions")
    local_nonpersistent_flags+=("--wait-for-deletions")
    flags+=("--wait-for-deletions-delay=")
    two_word_flags+=("--wait-for-deletions-delay")
    local_nonpersistent_flags+=("--wait-for-deletions-delay")
    local_nonpersistent_flags+=("--wait-for-deletions-delay=")
    flags+=("--wait-for-deletions-max=")
    two_word_flags+=("--wait-for-deletions-max")
    local_nonpersistent_flags+=("--wait-for-deletions-max")
    local_nonpersistent_flags+=("--wait-for-deletions-max=")
    flags+=("--watch-image=")
    two_word_flags+=("--watch-image")
    two_word_flags+=("-w")
    local_nonpersistent_flags+=("--watch-image")
    local_nonpersistent_flags+=("--watch-image=")
    local_nonpersistent_flags+=("-w")
    flags+=("--watch-poll-interval=")
    two_word_flags+=("--watch-poll-interval")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--watch-poll-interval")
    local_nonpersistent_flags+=("--watch-poll-interval=")
    local_nonpersistent_flags+=("-i")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_delete()
{
    last_command="skaffold_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--cloud-run-location=")
    two_word_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location=")
    flags+=("--cloud-run-project=")
    two_word_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project=")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--default-repo=")
    two_word_flags+=("--default-repo")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--default-repo")
    local_nonpersistent_flags+=("--default-repo=")
    local_nonpersistent_flags+=("-d")
    flags+=("--detect-minikube")
    local_nonpersistent_flags+=("--detect-minikube")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    local_nonpersistent_flags+=("-n")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--profile-auto-activation")
    local_nonpersistent_flags+=("--profile-auto-activation")
    flags+=("--propagate-profiles")
    local_nonpersistent_flags+=("--propagate-profiles")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_deploy()
{
    last_command="skaffold_deploy"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--build-artifacts=")
    two_word_flags+=("--build-artifacts")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--build-artifacts")
    local_nonpersistent_flags+=("--build-artifacts=")
    local_nonpersistent_flags+=("-a")
    flags+=("--build-concurrency=")
    two_word_flags+=("--build-concurrency")
    local_nonpersistent_flags+=("--build-concurrency")
    local_nonpersistent_flags+=("--build-concurrency=")
    flags+=("--cloud-run-location=")
    two_word_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location=")
    flags+=("--cloud-run-project=")
    two_word_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project=")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--default-repo=")
    two_word_flags+=("--default-repo")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--default-repo")
    local_nonpersistent_flags+=("--default-repo=")
    local_nonpersistent_flags+=("-d")
    flags+=("--detect-minikube")
    local_nonpersistent_flags+=("--detect-minikube")
    flags+=("--enable-platform-node-affinity")
    local_nonpersistent_flags+=("--enable-platform-node-affinity")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--hydration-dir=")
    two_word_flags+=("--hydration-dir")
    local_nonpersistent_flags+=("--hydration-dir")
    local_nonpersistent_flags+=("--hydration-dir=")
    flags+=("--images=")
    two_word_flags+=("--images")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--images")
    local_nonpersistent_flags+=("--images=")
    local_nonpersistent_flags+=("-i")
    flags+=("--iterative-status-check")
    local_nonpersistent_flags+=("--iterative-status-check")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label")
    local_nonpersistent_flags+=("--label=")
    local_nonpersistent_flags+=("-l")
    flags+=("--load-images")
    local_nonpersistent_flags+=("--load-images")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--mute-logs=")
    two_word_flags+=("--mute-logs")
    local_nonpersistent_flags+=("--mute-logs")
    local_nonpersistent_flags+=("--mute-logs=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    local_nonpersistent_flags+=("-n")
    flags+=("--port-forward")
    local_nonpersistent_flags+=("--port-forward")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--profile-auto-activation")
    local_nonpersistent_flags+=("--profile-auto-activation")
    flags+=("--propagate-profiles")
    local_nonpersistent_flags+=("--propagate-profiles")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--resource-selector-rules-file=")
    two_word_flags+=("--resource-selector-rules-file")
    local_nonpersistent_flags+=("--resource-selector-rules-file")
    local_nonpersistent_flags+=("--resource-selector-rules-file=")
    flags+=("--rpc-http-port=")
    two_word_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port=")
    flags+=("--rpc-port=")
    two_word_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port=")
    flags+=("--status-check")
    local_nonpersistent_flags+=("--status-check")
    flags+=("--status-check-selectors=")
    two_word_flags+=("--status-check-selectors")
    local_nonpersistent_flags+=("--status-check-selectors")
    local_nonpersistent_flags+=("--status-check-selectors=")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    local_nonpersistent_flags+=("-t")
    flags+=("--tail")
    local_nonpersistent_flags+=("--tail")
    flags+=("--tolerate-failures-until-deadline")
    local_nonpersistent_flags+=("--tolerate-failures-until-deadline")
    flags+=("--toot")
    local_nonpersistent_flags+=("--toot")
    flags+=("--wait-for-connection")
    local_nonpersistent_flags+=("--wait-for-connection")
    flags+=("--wait-for-deletions")
    local_nonpersistent_flags+=("--wait-for-deletions")
    flags+=("--wait-for-deletions-delay=")
    two_word_flags+=("--wait-for-deletions-delay")
    local_nonpersistent_flags+=("--wait-for-deletions-delay")
    local_nonpersistent_flags+=("--wait-for-deletions-delay=")
    flags+=("--wait-for-deletions-max=")
    two_word_flags+=("--wait-for-deletions-max")
    local_nonpersistent_flags+=("--wait-for-deletions-max")
    local_nonpersistent_flags+=("--wait-for-deletions-max=")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_dev()
{
    last_command="skaffold_dev"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--auto")
    local_nonpersistent_flags+=("--auto")
    flags+=("--auto-build")
    local_nonpersistent_flags+=("--auto-build")
    flags+=("--auto-create-config")
    local_nonpersistent_flags+=("--auto-create-config")
    flags+=("--auto-deploy")
    local_nonpersistent_flags+=("--auto-deploy")
    flags+=("--auto-sync")
    local_nonpersistent_flags+=("--auto-sync")
    flags+=("--build-concurrency=")
    two_word_flags+=("--build-concurrency")
    local_nonpersistent_flags+=("--build-concurrency")
    local_nonpersistent_flags+=("--build-concurrency=")
    flags+=("--cache-artifacts")
    local_nonpersistent_flags+=("--cache-artifacts")
    flags+=("--cache-file=")
    two_word_flags+=("--cache-file")
    local_nonpersistent_flags+=("--cache-file")
    local_nonpersistent_flags+=("--cache-file=")
    flags+=("--check-cluster-node-platforms")
    local_nonpersistent_flags+=("--check-cluster-node-platforms")
    flags+=("--cleanup")
    local_nonpersistent_flags+=("--cleanup")
    flags+=("--cloud-run-location=")
    two_word_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location=")
    flags+=("--cloud-run-project=")
    two_word_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project=")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--default-repo=")
    two_word_flags+=("--default-repo")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--default-repo")
    local_nonpersistent_flags+=("--default-repo=")
    local_nonpersistent_flags+=("-d")
    flags+=("--detect-minikube")
    local_nonpersistent_flags+=("--detect-minikube")
    flags+=("--digest-source=")
    two_word_flags+=("--digest-source")
    local_nonpersistent_flags+=("--digest-source")
    local_nonpersistent_flags+=("--digest-source=")
    flags+=("--disable-multi-platform-build")
    local_nonpersistent_flags+=("--disable-multi-platform-build")
    flags+=("--enable-platform-node-affinity")
    local_nonpersistent_flags+=("--enable-platform-node-affinity")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--hydration-dir=")
    two_word_flags+=("--hydration-dir")
    local_nonpersistent_flags+=("--hydration-dir")
    local_nonpersistent_flags+=("--hydration-dir=")
    flags+=("--insecure-registry=")
    two_word_flags+=("--insecure-registry")
    local_nonpersistent_flags+=("--insecure-registry")
    local_nonpersistent_flags+=("--insecure-registry=")
    flags+=("--iterative-status-check")
    local_nonpersistent_flags+=("--iterative-status-check")
    flags+=("--keep-running-on-failure")
    local_nonpersistent_flags+=("--keep-running-on-failure")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label")
    local_nonpersistent_flags+=("--label=")
    local_nonpersistent_flags+=("-l")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--mute-logs=")
    two_word_flags+=("--mute-logs")
    local_nonpersistent_flags+=("--mute-logs")
    local_nonpersistent_flags+=("--mute-logs=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    local_nonpersistent_flags+=("-n")
    flags+=("--no-prune")
    local_nonpersistent_flags+=("--no-prune")
    flags+=("--no-prune-children")
    local_nonpersistent_flags+=("--no-prune-children")
    flags+=("--platform=")
    two_word_flags+=("--platform")
    local_nonpersistent_flags+=("--platform")
    local_nonpersistent_flags+=("--platform=")
    flags+=("--port-forward")
    local_nonpersistent_flags+=("--port-forward")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--profile-auto-activation")
    local_nonpersistent_flags+=("--profile-auto-activation")
    flags+=("--propagate-profiles")
    local_nonpersistent_flags+=("--propagate-profiles")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--resource-selector-rules-file=")
    two_word_flags+=("--resource-selector-rules-file")
    local_nonpersistent_flags+=("--resource-selector-rules-file")
    local_nonpersistent_flags+=("--resource-selector-rules-file=")
    flags+=("--rpc-http-port=")
    two_word_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port=")
    flags+=("--rpc-port=")
    two_word_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port=")
    flags+=("--skip-tests")
    local_nonpersistent_flags+=("--skip-tests")
    flags+=("--status-check")
    local_nonpersistent_flags+=("--status-check")
    flags+=("--status-check-selectors=")
    two_word_flags+=("--status-check-selectors")
    local_nonpersistent_flags+=("--status-check-selectors")
    local_nonpersistent_flags+=("--status-check-selectors=")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    local_nonpersistent_flags+=("-t")
    flags+=("--tail")
    local_nonpersistent_flags+=("--tail")
    flags+=("--tolerate-failures-until-deadline")
    local_nonpersistent_flags+=("--tolerate-failures-until-deadline")
    flags+=("--toot")
    local_nonpersistent_flags+=("--toot")
    flags+=("--trigger=")
    two_word_flags+=("--trigger")
    local_nonpersistent_flags+=("--trigger")
    local_nonpersistent_flags+=("--trigger=")
    flags+=("--wait-for-connection")
    local_nonpersistent_flags+=("--wait-for-connection")
    flags+=("--wait-for-deletions")
    local_nonpersistent_flags+=("--wait-for-deletions")
    flags+=("--wait-for-deletions-delay=")
    two_word_flags+=("--wait-for-deletions-delay")
    local_nonpersistent_flags+=("--wait-for-deletions-delay")
    local_nonpersistent_flags+=("--wait-for-deletions-delay=")
    flags+=("--wait-for-deletions-max=")
    two_word_flags+=("--wait-for-deletions-max")
    local_nonpersistent_flags+=("--wait-for-deletions-max")
    local_nonpersistent_flags+=("--wait-for-deletions-max=")
    flags+=("--watch-image=")
    two_word_flags+=("--watch-image")
    two_word_flags+=("-w")
    local_nonpersistent_flags+=("--watch-image")
    local_nonpersistent_flags+=("--watch-image=")
    local_nonpersistent_flags+=("-w")
    flags+=("--watch-poll-interval=")
    two_word_flags+=("--watch-poll-interval")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--watch-poll-interval")
    local_nonpersistent_flags+=("--watch-poll-interval=")
    local_nonpersistent_flags+=("-i")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_diagnose()
{
    last_command="skaffold_diagnose"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--enable-templating")
    local_nonpersistent_flags+=("--enable-templating")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output")
    local_nonpersistent_flags+=("--output=")
    local_nonpersistent_flags+=("-o")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--profile-auto-activation")
    local_nonpersistent_flags+=("--profile-auto-activation")
    flags+=("--propagate-profiles")
    local_nonpersistent_flags+=("--propagate-profiles")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--yaml-only")
    local_nonpersistent_flags+=("--yaml-only")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_exec()
{
    last_command="skaffold_exec"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--build-artifacts=")
    two_word_flags+=("--build-artifacts")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--build-artifacts")
    local_nonpersistent_flags+=("--build-artifacts=")
    local_nonpersistent_flags+=("-a")
    flags+=("--default-repo=")
    two_word_flags+=("--default-repo")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--default-repo")
    local_nonpersistent_flags+=("--default-repo=")
    local_nonpersistent_flags+=("-d")
    flags+=("--docker-network=")
    two_word_flags+=("--docker-network")
    local_nonpersistent_flags+=("--docker-network")
    local_nonpersistent_flags+=("--docker-network=")
    flags+=("--env-file=")
    two_word_flags+=("--env-file")
    local_nonpersistent_flags+=("--env-file")
    local_nonpersistent_flags+=("--env-file=")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    local_nonpersistent_flags+=("-n")
    flags+=("--port-forward")
    local_nonpersistent_flags+=("--port-forward")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--profile-auto-activation")
    local_nonpersistent_flags+=("--profile-auto-activation")
    flags+=("--propagate-profiles")
    local_nonpersistent_flags+=("--propagate-profiles")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--rpc-http-port=")
    two_word_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port=")
    flags+=("--rpc-port=")
    two_word_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port=")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_fix()
{
    last_command="skaffold_fix"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output")
    local_nonpersistent_flags+=("--output=")
    local_nonpersistent_flags+=("-o")
    flags+=("--overwrite")
    local_nonpersistent_flags+=("--overwrite")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_help()
{
    last_command="skaffold_help"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_skaffold_init()
{
    last_command="skaffold_init"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--analyze")
    local_nonpersistent_flags+=("--analyze")
    flags+=("--artifact=")
    two_word_flags+=("--artifact")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--artifact")
    local_nonpersistent_flags+=("--artifact=")
    local_nonpersistent_flags+=("-a")
    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--compose-file=")
    two_word_flags+=("--compose-file")
    local_nonpersistent_flags+=("--compose-file")
    local_nonpersistent_flags+=("--compose-file=")
    flags+=("--default-kustomization=")
    two_word_flags+=("--default-kustomization")
    local_nonpersistent_flags+=("--default-kustomization")
    local_nonpersistent_flags+=("--default-kustomization=")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--generate-manifests")
    local_nonpersistent_flags+=("--generate-manifests")
    flags+=("--kubernetes-manifest=")
    two_word_flags+=("--kubernetes-manifest")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--kubernetes-manifest")
    local_nonpersistent_flags+=("--kubernetes-manifest=")
    local_nonpersistent_flags+=("-k")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--skip-build")
    local_nonpersistent_flags+=("--skip-build")
    flags+=("--skip-unreachable-dirs")
    local_nonpersistent_flags+=("--skip-unreachable-dirs")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_options()
{
    last_command="skaffold_options"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_render()
{
    last_command="skaffold_render"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--build-artifacts=")
    two_word_flags+=("--build-artifacts")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--build-artifacts")
    local_nonpersistent_flags+=("--build-artifacts=")
    local_nonpersistent_flags+=("-a")
    flags+=("--cache-artifacts")
    local_nonpersistent_flags+=("--cache-artifacts")
    flags+=("--default-repo=")
    two_word_flags+=("--default-repo")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--default-repo")
    local_nonpersistent_flags+=("--default-repo=")
    local_nonpersistent_flags+=("-d")
    flags+=("--digest-source=")
    two_word_flags+=("--digest-source")
    local_nonpersistent_flags+=("--digest-source")
    local_nonpersistent_flags+=("--digest-source=")
    flags+=("--enable-platform-node-affinity")
    local_nonpersistent_flags+=("--enable-platform-node-affinity")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--hydration-dir=")
    two_word_flags+=("--hydration-dir")
    local_nonpersistent_flags+=("--hydration-dir")
    local_nonpersistent_flags+=("--hydration-dir=")
    flags+=("--images=")
    two_word_flags+=("--images")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--images")
    local_nonpersistent_flags+=("--images=")
    local_nonpersistent_flags+=("-i")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label")
    local_nonpersistent_flags+=("--label=")
    local_nonpersistent_flags+=("-l")
    flags+=("--loud")
    local_nonpersistent_flags+=("--loud")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    local_nonpersistent_flags+=("-n")
    flags+=("--offline")
    local_nonpersistent_flags+=("--offline")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output")
    local_nonpersistent_flags+=("--output=")
    local_nonpersistent_flags+=("-o")
    flags+=("--platform=")
    two_word_flags+=("--platform")
    local_nonpersistent_flags+=("--platform")
    local_nonpersistent_flags+=("--platform=")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--profile-auto-activation")
    local_nonpersistent_flags+=("--profile-auto-activation")
    flags+=("--propagate-profiles")
    local_nonpersistent_flags+=("--propagate-profiles")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--resource-selector-rules-file=")
    two_word_flags+=("--resource-selector-rules-file")
    local_nonpersistent_flags+=("--resource-selector-rules-file")
    local_nonpersistent_flags+=("--resource-selector-rules-file=")
    flags+=("--set=")
    two_word_flags+=("--set")
    local_nonpersistent_flags+=("--set")
    local_nonpersistent_flags+=("--set=")
    flags+=("--set-value-file=")
    two_word_flags+=("--set-value-file")
    local_nonpersistent_flags+=("--set-value-file")
    local_nonpersistent_flags+=("--set-value-file=")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    local_nonpersistent_flags+=("-t")
    flags+=("--wait-for-connection")
    local_nonpersistent_flags+=("--wait-for-connection")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_run()
{
    last_command="skaffold_run"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--auto")
    local_nonpersistent_flags+=("--auto")
    flags+=("--auto-create-config")
    local_nonpersistent_flags+=("--auto-create-config")
    flags+=("--build-concurrency=")
    two_word_flags+=("--build-concurrency")
    local_nonpersistent_flags+=("--build-concurrency")
    local_nonpersistent_flags+=("--build-concurrency=")
    flags+=("--build-image=")
    two_word_flags+=("--build-image")
    two_word_flags+=("-b")
    local_nonpersistent_flags+=("--build-image")
    local_nonpersistent_flags+=("--build-image=")
    local_nonpersistent_flags+=("-b")
    flags+=("--cache-artifacts")
    local_nonpersistent_flags+=("--cache-artifacts")
    flags+=("--cache-file=")
    two_word_flags+=("--cache-file")
    local_nonpersistent_flags+=("--cache-file")
    local_nonpersistent_flags+=("--cache-file=")
    flags+=("--check-cluster-node-platforms")
    local_nonpersistent_flags+=("--check-cluster-node-platforms")
    flags+=("--cleanup")
    local_nonpersistent_flags+=("--cleanup")
    flags+=("--cloud-run-location=")
    two_word_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location")
    local_nonpersistent_flags+=("--cloud-run-location=")
    flags+=("--cloud-run-project=")
    two_word_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project")
    local_nonpersistent_flags+=("--cloud-run-project=")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--default-repo=")
    two_word_flags+=("--default-repo")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--default-repo")
    local_nonpersistent_flags+=("--default-repo=")
    local_nonpersistent_flags+=("-d")
    flags+=("--detect-minikube")
    local_nonpersistent_flags+=("--detect-minikube")
    flags+=("--digest-source=")
    two_word_flags+=("--digest-source")
    local_nonpersistent_flags+=("--digest-source")
    local_nonpersistent_flags+=("--digest-source=")
    flags+=("--disable-multi-platform-build")
    local_nonpersistent_flags+=("--disable-multi-platform-build")
    flags+=("--enable-platform-node-affinity")
    local_nonpersistent_flags+=("--enable-platform-node-affinity")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--hydration-dir=")
    two_word_flags+=("--hydration-dir")
    local_nonpersistent_flags+=("--hydration-dir")
    local_nonpersistent_flags+=("--hydration-dir=")
    flags+=("--insecure-registry=")
    two_word_flags+=("--insecure-registry")
    local_nonpersistent_flags+=("--insecure-registry")
    local_nonpersistent_flags+=("--insecure-registry=")
    flags+=("--iterative-status-check")
    local_nonpersistent_flags+=("--iterative-status-check")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context")
    local_nonpersistent_flags+=("--kube-context=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label")
    local_nonpersistent_flags+=("--label=")
    local_nonpersistent_flags+=("-l")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--mute-logs=")
    two_word_flags+=("--mute-logs")
    local_nonpersistent_flags+=("--mute-logs")
    local_nonpersistent_flags+=("--mute-logs=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    local_nonpersistent_flags+=("-n")
    flags+=("--no-prune")
    local_nonpersistent_flags+=("--no-prune")
    flags+=("--no-prune-children")
    local_nonpersistent_flags+=("--no-prune-children")
    flags+=("--platform=")
    two_word_flags+=("--platform")
    local_nonpersistent_flags+=("--platform")
    local_nonpersistent_flags+=("--platform=")
    flags+=("--port-forward")
    local_nonpersistent_flags+=("--port-forward")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--profile-auto-activation")
    local_nonpersistent_flags+=("--profile-auto-activation")
    flags+=("--propagate-profiles")
    local_nonpersistent_flags+=("--propagate-profiles")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--resource-selector-rules-file=")
    two_word_flags+=("--resource-selector-rules-file")
    local_nonpersistent_flags+=("--resource-selector-rules-file")
    local_nonpersistent_flags+=("--resource-selector-rules-file=")
    flags+=("--rpc-http-port=")
    two_word_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port=")
    flags+=("--rpc-port=")
    two_word_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port=")
    flags+=("--skip-tests")
    local_nonpersistent_flags+=("--skip-tests")
    flags+=("--status-check")
    local_nonpersistent_flags+=("--status-check")
    flags+=("--status-check-selectors=")
    two_word_flags+=("--status-check-selectors")
    local_nonpersistent_flags+=("--status-check-selectors")
    local_nonpersistent_flags+=("--status-check-selectors=")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    local_nonpersistent_flags+=("-t")
    flags+=("--tail")
    local_nonpersistent_flags+=("--tail")
    flags+=("--tolerate-failures-until-deadline")
    local_nonpersistent_flags+=("--tolerate-failures-until-deadline")
    flags+=("--toot")
    local_nonpersistent_flags+=("--toot")
    flags+=("--wait-for-connection")
    local_nonpersistent_flags+=("--wait-for-connection")
    flags+=("--wait-for-deletions")
    local_nonpersistent_flags+=("--wait-for-deletions")
    flags+=("--wait-for-deletions-delay=")
    two_word_flags+=("--wait-for-deletions-delay")
    local_nonpersistent_flags+=("--wait-for-deletions-delay")
    local_nonpersistent_flags+=("--wait-for-deletions-delay=")
    flags+=("--wait-for-deletions-max=")
    two_word_flags+=("--wait-for-deletions-max")
    local_nonpersistent_flags+=("--wait-for-deletions-max")
    local_nonpersistent_flags+=("--wait-for-deletions-max=")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_schema_get()
{
    last_command="skaffold_schema_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_schema()
{
    last_command="skaffold_schema"

    command_aliases=()

    commands=()
    commands+=("get")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_test()
{
    last_command="skaffold_test"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--build-artifacts=")
    two_word_flags+=("--build-artifacts")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--build-artifacts")
    local_nonpersistent_flags+=("--build-artifacts=")
    local_nonpersistent_flags+=("-a")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    local_nonpersistent_flags+=("-c")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--images=")
    two_word_flags+=("--images")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--images")
    local_nonpersistent_flags+=("--images=")
    local_nonpersistent_flags+=("-i")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--profile-auto-activation")
    local_nonpersistent_flags+=("--profile-auto-activation")
    flags+=("--propagate-profiles")
    local_nonpersistent_flags+=("--propagate-profiles")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--rpc-http-port=")
    two_word_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port=")
    flags+=("--rpc-port=")
    two_word_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port=")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--wait-for-connection")
    local_nonpersistent_flags+=("--wait-for-connection")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_verify()
{
    last_command="skaffold_verify"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--assume-yes")
    local_nonpersistent_flags+=("--assume-yes")
    flags+=("--build-artifacts=")
    two_word_flags+=("--build-artifacts")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--build-artifacts")
    local_nonpersistent_flags+=("--build-artifacts=")
    local_nonpersistent_flags+=("-a")
    flags+=("--default-repo=")
    two_word_flags+=("--default-repo")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--default-repo")
    local_nonpersistent_flags+=("--default-repo=")
    local_nonpersistent_flags+=("-d")
    flags+=("--docker-network=")
    two_word_flags+=("--docker-network")
    local_nonpersistent_flags+=("--docker-network")
    local_nonpersistent_flags+=("--docker-network=")
    flags+=("--env-file=")
    two_word_flags+=("--env-file")
    local_nonpersistent_flags+=("--env-file")
    local_nonpersistent_flags+=("--env-file=")
    flags+=("--filename=")
    two_word_flags+=("--filename")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--filename")
    local_nonpersistent_flags+=("--filename=")
    local_nonpersistent_flags+=("-f")
    flags+=("--module=")
    two_word_flags+=("--module")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--module")
    local_nonpersistent_flags+=("--module=")
    local_nonpersistent_flags+=("-m")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    local_nonpersistent_flags+=("-n")
    flags+=("--port-forward")
    local_nonpersistent_flags+=("--port-forward")
    flags+=("--profile=")
    two_word_flags+=("--profile")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--profile")
    local_nonpersistent_flags+=("--profile=")
    local_nonpersistent_flags+=("-p")
    flags+=("--profile-auto-activation")
    local_nonpersistent_flags+=("--profile-auto-activation")
    flags+=("--propagate-profiles")
    local_nonpersistent_flags+=("--propagate-profiles")
    flags+=("--remote-cache-dir=")
    two_word_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir")
    local_nonpersistent_flags+=("--remote-cache-dir=")
    flags+=("--rpc-http-port=")
    two_word_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port")
    local_nonpersistent_flags+=("--rpc-http-port=")
    flags+=("--rpc-port=")
    two_word_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port")
    local_nonpersistent_flags+=("--rpc-port=")
    flags+=("--status-check")
    local_nonpersistent_flags+=("--status-check")
    flags+=("--sync-remote-cache=")
    two_word_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache")
    local_nonpersistent_flags+=("--sync-remote-cache=")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_version()
{
    last_command="skaffold_version"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output")
    local_nonpersistent_flags+=("--output=")
    local_nonpersistent_flags+=("-o")
    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_skaffold_root_command()
{
    last_command="skaffold"

    command_aliases=()

    commands=()
    commands+=("apply")
    commands+=("build")
    commands+=("completion")
    commands+=("config")
    commands+=("debug")
    commands+=("delete")
    commands+=("deploy")
    commands+=("dev")
    commands+=("diagnose")
    commands+=("exec")
    commands+=("fix")
    commands+=("help")
    commands+=("init")
    commands+=("options")
    commands+=("render")
    commands+=("run")
    commands+=("schema")
    commands+=("test")
    commands+=("verify")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--color=")
    two_word_flags+=("--color")
    flags+=("--interactive")
    flags+=("--timestamps")
    flags+=("--update-check")
    flags+=("--verbosity=")
    two_word_flags+=("--verbosity")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_skaffold()
{
    local cur prev words cword split
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __skaffold_init_completion -n "=" || return
    fi

    local c=0
    local flag_parsing_disabled=
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("skaffold")
    local command_aliases=()
    local must_have_one_flag=()
    local must_have_one_noun=()
    local has_completion_function=""
    local last_command=""
    local nouns=()
    local noun_aliases=()

    __skaffold_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_skaffold skaffold
else
    complete -o default -o nospace -F __start_skaffold skaffold
fi

# ex: ts=4 sw=4 et filetype=sh
