if [ "$SHLVL" = "1" ] && ! /sbin/save-etc -v -q; then
  echo "Warning! unsaved configuration changes exist in the following files :"
  /sbin/save-etc -v -l | sed -e 's/^/ - /'
  echo "Note: you should use 'config save' after any changes to avoid this warning."
  while : ; do
    read -p "Do you want to save before exiting (Yes/No/Cancel) ? "
    rep="${REPLY:0:1}"
    if [ "$rep" = "c" -o "$rep" = "C" ]; then
      exec -l ${SHELL##*/}
    elif [ "$rep" = "y" -o "$rep" = "Y" ]; then
      echo -n "Saving changes... "
      /sbin/save-etc -f && echo "done."
      return 0
    elif [ "$rep" = "n" -o "$rep" = "N" ]; then
      echo "Exiting without saving changes."
      return 0
    else
      echo "=> Please answer Y to save, N to exit, or C to return to shell !"
      echo
    fi
  done
fi
