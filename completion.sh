#!/bin/bash
# Note: this script is sourced, so it's important not to pollute the shell's namespace

# returns the list of services in /etc/config.rc
_svc_list() {
	awk '/^[[:blank:]]*service/{ s[$2]="" } END{ for (x in s) print x;}' /etc/config.rc
}

# returns the list of services.instances in /etc/config.rc
_svc_inst_list() {
	awk '/^[[:blank:]]*service/{ s[$2($3?"."$3:"")]="" } END{ for (x in s) print x;}' /etc/config.rc
}

# returns the list of options supported by service[.instance] "$1"
_svc_inst_opt_list() {
	 [ -f /sbin/init.d/${1%.*} ] && /sbin/init.d/${1%.*} list_options | awk '{print $2}' | sort -u
}

# returns the list of instances for service $1 in /etc/config.rc
_inst_list() {
	awk -v svc="$1" '/^[[:blank:]]*service/{ if ($2==svc) i[$3]="" } END{ for (x in i) print x;}' /etc/config.rc
}

# main completion functions. Please keep them alphabetically sorted
_bootimg_completion() {
	local cw=${COMP_WORDS[COMP_CWORD]}

	case "${COMP_WORDS[1]}",${COMP_CWORD} in
	*,1)
		COMPREPLY=($(compgen -X functions -W "read fetch" "${cw}") \
		           $(compgen -o filenames -G "${cw}*"))
		;;
	read,2)
		COMPREPLY=($(compgen -X functions -W "- $(compgen -o filenames -G "${cw}*")" "${cw}"))
		;;
	fetch,2)
		COMPREPLY=($(compgen -X functions -W "tftp: http: update" "${cw}"))
		;;
	*,2)
		COMPREPLY=($(compgen -o filenames -G "${cw}*"))
		;;
	*)
		COMPREPLY=($(compgen -o filenames -G "${cw}*"))
		;;
	esac
	return 0
}

_config_completion() {
	local cw=${COMP_WORDS[COMP_CWORD]}

	case "${COMP_WORDS[1]}",${COMP_CWORD} in
	*,1)
		COMPREPLY=($(compgen -X functions -W "edit changes diff save write send read fetch push pull get set add del" ${cw}) \
		           $(compgen -o filenames -G "${cw}*"))
		;;
	get,2|set,2|add,2|del,2)
		COMPREPLY=($(compgen -W "$(_svc_inst_list)" ${cw}))
		;;
	get,3|set,3|add,3|del,3)
		COMPREPLY=($(compgen -W "$(_svc_inst_opt_list "${COMP_WORDS[2]}")" ${cw}))
		;;
	edit,2)
		COMPREPLY=($(compgen -W "$(_svc_list)" ${cw}))
		;;
	edit,3)
		COMPREPLY=($(compgen -W "$(_inst_list "${COMP_WORDS[2]}")" ${cw}))
		;;
	edit,*)
		return 1
		;;
	save,2)
		return 1
		;;
	write,2)
		COMPREPLY=($(compgen -X functions -W "- flash $(compgen -o filenames -G "${cw}*")" ${cw}))
		;;
	read,2)
		COMPREPLY=($(compgen -X functions -W "- $(compgen -o filenames -G "${cw}*")" ${cw}))
		;;
	send,2)
		COMPREPLY=($(compgen -X functions -W "tftp:" ${cw}))
		;;
	fetch,2)
		COMPREPLY=($(compgen -X functions -W "tftp: http:" ${cw}))
		;;
	changes,2)
		COMPREPLY=($(compgen -X functions -W "-q" ${cw}))
		;;
	diff,2)
		COMPREPLY=($(compgen -X functions -W "factory flash" ${cw}))
		;;
	*,2)
		COMPREPLY=($(compgen -o filenames -G "${cw}*"))
		;;
	*)
		COMPREPLY=($(compgen -o filenames -G "${cw}*"))
		;;
	esac
	return 0
}

_help_completion() {
	local cw=${COMP_WORDS[COMP_CWORD]}

	if [ ${COMP_CWORD} = 1 ]; then
		COMPREPLY=($(compgen -X functions -W "config system version" ${cw}))
	else
		return 1
	fi
	return 0
}

_service_completion() {
	local cw=${COMP_WORDS[COMP_CWORD]}

	case ${COMP_CWORD} in
	1)
		COMPREPLY=($(compgen -X functions -W "$(_svc_list)" ${cw}) \
		           $(compgen -o filenames -G "${cw}*"))
		;;
	2)
		COMPREPLY=($(/sbin/init.d/${COMP_WORDS[COMP_CWORD-1]} complete ${cw} 2>/dev/null) \
		           $(compgen -o filenames -W "start stop restart status check list_options" "${cw}"))
		;;
	3)
		COMPREPLY=($(compgen -W "$(_inst_list "${COMP_WORDS[1]}")" ${cw}))
		;;
	*)
		COMPREPLY=($(compgen -o filenames -G "${cw}*"))
		;;
	esac
	return 0
}

help() {
	case "$1" in
		"system")
			echo "The following main commands are useful to start :"
			echo "  - help        show the help"
			echo "  - exit        log out from this session"
			echo "  - config      edit/save/upload/download configuration files"
			echo "  - bootimg     download system images"
			echo "  - service     manage services"
			echo "  - logread     consult last logs"
			echo "  - root        get root privileges from the admin user"
			echo "  - version     report the system's version"
			;;
		"config")
			echo "Global system and network configuration is stored in /etc/config.rc. SSH"
			echo "public keys are stored in /etc/ssh/authorized_keys/<user>. The configuration"
			echo "is managed by the \"config\" utility. Use \"config changes\" to list unsaved"
			echo "changes, and \"config save\" to save them."
			;;
		"version")
			echo "\"version\" reports the current image version and the model name."
			;;
		*)
			echo "Please specify a topic :"
			echo "  - config for informations about services configuration"
			echo "  - system for the most common system management commands"
			echo "  - version for anything related to system image version"
			;;
	esac
	echo
}

version() {
	cat /usr/share/factory/version
}

?() {
	help "$@"
}

complete -F _bootimg_completion -o filenames bootimg
complete -F _config_completion  -o filenames config
complete -F _help_completion    -o filenames help     "?" "\?"
complete -F _service_completion -o filenames service
